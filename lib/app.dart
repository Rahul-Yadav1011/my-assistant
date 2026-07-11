import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/settings_service.dart';
import 'theme.dart';

class MitraApp extends StatefulWidget {
  const MitraApp({super.key});
  @override
  State<MitraApp> createState() => _MitraAppState();
}

class _MitraAppState extends State<MitraApp> {
  ThemeChoice _theme = ThemeChoice.dark;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final t = await SettingsService.instance.getTheme();
    if (mounted) setState(() => _theme = t);
  }

  ThemeMode get _mode {
    switch (_theme) {
      case ThemeChoice.dark:
        return ThemeMode.dark;
      case ThemeChoice.light:
        return ThemeMode.light;
      case ThemeChoice.system:
        return ThemeMode.system;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mitra',
      themeMode: _mode,
      theme: MitraTheme.light(),
      darkTheme: MitraTheme.dark(),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
