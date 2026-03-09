import 'package:shared_preferences/shared_preferences.dart';

/// 사용자가 선택한 디렉터리 경로와 보안 북마크를 영속 저장합니다.
/// 앱 재시작 후에도 라이브러리를 자동으로 복원하기 위해 사용합니다.
class LibraryPersistenceService {
  static const _keyPaths = 'library_saved_paths';
  static const _keyBookmarks = 'library_bookmarks';

  Future<List<String>> loadPaths() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyPaths) ?? [];
  }

  Future<void> addPath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    final paths = prefs.getStringList(_keyPaths) ?? [];
    if (!paths.contains(path)) {
      paths.add(path);
      await prefs.setStringList(_keyPaths, paths);
    }
  }

  Future<void> removePath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    final paths = prefs.getStringList(_keyPaths) ?? [];
    paths.remove(path);
    await prefs.setStringList(_keyPaths, paths);
    // 해당 경로의 북마크도 삭제
    await removeBookmark(path);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyPaths);
    await prefs.remove(_keyBookmarks);
  }

  // 보안 북마크 (macOS sandbox 재시작 후 접근 복원용)
  Future<Map<String, String>> loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_keyBookmarks) ?? [];
    final result = <String, String>{};
    for (final entry in raw) {
      final sep = entry.indexOf('||');
      if (sep > 0) {
        result[entry.substring(0, sep)] = entry.substring(sep + 2);
      }
    }
    return result;
  }

  Future<void> saveBookmark(String path, String bookmarkBase64) async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = await loadBookmarks();
    bookmarks[path] = bookmarkBase64;
    await prefs.setStringList(
      _keyBookmarks,
      bookmarks.entries.map((e) => '${e.key}||${e.value}').toList(),
    );
  }

  Future<void> removeBookmark(String path) async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = await loadBookmarks();
    bookmarks.remove(path);
    await prefs.setStringList(
      _keyBookmarks,
      bookmarks.entries.map((e) => '${e.key}||${e.value}').toList(),
    );
  }
}
