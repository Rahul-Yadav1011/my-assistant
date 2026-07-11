import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../services/settings_service.dart';
import '../theme.dart';

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
  ThemeChoice _theme = ThemeChoice.dark;

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
    _theme = await s.getTheme();
    if (mounted) setState(() => _loaded = true);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final s = SettingsService.instance;
    await s.setGeminiKey(_geminiCtrl.text.trim());
    await s.setGroqKey(_groqCtrl.text.trim());
    await s.setUserName(_nameCtrl.text.trim());
    await s.setTheme(_theme);
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved. Restart the app for theme changes to apply.')),
    );
  }

  Future<void> _testNotification() async {
    try {
      await NotificationService.instance.scheduleReminder(
        id: 99999,
        title: 'Mitra test 🔔',
        body: 'Notifications are working. You can set reminders.',
        when: DateTime.now().add(const Duration(seconds: 10)),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test scheduled. You should see a notification in 10 seconds. Lock your phone now to test background delivery.'),
          duration: Duration(seconds: 5),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to schedule: $e')));
    }
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
    if (!_loaded) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: MitraTheme.headerGradient)),
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section('Assistant Brain (LLM)'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Free, no credit card. Groq has more generous limits — set it as primary.', style: TextStyle(color: Colors.white.withOpacity(0.6))),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _groqCtrl,
                    obscureText: _hideGroq,
                    decoration: InputDecoration(
                      labelText: 'Groq API key (primary)',
                      helperText: 'Get free key at console.groq.com/keys',
                      suffixIcon: IconButton(
                        icon: Icon(_hideGroq ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _hideGroq = !_hideGroq),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _geminiCtrl,
                    obscureText: _hideGemini,
                    decoration: InputDecoration(
                      labelText: 'Gemini API key (fallback)',
                      helperText: 'Get free key at aistudio.google.com/apikey',
                      suffixIcon: IconButton(
                        icon: Icon(_hideGemini ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _hideGemini = !_hideGemini),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _section('Notifications'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: MitraTheme.cyan.withOpacity(0.18)),
                    child: const Icon(Icons.notifications_active, color: MitraTheme.cyan),
                  ),
                  title: const Text('Test notification'),
                  subtitle: const Text('Fires in 10 seconds — lock your phone to verify background delivery'),
                  trailing: const Icon(Icons.play_arrow),
                  onTap: _testNotification,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.orange.withOpacity(0.18)),
                    child: const Icon(Icons.help_outline, color: Colors.orange),
                  ),
                  title: const Text('Notifications not arriving?'),
                  subtitle: const Text('Tap for troubleshooting steps'),
                  onTap: () => _showNotificationHelp(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _section('How to set reminders'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('These phrasings are recognized by the task system:', style: TextStyle(color: Colors.white.withOpacity(0.7))),
                  const SizedBox(height: 12),
                  ..._examples.map((e) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text('• "$e"', style: const TextStyle(height: 1.4)),
                      )),
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
          Text('Mitra v0.5 · Built with Flutter', textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.3))),
        ],
      ),
    );
  }

  static const _examples = [
    'remind me to drink water in 5 minutes',
    'notify me after 30 min to take medicine',
    'remind me about the meeting at 3 pm',
    'wake me up at 6 am tomorrow',
    'set a reminder for dinner at 9',
    'add task pay electricity bill',
    "don't let me forget to call mom tonight",
    'show my tasks',
    'complete #3',
    'delete #2',
  ];

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Text(
          title.toUpperCase(),
          style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.5), fontWeight: FontWeight.w700, letterSpacing: 1.2),
        ),
      );

  void _showNotificationHelp(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Notifications not firing?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            const Text(
              '1. Android Settings → Apps → Mitra → Notifications → must be ON.\n\n'
              '2. Android Settings → Apps → Special access → Alarms & reminders → Mitra → must be ALLOWED.\n\n'
              '3. Android Settings → Apps → Mitra → Battery → set to "Unrestricted" or remove from battery optimization. Xiaomi/OPPO/Vivo phones are aggressive about killing scheduled work.\n\n'
              '4. Xiaomi/MIUI: also enable "Autostart" for Mitra in the Security app.\n\n'
              '5. Tap "Test notification" — if it fires, real reminders should too.',
              style: TextStyle(height: 1.6),
            ),
            const SizedBox(height: 20),
            FilledButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Got it')),
          ],
        ),
      ),
    );
  }
}
