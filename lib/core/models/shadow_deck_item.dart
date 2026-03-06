class ShadowDeckItem {
  final String id; // unique: audioPath + startTimeMs
  final String sentence;
  final String audioPath;
  final Duration startTime;
  final Duration endTime;
  int bestScore; // 0-100
  int reviewCount;
  DateTime? nextReviewAt;
  DateTime addedAt;

  ShadowDeckItem({
    required this.id,
    required this.sentence,
    required this.audioPath,
    required this.startTime,
    required this.endTime,
    this.bestScore = 0,
    this.reviewCount = 0,
    this.nextReviewAt,
    required this.addedAt,
  });

  bool get isDue {
    if (nextReviewAt == null) return true;
    return DateTime.now().isAfter(nextReviewAt!);
  }

  // Simple SRS: based on score, determine next review interval
  void scheduleNext(int score) {
    bestScore = score > bestScore ? score : bestScore;
    reviewCount++;
    final now = DateTime.now();
    int daysUntilNext;
    if (score < 60) {
      daysUntilNext = 1;
    } else if (score < 75) {
      daysUntilNext = 3;
    } else if (score < 90) {
      daysUntilNext = 7;
    } else {
      daysUntilNext = 14;
    }
    nextReviewAt = now.add(Duration(days: daysUntilNext));
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'sentence': sentence,
    'audioPath': audioPath,
    'startTimeMs': startTime.inMilliseconds,
    'endTimeMs': endTime.inMilliseconds,
    'bestScore': bestScore,
    'reviewCount': reviewCount,
    'nextReviewAt': nextReviewAt?.toIso8601String(),
    'addedAt': addedAt.toIso8601String(),
  };

  factory ShadowDeckItem.fromJson(Map<String, dynamic> json) => ShadowDeckItem(
    id: json['id'] as String,
    sentence: json['sentence'] as String,
    audioPath: json['audioPath'] as String,
    startTime: Duration(milliseconds: json['startTimeMs'] as int),
    endTime: Duration(milliseconds: json['endTimeMs'] as int),
    bestScore: json['bestScore'] as int? ?? 0,
    reviewCount: json['reviewCount'] as int? ?? 0,
    nextReviewAt: json['nextReviewAt'] != null
        ? DateTime.tryParse(json['nextReviewAt'] as String)
        : null,
    addedAt: DateTime.parse(json['addedAt'] as String),
  );
}
