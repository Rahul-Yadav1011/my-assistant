import 'package:flutter/material.dart';

import '../models/chat_message.dart';
import '../services/assistant_controller.dart';
import '../services/speech_service.dart';
import '../services/tts_service.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _controller = AssistantController.instance;
  final _textCtrl = TextEditingController();
  String _liveTranscript = '';
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    SpeechService.instance.init();
    TtsService.instance.init();
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  Future<void> _send(String input) async {
    final text = input.trim();
    if (text.isEmpty || _busy) return;
    setState(() => _busy = true);
    _textCtrl.clear();
    _liveTranscript = '';
    try {
      final reply = await _controller.handle(text);
      if (mounted) setState(() {});
      await TtsService.instance.speak(reply.text);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _toggleListen() async {
    final stt = SpeechService.instance;
    if (stt.isListening) {
      await stt.stop();
      setState(() {});
      return;
    }
    await TtsService.instance.stop();
    await stt.startListening(
      onResult: (text, isFinal) {
        setState(() => _liveTranscript = text);
        if (isFinal && text.trim().isNotEmpty) {
          _send(text);
        }
      },
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final history = _controller.history;
    final listening = SpeechService.instance.isListening;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Assistant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: history.isEmpty
                ? const _EmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: history.length,
                    itemBuilder: (_, i) => _Bubble(msg: history[i]),
                  ),
          ),
          if (_liveTranscript.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                '"$_liveTranscript"',
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          if (_busy) const LinearProgressIndicator(minHeight: 2),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
              child: Row(
                children: [
                  FloatingActionButton(
                    heroTag: 'mic',
                    onPressed: _busy ? null : _toggleListen,
                    backgroundColor: listening ? Colors.red : null,
                    child: Icon(listening ? Icons.mic : Icons.mic_none),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _textCtrl,
                      enabled: !_busy,
                      onSubmitted: _send,
                      decoration: const InputDecoration(
                        hintText:
                            'Type or tap the mic. Try: "remind me to drink water tomorrow at 8 am"',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed:
                        _busy ? null : () => _send(_textCtrl.text),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.assistant, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Try saying:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• "Remind me to call mom tomorrow at 6 pm"'),
            Text('• "Add task buy groceries in 2 hours"'),
            Text('• "Show my tasks"'),
            Text('• "What did the Stoics teach about anxiety?"'),
            Text('• "Build me a 30-day Rust learning roadmap"'),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final ChatMessage msg;
  const _Bubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    final isUser = msg.role == MessageRole.user;
    final color =
        isUser ? Theme.of(context).colorScheme.primaryContainer : Colors.grey.shade200;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(msg.content),
      ),
    );
  }
}
