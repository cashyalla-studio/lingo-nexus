class PodcastFeed {
  final String id;
  final String url;
  final String title;
  final String? imageUrl;
  final String? language;
  final DateTime addedAt;

  PodcastFeed({
    required this.id,
    required this.url,
    required this.title,
    this.imageUrl,
    this.language,
    required this.addedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'url': url,
    'title': title,
    'imageUrl': imageUrl,
    'language': language,
    'addedAt': addedAt.toIso8601String(),
  };

  factory PodcastFeed.fromJson(Map<String, dynamic> json) => PodcastFeed(
    id: json['id'] as String,
    url: json['url'] as String,
    title: json['title'] as String,
    imageUrl: json['imageUrl'] as String?,
    language: json['language'] as String?,
    addedAt: DateTime.parse(json['addedAt'] as String),
  );
}

class PodcastEpisode {
  final String id;
  final String feedId;
  final String title;
  final String audioUrl;
  final String? description;
  final Duration? duration;
  final DateTime? publishedAt;
  bool isDownloaded;
  String? localPath;

  PodcastEpisode({
    required this.id,
    required this.feedId,
    required this.title,
    required this.audioUrl,
    this.description,
    this.duration,
    this.publishedAt,
    this.isDownloaded = false,
    this.localPath,
  });

  String get durationLabel {
    if (duration == null) return '';
    final h = duration!.inHours;
    final m = duration!.inMinutes.remainder(60);
    final s = duration!.inSeconds.remainder(60);
    if (h > 0) {
      return '${h}h ${m}m';
    }
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}
