import 'dart:async';
import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';
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
You are Mitra — a thoughtful conversational assistant for one user.

WHAT YOU CAN DO:
- Discuss any topic, especially philosophy (Stoicism, Vedanta, Buddhism, Existentialism, Advaita), software engineering, planning, general questions.
- Give honest, grounded answers and reasoning.

WHAT YOU CANNOT DO — be honest about these limits, never pretend otherwise:
- You CANNOT set reminders, create tasks, schedule alarms, or send notifications. The app does that through a separate rule-based parser, not you.
- You CANNOT read news, check the calendar, access files, control devices, or take any action in the real world.
- You CANNOT remember earlier conversations beyond what is shown to you in this session.

IF THE USER ASKS YOU TO SET A REMINDER OR DO SOMETHING YOU CAN'T:
- Be direct: "I can't set reminders myself. Try saying 'remind me to drink water in 5 minutes' or 'notify me at 9 pm' — the app's task system will catch it."
- Do not say "Sure, I set it" or "I'll remind you" — that would be a lie.

STYLE:
- Brief by default: 2-3 sentences. Expand only when asked.
- For philosophy, cite the thinker or school (e.g. "Marcus Aurelius, Stoicism").
- For tech, give practical, ordered next steps.
- Plain prose only. NO markdown, NO bullet points, NO asterisks. Reply is read aloud by text-to-speech.
- Speak naturally, like a friend.
''';

  Future<String> chat({
    required String userMessage,
    required List<ChatMessage> history,
    CancelToken? cancel,
  }) async {
    final settings = SettingsService.instance;
    final geminiKey = await settings.getGeminiKey();
    final groqKey = await settings.getGroqKey();

    final hasGemini = geminiKey != null && geminiKey.isNotEmpty;
    final hasGroq = groqKey != null && groqKey.isNotEmpty;

    if (!hasGemini && !hasGroq) {
      throw LlmException(
        'No LLM keys set. Open Settings and add a Groq or Gemini key. Both are free.',
      );
    }

    cancel?.throwIfCancelled();

    if (hasGroq) {
      try {
        return await _callGroq(groqKey, userMessage, history, cancel);
      } catch (e) {
        if (e is LlmException && e.message.contains('Cancelled')) rethrow;
        if (!hasGemini) throw LlmException(_friendlyMessage('Groq', e));
      }
    }

    cancel?.throwIfCancelled();

    try {
      return await _callGemini(geminiKey!, userMessage, history, cancel);
    } catch (e) {
      if (e is LlmException && e.message.contains('Cancelled')) rethrow;
      throw LlmException(_friendlyMessage('Gemini', e));
    }
  }

  String _friendlyMessage(String provider, Object error) {
    final msg = error.toString().toLowerCase();
    if (msg.contains('quota') || msg.contains('rate') || msg.contains('429') || msg.contains('exceeded')) {
      return '$provider hit its free-tier rate limit. Try again in a minute, or add the other provider in Settings.';
    }
    if (msg.contains('api key') || msg.contains('apikey') || msg.contains('401') || msg.contains('403')) {
      return '$provider rejected the API key. Open Settings and paste a fresh key.';
    }
    if (msg.contains('timeout') || msg.contains('socket') || msg.contains('host')) {
      return 'Network issue reaching $provider. Check your connection.';
    }
    return '$provider error: $error';
  }

  Future<String> _callGemini(String apiKey, String userMessage, List<ChatMessage> history, CancelToken? cancel) async {
    final model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: apiKey,
      systemInstruction: Content.system(_systemPrompt),
    );

    final contents = <Content>[];
    for (final m in history) {
      if (m.role == MessageRole.system) continue;
      contents.add(m.role == MessageRole.user ? Content.text(m.content) : Content.model([TextPart(m.content)]));
    }
    contents.add(Content.text(userMessage));

    final resp = await model.generateContent(contents).timeout(const Duration(seconds: 30));
    cancel?.throwIfCancelled();
    final text = resp.text;
    if (text == null || text.trim().isEmpty) throw LlmException('Gemini returned empty response');
    return text.trim();
  }

  Future<String> _callGroq(String apiKey, String userMessage, List<ChatMessage> history, CancelToken? cancel) async {
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
      headers: {'Authorization': 'Bearer $apiKey', 'Content-Type': 'application/json'},
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
  }
}
