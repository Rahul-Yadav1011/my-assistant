import 'package:flutter/material.dart';
import '../screens/models_screen.dart';
import '../screens/news_screen.dart';
import '../screens/philosophy_screen.dart';
import '../screens/settings_screen.dart';
import '../theme.dart';

class AppDrawer extends StatelessWidget {
  /// 0 Assistant, 2 AI Models, 3 News, 4 Philosophy
  final int currentIndex;
  final VoidCallback? onAssistantTap;
  const AppDrawer({super.key, required this.currentIndex, this.onAssistantTap});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          _Header(),
          const SizedBox(height: 12),
          _NavItem(
            icon: Icons.chat_bubble_outline,
            label: 'Assistant',
            active: currentIndex == 0,
            onTap: () {
              Navigator.of(context).pop();
              onAssistantTap?.call();
            },
          ),
          _NavItem(icon: Icons.memory, label: 'AI Models', active: currentIndex == 2, onTap: () => _push(context, const ModelsScreen())),
          _NavItem(icon: Icons.newspaper, label: 'News', active: currentIndex == 3, onTap: () => _push(context, const NewsScreen())),
          _NavItem(icon: Icons.auto_awesome, label: 'Philosophy', active: currentIndex == 4, onTap: () => _push(context, const PhilosophyScreen())),
          const Spacer(),
          const Divider(height: 1),
          _NavItem(icon: Icons.settings_outlined, label: 'Settings', active: false, onTap: () => _push(context, const SettingsScreen())),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).pop();
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: const BoxDecoration(gradient: MitraTheme.headerGradient),
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Colors.white.withOpacity(0.10),
              border: Border.all(color: Colors.white.withOpacity(0.18)),
            ),
            child: const Icon(Icons.graphic_eq, color: Colors.white, size: 30),
          ),
          const Spacer(),
          const Text('Mitra', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 24, letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Text('Your personal AI', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _NavItem({required this.icon, required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: active ? MitraTheme.purple : null),
      title: Text(label, style: TextStyle(fontWeight: active ? FontWeight.w600 : FontWeight.normal, color: active ? MitraTheme.purple : null)),
      tileColor: active ? MitraTheme.purple.withOpacity(0.12) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      onTap: onTap,
    );
  }
}
