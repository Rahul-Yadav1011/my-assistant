import 'package:flutter/material.dart';
import '../screens/models_screen.dart';
import '../screens/news_screen.dart';
import '../screens/philosophy_screen.dart';
import '../screens/settings_screen.dart';
import '../theme.dart';

class AppDrawer extends StatelessWidget {
  /// 0 Assistant (Home), 2 AI Models, 3 News, 4 Philosophy
  final int currentIndex;
  const AppDrawer({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            const _Header(),
            const SizedBox(height: 8),
            _NavItem(
              icon: Icons.chat_bubble_outline,
              label: 'Assistant',
              active: currentIndex == 0,
              onTap: () => _goHome(context),
            ),
            _NavItem(
              icon: Icons.memory,
              label: 'AI Models',
              active: currentIndex == 2,
              onTap: () => _goToTab(context, const ModelsScreen(), currentIndex == 2),
            ),
            _NavItem(
              icon: Icons.newspaper,
              label: 'News',
              active: currentIndex == 3,
              onTap: () => _goToTab(context, const NewsScreen(), currentIndex == 3),
            ),
            _NavItem(
              icon: Icons.auto_awesome,
              label: 'Philosophy',
              active: currentIndex == 4,
              onTap: () => _goToTab(context, const PhilosophyScreen(), currentIndex == 4),
            ),
            const Spacer(),
            const Divider(height: 1),
            _NavItem(
              icon: Icons.settings_outlined,
              label: 'Settings',
              active: false,
              onTap: () {
                Navigator.of(context).pop(); // close drawer
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  /// Assistant = Home is always the very first route. Closing the drawer and
  /// popping back to the root reliably returns there from any screen.
  void _goHome(BuildContext context) {
    Navigator.of(context).pop(); // close drawer
    if (currentIndex != 0) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  /// For section screens: close drawer, return to Home root, then push the
  /// target. This keeps the back stack shallow (Home -> Section) instead of
  /// piling screens on top of each other, and guarantees the drawer's
  /// Assistant item always has a clean root to return to.
  void _goToTab(BuildContext context, Widget screen, bool alreadyHere) {
    Navigator.of(context).pop(); // close drawer
    if (alreadyHere) return; // already on this screen, nothing to do
    Navigator.of(context).popUntil((route) => route.isFirst);
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }
}

class _Header extends StatelessWidget {
  const _Header();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190,
      width: double.infinity,
      decoration: const BoxDecoration(gradient: MitraTheme.headerGradient),
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [MitraTheme.purple, MitraTheme.cyan],
              ),
              boxShadow: [
                BoxShadow(color: MitraTheme.purple.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 4)),
              ],
            ),
            child: const Icon(Icons.graphic_eq, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 14),
          const Text('Mitra',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 24, letterSpacing: 0.5)),
          const SizedBox(height: 2),
          Text('Your personal AI',
              style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 13)),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Material(
        color: active ? MitraTheme.purple.withOpacity(0.14) : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, size: 22, color: active ? MitraTheme.purple : Colors.white70),
                const SizedBox(width: 16),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                    color: active ? MitraTheme.purple : Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
