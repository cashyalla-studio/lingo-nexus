import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../scanner/scanner_provider.dart';
import '../shadowing/shadow_deck_provider.dart';
import '../shadowing/shadowing_provider.dart';
import '../../core/services/streak_provider.dart';

class StudyStats {
  final int totalShadowingSessions;
  final int masteredSentences; // shadow deck bestScore >= 90
  final int currentStreak;
  final List<int> recentScores; // last 10 pronunciation scores
  final Map<String, int> languageDistribution; // language code -> count
  final int todayMinutes; // today's studied minutes from journal

  const StudyStats({
    required this.totalShadowingSessions,
    required this.masteredSentences,
    required this.currentStreak,
    required this.recentScores,
    required this.languageDistribution,
    required this.todayMinutes,
  });
}

final studyStatsProvider = FutureProvider<StudyStats>((ref) async {
  // Load streak
  final streak = await ref.watch(streakDataProvider.future);

  // Load shadow deck for mastered sentences (bestScore >= 90)
  final deckAsync = ref.watch(shadowDeckProvider);
  final deckItems = deckAsync.value ?? [];
  final masteredSentences = deckItems.where((e) => e.bestScore >= 90).length;

  // Load pronunciation history for recent scores & session count
  final historyService = ref.watch(pronunciationHistoryServiceProvider);
  final allHistory = await historyService.loadAll();
  allHistory.sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
  final recentScores = allHistory.take(10).map((e) => e.score).toList();
  final totalShadowingSessions = allHistory.length;

  // Load study items for language distribution
  final itemsAsync = ref.watch(studyItemsProvider);
  final items = itemsAsync.value ?? [];
  final languageDistribution = <String, int>{};
  for (final item in items) {
    final lang = item.language ?? 'other';
    languageDistribution[lang] = (languageDistribution[lang] ?? 0) + 1;
  }

  // Get today's minutes from journal
  final journalService = ref.watch(journalServiceProvider);
  final todayEntry = await journalService.getTodayEntry();
  final todayMinutes = todayEntry?.minutesStudied ?? 0;

  return StudyStats(
    totalShadowingSessions: totalShadowingSessions,
    masteredSentences: masteredSentences,
    currentStreak: streak.current,
    recentScores: recentScores,
    languageDistribution: languageDistribution,
    todayMinutes: todayMinutes,
  );
});
