class Bookmark {
  final String id;
  final String sentence;
  final String sourceTitle; // StudyItem title
  final String audioPath;
  final Duration? startTime;
  final DateTime savedAt;
  String? note; // user can add a personal note

  Bookmark({
    required this.id,
    required this.sentence,
    required this.sourceTitle,
    required this.audioPath,
    this.startTime,
    required this.savedAt,
    this.note,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'sentence': sentence,
    'sourceTitle': sourceTitle,
    'audioPath': audioPath,
    'startTimeMs': startTime?.inMilliseconds,
    'savedAt': savedAt.toIso8601String(),
    'note': note,
  };

  factory Bookmark.fromJson(Map<String, dynamic> json) => Bookmark(
    id: json['id'] as String,
    sentence: json['sentence'] as String,
    sourceTitle: json['sourceTitle'] as String,
    audioPath: json['audioPath'] as String,
    startTime: json['startTimeMs'] != null
        ? Duration(milliseconds: json['startTimeMs'] as int)
        : null,
    savedAt: DateTime.parse(json['savedAt'] as String),
    note: json['note'] as String?,
  );
}
