import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class CacheEntry {
  final String folderName;
  final int sizeBytes;
  final int fileCount;
  final DateTime lastModified;

  const CacheEntry({
    required this.folderName,
    required this.sizeBytes,
    required this.fileCount,
    required this.lastModified,
  });

  String get sizeLabel {
    if (sizeBytes < 1024 * 1024) return '${(sizeBytes / 1024).toStringAsFixed(0)} KB';
    if (sizeBytes < 1024 * 1024 * 1024) {
      return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(sizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}

/// Google Drive 다운로드 캐시 및 앱 임시 파일을 관리합니다.
class CacheService {
  static const _driveCacheFolder = 'google_drive_imports';
  static const _openedFilesFolder = 'opened_files';

  Future<Directory> get _driveDir async {
    final docs = await getApplicationDocumentsDirectory();
    return Directory(p.join(docs.path, _driveCacheFolder));
  }

  Future<Directory> get _openedDir async {
    final docs = await getApplicationDocumentsDirectory();
    return Directory(p.join(docs.path, _openedFilesFolder));
  }

  /// Drive 캐시 폴더별 항목 목록
  Future<List<CacheEntry>> getDriveCacheEntries() async {
    final dir = await _driveDir;
    if (!await dir.exists()) return [];

    final entries = <CacheEntry>[];
    await for (final entity in dir.list()) {
      if (entity is Directory) {
        final size = await _dirSize(entity);
        final count = await _fileCount(entity);
        final stat = await entity.stat();
        entries.add(CacheEntry(
          folderName: p.basename(entity.path),
          sizeBytes: size,
          fileCount: count,
          lastModified: stat.modified,
        ));
      }
    }
    entries.sort((a, b) => b.lastModified.compareTo(a.lastModified));
    return entries;
  }

  /// 전체 캐시 용량 (Drive 다운로드 + 열린 파일)
  Future<int> getTotalCacheSize() async {
    int total = 0;
    final drive = await _driveDir;
    if (await drive.exists()) total += await _dirSize(drive);
    final opened = await _openedDir;
    if (await opened.exists()) total += await _dirSize(opened);
    return total;
  }

  /// 특정 Drive 폴더 캐시 삭제
  Future<void> clearDriveEntry(String folderName) async {
    final dir = await _driveDir;
    final target = Directory(p.join(dir.path, folderName));
    if (await target.exists()) await target.delete(recursive: true);
  }

  /// Drive 캐시 전체 삭제
  Future<void> clearAllDriveCache() async {
    final dir = await _driveDir;
    if (await dir.exists()) await dir.delete(recursive: true);
  }

  /// "열기로" 받은 파일 캐시 삭제
  Future<void> clearOpenedFiles() async {
    final dir = await _openedDir;
    if (await dir.exists()) await dir.delete(recursive: true);
  }

  /// 외부에서 열린 파일을 앱 샌드박스 내부로 복사합니다.
  Future<File> copyOpenedFile(String sourcePath) async {
    final dir = await _openedDir;
    await dir.create(recursive: true);
    final src = File(sourcePath);
    final dest = File(p.join(dir.path, p.basename(sourcePath)));
    return src.copy(dest.path);
  }

  Future<int> _dirSize(Directory dir) async {
    int total = 0;
    try {
      await for (final entity in dir.list(recursive: true)) {
        if (entity is File) {
          total += await entity.length();
        }
      }
    } catch (_) {}
    return total;
  }

  Future<int> _fileCount(Directory dir) async {
    int count = 0;
    try {
      await for (final entity in dir.list(recursive: true)) {
        if (entity is File) count++;
      }
    } catch (_) {}
    return count;
  }

  /// 용량 포맷 (정적 유틸)
  static String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
