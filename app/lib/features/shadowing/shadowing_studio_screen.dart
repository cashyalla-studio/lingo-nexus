import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lingo_nexus/generated/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/shadow_deck_item.dart';
import '../player/widgets/animated_waveform.dart';
import '../player/player_provider.dart';
import 'shadowing_provider.dart';
import 'shadow_deck_provider.dart';

class ShadowingStudioScreen extends ConsumerStatefulWidget {
  final String originalText;
  final String? audioPath;         // optional: specific audio file for this sentence
  final Duration? startTime;       // optional: segment start
  final Duration? endTime;         // optional: segment end
  final String? deckItemId;        // optional: if reviewing a deck item
  final String? language;          // optional: language code e.g. 'en', 'ja', 'ko'

  const ShadowingStudioScreen({
    super.key,
    this.originalText = "This is a sample sentence for shadowing practice.",
    this.audioPath,
    this.startTime,
    this.endTime,
    this.deckItemId,
    this.language,
  });

  @override
  ConsumerState<ShadowingStudioScreen> createState() =>
      _ShadowingStudioScreenState();
}

class _ShadowingStudioScreenState extends ConsumerState<ShadowingStudioScreen> {
  @override
  void initState() {
    super.initState();
    // Load history for this sentence
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(shadowingProvider.notifier).loadHistoryForSentence(widget.originalText);
    });
  }

  Future<void> _handleRecordButton() async {
    final notifier = ref.read(shadowingProvider.notifier);
    final state = ref.read(shadowingProvider);

    if (state == ShadowingState.idle) {
      await notifier.startRecording();
    } else if (state == ShadowingState.recording) {
      await notifier.stopRecording();
      await notifier.scoreRecording(widget.originalText, widget.language);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final shadowingState = ref.watch(shadowingProvider);
    final notifier = ref.read(shadowingProvider.notifier);

    final isRecording = shadowingState == ShadowingState.recording;
    final isProcessing = shadowingState == ShadowingState.processing;
    final isDone = shadowingState == ShadowingState.done;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.shadowingStudio,
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top Section: Native Speaker (Original)
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  border: Border(
                      bottom: BorderSide(
                          color: theme.colorScheme.outline
                              .withValues(alpha: 0.5))),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.shadowingNativeSpeaker,
                      style: theme.textTheme.labelMedium
                          ?.copyWith(color: theme.colorScheme.primary),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.originalText,
                      style:
                          theme.textTheme.titleLarge?.copyWith(height: 1.5),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 60,
                      child: AnimatedWaveform(
                          color: theme.colorScheme.primary, isPlaying: true),
                    ),
                  ],
                ),
              ),
            ),

            // 2. Bottom Section: User Recording & Assessment
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      l10n.shadowingYourTurn,
                      style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 16),

                    if (shadowingState == ShadowingState.idle)
                      Expanded(
                        child: Center(
                          child: Text(
                            "Tap the microphone to start shadowing.",
                            style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ),
                      )
                    else if (shadowingState == ShadowingState.recording)
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              l10n.listening,
                              style: theme.textTheme.titleLarge
                                  ?.copyWith(color: AppTheme.danger),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              height: 60,
                              child: AnimatedWaveform(
                                  color: AppTheme.danger, isPlaying: true),
                            ),
                          ],
                        ),
                      )
                    else if (shadowingState == ShadowingState.processing)
                      const Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text('분석 중...'),
                            ],
                          ),
                        ),
                      )
                    else // ShadowingState.done
                      Expanded(
                        child: _buildDoneSection(theme, l10n),
                      ),

                    // Record Button
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: isProcessing ? null : _handleRecordButton,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isRecording
                              ? AppTheme.danger.withValues(alpha: 0.2)
                              : theme.colorScheme.primary.withValues(alpha: 0.1),
                          border: Border.all(
                            color: isRecording
                                ? AppTheme.danger
                                : theme.colorScheme.primary.withValues(alpha: 0.5),
                            width: 2,
                          ),
                          boxShadow: [
                            if (isRecording)
                              BoxShadow(
                                  color: AppTheme.danger.withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  spreadRadius: 5)
                          ],
                        ),
                        child: isProcessing
                            ? Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: CircularProgressIndicator(
                                    color: theme.colorScheme.primary,
                                    strokeWidth: 2),
                              )
                            : Icon(
                                isRecording ? Icons.stop : Icons.mic,
                                size: 32,
                                color: isRecording
                                    ? AppTheme.danger
                                    : theme.colorScheme.primary,
                              ),
                      ),
                    ),

                    if (isDone) ...[
                      const SizedBox(height: 8),
                      // Retry button (if more attempts allowed)
                      if (notifier.canRecordMore)
                        TextButton.icon(
                          onPressed: () => notifier.reset(),
                          icon: const Icon(Icons.mic, size: 18),
                          label: Text(l10n.shadowingRetry(
                            notifier.attempts.length,
                            ShadowingNotifier.maxAttempts,
                          )),
                        )
                      else
                        TextButton.icon(
                          onPressed: null,
                          icon: const Icon(Icons.block, size: 18),
                          label: Text(l10n.shadowingAttemptCount(
                            ShadowingNotifier.maxAttempts,
                          )),
                        ),
                      // New session button
                      TextButton.icon(
                        onPressed: () => notifier.newSession(),
                        icon: const Icon(Icons.refresh),
                        label: Text(l10n.shadowingNewSession),
                      ),
                      // Shadow Deck button
                      const SizedBox(height: 8),
                      if (widget.deckItemId == null)
                        Consumer(
                          builder: (context, ref, _) {
                            return ElevatedButton.icon(
                              onPressed: () async {
                                final n = ref.read(shadowingProvider.notifier);
                                final score = n.score;
                                if (score == null) return;

                                final item = ShadowDeckItem(
                                  id: '${widget.audioPath ?? "unknown"}_${widget.startTime?.inMilliseconds ?? 0}',
                                  sentence: widget.originalText,
                                  audioPath: widget.audioPath ?? '',
                                  startTime: widget.startTime ?? Duration.zero,
                                  endTime: widget.endTime ?? const Duration(seconds: 10),
                                  bestScore: score.accuracy,
                                  addedAt: DateTime.now(),
                                );

                                final added = await ref.read(shadowDeckProvider.notifier).addItem(item);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text(added ? 'Shadow Deck에 추가되었습니다!' : '이미 덱에 있는 문장입니다.'),
                                  ));
                                }
                              },
                              icon: const Icon(Icons.playlist_add),
                              label: const Text('Shadow Deck에 추가'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                                foregroundColor: theme.colorScheme.primary,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                                ),
                              ),
                            );
                          },
                        )
                      else
                        Consumer(
                          builder: (context, ref, _) {
                            return ElevatedButton.icon(
                              onPressed: () async {
                                final score = ref.read(shadowingProvider.notifier).score;
                                if (score != null && widget.deckItemId != null) {
                                  await ref.read(shadowDeckProvider.notifier).updateScore(widget.deckItemId!, score.accuracy);
                                }
                                if (context.mounted) Navigator.pop(context);
                              },
                              icon: const Icon(Icons.check),
                              label: const Text('복습 완료'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.success.withValues(alpha: 0.15),
                                foregroundColor: AppTheme.success,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                            );
                          },
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoneSection(ThemeData theme, AppLocalizations l10n) {
    final score = ref.read(shadowingProvider.notifier).score;
    final notifier = ref.read(shadowingProvider.notifier);
    final attempts = notifier.attempts;
    final playbackMode = ref.watch(comparisonPlaybackProvider);
    final shadowingNotifier = ref.read(shadowingProvider.notifier);

    Duration segmentStart;
    Duration segmentEnd;
    if (widget.startTime != null && widget.endTime != null) {
      segmentStart = widget.startTime!;
      segmentEnd = widget.endTime!;
    } else {
      final syncItems = ref.watch(currentSyncItemsProvider);
      final matchingSyncItem = syncItems.isNotEmpty
          ? syncItems.firstWhere(
              (s) => s.sentence.toLowerCase().contains(
                  widget.originalText.toLowerCase().substring(
                      0, widget.originalText.length.clamp(0, 20))),
              orElse: () => syncItems.first,
            )
          : null;
      segmentStart = matchingSyncItem?.startTime ?? Duration.zero;
      segmentEnd = matchingSyncItem?.endTime ?? const Duration(seconds: 10);
    }

    if (score == null) {
      return const Center(child: Text('결과가 없습니다.'));
    }

    // No API key / scoring not available
    if (score.accuracy == 0 &&
        score.intonation == 0 &&
        score.fluency == 0 &&
        score.recordedTranscription == null) {
      return SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline,
                color: theme.colorScheme.onSurfaceVariant, size: 40),
            const SizedBox(height: 12),
            Text(
              'API 키 없이는 채점이 제한됩니다',
              style: theme.textTheme.bodyLarge
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildComparisonSection(
              theme: theme,
              playbackMode: playbackMode,
              shadowingNotifier: shadowingNotifier,
              segmentStart: segmentStart,
              segmentEnd: segmentEnd,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // Attempts row (shown if more than 1 attempt)
          if (attempts.isNotEmpty)
            _buildAttemptsRow(theme, l10n, attempts),

          const SizedBox(height: 8),

          // Highlighted text: mark incorrect words
          if (score.incorrectWords.isNotEmpty &&
              score.recordedTranscription != null)
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: theme.textTheme.titleLarge?.copyWith(height: 1.5),
                children: widget.originalText.split(' ').map((word) {
                  final clean =
                      word.toLowerCase().replaceAll(RegExp(r'[^\w]'), '');
                  final isIncorrect = score.incorrectWords.contains(clean);
                  return TextSpan(
                    text: '$word ',
                    style: isIncorrect
                        ? TextStyle(
                            color: AppTheme.danger,
                            decoration: TextDecoration.underline,
                          )
                        : null,
                  );
                }).toList(),
              ),
            )
          else
            Text(
              widget.originalText,
              style: theme.textTheme.titleLarge?.copyWith(height: 1.5),
              textAlign: TextAlign.center,
            ),

          const SizedBox(height: 32),

          // Scoring Charts (show latest score)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildScoreCircle(l10n.accuracy, score.accuracy, theme),
              _buildScoreCircle(l10n.intonation, score.intonation, theme),
              _buildScoreCircle(l10n.fluency, score.fluency, theme),
            ],
          ),

          const SizedBox(height: 24),
          _buildComparisonSection(
            theme: theme,
            playbackMode: playbackMode,
            shadowingNotifier: shadowingNotifier,
            segmentStart: segmentStart,
            segmentEnd: segmentEnd,
          ),
          // Show history if more than 1 attempt
          Builder(builder: (ctx) {
            final history = ref.read(shadowingProvider.notifier).sentenceHistory;
            if (history.length < 2) return const SizedBox.shrink();

            final firstScore = history.first.score;
            final latestScore = history.last.score;
            final improvement = latestScore - firstScore;
            final improvementColor = improvement > 0 ? AppTheme.success
                : improvement < 0 ? AppTheme.danger
                : theme.colorScheme.onSurfaceVariant;

            return Column(
              children: [
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('내 발음 히스토리',
                        style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(children: [
                            Text('첫 시도', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                            Text('$firstScore점', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                          ]),
                          Icon(Icons.arrow_forward, color: improvementColor),
                          Column(children: [
                            Text('최근', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                            Text('$latestScore점', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: improvementColor)),
                          ]),
                          Column(children: [
                            Text('변화', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                            Text('${improvement > 0 ? "+" : ""}$improvement',
                              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: improvementColor)),
                          ]),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 40,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: history.map((e) {
                            final h = (e.score / 100 * 36).clamp(4.0, 36.0);
                            Color c;
                            if (e.score >= 90) c = AppTheme.success;
                            else if (e.score >= 70) c = theme.colorScheme.primary;
                            else c = AppTheme.danger;
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 1.5),
                                child: Container(
                                  height: h,
                                  decoration: BoxDecoration(
                                    color: c.withValues(alpha: 0.7),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('${history.length}회 연습',
                        style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAttemptsRow(
    ThemeData theme,
    AppLocalizations l10n,
    List<RecordingAttempt> attempts,
  ) {
    final notifier = ref.read(shadowingProvider.notifier);
    final bestScore = notifier.bestScore;
    bool isBest(RecordingAttempt a) =>
        bestScore != null && a.score.accuracy == bestScore.accuracy;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        alignment: WrapAlignment.center,
        children: attempts.map((attempt) {
          final score = attempt.score.accuracy;
          final best = isBest(attempt);
          Color chipColor;
          if (score >= 90) {
            chipColor = AppTheme.success;
          } else if (score >= 70) {
            chipColor = theme.colorScheme.primary;
          } else {
            chipColor = AppTheme.danger;
          }

          return GestureDetector(
            onTap: () => notifier.playAttemptRecording(attempt.path),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: chipColor.withValues(alpha: best ? 0.25 : 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: chipColor.withValues(alpha: best ? 0.8 : 0.4),
                  width: best ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${l10n.shadowingAttempt} ${attempt.attemptNumber}: $score점',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: chipColor,
                      fontWeight: best ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  if (best) ...[
                    const SizedBox(width: 3),
                    Icon(Icons.star, size: 12, color: chipColor),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildComparisonSection({
    required ThemeData theme,
    required ComparisonPlaybackMode playbackMode,
    required ShadowingNotifier shadowingNotifier,
    required Duration segmentStart,
    required Duration segmentEnd,
  }) {
    return Column(
      children: [
        Text(
          '발음 비교 듣기',
          style: theme.textTheme.labelLarge
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildPlaybackButton(
              context: context,
              icon: Icons.record_voice_over,
              label: '원본',
              isActive:
                  playbackMode == ComparisonPlaybackMode.playingOriginal,
              theme: theme,
              onTap: () {
                final audioPath = widget.audioPath ?? ref.read(currentStudyItemProvider)?.audioPath;
                if (audioPath == null || audioPath.isEmpty) return;
                shadowingNotifier.playOriginalSegment(
                    audioPath, segmentStart, segmentEnd);
              },
            ),
            const SizedBox(width: 12),
            _buildPlaybackButton(
              context: context,
              icon: Icons.mic,
              label: '내 발음',
              isActive:
                  playbackMode == ComparisonPlaybackMode.playingRecording,
              theme: theme,
              onTap: () => shadowingNotifier.playRecording(),
            ),
            const SizedBox(width: 12),
            _buildPlaybackButton(
              context: context,
              icon: Icons.compare_arrows,
              label: '순차 비교',
              isActive:
                  playbackMode == ComparisonPlaybackMode.playingOriginal ||
                      playbackMode ==
                          ComparisonPlaybackMode.playingRecording,
              theme: theme,
              onTap: () {
                final audioPath = widget.audioPath ?? ref.read(currentStudyItemProvider)?.audioPath;
                if (audioPath == null || audioPath.isEmpty) return;
                shadowingNotifier.playComparison(
                    audioPath, segmentStart, segmentEnd);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlaybackButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isActive,
    required ThemeData theme,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive
              ? theme.colorScheme.primary.withValues(alpha: 0.2)
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.5),
            width: isActive ? 1.5 : 1.0,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                      color:
                          theme.colorScheme.primary.withValues(alpha: 0.2),
                      blurRadius: 8)
                ]
              : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                fontSize: 11,
                fontWeight:
                    isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCircle(String label, int score, ThemeData theme) {
    Color scoreColor;
    if (score >= 90) {
      scoreColor = AppTheme.success;
    } else if (score >= 70) {
      scoreColor = theme.colorScheme.primary;
    } else {
      scoreColor = AppTheme.danger;
    }

    return Column(
      children: [
        SizedBox(
          width: 60,
          height: 60,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: score / 100,
                backgroundColor:
                    theme.colorScheme.outline.withValues(alpha: 0.3),
                valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                strokeWidth: 6,
              ),
              Center(
                child: Text(
                  "$score",
                  style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold, color: scoreColor),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(label,
            style: theme.textTheme.labelMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }
}
