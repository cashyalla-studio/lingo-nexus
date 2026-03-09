class SyncItem {
  final Duration startTime;
  final Duration endTime;
  final String sentence;

  SyncItem({
    required this.startTime,
    required this.endTime,
    required this.sentence,
  });

  String get formattedTime {
    final minutes = startTime.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = startTime.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
