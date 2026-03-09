import 'package:shared_preferences/shared_preferences.dart';

/// 연속 학습 스트릭을 추적합니다.
class StreakService {
  static const String _keyCurrentStreak = 'streak_current';
  static const String _keyLastStudyDate = 'streak_last_date';
  static const String _keyLongestStreak = 'streak_longest';
  static const String _keyTotalStudyDays = 'streak_total_days';

  /// 오늘 학습 기록을 등록하고 스트릭을 업데이트합니다.
  Future<StreakData> recordStudyToday() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _dateKey(DateTime.now());
    final lastDateStr = prefs.getString(_keyLastStudyDate);

    int current = prefs.getInt(_keyCurrentStreak) ?? 0;
    int longest = prefs.getInt(_keyLongestStreak) ?? 0;
    int totalDays = prefs.getInt(_keyTotalStudyDays) ?? 0;

    if (lastDateStr == today) {
      // 오늘 이미 기록됨 — 스트릭 유지
      return StreakData(current: current, longest: longest, totalDays: totalDays);
    }

    final yesterday = _dateKey(DateTime.now().subtract(const Duration(days: 1)));

    if (lastDateStr == yesterday) {
      // 어제 학습 — 스트릭 연장
      current++;
    } else if (lastDateStr == null) {
      // 첫 학습
      current = 1;
    } else {
      // 스트릭 끊김 — 새로 시작
      current = 1;
    }

    if (current > longest) longest = current;
    totalDays++;

    await prefs.setInt(_keyCurrentStreak, current);
    await prefs.setInt(_keyLongestStreak, longest);
    await prefs.setInt(_keyTotalStudyDays, totalDays);
    await prefs.setString(_keyLastStudyDate, today);

    return StreakData(current: current, longest: longest, totalDays: totalDays);
  }

  Future<StreakData> getStreakData() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _dateKey(DateTime.now());
    final yesterday = _dateKey(DateTime.now().subtract(const Duration(days: 1)));
    final lastDateStr = prefs.getString(_keyLastStudyDate);

    int current = prefs.getInt(_keyCurrentStreak) ?? 0;
    final longest = prefs.getInt(_keyLongestStreak) ?? 0;
    final totalDays = prefs.getInt(_keyTotalStudyDays) ?? 0;

    // 어제도 오늘도 학습 안 했으면 스트릭 끊김
    if (lastDateStr != null && lastDateStr != today && lastDateStr != yesterday) {
      current = 0;
      await prefs.setInt(_keyCurrentStreak, 0);
    }

    return StreakData(current: current, longest: longest, totalDays: totalDays);
  }

  String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

class StreakData {
  final int current;
  final int longest;
  final int totalDays;
  const StreakData({required this.current, required this.longest, required this.totalDays});
}
