import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lingo_nexus/generated/l10n/app_localizations.dart';
import '../../core/models/study_item.dart';
import '../../core/theme/app_theme.dart';
import '../scanner/scanner_provider.dart';
import '../player/audio_engine.dart';
import '../player/player_provider.dart';
import 'google_drive_browser_screen.dart';
import 'script_attach_sheet.dart';

class LibrarySheet extends ConsumerStatefulWidget {
  const LibrarySheet({super.key});

  @override
  ConsumerState<LibrarySheet> createState() => _LibrarySheetState();
}

class _LibrarySheetState extends ConsumerState<LibrarySheet> {
  int _selectedFilter = 0; // 0: All, 1: iCloud, 2: Drive, 3: Local, 4: Pending Sync

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final studyItemsAsync = ref.watch(studyItemsProvider);

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
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.library,
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: Icon(Icons.add_circle_outline, color: theme.colorScheme.primary),
                    onPressed: () => _showImportOptions(context),
                    tooltip: '가져오기',
                  )
                ],
              ),
            ),

            // Filter Chips
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _filterChip('전체', 0, theme),
                  const SizedBox(width: 8),
                  _filterChip('iCloud', 1, theme, icon: Icons.cloud_outlined),
                  const SizedBox(width: 8),
                  _filterChip('Drive', 2, theme, icon: Icons.add_to_drive_outlined),
                  const SizedBox(width: 8),
                  _filterChip('로컬', 3, theme, icon: Icons.folder_outlined),
                  const SizedBox(width: 8),
                  _filterChip('스크립트 없음', 4, theme, icon: Icons.pending_outlined),
                ],
              ),
            ),

            const SizedBox(height: 8),
            const Divider(height: 1),

            // List
            Expanded(
              child: studyItemsAsync.when(
                data: (items) {
                  final filtered = items.where((item) {
                    if (_selectedFilter == 1) return item.source == StudyItemSource.iCloud;
                    if (_selectedFilter == 2) return item.source == StudyItemSource.googleDrive;
                    if (_selectedFilter == 3) return item.source == StudyItemSource.local;
                    if (_selectedFilter == 4) return item.scriptPath == null;
                    return true;
                  }).toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.library_music_outlined,
                              size: 48, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
                          const SizedBox(height: 16),
                          Text(
                            l10n.noContentFound,
                            style: theme.textTheme.bodyLarge
                                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          ),
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
                    itemCount: filtered.length,
                    itemBuilder: (context, index) => _buildItem(filtered[index], theme),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(
                  child: Text('Error: $err', style: TextStyle(color: theme.colorScheme.error)),
                ),
              ),
            ),
          ],
        ),
      ),
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
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(sourceIcon, color: sourceColor),
        ),
        title: Text(
          item.title,
          style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              // 소스 배지
              if (isICloud) ...[
                Icon(Icons.cloud_outlined, size: 12, color: AppTheme.accentPrimary),
                const SizedBox(width: 3),
                Text('iCloud', style: theme.textTheme.labelMedium?.copyWith(color: AppTheme.accentPrimary)),
                const SizedBox(width: 8),
              ] else if (isDrive) ...[
                Icon(Icons.add_to_drive_outlined, size: 12, color: const Color(0xFF4285F4)),
                const SizedBox(width: 3),
                Text('Drive', style: theme.textTheme.labelMedium?.copyWith(color: const Color(0xFF4285F4))),
                const SizedBox(width: 8),
              ],
              // 스크립트 상태
              Icon(
                hasScript ? Icons.check_circle : Icons.pending,
                size: 14,
                color: hasScript ? AppTheme.success : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                hasScript ? 'Synced' : 'Audio Only',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: hasScript ? AppTheme.success : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        onTap: () {
          ref.read(currentStudyItemProvider.notifier).state = item;
          final engine = ref.read(audioEngineProvider);
          engine.loadFile(item.audioPath).then((_) => engine.player.play());
          Navigator.pop(context);
        },
        onLongPress: () => _showItemActions(item),
      ),
    );
  }

  void _showItemActions(StudyItem item) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              item.title,
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),

            if (item.scriptPath == null)
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.accentPrimary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.attach_file, color: AppTheme.accentPrimary),
                ),
                title: const Text('스크립트 연결'),
                subtitle: const Text('.txt 또는 .srt 파일을 이 항목에 연결'),
                onTap: () {
                  Navigator.pop(context);
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => ScriptAttachSheet(
                      audioPath: item.audioPath,
                      itemTitle: item.title,
                    ),
                  );
                },
              ),

            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.danger.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.remove_circle_outline, color: AppTheme.danger),
              ),
              title: const Text('라이브러리에서 제거', style: TextStyle(color: AppTheme.danger)),
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

  void _showImportOptions(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true, // 추가: 내용이 길면 화면 위쪽까지 시트가 올라갈 수 있도록 허용
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: SingleChildScrollView( // 추가: 오버플로우 방지를 위해 스크롤뷰로 감쌈
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
              Text('가져오기', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const GoogleDriveBrowserScreen()),
                  );
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
                  Text(title, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
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

  Widget _filterChip(String label, int index, ThemeData theme, {IconData? icon}) {
    final isSelected = _selectedFilter == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = index),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: icon != null ? 12 : 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14,
                  color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 4),
            ],
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
}
