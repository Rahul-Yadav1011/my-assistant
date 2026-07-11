import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/philosophy_data.dart';
import '../services/philosophy_service.dart';
import '../theme.dart';
import '../widgets/app_drawer.dart';

class PhilosophyScreen extends StatelessWidget {
  const PhilosophyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final svc = PhilosophyService.instance;
    final qotd = svc.quoteOfTheDay();
    final schools = svc.allSchools();

    return Scaffold(
      drawer: const AppDrawer(currentIndex: 3),
      appBar: AppBar(
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: MitraTheme.headerGradient)),
        title: const Text('Philosophy'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _QuoteOfTheDayCard(entry: qotd),
          const SizedBox(height: 24),
          const Text('Schools', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          ...schools.map((s) => _SchoolCard(school: s)),
        ],
      ),
    );
  }
}

class _QuoteOfTheDayCard extends StatelessWidget {
  final PhilosophyEntry entry;
  const _QuoteOfTheDayCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [MitraTheme.deepPurple, MitraTheme.indigo]),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.wb_sunny_outlined, color: Colors.white70, size: 18),
              const SizedBox(width: 8),
              Text('Quote of the Day', style: TextStyle(color: Colors.white.withOpacity(0.85), fontWeight: FontWeight.w600, letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(height: 14),
          Text('"${entry.text}"', style: const TextStyle(color: Colors.white, fontSize: 17, height: 1.45, fontStyle: FontStyle.italic, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          Text('— ${entry.author}', style: TextStyle(color: Colors.white.withOpacity(0.85), fontWeight: FontWeight.w500)),
          Text(entry.school, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.copy_outlined, color: Colors.white70, size: 18),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: '"${entry.text}"\n— ${entry.author}, ${entry.school}'));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SchoolCard extends StatelessWidget {
  final PhilosophySchool school;
  const _SchoolCard({required this.school});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: MitraTheme.purple.withOpacity(0.18)),
          child: const Icon(Icons.auto_awesome, color: MitraTheme.purple),
        ),
        title: Text(school.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(school.origin, style: TextStyle(color: Colors.white.withOpacity(0.5))),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => _SchoolDetail(school: school))),
      ),
    );
  }
}

class _SchoolDetail extends StatelessWidget {
  final PhilosophySchool school;
  const _SchoolDetail({required this.school});

  @override
  Widget build(BuildContext context) {
    final quotes = PhilosophyService.instance.quotesBySchool(school.name);
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: MitraTheme.headerGradient)),
        title: Text(school.name),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(school.origin, style: TextStyle(color: Colors.white.withOpacity(0.5))),
          const SizedBox(height: 12),
          Text(school.summary, style: const TextStyle(height: 1.5)),
          const SizedBox(height: 24),
          const Text('Core ideas', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 8),
          ...school.coreIdeas.map((idea) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.circle, size: 6, color: MitraTheme.cyan),
                    const SizedBox(width: 12),
                    Expanded(child: Text(idea, style: const TextStyle(height: 1.5))),
                  ],
                ),
              )),
          if (quotes.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text('Quotes', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 8),
            ...quotes.map((q) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('"${q.text}"', style: const TextStyle(fontStyle: FontStyle.italic, height: 1.5)),
                        const SizedBox(height: 6),
                        Text('— ${q.author}', style: TextStyle(color: Colors.white.withOpacity(0.6))),
                      ],
                    ),
                  ),
                )),
          ],
        ],
      ),
    );
  }
}
