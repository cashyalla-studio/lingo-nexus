import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lingo_nexus/core/services/bookmark_service.dart';
import 'package:lingo_nexus/core/models/bookmark.dart';

Bookmark _makeBookmark(String id, {DateTime? savedAt}) => Bookmark(
      id: id,
      sentence: 'Test sentence ${id}',
      sourceTitle: 'Test Source',
      audioPath: '/test/audio.mp3',
      savedAt: savedAt ?? DateTime(2024, 1, 15, 12, 0, 0),
    );

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('BookmarkService', () {
    late BookmarkService service;

    setUp(() {
      service = BookmarkService();
    });

    test('loadAll returns empty list when no data stored', () async {
      final result = await service.loadAll();
      expect(result, isEmpty);
    });

    test('add bookmark then loadAll returns it', () async {
      final bm = _makeBookmark('bm1');
      final added = await service.add(bm);
      expect(added, isTrue);
      final list = await service.loadAll();
      expect(list.length, 1);
      expect(list.first.id, 'bm1');
    });

    test('add duplicate bookmark returns false and does not duplicate', () async {
      final bm = _makeBookmark('bm1');
      await service.add(bm);
      final added = await service.add(bm);
      expect(added, isFalse);
      final list = await service.loadAll();
      expect(list.length, 1);
    });

    test('remove deletes bookmark by id', () async {
      await service.add(_makeBookmark('bm1'));
      await service.remove('bm1');
      expect(await service.loadAll(), isEmpty);
    });

    test('remove non-existent id is a no-op', () async {
      await service.add(_makeBookmark('bm1'));
      await service.remove('bm999');
      expect((await service.loadAll()).length, 1);
    });

    test('isBookmarked returns true for existing bookmark', () async {
      await service.add(_makeBookmark('bm1'));
      expect(await service.isBookmarked('bm1'), isTrue);
    });

    test('isBookmarked returns false for missing bookmark', () async {
      expect(await service.isBookmarked('bm_missing'), isFalse);
    });

    test('updateNote persists note text', () async {
      await service.add(_makeBookmark('bm1'));
      await service.updateNote('bm1', 'My personal note');
      final list = await service.loadAll();
      expect(list.first.note, 'My personal note');
    });

    test('updateNote on non-existent id is a no-op', () async {
      await service.add(_makeBookmark('bm1'));
      await service.updateNote('bm999', 'Note');
      final list = await service.loadAll();
      expect(list.first.note, isNull);
    });

    test('loadAll sorts newest savedAt first', () async {
      final older = _makeBookmark('old', savedAt: DateTime(2024, 1, 1));
      final newer = _makeBookmark('new', savedAt: DateTime(2024, 6, 1));
      await service.add(older);
      await service.add(newer);
      final list = await service.loadAll();
      expect(list.first.id, 'new');
      expect(list.last.id, 'old');
    });

    test('bookmark with startTime round-trips through JSON', () async {
      final bm = Bookmark(
        id: 'bm_time',
        sentence: 'timed',
        sourceTitle: 'src',
        audioPath: '/a.mp3',
        savedAt: DateTime(2024, 3, 1),
        startTime: const Duration(milliseconds: 12345),
      );
      await service.add(bm);
      final loaded = (await service.loadAll()).first;
      expect(loaded.startTime, const Duration(milliseconds: 12345));
    });
  });
}
