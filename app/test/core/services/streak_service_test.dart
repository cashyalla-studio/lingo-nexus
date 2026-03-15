import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lingo_nexus/core/services/streak_service.dart';

String _dk(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

void main() {
  group('StreakService', () {
    late StreakService service;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      service = StreakService();
    });

    test('recordStudyToday first time -> streak becomes 1', () async {
      final data = await service.recordStudyToday();
      expect(data.current, 1);
      expect(data.longest, 1);
      expect(data.totalDays, 1);
    });

    test('recordStudyToday same day twice -> idempotent streak stays 1', () async {
      await service.recordStudyToday();
      final data = await service.recordStudyToday();
      expect(data.current, 1);
      expect(data.totalDays, 1);
    });

    test('recordStudyToday after 2-day gap -> streak resets to 1', () async {
      final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
      SharedPreferences.setMockInitialValues({
        'streak_current': 5,
        'streak_longest': 5,
        'streak_total_days': 5,
        'streak_last_date': _dk(twoDaysAgo),
      });
      final data = await service.recordStudyToday();
      expect(data.current, 1);
    });

    test('recordStudyToday consecutive days -> streak increments', () async {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      SharedPreferences.setMockInitialValues({
        'streak_current': 2,
        'streak_longest': 2,
        'streak_total_days': 2,
        'streak_last_date': _dk(yesterday),
      });
      final data = await service.recordStudyToday();
      expect(data.current, 3);
    });

    test('getStreakData with no data -> returns zeros', () async {
      final data = await service.getStreakData();
      expect(data.current, 0);
      expect(data.longest, 0);
      expect(data.totalDays, 0);
    });

    test('getStreakData with stale date -> current streak 0', () async {
      final stale = DateTime.now().subtract(const Duration(days: 3));
      SharedPreferences.setMockInitialValues({
        'streak_current': 7,
        'streak_longest': 7,
        'streak_total_days': 10,
        'streak_last_date': _dk(stale),
      });
      final data = await service.getStreakData();
      expect(data.current, 0);
      expect(data.longest, 7);
    });

    test('longest streak updates when current exceeds it', () async {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      SharedPreferences.setMockInitialValues({
        'streak_current': 4,
        'streak_longest': 4,
        'streak_total_days': 10,
        'streak_last_date': _dk(yesterday),
      });
      final data = await service.recordStudyToday();
      expect(data.current, 5);
      expect(data.longest, 5);
    });

    test('longest streak does not decrease when existing record is higher', () async {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      SharedPreferences.setMockInitialValues({
        'streak_current': 3,
        'streak_longest': 10,
        'streak_total_days': 20,
        'streak_last_date': _dk(yesterday),
      });
      final data = await service.recordStudyToday();
      expect(data.current, 4);
      expect(data.longest, 10);
    });

    test('totalDays increments on each new study day', () async {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      SharedPreferences.setMockInitialValues({
        'streak_current': 2,
        'streak_longest': 2,
        'streak_total_days': 5,
        'streak_last_date': _dk(yesterday),
      });
      final data = await service.recordStudyToday();
      expect(data.totalDays, 6);
    });
  });
}
