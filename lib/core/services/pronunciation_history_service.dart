import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pronunciation_history_entry.dart';

class PronunciationHistoryService {
  static const String _key = 'pronunciation_history';
  static const int _maxEntriesPerSentence = 20;

  Future<List<PronunciationHistoryEntry>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => PronunciationHistoryEntry.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> addEntry(PronunciationHistoryEntry entry) async {
    final all = await loadAll();
    all.add(entry);
    // Keep only last N entries per sentence to avoid unbounded growth
    final grouped = <String, List<PronunciationHistoryEntry>>{};
    for (final e in all) {
      grouped.putIfAbsent(e.sentenceId, () => []).add(e);
    }
    final trimmed = <PronunciationHistoryEntry>[];
    for (final entries in grouped.values) {
      entries.sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
      trimmed.addAll(entries.length > _maxEntriesPerSentence
          ? entries.sublist(entries.length - _maxEntriesPerSentence)
          : entries);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(trimmed.map((e) => e.toJson()).toList()));
  }

  Future<List<PronunciationHistoryEntry>> getHistoryForSentence(String sentenceId) async {
    final all = await loadAll();
    return all.where((e) => e.sentenceId == sentenceId).toList()
      ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
  }

  /// Returns sentences practiced in the last N days with their latest score and improvement
  Future<List<Map<String, dynamic>>> getRecentProgress({int days = 30}) async {
    final all = await loadAll();
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final recent = all.where((e) => e.recordedAt.isAfter(cutoff)).toList();

    final grouped = <String, List<PronunciationHistoryEntry>>{};
    for (final e in recent) {
      grouped.putIfAbsent(e.sentenceId, () => []).add(e);
    }

    final result = <Map<String, dynamic>>[];
    for (final entry in grouped.entries) {
      final sorted = entry.value..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
      final first = sorted.first.score;
      final latest = sorted.last.score;
      result.add({
        'sentenceId': entry.key,
        'sentence': sorted.last.sentence,
        'firstScore': first,
        'latestScore': latest,
        'improvement': latest - first,
        'attempts': sorted.length,
        'history': sorted,
      });
    }
    result.sort((a, b) => (b['improvement'] as int).compareTo(a['improvement'] as int));
    return result;
  }
}
