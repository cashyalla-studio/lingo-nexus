import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lingo_nexus/generated/l10n/app_localizations.dart';
import '../../core/models/study_item.dart';
import '../../core/models/language_option.dart';
import '../../core/theme/app_theme.dart';
import '../scanner/scanner_provider.dart';
import '../player/audio_engine.dart';
import '../player/player_provider.dart';
import '../player/player_screen.dart';
import '../playlist/playlist_provider.dart';
import 'google_drive_browser_screen.dart';
import 'script_attach_sheet.dart';

// ── 이모지 픽커용 옵션 ──────────────────────────────────────
const _playlistEmojis = [
  '🎵', '🎧', '📚', '✈️', '🗣️', '💼', '🏃', '🍽️',
  '❤️', '🎬', '🎤', '📖', '🌏', '🎓', '🏖️', '💡',
];

class LibrarySheet extends ConsumerStatefulWidget {
  const LibrarySheet({super.key});

  @override
  ConsumerState<LibrarySheet> createState() => _LibrarySheetState();
}

class _LibrarySheetState extends ConsumerState<LibrarySheet> {
  // 'playlist' | 'all' | language code (e.g. 'ko', 'en') | 'unset'
  String _langFilter = 'all';
  // 0: 전체, 1: iCloud, 2: Drive, 3: 로컬, 4: 스크립트없음
  int _sourceFilter = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final studyItemsAsync = ref.watch(studyItemsProvider);
    final playlists = ref.watch(playlistProvider);

    // 라이브러리에 실제 존재하는 언어 코드 수집
    final allItems = studyItemsAsync.value ?? [];
    final usedLangCodes = allItems.map((i) => i.language).toSet();

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.library,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      if (_langFilter == 'playlist')
                        IconButton(
                          icon: Icon(Icons.playlist_add, color: theme.colorScheme.primary),
                          onPressed: () => _showCreatePlaylistDialog(context),
                          tooltip: '새 플레이리스트',
                        ),
                      IconButton(
                        icon: Icon(Icons.add_circle_outline, color: theme.colorScheme.primary),
                        onPressed: () => _showImportOptions(context),
                        tooltip: '가져오기',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Language Tab Row ──
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _langChip('📚', '플레이리스트', 'playlist', theme),
                  const SizedBox(width: 8),
                  _langChip('🌐', '전체', 'all', theme),
                  const SizedBox(width: 8),
                  // 실제 사용 중인 언어만 표시
                  ...kStudyLanguages
                      .where((l) => usedLangCodes.contains(l.code))
                      .map((l) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _langChip(l.emoji, l.name, l.code, theme),
                          )),
                  // 미설정 항목이 있으면 표시
                  if (usedLangCodes.contains(null))
                    _langChip('❓', '미설정', 'unset', theme),
                ],
              ),
            ),

            // ── Source Filter Row (플레이리스트 탭이 아닐 때만) ──
            if (_langFilter != 'playlist') ...[
              const SizedBox(height: 6),
              SizedBox(
                height: 34,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _sourceChip('전체', 0, theme),
                    const SizedBox(width: 6),
                    _sourceChip('iCloud', 1, theme, icon: Icons.cloud_outlined),
                    const SizedBox(width: 6),
                    _sourceChip('Drive', 2, theme, icon: Icons.add_to_drive_outlined),
                    const SizedBox(width: 6),
                    _sourceChip('로컬', 3, theme, icon: Icons.folder_outlined),
                    const SizedBox(width: 6),
                    _sourceChip('스크립트없음', 4, theme, icon: Icons.pending_outlined),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 6),
            const Divider(height: 1),

            // Content
            Expanded(
              child: _langFilter == 'playlist'
                  ? _buildPlaylistsView(playlists, theme)
                  : studyItemsAsync.when(
                      data: (items) => _buildItemList(_applyFilters(items), theme, l10n),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, _) => Center(
                        child: Text('Error: $err',
                          style: TextStyle(color: theme.colorScheme.error))),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  List<StudyItem> _applyFilters(List<StudyItem> items) {
    return items.where((item) {
      // language filter
      if (_langFilter == 'unset' && item.language != null) return false;
      if (_langFilter != 'all' && _langFilter != 'unset' && item.language != _langFilter) return false;
      // source filter
      if (_sourceFilter == 1) return item.source == StudyItemSource.iCloud;
      if (_sourceFilter == 2) return item.source == StudyItemSource.googleDrive;
      if (_sourceFilter == 3) return item.source == StudyItemSource.local;
      if (_sourceFilter == 4) return item.scriptPath == null;
      return true;
    }).toList();
  }

  // ── Filter chip builders ─────────────────────────────────

  Widget _langChip(String emoji, String label, String value, ThemeData theme) {
    final isSelected = _langFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _langFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline.withValues(alpha: 0.6),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            Text(label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              )),
          ],
        ),
      ),
    );
  }

  Widget _sourceChip(String label, int value, ThemeData theme, {IconData? icon}) {
    final isSelected = _sourceFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _sourceFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.secondary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.secondary
                : theme.colorScheme.outline.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 12,
                color: isSelected ? theme.colorScheme.secondary : theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 3),
            ],
            Text(label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isSelected ? theme.colorScheme.secondary : theme.colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              )),
          ],
        ),
      ),
    );
  }

  // ── Item list ────────────────────────────────────────────

  Widget _buildItemList(List<StudyItem> items, ThemeData theme, AppLocalizations l10n) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.library_music_outlined,
              size: 48, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            Text(l10n.noContentFound,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => _showImportOptions(context),
              icon: const Icon(Icons.add),
              label: const Text('가져오기'),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: items.length,
      itemBuilder: (context, index) => _buildItem(items[index], theme),
    );
  }

  Widget _buildItem(StudyItem item, ThemeData theme) {
    final hasScript = item.scriptPath != null;
    final isICloud = item.source == StudyItemSource.iCloud;
    final isDrive = item.source == StudyItemSource.googleDrive;

    final sourceIcon = isICloud
        ? Icons.cloud_done_outlined
        : isDrive
            ? Icons.add_to_drive_outlined
            : Icons.headphones;
    final sourceColor = isICloud
        ? AppTheme.accentPrimary
        : isDrive
            ? const Color(0xFF4285F4)
            : theme.colorScheme.onSurfaceVariant;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.4)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(sourceIcon, color: sourceColor, size: 22),
            ),
            // 언어 배지
            if (item.language != null)
              Positioned(
                bottom: -4, right: -6,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
                  ),
                  child: Text(langEmoji(item.language), style: const TextStyle(fontSize: 12)),
                ),
              ),
          ],
        ),
        title: Text(item.title,
          style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
          maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Row(
            children: [
              if (item.language != null) ...[
                Text(langEmoji(item.language), style: const TextStyle(fontSize: 11)),
                const SizedBox(width: 3),
                Text(langName(item.language),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary.withValues(alpha: 0.8))),
                const SizedBox(width: 8),
              ],
              Icon(
                hasScript ? Icons.check_circle : Icons.pending,
                size: 12,
                color: hasScript ? AppTheme.success : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 3),
              Text(
                hasScript ? 'Synced' : 'Audio Only',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: hasScript ? AppTheme.success : theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        onTap: () => _playItem(item),
        onLongPress: () => _showItemActions(item),
      ),
    );
  }

  void _playItem(StudyItem item) {
    ref.read(currentPlaylistIdProvider.notifier).state = null;
    ref.read(currentStudyItemProvider.notifier).state = item;
    final engine = ref.read(audioEngineProvider);
    engine.loadFile(item.audioPath).then((_) => engine.player.play());
    Navigator.pop(context);
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PlayerScreen()));
  }

  // ── Playlists view ───────────────────────────────────────

  Widget _buildPlaylistsView(List<Playlist> playlists, ThemeData theme) {
    if (playlists.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🎵', style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text('플레이리스트가 없습니다.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: () => _showCreatePlaylistDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('새 플레이리스트 만들기'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: playlists.length,
      itemBuilder: (context, index) => _buildPlaylistCard(playlists[index], theme),
    );
  }

  Widget _buildPlaylistCard(Playlist pl, ThemeData theme) {
    final allItems = ref.read(studyItemsProvider).value ?? [];
    final trackItems = allItems
        .where((i) => pl.audioPaths.contains(i.audioPath))
        .toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.08),
            theme.colorScheme.surfaceContainerHighest,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
            leading: Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2)),
              ),
              child: Center(
                child: Text(pl.emoji, style: const TextStyle(fontSize: 26)),
              ),
            ),
            title: Text(pl.name,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${pl.audioPaths.length}곡',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant)),
                if (pl.description != null && pl.description!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(pl.description!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7)),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 재생 버튼
                if (pl.audioPaths.isNotEmpty)
                  IconButton(
                    icon: Icon(Icons.play_circle_filled,
                      color: theme.colorScheme.primary, size: 36),
                    onPressed: () => _playPlaylist(pl),
                  ),
                // 옵션 메뉴
                IconButton(
                  icon: Icon(Icons.more_vert,
                    color: theme.colorScheme.onSurfaceVariant),
                  onPressed: () => _showPlaylistOptions(pl),
                ),
              ],
            ),
          ),
          // 트랙 미리보기 (최대 3개)
          if (trackItems.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Column(
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  ...trackItems.take(3).toList().asMap().entries.map((e) {
                    final idx = e.key;
                    final item = e.value;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 20,
                            child: Text('${idx + 1}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                              textAlign: TextAlign.center),
                          ),
                          const SizedBox(width: 8),
                          if (item.language != null) ...[
                            Text(langEmoji(item.language),
                              style: const TextStyle(fontSize: 11)),
                            const SizedBox(width: 4),
                          ],
                          Expanded(
                            child: Text(item.title,
                              style: theme.textTheme.labelMedium,
                              overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                    );
                  }),
                  if (pl.audioPaths.length > 3)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text('+ ${pl.audioPaths.length - 3}곡 더',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary)),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _playPlaylist(Playlist pl) {
    final allItems = ref.read(studyItemsProvider).value ?? [];
    final firstItem = allItems.firstWhere(
      (item) => item.audioPath == pl.audioPaths.first,
      orElse: () => allItems.first,
    );
    ref.read(currentPlaylistIdProvider.notifier).state = pl.id;
    ref.read(currentStudyItemProvider.notifier).state = firstItem;
    final engine = ref.read(audioEngineProvider);
    engine.loadFile(firstItem.audioPath).then((_) => engine.player.play());
    Navigator.pop(context);
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PlayerScreen()));
  }

  void _showPlaylistOptions(Playlist pl) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Row(
              children: [
                Text(pl.emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Text(pl.name,
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: _optionIcon(Icons.edit_outlined, theme.colorScheme.primary, theme),
              title: const Text('이름/이모지 수정'),
              onTap: () {
                Navigator.pop(context);
                _showEditPlaylistDialog(context, pl);
              },
            ),
            ListTile(
              leading: _optionIcon(Icons.delete_outline, AppTheme.danger, theme),
              title: const Text('삭제', style: TextStyle(color: AppTheme.danger)),
              onTap: () {
                Navigator.pop(context);
                ref.read(playlistProvider.notifier).deletePlaylist(pl.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _optionIcon(IconData icon, Color color, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color),
    );
  }

  // ── Dialogs ──────────────────────────────────────────────

  void _showCreatePlaylistDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String selectedEmoji = '🎵';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _PlaylistFormSheet(
        title: '새 플레이리스트',
        nameController: nameCtrl,
        descController: descCtrl,
        initialEmoji: selectedEmoji,
        onConfirm: (name, emoji, desc) {
          if (name.trim().isNotEmpty) {
            ref.read(playlistProvider.notifier).createPlaylist(
              name.trim(),
              emoji: emoji,
              description: desc.trim().isEmpty ? null : desc.trim(),
            );
          }
        },
      ),
    );
  }

  void _showEditPlaylistDialog(BuildContext context, Playlist pl) {
    final nameCtrl = TextEditingController(text: pl.name);
    final descCtrl = TextEditingController(text: pl.description ?? '');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _PlaylistFormSheet(
        title: '플레이리스트 수정',
        nameController: nameCtrl,
        descController: descCtrl,
        initialEmoji: pl.emoji,
        onConfirm: (name, emoji, desc) {
          if (name.trim().isNotEmpty) {
            ref.read(playlistProvider.notifier).updatePlaylist(
              pl.id,
              name: name.trim(),
              emoji: emoji,
              description: desc.trim().isEmpty ? null : desc.trim(),
            );
          }
        },
      ),
    );
  }

  // ── Item actions ─────────────────────────────────────────

  void _showItemActions(StudyItem item) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Row(
              children: [
                if (item.language != null) ...[
                  Text(langEmoji(item.language), style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(item.title,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            const SizedBox(height: 16),

            ListTile(
              leading: _optionIcon(Icons.language, theme.colorScheme.tertiary, theme),
              title: Text(item.language == null
                  ? '언어 설정'
                  : '언어 변경 (현재: ${langName(item.language)})'),
              onTap: () {
                Navigator.pop(context);
                _showLanguagePicker(item);
              },
            ),

            ListTile(
              leading: _optionIcon(Icons.playlist_add, theme.colorScheme.primary, theme),
              title: const Text('플레이리스트에 추가'),
              onTap: () {
                Navigator.pop(context);
                _showAddToPlaylistSheet(context, item);
              },
            ),

            if (item.scriptPath == null)
              ListTile(
                leading: _optionIcon(Icons.attach_file, AppTheme.accentPrimary, theme),
                title: const Text('스크립트 연결'),
                subtitle: const Text('.txt 또는 .srt 파일을 이 항목에 연결'),
                onTap: () {
                  Navigator.pop(context);
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    useSafeArea: true,
                    builder: (_) => ScriptAttachSheet(
                      audioPath: item.audioPath,
                      itemTitle: item.title,
                    ),
                  );
                },
              ),

            ListTile(
              leading: _optionIcon(Icons.remove_circle_outline, AppTheme.danger, theme),
              title: const Text('라이브러리에서 제거',
                style: TextStyle(color: AppTheme.danger)),
              subtitle: const Text('파일 원본은 삭제되지 않습니다'),
              onTap: () {
                Navigator.pop(context);
                ref.read(studyItemsProvider.notifier).removeItem(item.audioPath);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguagePicker(StudyItem item) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text('학습 언어 선택',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            ),
            // 미설정 옵션
            ListTile(
              leading: const Text('❓', style: TextStyle(fontSize: 22)),
              title: const Text('미설정'),
              trailing: item.language == null
                  ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
                  : null,
              onTap: () {
                ref.read(studyItemsProvider.notifier).setItemLanguage(item.audioPath, null);
                Navigator.pop(context);
              },
            ),
            ...kStudyLanguages.map((l) => ListTile(
              leading: Text(l.emoji, style: const TextStyle(fontSize: 22)),
              title: Text(l.name),
              trailing: item.language == l.code
                  ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
                  : null,
              onTap: () {
                ref.read(studyItemsProvider.notifier).setItemLanguage(item.audioPath, l.code);
                Navigator.pop(context);
              },
            )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showAddToPlaylistSheet(BuildContext context, StudyItem item) {
    final playlists = ref.read(playlistProvider);
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('어떤 플레이리스트에 추가할까요?',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (playlists.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text('먼저 플레이리스트를 생성해주세요.'),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showCreatePlaylistDialog(context);
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('새 플레이리스트 만들기'),
                    ),
                  ],
                ),
              )
            else
              ...playlists.map((pl) {
                final alreadyIn = pl.audioPaths.contains(item.audioPath);
                return ListTile(
                  leading: Text(pl.emoji, style: const TextStyle(fontSize: 22)),
                  title: Text(pl.name),
                  subtitle: Text('${pl.audioPaths.length}곡'),
                  trailing: alreadyIn
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : const Icon(Icons.add_circle_outline),
                  onTap: alreadyIn ? null : () {
                    ref.read(playlistProvider.notifier).addItemsToPlaylist(pl.id, [item.audioPath]);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${pl.name}에 추가됨')));
                  },
                );
              }),
          ],
        ),
      ),
    );
  }

  // ── Import ───────────────────────────────────────────────

  void _showImportOptions(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('가져오기',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _importOption(
                context: context,
                icon: Icons.folder_open_outlined,
                iconColor: theme.colorScheme.primary,
                title: '이 기기에서 가져오기',
                subtitle: '로컬 폴더에서 오디오+스크립트 불러오기',
                onTap: () {
                  Navigator.pop(context);
                  ref.read(studyItemsProvider.notifier).pickAndScanDirectory();
                },
              ),
              const SizedBox(height: 12),
              _importOption(
                context: context,
                icon: Icons.cloud_outlined,
                iconColor: AppTheme.accentPrimary,
                title: 'iCloud Drive에서 가져오기',
                subtitle: 'iCloud Drive 폴더를 라이브러리에 연결',
                onTap: () {
                  Navigator.pop(context);
                  ref.read(studyItemsProvider.notifier).pickAndScanDirectory();
                },
              ),
              const SizedBox(height: 12),
              _importOption(
                context: context,
                icon: Icons.add_to_drive_outlined,
                iconColor: const Color(0xFF4285F4),
                title: 'Google Drive에서 가져오기',
                subtitle: 'Google Drive 폴더를 탐색하고 다운로드',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const GoogleDriveBrowserScreen()));
                },
              ),
              const SizedBox(height: 12),
              _importOption(
                context: context,
                icon: Icons.sync_outlined,
                iconColor: AppTheme.accentDim,
                title: 'Scripta Sync iCloud 폴더 자동 동기화',
                subtitle: 'iCloud Drive/Scripta Sync/ 폴더를 자동 스캔',
                onTap: () {
                  Navigator.pop(context);
                  ref.read(studyItemsProvider.notifier).syncFromICloud();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _importOption({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                    style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

// ── Playlist Create/Edit Bottom Sheet ────────────────────────
class _PlaylistFormSheet extends StatefulWidget {
  final String title;
  final TextEditingController nameController;
  final TextEditingController descController;
  final String initialEmoji;
  final void Function(String name, String emoji, String desc) onConfirm;

  const _PlaylistFormSheet({
    required this.title,
    required this.nameController,
    required this.descController,
    required this.initialEmoji,
    required this.onConfirm,
  });

  @override
  State<_PlaylistFormSheet> createState() => _PlaylistFormSheetState();
}

class _PlaylistFormSheetState extends State<_PlaylistFormSheet> {
  late String _selectedEmoji;

  @override
  void initState() {
    super.initState();
    _selectedEmoji = widget.initialEmoji;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(widget.title,
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // Emoji picker
            Text('이모지', style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _playlistEmojis.map((e) {
                final selected = _selectedEmoji == e;
                return GestureDetector(
                  onTap: () => setState(() => _selectedEmoji = e),
                  child: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: selected
                          ? theme.colorScheme.primary.withValues(alpha: 0.15)
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected
                            ? theme.colorScheme.primary
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(e, style: const TextStyle(fontSize: 22))),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),
            Text('이름', style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: widget.nameController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: '예: 영어 여행 회화, 비즈니스 일본어',
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 16),
            Text('설명 (선택)', style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: widget.descController,
              decoration: InputDecoration(
                hintText: '예: 여행할 때 쓸 영어 표현 모음',
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  widget.onConfirm(
                    widget.nameController.text,
                    _selectedEmoji,
                    widget.descController.text,
                  );
                  Navigator.pop(context);
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('저장', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
