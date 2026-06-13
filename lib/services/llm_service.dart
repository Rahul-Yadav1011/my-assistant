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

class LlmService {
  LlmService._();
  static final LlmService instance = LlmService._();

  static const _systemPrompt = '''
You are a warm, concise personal assistant for one user.
You help with: planning the day, remembering tasks, discussing philosophy
(Stoicism, Existentialism, Vedanta, Buddhism, Indian philosophy), and
software-engineering learning roadmaps.

Style:
- Be brief by default (2–4 sentences) unless asked for depth.
- When discussing philosophy, cite the thinker or school.
- For tech topics, give practical, ordered next steps.
- Speak naturally — your reply may be read aloud by TTS.
''';

  /// Sends [userMessage] together with prior [history] (oldest first).
  /// Returns the assistant text. Tries Gemini first, falls back to Groq.
  Future<String> chat({
    required String userMessage,
    required List<ChatMessage> history,
  }) async {
    final settings = SettingsService.instance;
    final geminiKey = await settings.getGeminiKey();
    final groqKey = await settings.getGroqKey();

    final hasGemini = geminiKey != null && geminiKey.isNotEmpty;
    final hasGroq = groqKey != null && groqKey.isNotEmpty;

    if (!hasGemini && !hasGroq) {
      throw LlmException(
        'No LLM keys set. Go to Settings and add a Gemini or Groq key.',
      );
    }

    // Try Gemini first
    if (hasGemini) {
      try {
        return await _callGemini(geminiKey, userMessage, history);
      } catch (e) {
        if (!hasGroq) {
          throw LlmException('Gemini failed: $e');
        }
        // fall through to Groq
      }
    }

    // Groq fallback (or primary if no Gemini key)
    return _callGroq(groqKey!, userMessage, history);
  }

  Future<String> _callGemini(
    String apiKey,
    String userMessage,
    List<ChatMessage> history,
  ) async {
    final model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: apiKey,
      systemInstruction: Content.system(_systemPrompt),
    );

    final contents = <Content>[];
    for (final m in history) {
      if (m.role == MessageRole.system) continue;
      contents.add(
        m.role == MessageRole.user
            ? Content.text(m.content)
            : Content.model([TextPart(m.content)]),
      );
    }
    contents.add(Content.text(userMessage));

    final resp = await model.generateContent(contents).timeout(
          const Duration(seconds: 30),
        );
    final text = resp.text;
    if (text == null || text.trim().isEmpty) {
      throw LlmException('Gemini returned empty response');
    }
    return text.trim();
  }

  Future<String> _callGroq(
    String apiKey,
    String userMessage,
    List<ChatMessage> history,
  ) async {
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

    final resp = await http
        .post(
          Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'model': 'llama-3.3-70b-versatile',
            'messages': messages,
            'temperature': 0.7,
            'max_tokens': 800,
          }),
        )
        .timeout(const Duration(seconds: 30));

    if (resp.statusCode != 200) {
      throw LlmException(
        'Groq HTTP ${resp.statusCode}: ${resp.body.substring(0, resp.body.length.clamp(0, 200))}',
      );
    }
    final data = jsonDecode(resp.body) as Map<String, Object?>;
    final choices = data['choices'] as List?;
    if (choices == null || choices.isEmpty) {
      throw LlmException('Groq returned no choices');
    }
    final msg = (choices.first as Map)['message'] as Map?;
    final content = msg?['content'] as String?;
    if (content == null || content.trim().isEmpty) {
      throw LlmException('Groq returned empty content');
    }
    return content.trim();
  }
}
