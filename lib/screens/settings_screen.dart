import 'package:flutter/material.dart';

import '../services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _geminiCtrl = TextEditingController();
  final _groqCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  bool _loaded = false;
  bool _saving = false;
  bool _hideGemini = true;
  bool _hideGroq = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = SettingsService.instance;
    _geminiCtrl.text = (await s.getGeminiKey()) ?? '';
    _groqCtrl.text = (await s.getGroqKey()) ?? '';
    _nameCtrl.text = (await s.getUserName()) ?? '';
    if (mounted) setState(() => _loaded = true);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final s = SettingsService.instance;
    await s.setGeminiKey(_geminiCtrl.text.trim());
    await s.setGroqKey(_groqCtrl.text.trim());
    await s.setUserName(_nameCtrl.text.trim());
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved.')),
    );
  }

  @override
  void dispose() {
    _geminiCtrl.dispose();
    _groqCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'API keys',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 4),
          const Text(
            'Get a free Gemini key at aistudio.google.com (no credit card). '
            'Get a free Groq key at console.groq.com (no credit card). '
            'Both are stored encrypted on this device only.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _geminiCtrl,
            obscureText: _hideGemini,
            decoration: InputDecoration(
              labelText: 'Gemini API key',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(_hideGemini ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _hideGemini = !_hideGemini),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _groqCtrl,
            obscureText: _hideGroq,
            decoration: InputDecoration(
              labelText: 'Groq API key (fallback)',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(_hideGroq ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _hideGroq = !_hideGroq),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'About you',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
              labelText: 'Your name (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _saving ? null : _save,
            child: Text(_saving ? 'Saving…' : 'Save'),
          ),
        ],
      ),
    );
  }
}
