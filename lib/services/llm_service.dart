import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/chat_message.dart';
import 'settings_service.dart';

class LlmException implements Exception {
  final String message;
  LlmException(this.message);
  @override
  String toString() => message;
}

class CancelToken {
  bool _cancelled = false;
  bool get isCancelled => _cancelled;
  void cancel() => _cancelled = true;
  void throwIfCancelled() {
    if (_cancelled) throw LlmException('Cancelled by user.');
  }
}

class LlmService {
  LlmService._();
  static final LlmService instance = LlmService._();

  static const _systemPrompt = '''
You are Mitra — a thoughtful, direct personal AI assistant for one user.

WHAT YOU DO:
- Answer any question the user asks, clearly and helpfully.
- You are especially good at philosophy (Stoicism, Vedanta, Buddhism, Existentialism, Advaita and more), software engineering, planning, and explaining ideas simply.
- Give honest, grounded answers. If you are unsure, say so.

STYLE:
- Be clear and reasonably brief. Expand when the user asks for depth.
- For philosophy, name the thinker or school (e.g. "Marcus Aurelius, Stoicism").
- For tech, give practical, ordered steps.
- Plain prose. NO markdown, NO bullet points, NO asterisks. Your reply may be read aloud by text-to-speech.
- Speak naturally, like a knowledgeable friend.

Be honest about being an AI. Do not claim to take real-world actions you cannot perform.
''';

  /// Routes to whichever engine the user selected.
  Future<String> chat({
    required String userMessage,
    required List<ChatMessage> history,
    CancelToken? cancel,
  }) async {
    final engine = await SettingsService.instance.getEngine();
    switch (engine) {
      case EngineChoice.groq:
        return _chatGroq(userMessage, history, cancel);
      case EngineChoice.onDevice:
        return _chatOnDevice(userMessage, history, cancel);
    }
  }

  // ---------------- Online: Groq ----------------
  Future<String> _chatGroq(
    String userMessage,
    List<ChatMessage> history,
    CancelToken? cancel,
  ) async {
    final groqKey = await SettingsService.instance.getGroqKey();
    if (groqKey == null || groqKey.isEmpty) {
      throw LlmException(
        'No Groq key set. Open Settings and add your Groq key (free at console.groq.com/keys), '
        'or switch to an offline model in AI Models.',
      );
    }

    cancel?.throwIfCancelled();

    try {
      final messages = <Map<String, String>>[
        {'role': 'system', 'content': _systemPrompt},
        for (final m in history)
          {
            'role': switch (m.role) {
              MessageRole.user => 'user',
              MessageRole.assistant => 'assistant',
              MessageRole.system => 'system',
            },
            'content': m.content,
          },
        {'role': 'user', 'content': userMessage},
      ];

      final resp = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {'Authorization': 'Bearer $groqKey', 'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': 'llama-3.3-70b-versatile',
          'messages': messages,
          'temperature': 0.7,
          'max_tokens': 800,
        }),
      ).timeout(const Duration(seconds: 30));

      cancel?.throwIfCancelled();

      if (resp.statusCode != 200) {
        throw LlmException('Groq HTTP ${resp.statusCode}: ${resp.body.substring(0, resp.body.length.clamp(0, 200))}');
      }
      final data = jsonDecode(resp.body) as Map<String, Object?>;
      final choices = data['choices'] as List?;
      if (choices == null || choices.isEmpty) throw LlmException('Groq returned no choices');
      final msg = (choices.first as Map)['message'] as Map?;
      final content = msg?['content'] as String?;
      if (content == null || content.trim().isEmpty) throw LlmException('Groq returned empty content');
      return content.trim();
    } catch (e) {
      if (e is LlmException) rethrow;
      throw LlmException(_friendlyMessage('Groq', e));
    }
  }

  // ---------------- Offline: on-device model ----------------
  // Wired to the real on-device engine (flutter_gemma) next turn.
  // For now, if the user selects offline without a ready model, we guide them.
  Future<String> _chatOnDevice(
    String userMessage,
    List<ChatMessage> history,
    CancelToken? cancel,
  ) async {
    final modelId = await SettingsService.instance.getActiveModelId();
    if (modelId == null) {
      throw LlmException(
        'No offline model is active yet. Open AI Models, download one, and set it as active — '
        'or switch back to Groq (online) in Settings.',
      );
    }
    // Placeholder until real inference is wired next turn.
    throw LlmException(
      'Offline model "$modelId" is downloaded, but on-device inference is being finished in the next update. '
      'For now, switch to Groq (online) in Settings to chat.',
    );
  }

  String _friendlyMessage(String provider, Object error) {
    final msg = error.toString().toLowerCase();
    if (msg.contains('quota') || msg.contains('rate') || msg.contains('429') || msg.contains('exceeded')) {
      return '$provider hit its free-tier rate limit. Try again in a minute, or switch to an offline model.';
    }
    if (msg.contains('api key') || msg.contains('apikey') || msg.contains('401') || msg.contains('403')) {
      return '$provider rejected the API key. Open Settings and paste a fresh key.';
    }
    if (msg.contains('timeout') || msg.contains('socket') || msg.contains('host') || msg.contains('network')) {
      return 'Network issue reaching $provider. Check your connection, or use an offline model.';
    }
    return '$provider error: $error';
  }
}
