import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../services/assistant_controller.dart';
import '../services/settings_service.dart';
import '../services/speech_service.dart';
import '../services/tts_service.dart';
import '../theme.dart';
import '../widgets/app_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _controller = AssistantController.instance;
  final _textCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  String _liveTranscript = '';
  bool _busy = false;
  EngineChoice _engine = EngineChoice.groq;

  @override
  void initState() {
    super.initState();
    SpeechService.instance.init();
    TtsService.instance.init();
    _loadEngine();
  }

  Future<void> _loadEngine() async {
    final e = await SettingsService.instance.getEngine();
    if (mounted) setState(() => _engine = e);
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _send(String input) async {
    final text = input.trim();
    if (text.isEmpty || _busy) return;
    setState(() {
      _busy = true;
      _textCtrl.clear();
      _liveTranscript = '';
    });
    _scrollToBottom();
    try {
      final reply = await _controller.handle(text);
      if (!mounted) return;
      setState(() {});
      _scrollToBottom();
      if (!reply.wasCancelled) await TtsService.instance.speak(reply.text);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _cancelGeneration() => _controller.cancelCurrent();

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
        if (isFinal && text.trim().isNotEmpty) _send(text);
      },
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final history = _controller.history;
    final listening = SpeechService.instance.isListening;

    return Scaffold(
      drawer: AppDrawer(currentIndex: 0, onAssistantTap: () {}),
      appBar: AppBar(
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: MitraTheme.headerGradient)),
        title: const Row(children: [Icon(Icons.graphic_eq, size: 22), SizedBox(width: 8), Text('Mitra')]),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(child: _EngineChip(engine: _engine)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: history.isEmpty
                ? const _EmptyState()
                : ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.all(12),
                    itemCount: history.length,
                    itemBuilder: (_, i) => _Bubble(msg: history[i]),
                  ),
          ),
          if (_liveTranscript.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text('"$_liveTranscript"', style: TextStyle(color: Colors.white.withOpacity(0.5))),
            ),
          if (_busy)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                  const SizedBox(width: 12),
                  const Text('Thinking…'),
                  const Spacer(),
                  TextButton.icon(onPressed: _cancelGeneration, icon: const Icon(Icons.stop_circle_outlined, size: 18), label: const Text('Stop')),
                ],
              ),
            ),
          ValueListenableBuilder<bool>(
            valueListenable: TtsService.instance.isSpeaking,
            builder: (_, speaking, __) {
              if (!speaking) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.volume_up, size: 18, color: MitraTheme.cyan),
                    const SizedBox(width: 8),
                    const Text('Speaking…'),
                    const Spacer(),
                    FilledButton.tonalIcon(
                      onPressed: () => TtsService.instance.stop(),
                      icon: const Icon(Icons.stop, size: 18),
                      label: const Text('Stop speaking'),
                    ),
                  ],
                ),
              );
            },
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: listening ? Colors.red.withOpacity(0.85) : MitraTheme.purple.withOpacity(0.18),
                    ),
                    child: IconButton(
                      iconSize: 28,
                      icon: Icon(listening ? Icons.mic : Icons.mic_none, color: listening ? Colors.white : MitraTheme.purple),
                      onPressed: _busy ? null : _toggleListen,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _textCtrl,
                      enabled: !_busy,
                      onSubmitted: _send,
                      decoration: const InputDecoration(hintText: 'Ask me anything…'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(icon: const Icon(Icons.send), onPressed: _busy ? null : () => _send(_textCtrl.text)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EngineChip extends StatelessWidget {
  final EngineChoice engine;
  const _EngineChip({required this.engine});

  @override
  Widget build(BuildContext context) {
    final online = engine == EngineChoice.groq;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(online ? Icons.cloud_outlined : Icons.smartphone, size: 14, color: Colors.white),
          const SizedBox(width: 5),
          Text(online ? 'Groq' : 'Offline', style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    final suggestions = [
      '"Explain quantum entanglement simply"',
      '"What do Stoics say about anxiety?"',
      '"Give me a 30-day plan to learn Rust"',
      '"Summarize the Bhagavad Gita\'s core idea"',
    ];
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [MitraTheme.purple, MitraTheme.cyan]),
              ),
              child: const Icon(Icons.graphic_eq, color: Colors.white, size: 36),
            ),
            const SizedBox(height: 20),
            const Text("Hi, I'm Mitra.", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text('Your personal AI. Ask me anything — try:', style: TextStyle(color: Colors.white.withOpacity(0.6))),
            const SizedBox(height: 12),
            ...suggestions.map((s) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Text(s, style: TextStyle(color: Colors.white.withOpacity(0.8))),
                )),
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
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
        decoration: BoxDecoration(
          gradient: isUser
              ? const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [MitraTheme.purple, Color(0xFF6D28D9)])
              : null,
          color: isUser ? null : MitraTheme.cardDark,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
        ),
        child: SelectableText(msg.content, style: const TextStyle(color: Colors.white, height: 1.4)),
      ),
    );
  }
}
