import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// 임시 파일(녹음, 클립 익스포트 등)을 정기적으로 정리합니다.
class TempCleanupService {
  static const Duration _maxAge = Duration(hours: 24);

  /// 24시간이 지난 임시 파일을 삭제합니다.
  Future<int> cleanOldTempFiles() async {
    int deletedCount = 0;
    try {
      final tempDir = await getTemporaryDirectory();
      final now = DateTime.now();

      await for (final entity in tempDir.list()) {
        if (entity is File) {
          final stat = await entity.stat();
          final age = now.difference(stat.modified);
          if (age > _maxAge) {
            final name = entity.path.split('/').last;
            // 앱이 생성한 임시 파일만 삭제 (shadowing_, clip_export_ 접두사)
            if (name.startsWith('shadowing_') || name.startsWith('clip_export_')) {
              await entity.delete();
              deletedCount++;
            }
          }
        }
      }
    } catch (_) {}
    return deletedCount;
  }

  /// 특정 경로의 임시 파일을 즉시 삭제합니다.
  Future<void> deleteFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } catch (_) {}
  }
}
