import '../../core/models/sync_item.dart';

/// SRT 자막 파일을 파싱하여 SyncItem 리스트로 변환합니다.
class SrtParserService {
  /// SRT 파일 내용을 파싱하여 SyncItem 목록을 반환합니다.
  List<SyncItem> parse(String srtContent) {
    final items = <SyncItem>[];
    final blocks = srtContent.trim().split(RegExp(r'\n\s*\n'));

    for (final block in blocks) {
      final lines = block.trim().split('\n');
      if (lines.length < 3) continue;

      // 첫 번째 줄: 시퀀스 번호 (무시)
      // 두 번째 줄: 타임코드 "00:00:01,000 --> 00:00:04,000"
      final timecodeMatch = RegExp(
        r'(\d{2}):(\d{2}):(\d{2})[,.](\d{3})\s*-->\s*(\d{2}):(\d{2}):(\d{2})[,.](\d{3})',
      ).firstMatch(lines[1]);

      if (timecodeMatch == null) continue;

      final startMs = _toMs(
        timecodeMatch.group(1)!,
        timecodeMatch.group(2)!,
        timecodeMatch.group(3)!,
        timecodeMatch.group(4)!,
      );
      final endMs = _toMs(
        timecodeMatch.group(5)!,
        timecodeMatch.group(6)!,
        timecodeMatch.group(7)!,
        timecodeMatch.group(8)!,
      );

      // 나머지 줄: 자막 텍스트 (HTML 태그 제거)
      final text = lines.sublist(2).join(' ').replaceAll(RegExp(r'<[^>]+>'), '').trim();
      if (text.isEmpty) continue;

      items.add(SyncItem(
        startTime: Duration(milliseconds: startMs),
        endTime: Duration(milliseconds: endMs),
        sentence: text,
      ));
    }
    return items;
  }

  int _toMs(String h, String m, String s, String ms) {
    return int.parse(h) * 3600000 +
        int.parse(m) * 60000 +
        int.parse(s) * 1000 +
        int.parse(ms);
  }

  /// SRT 파일의 전체 텍스트를 추출합니다 (타임코드 제거).
  String extractPlainText(String srtContent) {
    return parse(srtContent).map((i) => i.sentence).join(' ');
  }
}
