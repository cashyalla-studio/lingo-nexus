import 'sync_item.dart';

enum StudyItemSource { local, iCloud, googleDrive }

class StudyItem {
  final String title;
  final String audioPath;
  final String? scriptPath;
  final StudyItemSource source;
  Duration lastPosition;
  DateTime? lastPlayedAt;
  Duration? totalDuration;
  List<SyncItem>? syncItems;

  StudyItem({
    required this.title,
    required this.audioPath,
    this.scriptPath,
    this.source = StudyItemSource.local,
    this.lastPosition = Duration.zero,
    this.lastPlayedAt,
    this.totalDuration,
    this.syncItems,
  });

  StudyItem copyWith({
    String? title,
    String? audioPath,
    String? scriptPath,
    StudyItemSource? source,
    Duration? lastPosition,
    DateTime? lastPlayedAt,
    Duration? totalDuration,
    List<SyncItem>? syncItems,
  }) {
    return StudyItem(
      title: title ?? this.title,
      audioPath: audioPath ?? this.audioPath,
      scriptPath: scriptPath ?? this.scriptPath,
      source: source ?? this.source,
      lastPosition: lastPosition ?? this.lastPosition,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      totalDuration: totalDuration ?? this.totalDuration,
      syncItems: syncItems ?? this.syncItems,
    );
  }

  /// SRT 파일을 스크립트로 사용하는지 여부
  bool get isScriptSrt => scriptPath?.toLowerCase().endsWith('.srt') ?? false;

  double get progressRatio {
    if (totalDuration == null || totalDuration!.inMilliseconds == 0) return 0.0;
    return (lastPosition.inMilliseconds / totalDuration!.inMilliseconds).clamp(0.0, 1.0);
  }

  String get progressTimeLeft {
    if (totalDuration == null) return '';
    final remaining = totalDuration! - lastPosition;
    final mins = remaining.inMinutes;
    if (mins <= 0) return '완료';
    return '$mins분 남음';
  }

  bool get isCompleted => progressRatio >= 0.95;
}
