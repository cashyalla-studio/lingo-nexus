import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lingo_nexus/generated/l10n/app_localizations.dart';
import '../scanner/scanner_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/pronunciation_history_service.dart';
import '../../core/services/streak_provider.dart';
import '../shadowing/shadowing_provider.dart';
import '../minimal_pair/minimal_pair_screen.dart';
import 'learning_heatmap.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final itemsAsync = ref.watch(studyItemsProvider);
    // Reference the provider to make it available
    final historyService = ref.watch(pronunciationHistoryServiceProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.stats,
                  style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                itemsAsync.when(
                  data: (items) {
                    final studiedItems = items.where((i) => i.lastPlayedAt != null).toList();
                    final completedCount = items.where((i) => i.isCompleted).length;
                    final totalMinutes = studiedItems.fold<int>(
                      0, (sum, i) => sum + i.lastPosition.inMinutes);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Summary row
                        Row(
                          children: [
                            Expanded(child: _StatCard(
                              icon: Icons.headphones,
                              label: '학습한 콘텐츠',
                              value: '${studiedItems.length}개',
                              theme: theme,
                            )),
                            const SizedBox(width: 12),
                            Expanded(child: _StatCard(
                              icon: Icons.check_circle,
                              label: '완료',
                              value: '$completedCount개',
                              theme: theme,
                              color: AppTheme.success,
                            )),
                            const SizedBox(width: 12),
                            Expanded(child: _StatCard(
                              icon: Icons.timer,
                              label: '총 학습시간',
                              value: '$totalMinutes분',
                              theme: theme,
                            )),
                          ],
                        ),
                        const SizedBox(height: 32),

                        if (studiedItems.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(40.0),
                              child: Column(
                                children: [
                                  Icon(Icons.bar_chart_outlined, size: 64,
                                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
                                  const SizedBox(height: 16),
                                  Text('아직 학습 기록이 없습니다.\n라이브러리에서 콘텐츠를 추가해보세요.',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant),
                                    textAlign: TextAlign.center),
                                ],
                              ),
                            ),
                          )
                        else ...[
                          Text('학습 항목별 진도',
                            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 16),
                          ...studiedItems.map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        item.isCompleted ? Icons.check_circle : Icons.headphones,
                                        color: item.isCompleted ? AppTheme.success : theme.colorScheme.primary,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(item.title,
                                          style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                                          maxLines: 1, overflow: TextOverflow.ellipsis),
                                      ),
                                      Text(
                                        item.isCompleted ? '완료' : '${(item.progressRatio * 100).toInt()}%',
                                        style: theme.textTheme.labelMedium?.copyWith(
                                          color: item.isCompleted ? AppTheme.success : theme.colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: item.progressRatio,
                                      backgroundColor: theme.colorScheme.outline.withValues(alpha: 0.3),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        item.isCompleted ? AppTheme.success : theme.colorScheme.primary),
                                      minHeight: 6,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )),
                          // Pronunciation improvement section
                          const SizedBox(height: 32),
                          Text('발음 향상 현황',
                            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 16),
                          FutureBuilder<List<Map<String, dynamic>>>(
                            future: historyService.getRecentProgress(),
                            builder: (ctx, snapshot) {
                              if (!snapshot.hasData) return const SizedBox.shrink();
                              final progress = snapshot.data!;
                              if (progress.isEmpty) {
                                return Text('쉐도잉 연습을 완료하면 발음 향상 기록이 여기에 표시됩니다.',
                                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant));
                              }
                              return Column(
                                children: progress.take(5).map((p) {
                                  final improvement = p['improvement'] as int;
                                  final improvementColor = improvement > 0 ? AppTheme.success
                                      : improvement < 0 ? AppTheme.danger
                                      : theme.colorScheme.onSurfaceVariant;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.surfaceContainerHighest,
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(p['sentence'] as String,
                                                  style: theme.textTheme.bodyMedium,
                                                  maxLines: 1, overflow: TextOverflow.ellipsis),
                                                Text('${p["attempts"]}회 연습',
                                                  style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            '${improvement > 0 ? "+" : ""}$improvement점',
                                            style: theme.textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold, color: improvementColor),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                          // Streak & Heatmap Section
                          const SizedBox(height: 32),
                          Text('학습 스트릭',
                            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 16),
                          Consumer(builder: (ctx, ref, _) {
                            final streakAsync = ref.watch(streakDataProvider);
                            return streakAsync.when(
                              data: (streak) => Row(
                                children: [
                                  Expanded(child: _StatCard(
                                    icon: Icons.local_fire_department,
                                    label: '연속 학습',
                                    value: '${streak.current}일',
                                    theme: theme,
                                    color: const Color(0xFFFF6B00),
                                  )),
                                  const SizedBox(width: 12),
                                  Expanded(child: _StatCard(
                                    icon: Icons.emoji_events,
                                    label: '최장 스트릭',
                                    value: '${streak.longest}일',
                                    theme: theme,
                                  )),
                                  const SizedBox(width: 12),
                                  Expanded(child: _StatCard(
                                    icon: Icons.calendar_today,
                                    label: '총 학습일',
                                    value: '${streak.totalDays}일',
                                    theme: theme,
                                  )),
                                ],
                              ),
                              loading: () => const SizedBox.shrink(),
                              error: (_, __) => const SizedBox.shrink(),
                            );
                          }),
                          const SizedBox(height: 24),
                          Consumer(builder: (ctx, ref, _) {
                            final journalAsync = ref.watch(journalEntriesProvider);
                            return journalAsync.when(
                              data: (entries) => LearningHeatmap(entries: entries),
                              loading: () => const SizedBox.shrink(),
                              error: (_, __) => const SizedBox.shrink(),
                            );
                          }),
                          const SizedBox(height: 32),
                          GestureDetector(
                            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => const MinimalPairScreen())),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(Icons.hearing, color: theme.colorScheme.primary, size: 28),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('최소쌍 훈련', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                        Text('비슷한 소리 구별하기 (영어/일본어/스페인어)',
                                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                                      ],
                                    ),
                                  ),
                                  Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ],
                    );
                  },
                  loading: () => const Center(child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(),
                  )),
                  error: (err, _) => Center(child: Text('오류: $err')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ThemeData theme;
  final Color? color;

  const _StatCard({required this.icon, required this.label, required this.value, required this.theme, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? theme.colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: c, size: 28),
          const SizedBox(height: 8),
          Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: c)),
          const SizedBox(height: 4),
          Text(label, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
