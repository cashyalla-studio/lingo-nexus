import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import '../../core/models/study_item.dart';
import '../../core/services/cache_service.dart';
import '../../core/services/file_open_service.dart';
import '../../core/services/google_drive_service.dart';
import '../../core/services/icloud_service.dart';
import '../../core/services/library_persistence_service.dart';
import '../../core/services/progress_service.dart';
import 'directory_scanner_service.dart';

final cacheServiceProvider = Provider((ref) => CacheService());
final fileOpenServiceProvider = Provider((ref) => FileOpenService());

final googleDriveServiceProvider = Provider((ref) => GoogleDriveService());

final scannerServiceProvider = Provider((ref) => DirectoryScannerService());
final progressServiceProvider = Provider((ref) => ProgressService());
final iCloudServiceProvider = Provider((ref) => ICloudService());
final libraryPersistenceProvider = Provider((ref) => LibraryPersistenceService());

final studyItemsProvider = StateNotifierProvider<StudyItemsNotifier, AsyncValue<List<StudyItem>>>((ref) {
  return StudyItemsNotifier(
    ref.watch(scannerServiceProvider),
    ref.watch(progressServiceProvider),
    ref.watch(iCloudServiceProvider),
    ref.watch(libraryPersistenceProvider),
  );
});

class StudyItemsNotifier extends StateNotifier<AsyncValue<List<StudyItem>>> {
  final DirectoryScannerService _scanner;
  final ProgressService _progress;
  final ICloudService _icloud;
  final LibraryPersistenceService _persistence;

  StudyItemsNotifier(this._scanner, this._progress, this._icloud, this._persistence)
      : super(const AsyncValue.data([]));

  /// 앱 시작 시 저장된 디렉터리들을 자동 복원합니다.
  Future<void> initLibrary() async {
    state = const AsyncValue.loading();
    try {
      final allItems = <StudyItem>[];
      final savedPaths = await _persistence.loadPaths();
      final bookmarks = await _persistence.loadBookmarks();

      for (final savedPath in savedPaths) {
        String resolvedPath = savedPath;

        // macOS 보안 북마크로 접근 복원 시도
        final bookmark = bookmarks[savedPath];
        if (bookmark != null) {
          final resolved = await _icloud.resolveBookmark(bookmark);
          if (resolved != null) resolvedPath = resolved;
        }

        final source = _detectSource(resolvedPath);
        final items = await _scanner.scanFromPath(resolvedPath, source: source);
        allItems.addAll(items);
      }

      await _loadProgress(allItems);
      state = AsyncValue.data(allItems);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// 사용자가 직접 폴더를 선택하여 라이브러리에 추가합니다.
  Future<void> pickAndScanDirectory() async {
    state = const AsyncValue.loading();
    try {
      final result = await _scanner.scanDirectory();
      if (result.selectedPath == null) {
        // 취소 — 기존 상태 유지
        await initLibrary();
        return;
      }

      final dirPath = result.selectedPath!;
      final source = _detectSource(dirPath);

      // 북마크 생성 및 경로 영속화
      final bookmark = await _icloud.createBookmark(dirPath);
      await _persistence.addPath(dirPath);
      if (bookmark != null) {
        await _persistence.saveBookmark(dirPath, bookmark);
      }

      final newItems = result.items.map((item) => StudyItem(
        title: item.title,
        audioPath: item.audioPath,
        scriptPath: item.scriptPath,
        source: source,
      )).toList();

      final current = state.value ?? [];
      final merged = _mergeItems(current, newItems);
      await _loadProgress(merged);
      state = AsyncValue.data(merged);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// iCloud 컨테이너 디렉터리를 자동으로 스캔합니다.
  Future<void> syncFromICloud() async {
    final container = await _icloud.getContainerDirectory();
    if (container == null) return;

    final icloudItems = await _scanner.scanFromPath(
      container.path,
      source: StudyItemSource.iCloud,
    );
    await _persistence.addPath(container.path);

    final current = state.value ?? [];
    final merged = _mergeItems(current, icloudItems);
    await _loadProgress(merged);
    state = AsyncValue.data(merged);
  }

  /// 디렉터리를 라이브러리에서 제거합니다.
  Future<void> removeDirectory(String directoryPath) async {
    await _icloud.stopAccessing(directoryPath);
    await _persistence.removePath(directoryPath);
    await initLibrary();
  }

  /// Google Drive 임포트 등 외부에서 생성된 StudyItem들을 라이브러리에 추가합니다.
  Future<void> addItems(List<StudyItem> newItems) async {
    final current = state.value ?? [];
    final merged = _mergeItems(current, newItems);
    await _loadProgress(merged);
    state = AsyncValue.data(merged);
  }

  /// 오디오 전용 항목에 스크립트 파일을 연결합니다.
  void attachScript(String audioPath, String scriptPath) {
    final current = state.value;
    if (current == null) return;
    state = AsyncValue.data([
      for (final item in current)
        if (item.audioPath == audioPath) item.copyWith(scriptPath: scriptPath) else item,
    ]);
  }

  /// 라이브러리에서 항목을 제거합니다.
  void removeItem(String audioPath) {
    final current = state.value;
    if (current == null) return;
    state = AsyncValue.data(current.where((i) => i.audioPath != audioPath).toList());
  }

  /// "다음으로 열기"로 전달된 단일 파일을 라이브러리에 추가합니다.
  Future<void> addSingleFile(String filePath) async {
    final lower = filePath.toLowerCase();
    if (!lower.endsWith('.mp3') && !lower.endsWith('.m4a') && !lower.endsWith('.wav')) return;
    final title = p.basenameWithoutExtension(filePath);
    final newItem = StudyItem(title: title, audioPath: filePath, source: StudyItemSource.local);
    await addItems([newItem]);
  }

  Future<void> updateItemProgress(String audioPath, Duration position, Duration? totalDuration) async {
    await _progress.saveProgress(audioPath, position, totalDuration);
    final current = state.value;
    if (current == null) return;
    for (final item in current) {
      if (item.audioPath == audioPath) {
        item.lastPosition = position;
        item.lastPlayedAt = DateTime.now();
        if (totalDuration != null) item.totalDuration = totalDuration;
        break;
      }
    }
    state = AsyncValue.data(List<StudyItem>.from(current));
  }

  // 경로에서 소스 타입 판별 (iCloud Drive 경로 패턴 감지)
  StudyItemSource _detectSource(String dirPath) {
    if (dirPath.contains('com~apple~CloudDocs') || dirPath.contains('/iCloud/')) {
      return StudyItemSource.iCloud;
    }
    return StudyItemSource.local;
  }

  // 기존 항목과 새 항목 병합 (audioPath 기준 중복 제거)
  List<StudyItem> _mergeItems(List<StudyItem> current, List<StudyItem> incoming) {
    final existingPaths = {for (final item in current) item.audioPath};
    final newOnly = incoming.where((item) => !existingPaths.contains(item.audioPath));
    return [...current, ...newOnly];
  }

  Future<void> _loadProgress(List<StudyItem> items) async {
    for (final item in items) {
      final prog = await _progress.loadProgress(item.audioPath);
      item.lastPosition = prog['position'] as Duration;
      item.lastPlayedAt = prog['lastPlayedAt'] as DateTime?;
      item.totalDuration = prog['totalDuration'] as Duration?;
      final syncItems = await _progress.loadSyncItems(item.audioPath);
      if (syncItems != null) {
        item.syncItems = syncItems;
      }
    }
  }
}
