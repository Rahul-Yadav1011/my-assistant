import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:webfeed_revised/webfeed_revised.dart';

class NewsItem {
  final String title;
  final String? description;
  final String? link;
  final DateTime? pubDate;
  final String source;
  NewsItem({required this.title, required this.source, this.description, this.link, this.pubDate});
}

class NewsSource {
  final String name;
  final String url;
  final String category;
  const NewsSource(this.name, this.url, this.category);
}

class NewsService {
  NewsService._();
  static final NewsService instance = NewsService._();

  static const List<NewsSource> sources = [
    NewsSource('NDTV', 'https://feeds.feedburner.com/ndtvnews-top-stories', 'india'),
    NewsSource('The Hindu', 'https://www.thehindu.com/feeder/default.rss', 'india'),
    NewsSource('Times of India', 'https://timesofindia.indiatimes.com/rssfeedstopstories.cms', 'india'),
    NewsSource('Hindustan Times', 'https://www.hindustantimes.com/feeds/rss/india-news/rssfeed.xml', 'india'),
    NewsSource('BBC', 'http://feeds.bbci.co.uk/news/world/rss.xml', 'world'),
    NewsSource('Reuters', 'https://feeds.reuters.com/reuters/topNews', 'world'),
    NewsSource('Hacker News', 'https://hnrss.org/frontpage', 'tech'),
    NewsSource('TechCrunch', 'https://techcrunch.com/feed/', 'tech'),
  ];

  Future<List<NewsItem>> fetchCategory(String category, {int perSource = 8}) async {
    final relevant = sources.where((s) => s.category == category).toList();
    final futures = relevant.map((s) => _fetchOne(s, perSource));
    final batches = await Future.wait(futures);
    final all = batches.expand((b) => b).toList();
    all.sort((a, b) {
      final ad = a.pubDate, bd = b.pubDate;
      if (ad == null && bd == null) return 0;
      if (ad == null) return 1;
      if (bd == null) return -1;
      return bd.compareTo(ad);
    });
    return all;
  }

  Future<List<NewsItem>> _fetchOne(NewsSource src, int limit) async {
    try {
      final resp = await http.get(Uri.parse(src.url)).timeout(const Duration(seconds: 12));
      if (resp.statusCode != 200) return [];
      final body = resp.body;
      try {
        final feed = RssFeed.parse(body);
        return (feed.items ?? [])
            .take(limit)
            .map((it) => NewsItem(
                  title: it.title?.trim() ?? '(untitled)',
                  description: _cleanDescription(it.description),
                  link: it.link,
                  pubDate: it.pubDate,
                  source: src.name,
                ))
            .toList();
      } catch (_) {
        try {
          final feed = AtomFeed.parse(body);
          return (feed.items ?? [])
              .take(limit)
              .map((it) => NewsItem(
                    title: it.title?.trim() ?? '(untitled)',
                    description: _cleanDescription(it.summary),
                    link: it.links?.isNotEmpty == true ? it.links!.first.href : null,
                    pubDate: it.updated,
                    source: src.name,
                  ))
              .toList();
        } catch (_) {
          return [];
        }
      }
    } catch (_) {
      return [];
    }
  }

  String? _cleanDescription(String? s) {
    if (s == null) return null;
    final cleaned = s.replaceAll(RegExp(r'<[^>]+>'), '').replaceAll(RegExp(r'\s+'), ' ').trim();
    if (cleaned.length > 250) return '${cleaned.substring(0, 247)}...';
    return cleaned.isEmpty ? null : cleaned;
  }
}
