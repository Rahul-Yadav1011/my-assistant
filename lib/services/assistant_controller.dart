import 'package:intl/intl.dart';
import '../models/chat_message.dart';
import '../models/task.dart';
import 'command_parser.dart';
import 'database_service.dart';
import 'llm_service.dart';
import 'notification_service.dart';

class AssistantReply {
  final String text;
  final bool isFromLlm;
  final bool wasCancelled;
  AssistantReply(this.text, {this.isFromLlm = false, this.wasCancelled = false});
}

class AssistantController {
  AssistantController._();
  static final AssistantController instance = AssistantController._();

  final List<ChatMessage> _history = [];
  CancelToken? _currentCancel;

  List<ChatMessage> get history => List.unmodifiable(_history);
  bool get isBusy => _currentCancel != null;

  void cancelCurrent() {
    _currentCancel?.cancel();
  }

  Future<AssistantReply> handle(String input) async {
    _history.add(ChatMessage(role: MessageRole.user, content: input));
    final parsed = CommandParser.parse(input);

    AssistantReply reply;
    switch (parsed) {
      case AddTaskCommand(task: final t):
        reply = await _handleAddTask(t);
      case ListTasksCommand():
        reply = await _handleListTasks();
      case CompleteTaskCommand(taskId: final id):
        reply = await _handleComplete(id);
      case DeleteTaskCommand(taskId: final id):
        reply = await _handleDelete(id);
      case UnknownCommand():
        reply = await _handleLlm(input);
    }

    _history.add(ChatMessage(role: MessageRole.assistant, content: reply.text));
    return reply;
  }

  Future<AssistantReply> _handleAddTask(Task t) async {
    final db = DatabaseService.instance;
    final id = await db.insertTask(t);
    await NotificationService.instance.scheduleReminder(
      id: id,
      title: 'Reminder',
      body: t.title,
      when: t.dueAt,
    );
    final whenLabel = _formatDue(t.dueAt);
    return AssistantReply('✓ Saved: "${t.title}". I will remind you $whenLabel.');
  }

  Future<AssistantReply> _handleListTasks() async {
    final tasks = await DatabaseService.instance.getPendingTasks();
    if (tasks.isEmpty) return AssistantReply('You have no pending tasks.');
    final buf = StringBuffer('You have ${tasks.length} pending task(s):\n');
    for (final t in tasks) {
      buf.writeln('#${t.id}: ${t.title} — ${_formatDue(t.dueAt)}');
    }
    return AssistantReply(buf.toString().trim());
  }

  Future<AssistantReply> _handleComplete(int id) async {
    final t = await DatabaseService.instance.getTask(id);
    if (t == null) return AssistantReply('No task with id #$id.');
    await DatabaseService.instance.markDone(id, true);
    await NotificationService.instance.cancel(id);
    return AssistantReply('Marked #$id "${t.title}" as done.');
  }

  Future<AssistantReply> _handleDelete(int id) async {
    final t = await DatabaseService.instance.getTask(id);
    if (t == null) return AssistantReply('No task with id #$id.');
    await DatabaseService.instance.deleteTask(id);
    await NotificationService.instance.cancel(id);
    return AssistantReply('Deleted #$id "${t.title}".');
  }

  Future<AssistantReply> _handleLlm(String input) async {
    final cancel = CancelToken();
    _currentCancel = cancel;
    try {
      final text = await LlmService.instance.chat(
        userMessage: input,
        history: _history.length > 1 ? _history.sublist(0, _history.length - 1) : <ChatMessage>[],
        cancel: cancel,
      );
      return AssistantReply(text, isFromLlm: true);
    } on LlmException catch (e) {
      if (e.message.contains('Cancelled')) return AssistantReply('(cancelled)', wasCancelled: true);
      return AssistantReply(e.message);
    } catch (e) {
      return AssistantReply('Could not reach the assistant brain: $e');
    } finally {
      _currentCancel = null;
    }
  }

  String _formatDue(DateTime when) {
    final now = DateTime.now();
    final isToday = when.year == now.year && when.month == now.month && when.day == now.day;
    final tomorrow = now.add(const Duration(days: 1));
    final isTomorrow = when.year == tomorrow.year && when.month == tomorrow.month && when.day == tomorrow.day;
    final time = DateFormat('h:mm a').format(when);
    if (isToday) return 'today at $time';
    if (isTomorrow) return 'tomorrow at $time';
    return 'on ${DateFormat('EEE, MMM d').format(when)} at $time';
  }
}
