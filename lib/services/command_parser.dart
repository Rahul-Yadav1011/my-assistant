import '../models/task.dart';

/// Result of attempting to parse user input.
sealed class ParsedCommand {}

class AddTaskCommand extends ParsedCommand {
  final Task task;
  AddTaskCommand(this.task);
}

class ListTasksCommand extends ParsedCommand {}

class DeleteTaskCommand extends ParsedCommand {
  final int taskId;
  DeleteTaskCommand(this.taskId);
}

class CompleteTaskCommand extends ParsedCommand {
  final int taskId;
  CompleteTaskCommand(this.taskId);
}

class UnknownCommand extends ParsedCommand {
  final String rawText;
  UnknownCommand(this.rawText);
}

/// Lightweight pattern-based parser. Anything it can't confidently classify
/// becomes UnknownCommand, which the caller forwards to the LLM.
class CommandParser {
  static ParsedCommand parse(String input) {
    final trimmed = input.trim();
    final text = trimmed.toLowerCase();
    if (text.isEmpty) return UnknownCommand(input);

    // List tasks
    final listPatterns = [
      RegExp(r"^(show|list|what are)( my)? (tasks|todos|to-?dos|reminders)"),
      RegExp(r"^what'?s on my (list|plate|todo)"),
      RegExp(r"^my tasks\??$"),
    ];
    for (final r in listPatterns) {
      if (r.hasMatch(text)) return ListTasksCommand();
    }

    // Complete / delete by id
    final completeRe = RegExp(r"^(complete|done|finish|mark done) (?:task )?#?(\d+)");
    final completeM = completeRe.firstMatch(text);
    if (completeM != null) {
      return CompleteTaskCommand(int.parse(completeM.group(2)!));
    }

    final deleteRe = RegExp(r"^(delete|remove|cancel) (?:task )?#?(\d+)");
    final deleteM = deleteRe.firstMatch(text);
    if (deleteM != null) {
      return DeleteTaskCommand(int.parse(deleteM.group(2)!));
    }

    // Add task — multiple natural phrasings
    final addPrefixes = [
      RegExp(r"^remind me to "),
      RegExp(r"^remember to "),
      RegExp(r"^remember "),
      RegExp(r"^add task "),
      RegExp(r"^add a task to "),
      RegExp(r"^add to my list "),
      RegExp(r"^todo:? "),
      RegExp(r"^note to self:? "),
    ];

    for (final prefix in addPrefixes) {
      final m = prefix.firstMatch(text);
      if (m != null) {
        final raw = trimmed.substring(m.end).trim();
        if (raw.isEmpty) continue;
        final parsed = _extractTitleAndTime(raw);
        return AddTaskCommand(
          Task(title: parsed.title, dueAt: parsed.dueAt),
        );
      }
    }

    return UnknownCommand(input);
  }

  static _TitleTime _extractTitleAndTime(String raw) {
    final now = DateTime.now();
    final lower = raw.toLowerCase();

    DateTime? when;
    String title = raw;

    // Time-of-day extraction: "at 9", "at 9:30", "at 9 am", "at 9:30 pm"
    final atTimeRe =
        RegExp(r"\bat (\d{1,2})(?::(\d{2}))?\s?(am|pm)?\b", caseSensitive: false);
    final atMatch = atTimeRe.firstMatch(lower);

    int? hour;
    int minute = 0;
    bool? isPm;
    if (atMatch != null) {
      hour = int.parse(atMatch.group(1)!);
      if (atMatch.group(2) != null) minute = int.parse(atMatch.group(2)!);
      final ampm = atMatch.group(3);
      if (ampm != null) isPm = ampm == 'pm';
      title = title.replaceFirst(atTimeRe, '').trim();
    }

    // Day keywords
    if (lower.contains('tomorrow')) {
      final base = now.add(const Duration(days: 1));
      when = _atOrDefault(base, hour, minute, isPm);
      title = title.replaceAll(RegExp(r'\btomorrow\b', caseSensitive: false), '').trim();
    } else if (lower.contains('today')) {
      when = _atOrDefault(now, hour, minute, isPm);
      title = title.replaceAll(RegExp(r'\btoday\b', caseSensitive: false), '').trim();
    } else if (lower.contains('tonight')) {
      when = _at(now, hour ?? 20, minute, isPm ?? true);
      title = title.replaceAll(RegExp(r'\btonight\b', caseSensitive: false), '').trim();
    } else if (lower.contains('next week')) {
      final base = now.add(const Duration(days: 7));
      when = _atOrDefault(base, hour, minute, isPm);
      title =
          title.replaceAll(RegExp(r'\bnext week\b', caseSensitive: false), '').trim();
    } else if (atMatch != null) {
      // "at 9 pm" with no day → today if in future, else tomorrow
      final candidate = _at(now, hour!, minute, isPm ?? (hour < 8));
      when = candidate.isAfter(now)
          ? candidate
          : candidate.add(const Duration(days: 1));
    }

    // "in N minutes/hours/days"
    final inRe = RegExp(r"\bin (\d+)\s?(minute|min|minutes|hour|hours|day|days)\b",
        caseSensitive: false);
    final inMatch = inRe.firstMatch(lower);
    if (inMatch != null) {
      final n = int.parse(inMatch.group(1)!);
      final unit = inMatch.group(2)!;
      Duration d;
      if (unit.startsWith('min')) {
        d = Duration(minutes: n);
      } else if (unit.startsWith('hour')) {
        d = Duration(hours: n);
      } else {
        d = Duration(days: n);
      }
      when = now.add(d);
      title = title.replaceFirst(inRe, '').trim();
    }

    // Default: tomorrow 9 AM
    when ??= DateTime(now.year, now.month, now.day + 1, 9, 0);

    // Strip trailing/leading punctuation and connector words
    title = title
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'^(to |that |about )'), '')
        .replaceAll(RegExp(r'[.,!?\s]+$'), '')
        .trim();
    if (title.isEmpty) title = raw;

    return _TitleTime(title, when);
  }

  static DateTime _at(DateTime day, int hour, int minute, bool isPm) {
    var h = hour;
    if (isPm && h < 12) h += 12;
    if (!isPm && h == 12) h = 0;
    return DateTime(day.year, day.month, day.day, h, minute);
  }

  static DateTime _atOrDefault(
      DateTime day, int? hour, int minute, bool? isPm) {
    if (hour == null) {
      return DateTime(day.year, day.month, day.day, 9, 0);
    }
    return _at(day, hour, minute, isPm ?? (hour < 8));
  }
}

class _TitleTime {
  final String title;
  final DateTime dueAt;
  _TitleTime(this.title, this.dueAt);
}
