import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/news_service.dart';
import '../theme.dart';
import '../widgets/app_drawer.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});
  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _categories = const ['india', 'world', 'tech'];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(currentIndex: 2),
      appBar: AppBar(
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: MitraTheme.headerGradient)),
        title: const Text('News'),
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: MitraTheme.cyan,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [Tab(text: 'India'), Tab(text: 'World'), Tab(text: 'Tech')],
        ),
      ),
      body: TabBarView(controller: _tabs, children: _categories.map((c) => _CategoryFeed(category: c)).toList()),
    );
  }
}

class _CategoryFeed extends StatefulWidget {
  final String category;
  const _CategoryFeed({required this.category});
  @override
  State<_CategoryFeed> createState() => _CategoryFeedState();
}

class _CategoryFeedState extends State<_CategoryFeed> with AutomaticKeepAliveClientMixin {
  Future<List<NewsItem>>? _future;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() => _future = NewsService.instance.fetchCategory(widget.category));
  }

  Future<void> _open(String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RefreshIndicator(
      onRefresh: () async => _load(),
      child: FutureBuilder<List<NewsItem>>(
        future: _future,
        builder: (_, snap) {
          if (snap.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
          if (snap.hasError) return _Error(message: snap.error.toString(), onRetry: _load);
          final items = snap.data ?? const [];
          if (items.isEmpty) return _Error(message: 'No news fetched. Check your internet?', onRetry: _load);
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            itemBuilder: (_, i) {
              final n = items[i];
              return Card(
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _open(n.link),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(n.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, height: 1.35)),
                        if (n.description != null) ...[
                          const SizedBox(height: 8),
                          Text(n.description!, style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 13, height: 1.4), maxLines: 3, overflow: TextOverflow.ellipsis),
                        ],
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: MitraTheme.purple.withOpacity(0.20), borderRadius: BorderRadius.circular(6)),
                              child: Text(n.source, style: const TextStyle(fontSize: 11, color: MitraTheme.purple, fontWeight: FontWeight.w600)),
                            ),
                            const Spacer(),
                            if (n.pubDate != null)
                              Text(_relative(n.pubDate!), style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.4))),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _relative(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} h ago';
    if (diff.inDays < 7) return '${diff.inDays} d ago';
    return DateFormat('MMM d').format(dt);
  }
}

class _Error extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _Error({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 80),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Icon(Icons.cloud_off, size: 64, color: Colors.white24),
                const SizedBox(height: 12),
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(onPressed: onRetry, child: const Text('Retry')),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
