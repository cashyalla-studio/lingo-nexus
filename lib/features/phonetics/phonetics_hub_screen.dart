import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../minimal_pair/minimal_pair_screen.dart';
import 'tts_practice_screen.dart';
import 'pitch_accent_screen.dart';
import 'kana_drill_screen.dart';
import 'phonetics_quiz_screen.dart';

class PhoneticsHubScreen extends ConsumerWidget {
  const PhoneticsHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final tools = [
      _PhoneticsTool(
        icon: Icons.quiz,
        title: '발음 퀴즈',
        description: 'IPA 발음기호 ↔ 단어 매칭 퀴즈\n스트릭 보너스 + 정확도 통계',
        color: Colors.deepPurple,
        onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const PhoneticsQuizScreen())),
      ),
      _PhoneticsTool(
        icon: Icons.volume_up,
        title: 'TTS 발음 연습',
        description: '단어를 듣고 IPA 발음기호와 함께 따라 말하기\nAPI 키 불필요 · 완전 무료',
        color: const Color(0xFF00FFD1),
        onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const TtsPracticeScreen())),
      ),
      _PhoneticsTool(
        icon: Icons.compare_arrows,
        title: '최소쌍 훈련',
        description: '비슷한 소리 구별하기 (ship vs sheep 등)\nTTS 듣기 + 발음 채점 포함',
        color: Colors.orange,
        onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const MinimalPairScreen())),
      ),
      _PhoneticsTool(
        icon: Icons.graphic_eq,
        title: '일본어 피치 악센트',
        description: '同音異義語의 높낮이 패턴 시각화 훈련\n예: はし(箸/橋/端) 구별하기',
        color: Colors.purple,
        onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const PitchAccentScreen())),
      ),
      _PhoneticsTool(
        icon: Icons.translate,
        title: '히라가나 · 가타카나 드릴',
        description: '모든 가나 문자를 탭하여 TTS 발음 청취\n50음도 전체 수록',
        color: Colors.blue,
        onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const KanaDrillScreen())),
      ),
    ];

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('발음 훈련 센터'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF00FFD1).withValues(alpha: 0.15),
                    theme.colorScheme.surface,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF00FFD1).withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00FFD1).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.record_voice_over,
                      color: Color(0xFF00FFD1), size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('AI 없이 발음 훈련',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('기기 TTS + 온디바이스 음성인식\nAPI 키 없이 무료로 사용 가능',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.5)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            Text('훈련 도구',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),

            ...tools.map((tool) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: tool.onTap,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: tool.color.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: tool.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(tool.icon, color: tool.color, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tool.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(tool.description,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                height: 1.5)),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right,
                        color: theme.colorScheme.onSurfaceVariant),
                    ],
                  ),
                ),
              ),
            )),

            const SizedBox(height: 28),

            // Coming soon section
            Text('준비 중',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            ...[
              ('스페인어 IPA', '스페인어 발음기호 + 연습 (준비 중)', Icons.language),
            ].map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(item.$3,
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                      size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.$1,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6))),
                          Text(item.$2,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4))),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.outline.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('준비 중',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5))),
                    ),
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _PhoneticsTool {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;
  const _PhoneticsTool({
    required this.icon, required this.title, required this.description,
    required this.color, required this.onTap,
  });
}
