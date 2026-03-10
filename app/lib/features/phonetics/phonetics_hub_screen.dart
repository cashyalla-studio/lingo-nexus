import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lingo_nexus/generated/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;

    final tools = [
      _PhoneticsTool(
        icon: Icons.quiz,
        title: l10n.phoneticsQuizTitle,
        description: l10n.phoneticsQuizDesc,
        color: Colors.deepPurple,
        onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const PhoneticsQuizScreen())),
      ),
      _PhoneticsTool(
        icon: Icons.volume_up,
        title: l10n.phoneticsTtsPracticeTitle,
        description: l10n.phoneticsTtsPracticeDesc,
        color: const Color(0xFF00FFD1),
        onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const TtsPracticeScreen())),
      ),
      _PhoneticsTool(
        icon: Icons.compare_arrows,
        title: l10n.statsMinimalPair,
        description: l10n.phoneticsMinimalPairDesc,
        color: Colors.orange,
        onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const MinimalPairScreen())),
      ),
      _PhoneticsTool(
        icon: Icons.graphic_eq,
        title: l10n.phoneticsPitchAccentTitle,
        description: l10n.phoneticsPitchAccentDesc,
        color: Colors.purple,
        onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const PitchAccentScreen())),
      ),
      _PhoneticsTool(
        icon: Icons.translate,
        title: l10n.phoneticsKanaDrillTitle,
        description: l10n.phoneticsKanaDrillDesc,
        color: Colors.blue,
        onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const KanaDrillScreen())),
      ),
    ];

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.homePhoneticsHub),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
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
                        Text(l10n.phoneticsHubFreeTitle,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(l10n.phoneticsHubFreeSubtitle,
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

            Text(l10n.phoneticsHubTrainingTools,
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
            Text(l10n.phoneticsComingSoon,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            ...[
              (l10n.phoneticsSpanishIpa, l10n.phoneticsSpanishIpaSubtitle, Icons.language),
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
                      child: Text(l10n.phoneticsComingSoon,
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
