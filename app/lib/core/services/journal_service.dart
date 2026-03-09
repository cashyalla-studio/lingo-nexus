import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// 자동으로 일별 학습 일지를 생성 및 저장합니다.
class JournalService {
  static const String _keyJournal = 'journal_entries';

  Future<List<JournalEntry>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyJournal);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => JournalEntry.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<JournalEntry?> getTodayEntry() async {
    final all = await loadAll();
    final today = _dateKey(DateTime.now());
    try {
      return all.firstWhere((e) => e.dateKey == today);
    } catch (_) {
      return null;
    }
  }

  Future<JournalEntry> recordActivity({
    required String studiedTitle,
    int sentencesShadowed = 0,
    int minutesStudied = 0,
    int pronunciationScore = 0,
  }) async {
    final all = await loadAll();
    final today = _dateKey(DateTime.now());

    JournalEntry? existing;
    try {
      existing = all.firstWhere((e) => e.dateKey == today);
    } catch (_) {}

    JournalEntry updated;
    if (existing != null) {
      updated = existing.copyWith(
        studiedTitles: {...existing.studiedTitles, studiedTitle}.toList(),
        sentencesShadowed: existing.sentencesShadowed + sentencesShadowed,
        minutesStudied: existing.minutesStudied + minutesStudied,
        bestPronunciationScore: pronunciationScore > existing.bestPronunciationScore
            ? pronunciationScore
            : existing.bestPronunciationScore,
      );
      all.removeWhere((e) => e.dateKey == today);
    } else {
      updated = JournalEntry(
        dateKey: today,
        date: DateTime.now(),
        studiedTitles: [studiedTitle],
        sentencesShadowed: sentencesShadowed,
        minutesStudied: minutesStudied,
        bestPronunciationScore: pronunciationScore,
      );
    }

    all.insert(0, updated);
    // 최대 90일 보관
    final trimmed = all.take(90).toList();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyJournal, jsonEncode(trimmed.map((e) => e.toJson()).toList()));
    return updated;
  }

  String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

class JournalEntry {
  final String dateKey;
  final DateTime date;
  final List<String> studiedTitles;
  final int sentencesShadowed;
  final int minutesStudied;
  final int bestPronunciationScore;

  const JournalEntry({
    required this.dateKey,
    required this.date,
    required this.studiedTitles,
    required this.sentencesShadowed,
    required this.minutesStudied,
    required this.bestPronunciationScore,
  });

  JournalEntry copyWith({
    List<String>? studiedTitles,
    int? sentencesShadowed,
    int? minutesStudied,
    int? bestPronunciationScore,
  }) => JournalEntry(
    dateKey: dateKey,
    date: date,
    studiedTitles: studiedTitles ?? this.studiedTitles,
    sentencesShadowed: sentencesShadowed ?? this.sentencesShadowed,
    minutesStudied: minutesStudied ?? this.minutesStudied,
    bestPronunciationScore: bestPronunciationScore ?? this.bestPronunciationScore,
  );

  String get formattedDate {
    final months = ['1월', '2월', '3월', '4월', '5월', '6월', '7월', '8월', '9월', '10월', '11월', '12월'];
    return '${date.year}년 ${months[date.month - 1]} ${date.day}일';
  }

  String get summary {
    if (studiedTitles.isEmpty) return '학습 기록 없음';
    final titles = studiedTitles.take(2).join(', ');
    final extra = studiedTitles.length > 2 ? ' 외 ${studiedTitles.length - 2}개' : '';
    return '$titles$extra 학습';
  }

  factory JournalEntry.fromJson(Map<String, dynamic> json) => JournalEntry(
    dateKey: json['dateKey'] as String,
    date: DateTime.parse(json['date'] as String),
    studiedTitles: List<String>.from(json['studiedTitles'] as List),
    sentencesShadowed: (json['sentencesShadowed'] as int?) ?? 0,
    minutesStudied: (json['minutesStudied'] as int?) ?? 0,
    bestPronunciationScore: (json['bestPronunciationScore'] as int?) ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'dateKey': dateKey,
    'date': date.toIso8601String(),
    'studiedTitles': studiedTitles,
    'sentencesShadowed': sentencesShadowed,
    'minutesStudied': minutesStudied,
    'bestPronunciationScore': bestPronunciationScore,
  };
}
