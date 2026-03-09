import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/subscription_service.dart';
import 'subscription_provider.dart';

class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tierAsync = ref.watch(subscriptionTierProvider);
    final aiUsedAsync = ref.watch(aiCallsUsedProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('구독 관리'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Status
            tierAsync.when(
              data: (tier) => Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: tier == SubscriptionTier.pro
                        ? [const Color(0xFF00FFD1), const Color(0xFF0080FF)]
                        : [theme.colorScheme.surfaceContainerHighest, theme.colorScheme.surface],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          tier == SubscriptionTier.pro ? Icons.workspace_premium : Icons.person_outline,
                          color: tier == SubscriptionTier.pro ? Colors.black : theme.colorScheme.primary,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          tier == SubscriptionTier.pro ? 'Pro 플랜' : 'Free 플랜',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: tier == SubscriptionTier.pro ? Colors.black : theme.colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (tier == SubscriptionTier.free) ...[
                      const SizedBox(height: 12),
                      aiUsedAsync.when(
                        data: (used) => Text(
                          'AI 사용량: $used / ${SubscriptionService.freeAiCallsPerMonth}회 (이번 달)',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                    ],
                  ],
                ),
              ),
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            const SizedBox(height: 32),

            // Pro Features
            Text('Pro 플랜 혜택', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            ..._proFeatures.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00FFD1).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(f['icon'] as IconData, color: const Color(0xFF00FFD1), size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(f['title'] as String, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                        Text(f['desc'] as String, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                ],
              ),
            )),

            const SizedBox(height: 32),

            // Pricing
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF00FFD1).withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Text('월간 구독', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('₩9,900 / 월', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF00FFD1))),
                  const SizedBox(height: 4),
                  Text('연간 구독 시 ₩89,000 (25% 할인)',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00FFD1),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () => _showUpgradeDialog(context, ref),
                      child: const Text('Pro로 업그레이드', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            Center(
              child: Text(
                '결제 시스템은 곧 연동됩니다',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUpgradeDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pro 업그레이드'),
        content: const Text('결제 시스템이 준비 중입니다.\n현재는 개발자 모드로 Pro를 활성화할 수 있습니다.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
          TextButton(
            onPressed: () async {
              final service = ref.read(subscriptionServiceProvider);
              await service.setTier(SubscriptionTier.pro);
              ref.invalidate(subscriptionTierProvider);
              ref.invalidate(aiCallsUsedProvider);
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pro 플랜이 활성화되었습니다!'),
                    backgroundColor: Color(0xFF00FFD1)),
                );
              }
            },
            child: const Text('개발자 모드 활성화'),
          ),
        ],
      ),
    );
  }

  static final List<Map<String, dynamic>> _proFeatures = [
    {'icon': Icons.auto_awesome, 'title': 'AI 튜터 무제한', 'desc': '문법 설명, 어휘, 대화 연습 제한 없이'},
    {'icon': Icons.mic, 'title': '발음 연습 무제한', 'desc': '월 10회 제한 없이 Whisper로 채점'},
    {'icon': Icons.sync, 'title': 'Whisper 자동 동기화', 'desc': '정밀한 문장 단위 타임스탬프 생성'},
    {'icon': Icons.cloud_sync, 'title': '클라우드 백업', 'desc': '학습 데이터 iCloud/Drive 자동 백업'},
    {'icon': Icons.bar_chart, 'title': '고급 통계', 'desc': '상세 발음 성장 분석 및 리포트'},
  ];
}
