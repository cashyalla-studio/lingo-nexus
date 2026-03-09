class PronunciationHistoryEntry {
  final String sentenceId;   // unique: hash of sentence text
  final String sentence;
  final int score;
  final DateTime recordedAt;

  const PronunciationHistoryEntry({
    required this.sentenceId,
    required this.sentence,
    required this.score,
    required this.recordedAt,
  });

  Map<String, dynamic> toJson() => {
    'sentenceId': sentenceId,
    'sentence': sentence,
    'score': score,
    'recordedAt': recordedAt.toIso8601String(),
  };

  factory PronunciationHistoryEntry.fromJson(Map<String, dynamic> json) =>
    PronunciationHistoryEntry(
      sentenceId: json['sentenceId'] as String,
      sentence: json['sentence'] as String,
      score: json['score'] as int,
      recordedAt: DateTime.parse(json['recordedAt'] as String),
    );

  static String computeId(String sentence) {
    // Simple hash: use hashCode as a stable string key
    return sentence.trim().toLowerCase().hashCode.toString();
  }
}
