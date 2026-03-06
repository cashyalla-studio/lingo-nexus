import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/bookmark.dart';
import '../../core/services/bookmark_service.dart';

final bookmarkServiceProvider = Provider((ref) => BookmarkService());

class BookmarksNotifier extends StateNotifier<AsyncValue<List<Bookmark>>> {
  BookmarksNotifier(this._service) : super(const AsyncValue.loading()) {
    load();
  }

  final BookmarkService _service;

  Future<void> load() async {
    try {
      state = AsyncValue.data(await _service.loadAll());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> add(Bookmark bookmark) async {
    final added = await _service.add(bookmark);
    if (added) await load();
    return added;
  }

  Future<void> remove(String id) async {
    await _service.remove(id);
    await load();
  }

  Future<void> updateNote(String id, String note) async {
    await _service.updateNote(id, note);
    await load();
  }
}

final bookmarksProvider = StateNotifierProvider<BookmarksNotifier, AsyncValue<List<Bookmark>>>((ref) {
  return BookmarksNotifier(ref.watch(bookmarkServiceProvider));
});
