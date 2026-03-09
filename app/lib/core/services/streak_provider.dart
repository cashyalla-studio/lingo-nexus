import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'streak_service.dart';
import 'journal_service.dart';

final streakServiceProvider = Provider((ref) => StreakService());
final journalServiceProvider = Provider((ref) => JournalService());

final streakDataProvider = FutureProvider<StreakData>((ref) async {
  final service = ref.watch(streakServiceProvider);
  return service.getStreakData();
});

final journalEntriesProvider = FutureProvider<List<JournalEntry>>((ref) async {
  final service = ref.watch(journalServiceProvider);
  return service.loadAll();
});
