import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'podcast_model.dart';

class PodcastService {
  /// Parse RSS feed URL and return feed metadata + episodes.
  Future<({String title, String? imageUrl, List<PodcastEpisode> episodes})>
      parseFeed(String url, String feedId) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch RSS feed (${response.statusCode})');
    }

    final body = response.body;
    // Extract channel-level title (first <title> tag)
    final title = _extractTag(body, 'title') ?? 'Unknown';
    final imageUrl = _extractImageUrl(body);
    final episodes = _parseEpisodes(body, feedId);

    return (title: title, imageUrl: imageUrl, episodes: episodes);
  }

  String? _extractTag(String xml, String tag) {
    final match = RegExp('<$tag>([^<]+)</$tag>').firstMatch(xml);
    return match?.group(1)?.trim();
  }

  String? _extractImageUrl(String xml) {
    // Try <itunes:image href="..."> first
    var match = RegExp(r'<itunes:image\s+href="([^"]+)"').firstMatch(xml);
    if (match != null) return match.group(1);
    // Then <image><url>...</url>
    match = RegExp(r'<image>.*?<url>([^<]+)</url>', dotAll: true).firstMatch(xml);
    return match?.group(1)?.trim();
  }

  List<PodcastEpisode> _parseEpisodes(String xml, String feedId) {
    final episodes = <PodcastEpisode>[];
    final itemMatches =
        RegExp(r'<item>(.*?)</item>', dotAll: true).allMatches(xml);

    for (final m in itemMatches.take(50)) {
      final item = m.group(1)!;
      final title = _extractTag(item, 'title') ?? 'Episode';

      // Get audio URL from enclosure tag
      final enclosure =
          RegExp(r'<enclosure[^>]+url="([^"]+)"').firstMatch(item);
      if (enclosure == null) continue;
      final audioUrl = enclosure.group(1)!;

      // Parse duration
      final durStr = _extractTag(item, 'itunes:duration');
      Duration? duration;
      if (durStr != null) {
        final parts =
            durStr.split(':').map((s) => int.tryParse(s.trim())).toList();
        if (parts.length == 3 && parts.every((pp) => pp != null)) {
          duration = Duration(
              hours: parts[0]!, minutes: parts[1]!, seconds: parts[2]!);
        } else if (parts.length == 2 && parts.every((pp) => pp != null)) {
          duration = Duration(minutes: parts[0]!, seconds: parts[1]!);
        } else if (parts.length == 1 && parts[0] != null) {
          // Seconds-only format
          duration = Duration(seconds: parts[0]!);
        }
      }

      final pubDateStr = _extractTag(item, 'pubDate');
      final description = _extractTag(item, 'description');

      episodes.add(PodcastEpisode(
        id: '${feedId}_${audioUrl.hashCode.abs()}',
        feedId: feedId,
        title: title,
        audioUrl: audioUrl,
        description: description,
        duration: duration,
        publishedAt: pubDateStr != null ? _parseDate(pubDateStr) : null,
      ));
    }
    return episodes;
  }

  DateTime? _parseDate(String s) {
    // RSS pubDate is typically RFC 2822 format, try ISO first then give up gracefully
    try {
      return DateTime.parse(s);
    } catch (_) {
      return null;
    }
  }

  /// Download episode audio to local storage; returns local file path or null on failure.
  Future<String?> downloadEpisode(PodcastEpisode episode) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final podcastDir = Directory(p.join(dir.path, 'podcasts'));
      await podcastDir.create(recursive: true);

      final uri = Uri.parse(episode.audioUrl);
      final ext = uri.pathSegments.isNotEmpty &&
              uri.pathSegments.last.contains('.')
          ? uri.pathSegments.last.split('.').last.toLowerCase()
          : 'm4a';
      final safeExt = ['mp3', 'm4a', 'wav', 'aac', 'ogg'].contains(ext)
          ? ext
          : 'm4a';

      final localPath =
          p.join(podcastDir.path, '${episode.id}.$safeExt');

      final response = await http.get(Uri.parse(episode.audioUrl));
      if (response.statusCode != 200) return null;

      await File(localPath).writeAsBytes(response.bodyBytes);
      return localPath;
    } catch (_) {
      return null;
    }
  }
}
