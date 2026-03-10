import 'package:flutter/material.dart';
import 'package:lingo_nexus/generated/l10n/app_localizations.dart';
import '../../core/services/journal_service.dart';

/// GitHub 스타일의 연간 학습 열지도 위젯
class LearningHeatmap extends StatelessWidget {
  final List<JournalEntry> entries;

  const LearningHeatmap({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final activityMap = {for (final e in entries) e.dateKey: e.minutesStudied};

    final now = DateTime.now();
    const weeks = 15; // 약 15주(105일) 표시
    final startDate = now.subtract(const Duration(days: weeks * 7 - 1));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.heatmapTitle(weeks),
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(weeks, (weekIndex) {
              return Padding(
                padding: const EdgeInsets.only(right: 3),
                child: Column(
                  children: List.generate(7, (dayIndex) {
                    final date = startDate.add(Duration(days: weekIndex * 7 + dayIndex));
                    if (date.isAfter(now)) return const SizedBox(width: 14, height: 14);

                    final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                    final minutes = activityMap[dateKey] ?? 0;
                    final intensity = _getIntensity(minutes);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Tooltip(
                        message: minutes > 0
                            ? l10n.heatmapTooltip('${date.month}/${date.day}', minutes)
                            : '${date.month}/${date.day}: ${l10n.heatmapNoActivity}',
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: _getColor(theme, intensity),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(l10n.heatmapLess, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(width: 4),
            ...List.generate(5, (i) => Padding(
              padding: const EdgeInsets.only(left: 3),
              child: Container(
                width: 12, height: 12,
                decoration: BoxDecoration(
                  color: _getColor(theme, i),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            )),
            const SizedBox(width: 4),
            Text(l10n.heatmapMore, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ],
    );
  }

  int _getIntensity(int minutes) {
    if (minutes == 0) return 0;
    if (minutes < 5) return 1;
    if (minutes < 15) return 2;
    if (minutes < 30) return 3;
    return 4;
  }

  Color _getColor(ThemeData theme, int intensity) {
    const colors = [
      Color(0xFF1A1F27),   // 0: no activity
      Color(0xFF003D30),   // 1: minimal
      Color(0xFF00604A),   // 2: light
      Color(0xFF009970),   // 3: moderate
      Color(0xFF00FFD1),   // 4: high
    ];
    return colors[intensity.clamp(0, 4)];
  }
}
