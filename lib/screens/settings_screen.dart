import 'package:flutter/material.dart';

import '../services/settings_service.dart';
import '../theme.dart';
import 'models_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _groqCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  bool _loaded = false;
  bool _saving = false;
  bool _hideGroq = true;
  ThemeChoice _theme = ThemeChoice.dark;
  EngineChoice _engine = EngineChoice.groq;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = SettingsService.instance;
    _groqCtrl.text = (await s.getGroqKey()) ?? '';
    _nameCtrl.text = (await s.getUserName()) ?? '';
    _theme = await s.getTheme();
    _engine = await s.getEngine();
    if (mounted) setState(() => _loaded = true);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final s = SettingsService.instance;
    await s.setGroqKey(_groqCtrl.text.trim());
    await s.setUserName(_nameCtrl.text.trim());
    await s.setTheme(_theme);
    await s.setEngine(_engine);
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved. Restart the app for theme changes to apply.')),
    );
  }

  @override
  void dispose() {
    _groqCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: MitraTheme.headerGradient)),
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section('AI Engine'),
          Card(
            child: Column(
              children: [
                RadioListTile<EngineChoice>(
                  title: const Text('Groq (online)'),
                  subtitle: const Text('Fast, smartest. Needs internet + API key.'),
                  value: EngineChoice.groq,
                  groupValue: _engine,
                  onChanged: (v) => setState(() => _engine = v ?? EngineChoice.groq),
                ),
                RadioListTile<EngineChoice>(
                  title: const Text('On-device (offline)'),
                  subtitle: const Text('Private, no internet. Needs a downloaded model.'),
                  value: EngineChoice.onDevice,
                  groupValue: _engine,
                  onChanged: (v) => setState(() => _engine = v ?? EngineChoice.groq),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.memory, color: MitraTheme.purple),
                  title: const Text('Manage AI Models'),
                  subtitle: const Text('Download offline models, pick active one'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ModelsScreen()),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _section('Groq API Key'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Free, no credit card. Only needed for the online engine.',
                      style: TextStyle(color: Colors.white.withOpacity(0.6))),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _groqCtrl,
                    obscureText: _hideGroq,
                    decoration: InputDecoration(
                      labelText: 'Groq API key',
                      helperText: 'Get free key at console.groq.com/keys',
                      suffixIcon: IconButton(
                        icon: Icon(_hideGroq ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _hideGroq = !_hideGroq),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _section('About You'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Your name (optional)')),
            ),
          ),
          const SizedBox(height: 24),
          _section('Appearance'),
          Card(
            child: Column(
              children: [
                RadioListTile<ThemeChoice>(
                  title: const Text('Dark'),
                  subtitle: const Text('Modern dark mode (recommended)'),
                  value: ThemeChoice.dark,
                  groupValue: _theme,
                  onChanged: (v) => setState(() => _theme = v ?? ThemeChoice.dark),
                ),
                RadioListTile<ThemeChoice>(
                  title: const Text('Light'),
                  value: ThemeChoice.light,
                  groupValue: _theme,
                  onChanged: (v) => setState(() => _theme = v ?? ThemeChoice.dark),
                ),
                RadioListTile<ThemeChoice>(
                  title: const Text('Follow System'),
                  value: ThemeChoice.system,
                  groupValue: _theme,
                  onChanged: (v) => setState(() => _theme = v ?? ThemeChoice.dark),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          FilledButton(onPressed: _saving ? null : _save, child: Text(_saving ? 'Saving…' : 'Save')),
          const SizedBox(height: 24),
          Text('Mitra v0.7 · Built with Flutter', textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.3))),
        ],
      ),
    );
  }

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Text(
          title.toUpperCase(),
          style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.5), fontWeight: FontWeight.w700, letterSpacing: 1.2),
        ),
      );
}
