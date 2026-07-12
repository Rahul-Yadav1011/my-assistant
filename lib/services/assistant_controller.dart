import '../models/chat_message.dart';
import 'llm_service.dart';

class AssistantReply {
  final String text;
  final bool isFromLlm;
  final bool wasCancelled;
  AssistantReply(this.text, {this.isFromLlm = false, this.wasCancelled = false});
}

/// Orchestrates the chat. Mitra is now a pure AI assistant — every message
/// goes to the selected LLM engine (Groq online or on-device offline).
///
/// Task/reminder handling has been retired from the main flow. The task code
/// (command_parser, database_service, notification_service) still exists in
/// the project and can be brought back as an "advanced/professional" module
/// later without rework.
class AssistantController {
  AssistantController._();
  static final AssistantController instance = AssistantController._();

  final List<ChatMessage> _history = [];
  CancelToken? _currentCancel;

  List<ChatMessage> get history => List.unmodifiable(_history);
  bool get isBusy => _currentCancel != null;

  void cancelCurrent() => _currentCancel?.cancel();

  void clearHistory() => _history.clear();

  Future<AssistantReply> handle(String input) async {
    _history.add(ChatMessage(role: MessageRole.user, content: input));
    final reply = await _handleLlm(input);
    _history.add(ChatMessage(role: MessageRole.assistant, content: reply.text));
    return reply;
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
      return AssistantReply('Something went wrong: $e');
    } finally {
      _currentCancel = null;
    }
  }
}
