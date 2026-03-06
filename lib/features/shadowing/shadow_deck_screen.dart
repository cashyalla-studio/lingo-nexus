import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'shadow_deck_provider.dart';
import '../../core/models/shadow_deck_item.dart';
import '../../core/theme/app_theme.dart';
import 'shadowing_studio_screen.dart';

class ShadowDeckScreen extends ConsumerWidget {
  const ShadowDeckScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final deckAsync = ref.watch(shadowDeckProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text('Shadow Deck', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: deckAsync.when(
        data: (items) {
          final dueItems = items.where((e) => e.isDue).toList();
          final upcomingItems = items.where((e) => !e.isDue).toList()
            ..sort((a, b) => a.nextReviewAt!.compareTo(b.nextReviewAt!));

          return Column(
            children: [
              // Due count banner
              if (dueItems.isNotEmpty)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary.withValues(alpha: 0.2),
                        theme.colorScheme.primary.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.notifications_active, color: theme.colorScheme.primary, size: 32),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('오늘 복습할 문장', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary)),
                            Text('${dueItems.length}개 준비됨', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _startReview(context, dueItems),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('시작'),
                      ),
                    ],
                  ),
                ),

              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.library_add_outlined, size: 64,
                              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
                            const SizedBox(height: 16),
                            Text('Shadow Deck이 비어있습니다.',
                              style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                            const SizedBox(height: 8),
                            Text('쉐도잉 연습 후 문장을 덱에 추가하세요.',
                              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                          ],
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          if (dueItems.isNotEmpty) ...[
                            _SectionHeader(title: '복습 예정 (${dueItems.length})', theme: theme, color: theme.colorScheme.primary),
                            ...dueItems.map((item) => _DeckItemTile(item: item, isDue: true, theme: theme, ref: ref)),
                          ],
                          if (upcomingItems.isNotEmpty) ...[
                            _SectionHeader(title: '학습 완료 (${upcomingItems.length})', theme: theme),
                            ...upcomingItems.map((item) => _DeckItemTile(item: item, isDue: false, theme: theme, ref: ref)),
                          ],
                          const SizedBox(height: 80),
                        ],
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류: $e')),
      ),
    );
  }

  void _startReview(BuildContext context, List<ShadowDeckItem> items) {
    if (items.isEmpty) return;
    final first = items.first;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ShadowingStudioScreen(
        originalText: first.sentence,
        audioPath: first.audioPath,
        startTime: first.startTime,
        endTime: first.endTime,
        deckItemId: first.id,
      ),
    ));
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final ThemeData theme;
  final Color? color;
  const _SectionHeader({required this.title, required this.theme, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(title, style: theme.textTheme.labelLarge?.copyWith(
        color: color ?? theme.colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w600,
      )),
    );
  }
}

class _DeckItemTile extends StatelessWidget {
  final ShadowDeckItem item;
  final bool isDue;
  final ThemeData theme;
  final WidgetRef ref;
  const _DeckItemTile({required this.item, required this.isDue, required this.theme, required this.ref});

  @override
  Widget build(BuildContext context) {
    Color scoreColor;
    if (item.bestScore >= 90) scoreColor = AppTheme.success;
    else if (item.bestScore >= 70) scoreColor = theme.colorScheme.primary;
    else scoreColor = AppTheme.danger;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: isDue ? Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)) : null,
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(shape: BoxShape.circle, color: scoreColor.withValues(alpha: 0.15)),
              child: Center(
                child: Text('${item.bestScore}', style: theme.textTheme.titleSmall?.copyWith(
                  color: scoreColor, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.sentence, style: theme.textTheme.bodyMedium,
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(
                    isDue ? '오늘 복습' : '${item.nextReviewAt!.difference(DateTime.now()).inDays}일 후 복습',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isDue ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: theme.colorScheme.onSurfaceVariant, size: 20),
              onPressed: () => ref.read(shadowDeckProvider.notifier).removeItem(item.id),
            ),
          ],
        ),
      ),
    );
  }
}
