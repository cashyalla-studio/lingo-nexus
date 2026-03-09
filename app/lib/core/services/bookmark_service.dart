import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bookmark.dart';

class BookmarkService {
  static const String _key = 'bookmarks';

  Future<List<Bookmark>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => Bookmark.fromJson(e as Map<String, dynamic>)).toList()
        ..sort((a, b) => b.savedAt.compareTo(a.savedAt)); // newest first
    } catch (_) {
      return [];
    }
  }

  Future<bool> add(Bookmark bookmark) async {
    final bookmarks = await loadAll();
    if (bookmarks.any((b) => b.id == bookmark.id)) return false;
    bookmarks.insert(0, bookmark);
    await _save(bookmarks);
    return true;
  }

  Future<void> remove(String id) async {
    final bookmarks = await loadAll();
    bookmarks.removeWhere((b) => b.id == id);
    await _save(bookmarks);
  }

  Future<void> updateNote(String id, String note) async {
    final bookmarks = await loadAll();
    final idx = bookmarks.indexWhere((b) => b.id == id);
    if (idx >= 0) {
      bookmarks[idx].note = note;
      await _save(bookmarks);
    }
  }

  Future<bool> isBookmarked(String sentenceId) async {
    final bookmarks = await loadAll();
    return bookmarks.any((b) => b.id == sentenceId);
  }

  Future<void> _save(List<Bookmark> bookmarks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(bookmarks.map((b) => b.toJson()).toList()));
  }
}
