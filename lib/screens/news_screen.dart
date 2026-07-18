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
      drawer: const AppDrawer(currentIndex: 3),
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
  bool _loading = true;
  String? _error;
  List<NewsItem> _items = [];
  int _dismissedCount = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await NewsService.instance.fetchCategory(widget.category);
      if (!mounted) return;
      setState(() {
        _items = items;
        _dismissedCount = 0;
        _loading = false;
        _error = items.isEmpty ? 'No news fetched. Check your internet?' : null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _open(String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _dismiss(NewsItem item) {
    setState(() {
      _items.remove(item);
      _dismissedCount++;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return _ErrorView(message: _error!, onRetry: _load);

    if (_items.isEmpty) {
      // Everything read/dismissed — friendly empty state with refresh.
      return RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          children: [
            const SizedBox(height: 100),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(Icons.check_circle_outline, size: 64, color: MitraTheme.cyan),
                    const SizedBox(height: 12),
                    Text(
                      _dismissedCount > 0 ? "You're all caught up!" : 'No news right now.',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Text('Pull down or tap refresh for more.',
                        style: TextStyle(color: Colors.white.withOpacity(0.5))),
                    const SizedBox(height: 16),
                    FilledButton.icon(onPressed: _load, icon: const Icon(Icons.refresh), label: const Text('Refresh')),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: Column(
        children: [
          // Little hint bar showing progress + swipe tip
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
            child: Row(
              children: [
                Icon(Icons.swipe, size: 15, color: Colors.white.withOpacity(0.4)),
                const SizedBox(width: 6),
                Text('Swipe a card away as you read',
                    style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.4))),
                const Spacer(),
                Text('${_items.length} left',
                    style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.4))),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _items.length,
              itemBuilder: (_, i) {
                final n = _items[i];
                return Dismissible(
                  key: ValueKey('${n.source}-${n.title}-$i'),
                  direction: DismissDirection.horizontal,
                  background: _swipeBg(Alignment.centerLeft),
                  secondaryBackground: _swipeBg(Alignment.centerRight),
                  onDismissed: (_) => _dismiss(n),
                  child: _NewsCard(item: n, onTap: () => _open(n.link)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _swipeBg(Alignment align) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: MitraTheme.cyan.withOpacity(0.18),
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: align,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check, color: MitraTheme.cyan, size: 20),
          SizedBox(width: 6),
          Text('Mark read', style: TextStyle(color: MitraTheme.cyan, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  final NewsItem item;
  final VoidCallback onTap;
  const _NewsCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, height: 1.35)),
              if (item.description != null) ...[
                const SizedBox(height: 8),
                Text(item.description!,
                    style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 13, height: 1.4),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis),
              ],
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: MitraTheme.purple.withOpacity(0.20), borderRadius: BorderRadius.circular(6)),
                    child: Text(item.source, style: const TextStyle(fontSize: 11, color: MitraTheme.purple, fontWeight: FontWeight.w600)),
                  ),
                  const Spacer(),
                  if (item.pubDate != null)
                    Text(_relative(item.pubDate!), style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.4))),
                ],
              ),
            ],
          ),
        ),
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

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

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
