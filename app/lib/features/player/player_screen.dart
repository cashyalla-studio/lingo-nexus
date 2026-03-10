import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lingo_nexus/generated/l10n/app_localizations.dart';
import 'package:just_audio/just_audio.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/bookmark.dart';
import '../bookmarks/bookmarks_provider.dart';
import '../bookmarks/bookmarks_screen.dart';
import '../scanner/scanner_provider.dart';
import '../credits/credits_screen.dart';
import '../tutor/ai_tutor_sheet.dart';
import '../scribe/scribe_mode_screen.dart';
import '../shadowing/shadowing_studio_screen.dart';
import '../vocabulary/vocabulary_sheet.dart';
import '../sync/auto_sync_setup_screen.dart';
import '../../core/models/sync_item.dart';
import '../clip/clip_editor_screen.dart';
import '../active_recall/active_recall_screen.dart';
import 'audio_engine.dart';
import 'player_provider.dart';
import 'widgets/animated_waveform.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  const PlayerScreen({super.key});

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  @override
  void dispose() {
    final engine = ref.read(audioEngineProvider);
    if (engine.player.playing) {
      engine.player.pause();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(progressTrackingProvider); // 진도 추적 활성화
    ref.watch(autoPlayNextProvider); // 자동 다음 곡 재생 활성화
    final engine = ref.watch(audioEngineProvider);
    
    final isPlayingAsync = ref.watch(isPlayingProvider);
    final isPlaying = isPlayingAsync.value ?? false;
    final speedAsync = ref.watch(playbackSpeedProvider);
    final speed = speedAsync.value ?? 1.0;
    final loopModeAsync = ref.watch(loopModeProvider);
    final loopMode = loopModeAsync.value ?? LoopMode.off;
    
    final currentItem = ref.watch(currentStudyItemProvider);
    final scriptAsync = ref.watch(currentScriptContentProvider);
    final syncItems = ref.watch(currentSyncItemsProvider);
    final activeIndex = ref.watch(activeSentenceIndexProvider);
    final shouldSuggestSpeedUp = ref.watch(speedUpgradeSuggestionProvider);

    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      drawer: const _StudyListDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        title: GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AutoSyncSetupScreen()),
            );
          },
          child: Column(
            children: [
              Text(
                currentItem?.title ?? l10n.selectFile,
                style: theme.textTheme.titleLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (currentItem != null)
                Text(
                  'Ready • Tap title for AI Sync',
                  style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary),
                ),
            ],
          ),
        ),
        centerTitle: true,
        actions: [
          if (currentItem != null)
            IconButton(
              icon: const Icon(Icons.content_cut_outlined),
              tooltip: l10n.playerClipEdit,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ClipEditorScreen(
                    item: currentItem,
                    syncItems: syncItems,
                  ),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.bookmarks_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const BookmarksScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.bolt_outlined),
            onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const CreditsScreen())),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = constraints.maxWidth > 600 ? constraints.maxWidth * 0.2 : 16.0;

          return Column(
            children: [
              // --- 1. Script Area ---
              Expanded(
                child: scriptAsync.when(
                  data: (text) {
                    if (currentItem == null) {
                      return _buildEmptyState(context);
                    }

                    if (currentItem.scriptPath == null) {
                      return _buildNoScriptState(context);
                    }

                    // 임시 문장 분리 로직 (추후 STT LRC로 교체)
                    final sentences = text.split(RegExp(r'(?<=[.!?])\s+')).where((s) => s.isNotEmpty).toList();
                    if (sentences.isEmpty) {
                      sentences.add(text);
                    }

                    return ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 24),
                      itemCount: sentences.length,
                      itemBuilder: (context, index) {
                        final hasSync = syncItems.isNotEmpty && index < syncItems.length;
                        return ScriptLine(
                          isActive: hasSync ? index == activeIndex : index == 0,
                          text: sentences[index].trim(),
                          timeCode: hasSync ? syncItems[index].formattedTime : "00:00",
                          onTap: hasSync ? () => engine.seek(syncItems[index].startTime) : () {},
                          onLongPress: () => _showAiMenu(context, sentences[index].trim(), theme, l10n),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Center(child: Text(l10n.playerError(err.toString()), style: TextStyle(color: theme.colorScheme.error))),
                ),
              ),

              // Speed upgrade suggestion banner
              if (shouldSuggestSpeedUp)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.speed, color: theme.colorScheme.primary, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.playerSpeedSuggestion,
                          style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          final engine = ref.read(audioEngineProvider);
                          final currentSpeed = ref.read(playbackSpeedProvider).value ?? 1.0;
                          // Round up to next increment: 0.75→1.0, 1.0→1.25, 1.25→1.5
                          final nextSpeed = currentSpeed < 1.0 ? 1.0 : currentSpeed < 1.25 ? 1.25 : 1.5;
                          engine.setSpeed(nextSpeed);
                          final item = ref.read(currentStudyItemProvider);
                          if (item != null) {
                            ref.read(progressServiceProvider).saveSpeed(item.audioPath, nextSpeed);
                          }
                        },
                        style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(40, 28)),
                        child: Text(l10n.playerSpeedIncrease),
                      ),
                    ],
                  ),
                ),

              // Real-time Waveform Rendering
              Container(
                height: 100,
                margin: const EdgeInsets.symmetric(vertical: 24),
                child: AnimatedWaveform(
                  color: theme.colorScheme.primary,
                  isPlaying: isPlaying,
                ),
              ),

              // --- 2. Bottom Player Bar ---
              PlayerBottomBar(
                horizontalPadding: horizontalPadding,
                engine: engine,
                isPlaying: isPlaying,
                speed: speed,
                loopMode: loopMode,
                hasItem: currentItem != null,
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAiMenu(BuildContext context, String text, ThemeData theme, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40, height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(l10n.selectedSentence, style: theme.textTheme.labelMedium),
                const SizedBox(height: 8),
                Text(
                  text, 
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                _buildMenuButton(context, Icons.auto_awesome, l10n.aiGrammarAnalysis, theme, () {
                  Navigator.pop(context);
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    useSafeArea: true,
                    builder: (context) => AiTutorBottomSheet(sentence: text),
                  );
                }),
                const SizedBox(height: 12),
                _buildMenuButton(context, Icons.menu_book, l10n.vocabularyHelper, theme, () {
                  Navigator.pop(context);
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    useSafeArea: true,
                    builder: (context) => VocabularyBottomSheet(
                      word: text,
                      contextSentence: text,
                    ),
                  );
                }),
                const SizedBox(height: 12),
                _buildMenuButton(context, Icons.draw_outlined, l10n.playerMenuDictation, theme, () {
                  Navigator.pop(context);
                  // Find the matching sync item for this sentence to get audio timing
                  final syncItems = ref.read(currentSyncItemsProvider);
                  final currentItem = ref.read(currentStudyItemProvider);

                  if (currentItem == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.playerSelectFileFirst)),
                    );
                    return;
                  }

                  // Find matching sync item (match by sentence content)
                  SyncItem? matchingSyncItem;
                  if (syncItems.isNotEmpty) {
                    try {
                      matchingSyncItem = syncItems.firstWhere(
                        (s) => s.sentence.toLowerCase().contains(
                          text.toLowerCase().substring(0, text.length.clamp(0, 15))),
                      );
                    } catch (_) {
                      matchingSyncItem = syncItems.isNotEmpty ? syncItems.first : null;
                    }
                  }

                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => ScribeModeScreen(
                      originalText: text,
                      audioPath: currentItem.audioPath,
                      startTime: matchingSyncItem?.startTime ?? Duration.zero,
                      endTime: matchingSyncItem?.endTime ?? const Duration(seconds: 10),
                    ),
                  ));
                }),
                const SizedBox(height: 12),
                _buildMenuButton(context, Icons.mic, l10n.shadowingStudio, theme, () {
                  Navigator.pop(context);
                  // Pass audio context so ShadowDeck can play and store the segment
                  final syncItemsForShadow = ref.read(currentSyncItemsProvider);
                  final currentItemForShadow = ref.read(currentStudyItemProvider);
                  SyncItem? matchingSyncItemForShadow;
                  if (syncItemsForShadow.isNotEmpty) {
                    try {
                      matchingSyncItemForShadow = syncItemsForShadow.firstWhere(
                        (s) => s.sentence.toLowerCase().contains(
                          text.toLowerCase().substring(0, text.length.clamp(0, 15))),
                      );
                    } catch (_) {
                      matchingSyncItemForShadow = syncItemsForShadow.first;
                    }
                  }
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ShadowingStudioScreen(
                        originalText: text,
                        audioPath: currentItemForShadow?.audioPath,
                        startTime: matchingSyncItemForShadow?.startTime,
                        endTime: matchingSyncItemForShadow?.endTime,
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 12),
                _buildMenuButton(context, Icons.psychology_outlined, l10n.playerMenuActiveRecall, theme, () {
                  Navigator.pop(context);
                  final currentItem = ref.read(currentStudyItemProvider);
                  if (currentItem == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.playerSelectFileFirst)),
                    );
                    return;
                  }
                  final syncItemsForRecall = ref.read(currentSyncItemsProvider);
                  SyncItem? matchingSyncItemForRecall;
                  if (syncItemsForRecall.isNotEmpty) {
                    try {
                      matchingSyncItemForRecall = syncItemsForRecall.firstWhere(
                        (s) => s.sentence.toLowerCase().contains(
                          text.toLowerCase().substring(0, text.length.clamp(0, 15))),
                      );
                    } catch (_) {
                      matchingSyncItemForRecall = syncItemsForRecall.first;
                    }
                  }
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => ActiveRecallScreen(
                      sentence: text,
                      audioPath: currentItem.audioPath,
                      startTime: matchingSyncItemForRecall?.startTime,
                      endTime: matchingSyncItemForRecall?.endTime,
                    ),
                  ));
                }),
                const SizedBox(height: 12),
                _buildMenuButton(context, Icons.bookmark_add_outlined, l10n.playerMenuBookmark, theme, () async {
                  Navigator.pop(context);
                  final currentItem = ref.read(currentStudyItemProvider);
                  if (currentItem == null) return;

                  final syncItems = ref.read(currentSyncItemsProvider);
                  SyncItem? matchingSyncItem;
                  if (syncItems.isNotEmpty) {
                    try {
                      matchingSyncItem = syncItems.firstWhere(
                        (s) => s.sentence.toLowerCase().contains(
                          text.toLowerCase().substring(0, text.length.clamp(0, 15))),
                      );
                    } catch (_) {}
                  }

                  final bookmark = Bookmark(
                    id: '${currentItem.audioPath}_${text.hashCode}',
                    sentence: text,
                    sourceTitle: currentItem.title,
                    audioPath: currentItem.audioPath,
                    startTime: matchingSyncItem?.startTime,
                    savedAt: DateTime.now(),
                  );

                  final added = await ref.read(bookmarksProvider.notifier).add(bookmark);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(added ? l10n.playerBookmarkSaved : l10n.playerBookmarkDuplicate),
                      duration: const Duration(seconds: 2),
                    ));
                  }
                }),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildMenuButton(BuildContext context, IconData icon, String label, ThemeData theme, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(width: 16),
            Text(label, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
            const Spacer(),
            Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Widget _buildNoScriptState(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, size: 48, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            Text(
              l10n.noScriptFile,
              style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.noScriptHint,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Icon(Icons.library_music_outlined, size: 48, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(
              l10n.noContentFound.split('\n').first,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.readyToMaster,
              style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: const Icon(Icons.folder_open),
              label: Text(l10n.library),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                foregroundColor: theme.colorScheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () {
                final engine = ref.read(audioEngineProvider);
                engine.setSpeed(0.75);
                Scaffold.of(context).openDrawer();
              },
              icon: const Icon(Icons.slow_motion_video),
              label: Text(AppLocalizations.of(context)!.playerBeginnerMode),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.onSurfaceVariant,
                side: BorderSide(color: theme.colorScheme.outline),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 컴포넌트: 스크립트 문장 줄
class ScriptLine extends StatelessWidget {
  final bool isActive;
  final String text;
  final String timeCode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const ScriptLine({
    super.key, 
    required this.isActive, 
    required this.text, 
    required this.timeCode,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? theme.colorScheme.primary.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 44,
              child: Text(timeCode, style: theme.textTheme.labelMedium),
            ),
            Expanded(
              child: Text(
                text,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: isActive ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 컴포넌트: 메인 플레이어 컨트롤 바
class PlayerBottomBar extends ConsumerWidget {
  final double horizontalPadding;
  final AudioEngine engine;
  final bool isPlaying;
  final double speed;
  final LoopMode loopMode;
  final bool hasItem;

  const PlayerBottomBar({
    super.key,
    required this.horizontalPadding,
    required this.engine,
    required this.isPlaying,
    required this.speed,
    required this.loopMode,
    required this.hasItem,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final position = ref.watch(positionProvider).value ?? Duration.zero;
    final duration = ref.watch(durationProvider).value;
    final sliderValue = (duration != null && duration.inMilliseconds > 0)
        ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;
    final abLoop = ref.watch(abLoopProvider);
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, 16 + bottomInset),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(color: theme.colorScheme.surface, blurRadius: 20, offset: const Offset(0, -10))
        ]
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // A-B 루프 인디케이터 바
          if (abLoop.hasStart)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.loop, size: 14, color: theme.colorScheme.primary),
                        const SizedBox(width: 4),
                        Text(
                          abLoop.isActive
                              ? 'A-B: ${_fmtDur(abLoop.start!)} → ${_fmtDur(abLoop.end!)}'
                              : l10n.playerAbLoopASet(_fmtDur(abLoop.start!)),
                          style: TextStyle(fontSize: 11, color: theme.colorScheme.primary, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      ref.read(abLoopProvider.notifier).clear();
                      engine.clearAbLoop();
                    },
                    child: Icon(Icons.close, size: 16, color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),

          // 시크바
          SliderTheme(
            data: theme.sliderTheme,
            child: Slider(
              value: sliderValue,
              onChanged: (val) {
                if (duration != null) {
                  engine.seek(Duration(milliseconds: (val * duration.inMilliseconds).round()));
                }
              },
            ),
          ),
          
          // 메인 재생 컨트롤 바 (가운데 정렬)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(icon: const Icon(Icons.replay_10, size: 36), onPressed: hasItem ? () => engine.skipBackward() : null),
              const SizedBox(width: 24),
              // 중앙 거대 재생 버튼
              GestureDetector(
                onTap: () => hasItem ? engine.togglePlayPause() : null,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                    boxShadow: [
                      if (isPlaying)
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.2),
                          blurRadius: 16,
                          spreadRadius: 4
                        )
                    ]
                  ),
                  child: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 40,
                    color: hasItem ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant
                  ),
                ),
              ),
              const SizedBox(width: 24),
              IconButton(icon: const Icon(Icons.forward_10, size: 36), onPressed: hasItem ? () => engine.skipForward() : null),
            ],
          ),
          const SizedBox(height: 16),
          
          // 부가 옵션 컨트롤 바 (배속, 반복, A-B 루프)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 스피드 조절
              PopupMenuButton<double>(
                initialValue: speed,
                color: theme.colorScheme.surfaceContainerHighest,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: _buildSmallChip(context, '${speed}x', Icons.speed),
                onSelected: (value) {
                  engine.setSpeed(value);
                  final item = ref.read(currentStudyItemProvider);
                  if (item != null) {
                    ref.read(progressServiceProvider).saveSpeed(item.audioPath, value);
                  }
                },
                itemBuilder: (context) => [0.5, 0.75, 1.0, 1.25, 1.5, 2.0].map((v) =>
                  PopupMenuItem(value: v, child: Text('${v}x', style: theme.textTheme.bodyMedium))
                ).toList(),
              ),

              // 루프 모드 (반복 설정) 토글 버튼
              GestureDetector(
                onTap: () => hasItem ? engine.toggleLoopMode() : null,
                child: _buildSmallChip(
                  context,
                  loopMode == LoopMode.off ? l10n.playerLoopOff : loopMode == LoopMode.one ? l10n.playerLoopOne : l10n.playerLoopAll,
                  loopMode == LoopMode.one ? Icons.repeat_one : Icons.repeat,
                  isActive: loopMode != LoopMode.off,
                ),
              ),

              // A-B 루프 버튼 (롱프레스: A, 숏탭: B)
              GestureDetector(
                onTap: () {
                  // B 설정 (또는 전체 해제)
                  if (abLoop.isActive) {
                    ref.read(abLoopProvider.notifier).clear();
                    engine.clearAbLoop();
                  } else if (abLoop.hasStart) {
                    final bTime = position;
                    if (bTime > abLoop.start!) {
                      ref.read(abLoopProvider.notifier).setEnd(bTime);
                      engine.setAbLoop(abLoop.start!, bTime);
                    }
                  } else {
                    ref.read(abLoopProvider.notifier).setStart(position);
                  }
                },
                onLongPress: () {
                  // A 재설정
                  ref.read(abLoopProvider.notifier).clear();
                  engine.clearAbLoop();
                  ref.read(abLoopProvider.notifier).setStart(position);
                },
                child: _buildSmallChip(
                  context,
                  abLoop.isActive ? 'A-B' : abLoop.hasStart ? 'A…' : 'A-B',
                  Icons.loop,
                  isActive: abLoop.isActive || abLoop.hasStart,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _fmtDur(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Widget _buildSmallChip(BuildContext context, String label, IconData icon, {bool isActive = false}) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? theme.colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isActive ? theme.colorScheme.primary.withValues(alpha: 0.5) : theme.colorScheme.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isActive ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            label, 
            style: TextStyle(
              color: isActive ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant, 
              fontSize: 13, 
              fontWeight: FontWeight.w500
            )
          ),
        ],
      ),
    );
  }
}

class _StudyListDrawer extends ConsumerWidget {
  const _StudyListDrawer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studyItemsAsync = ref.watch(studyItemsProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Drawer(
      backgroundColor: theme.colorScheme.surface,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.library, style: theme.textTheme.titleLarge),
                  IconButton(
                    icon: Icon(Icons.create_new_folder, color: theme.colorScheme.primary),
                    onPressed: () => ref.read(studyItemsProvider.notifier).pickAndScanDirectory(),
                  )
                ],
              ),
            ),
            Divider(color: theme.colorScheme.outline, height: 1),
            Expanded(
              child: studyItemsAsync.when(
                data: (items) {
                  if (items.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          l10n.noContentFound, 
                          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant), 
                          textAlign: TextAlign.center
                        ),
                      )
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final hasScript = item.scriptPath != null;
                      
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                             ref.read(currentStudyItemProvider.notifier).state = item;
                             ref.read(currentSyncItemsProvider.notifier).state = item.syncItems ?? []; // Load existing sync or reset
                             final engine = ref.read(audioEngineProvider);
                             engine.loadFile(item.audioPath).then((_) {
                               engine.player.play();
                               // Restore saved speed for this item
                               final progressService = ref.read(progressServiceProvider);
                               progressService.loadSpeed(item.audioPath).then((savedSpeed) {
                                 engine.setSpeed(savedSpeed);
                               });
                             }).catchError((e) {
                               // Audio load failed - item is selected but won't play
                               debugPrint('Failed to load audio: $e');
                             });
                             Navigator.pop(context); // 서랍 닫기
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surface,
                                    borderRadius: BorderRadius.circular(12)
                                  ),
                                  child: Icon(Icons.headphones, color: theme.colorScheme.onSurfaceVariant, size: 24),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.title, style: theme.textTheme.bodyLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            hasScript ? Icons.text_snippet : Icons.text_snippet_outlined, 
                                            size: 14, 
                                            color: hasScript ? AppTheme.success : theme.colorScheme.onSurfaceVariant
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            hasScript ? l10n.playerScriptReady : l10n.playerNoScript,
                                            style: theme.textTheme.labelMedium?.copyWith(
                                              color: hasScript ? AppTheme.success : theme.colorScheme.onSurfaceVariant
                                            )
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text(l10n.playerError(err.toString()), style: TextStyle(color: theme.colorScheme.error))),
              ),
            )
          ],
        ),
      ),
    );
  }
}
