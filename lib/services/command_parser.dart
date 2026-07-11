import '../models/task.dart';

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

class CommandParser {
  static bool looksLikeReminderRequest(String input) {
    final t = input.toLowerCase();
    const keywords = [
      'remind', 'reminder', 'notify', 'alert', 'wake me',
      'ping me', 'set alarm', 'set an alarm',
      "don't forget", 'dont forget', "don't let me forget",
      'remember to', 'make a note', 'add task',
    ];
    return keywords.any(t.contains);
  }

  static ParsedCommand parse(String input) {
    final trimmed = input.trim();
    final text = trimmed.toLowerCase();
    if (text.isEmpty) return UnknownCommand(input);

    final listPatterns = [
      RegExp(r"^(show|list|view|see)( me)?( my)? (tasks|todos|to-?dos|reminders|pending|list)"),
      RegExp(r"^(what are|what'?re)( my)? (tasks|todos|to-?dos|reminders|pending)"),
      RegExp(r"^what'?s on my (list|plate|todo|tasks|schedule)"),
      RegExp(r"^what'?s (pending|due|left)\b"),
      RegExp(r"^my tasks\??$"),
      RegExp(r"^my list\??$"),
      RegExp(r"^pending tasks\??$"),
      RegExp(r"^show reminders\b"),
    ];
    for (final r in listPatterns) {
      if (r.hasMatch(text)) return ListTasksCommand();
    }

    final completeRe = RegExp(r"^(complete|done|finish|mark done|mark as done|tick off) (?:task )?#?(\d+)");
    final completeM = completeRe.firstMatch(text);
    if (completeM != null) return CompleteTaskCommand(int.parse(completeM.group(2)!));

    final deleteRe = RegExp(r"^(delete|remove|cancel|drop) (?:task )?#?(\d+)");
    final deleteM = deleteRe.firstMatch(text);
    if (deleteM != null) return DeleteTaskCommand(int.parse(deleteM.group(2)!));

    final addPrefixes = <RegExp>[
      RegExp(r"^remind me to "),
      RegExp(r"^remind me about "),
      RegExp(r"^remind me of "),
      RegExp(r"^remind me that "),
      RegExp(r"^remind me "),
      RegExp(r"^notify me to "),
      RegExp(r"^notify me about "),
      RegExp(r"^notify me of "),
      RegExp(r"^notify me that "),
      RegExp(r"^notify me "),
      RegExp(r"^alert me to "),
      RegExp(r"^alert me about "),
      RegExp(r"^alert me when "),
      RegExp(r"^alert me "),
      RegExp(r"^ping me about "),
      RegExp(r"^ping me to "),
      RegExp(r"^ping me "),
      RegExp(r"^wake me up to "),
      RegExp(r"^wake me up about "),
      RegExp(r"^wake me up "),
      RegExp(r"^wake me to "),
      RegExp(r"^wake me "),
      RegExp(r"^remember to "),
      RegExp(r"^remember that "),
      RegExp(r"^remember "),
      RegExp(r"^don'?t let me forget to "),
      RegExp(r"^don'?t let me forget about "),
      RegExp(r"^don'?t let me forget "),
      RegExp(r"^don'?t forget to "),
      RegExp(r"^don'?t forget "),
      RegExp(r"^set a reminder to "),
      RegExp(r"^set a reminder for "),
      RegExp(r"^set a reminder about "),
      RegExp(r"^set a reminder "),
      RegExp(r"^set reminder for "),
      RegExp(r"^set reminder to "),
      RegExp(r"^set reminder "),
      RegExp(r"^set an alarm for "),
      RegExp(r"^set an alarm to "),
      RegExp(r"^set an alarm "),
      RegExp(r"^set alarm for "),
      RegExp(r"^set alarm to "),
      RegExp(r"^set alarm "),
      RegExp(r"^schedule a reminder for "),
      RegExp(r"^schedule a reminder to "),
      RegExp(r"^schedule a reminder "),
      RegExp(r"^schedule a task "),
      RegExp(r"^add task "),
      RegExp(r"^add a task to "),
      RegExp(r"^add a task about "),
      RegExp(r"^add a task "),
      RegExp(r"^create task "),
      RegExp(r"^create a task to "),
      RegExp(r"^create a task "),
      RegExp(r"^new task "),
      RegExp(r"^add to my list "),
      RegExp(r"^add to list "),
      RegExp(r"^add to my tasks "),
      RegExp(r"^make a note to "),
      RegExp(r"^make a note that "),
      RegExp(r"^make a note about "),
      RegExp(r"^make a note "),
      RegExp(r"^note to self:?\s+"),
      RegExp(r"^note:\s+"),
      RegExp(r"^todo:?\s+"),
      RegExp(r"^to-do:?\s+"),
      RegExp(r"^tell me to "),
    ];

    for (final prefix in addPrefixes) {
      final m = prefix.firstMatch(text);
      if (m != null) {
        final raw = trimmed.substring(m.end).trim();
        if (raw.isEmpty) continue;
        final parsed = _extractTitleAndTime(raw);
        return AddTaskCommand(Task(title: parsed.title, dueAt: parsed.dueAt));
      }
    }

    return UnknownCommand(input);
  }

  static bool _hasPmContext(String lower) {
    const eveningWords = ['dinner', 'night', 'tonight', 'evening', 'supper', 'late', 'pm', 'p.m.', 'midnight'];
    return eveningWords.any(lower.contains);
  }

  static bool _hasAmContext(String lower) {
    const morningWords = ['breakfast', 'morning', 'sunrise', 'dawn', 'am', 'a.m.'];
    return morningWords.any(lower.contains);
  }

  static _TitleTime _extractTitleAndTime(String raw) {
    final now = DateTime.now();
    final lower = raw.toLowerCase();
    final hasPmContext = _hasPmContext(lower);
    final hasAmContext = _hasAmContext(lower);

    DateTime? when;
    String title = raw;

    final atTimeRe = RegExp(r"\bat (\d{1,2})(?::(\d{2}))?\s?(am|pm|a\.m\.|p\.m\.)?\b", caseSensitive: false);
    final atMatch = atTimeRe.firstMatch(lower);

    int? hour;
    int minute = 0;
    bool? isPm;
    if (atMatch != null) {
      hour = int.parse(atMatch.group(1)!);
      if (atMatch.group(2) != null) minute = int.parse(atMatch.group(2)!);
      final ampm = atMatch.group(3);
      if (ampm != null) isPm = ampm.startsWith('p');
      title = title.replaceFirst(atTimeRe, '').trim();
    }

    if (atMatch != null && isPm == null && hour != null) {
      if (hasPmContext) {
        isPm = true;
      } else if (hasAmContext) {
        isPm = false;
      } else if (hour >= 1 && hour <= 6) {
        isPm = true;
      } else if (hour >= 7 && hour <= 11) {
        isPm = now.hour >= 12;
      } else if (hour == 12) {
        isPm = false;
      } else if (hour >= 13 && hour <= 23) {
        isPm = true;
      }
    }

    final afterRe = RegExp(r"\bafter (\d+)\s?(minute|min|minutes|hour|hours|day|days)\b", caseSensitive: false);
    final inRe = RegExp(r"\bin (\d+)\s?(minute|min|minutes|hour|hours|day|days)\b", caseSensitive: false);

    Match? relativeMatch = inRe.firstMatch(lower) ?? afterRe.firstMatch(lower);
    if (relativeMatch != null) {
      final n = int.parse(relativeMatch.group(1)!);
      final unit = relativeMatch.group(2)!;
      Duration d;
      if (unit.startsWith('min')) {
        d = Duration(minutes: n);
      } else if (unit.startsWith('hour')) {
        d = Duration(hours: n);
      } else {
        d = Duration(days: n);
      }
      when = now.add(d);
      title = title.replaceFirst(inRe, '').replaceFirst(afterRe, '').trim();
    }

    if (when == null) {
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
        title = title.replaceAll(RegExp(r'\bnext week\b', caseSensitive: false), '').trim();
      } else if (atMatch != null && hour != null) {
        final candidate = _at(now, hour, minute, isPm ?? false);
        when = candidate.isAfter(now) ? candidate : candidate.add(const Duration(days: 1));
      }
    }

    when ??= DateTime(now.year, now.month, now.day + 1, 9, 0);

    title = title
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'^(to |that |about |of |for )'), '')
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

  static DateTime _atOrDefault(DateTime day, int? hour, int minute, bool? isPm) {
    if (hour == null) return DateTime(day.year, day.month, day.day, 9, 0);
    return _at(day, hour, minute, isPm ?? false);
  }
}

class _TitleTime {
  final String title;
  final DateTime dueAt;
  _TitleTime(this.title, this.dueAt);
}
