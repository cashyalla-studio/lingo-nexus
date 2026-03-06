import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/study_item.dart';
import '../../core/services/google_drive_service.dart';
import '../../core/theme/app_theme.dart';
import '../scanner/scanner_provider.dart';

class GoogleDriveBrowserScreen extends ConsumerStatefulWidget {
  const GoogleDriveBrowserScreen({super.key});

  @override
  ConsumerState<GoogleDriveBrowserScreen> createState() => _GoogleDriveBrowserScreenState();
}

class _GoogleDriveBrowserScreenState extends ConsumerState<GoogleDriveBrowserScreen> {
  // 폴더 탐색 스택: (folderId, folderName)
  final _folderStack = <({String id, String name})>[
    (id: 'root', name: 'Google Drive'),
  ];

  List<DriveItem> _items = [];
  bool _loading = true;
  String? _error;
  String? _accessToken;

  // 다운로드 상태
  bool _downloading = false;
  String _downloadStatus = '';
  double _downloadProgress = 0;

  @override
  void initState() {
    super.initState();
    _signInAndLoad();
  }

  GoogleDriveService get _service => ref.read(googleDriveServiceProvider);

  ({String id, String name}) get _currentFolder => _folderStack.last;

  bool get _hasAudioInCurrentFolder =>
      _items.any((item) => !item.isFolder && item.isAudio);

  Future<void> _signInAndLoad() async {
    setState(() { _loading = true; _error = null; });
    final token = await _service.signIn();
    if (token == null) {
      setState(() { _loading = false; _error = '로그인에 실패했습니다.'; });
      return;
    }
    _accessToken = token;
    await _loadFolder();
  }

  Future<void> _loadFolder() async {
    if (_accessToken == null) return;
    setState(() { _loading = true; _error = null; });
    try {
      final items = await _service.listFolder(_currentFolder.id, _accessToken!);
      setState(() { _items = items; _loading = false; });
    } catch (e) {
      setState(() { _loading = false; _error = e.toString(); });
    }
  }

  void _navigateInto(DriveItem folder) {
    _folderStack.add((id: folder.id, name: folder.name));
    _loadFolder();
  }

  void _navigateBack() {
    if (_folderStack.length <= 1) return;
    _folderStack.removeLast();
    _loadFolder();
  }

  Future<void> _importCurrentFolder() async {
    if (_accessToken == null) return;
    setState(() {
      _downloading = true;
      _downloadStatus = '준비 중...';
      _downloadProgress = 0;
    });

    try {
      final pairs = await _service.importFolder(
        folderId: _currentFolder.id,
        folderName: _currentFolder.name,
        accessToken: _accessToken!,
        onProgress: (fileName, progress) {
          setState(() {
            _downloadStatus = fileName;
            _downloadProgress = progress;
          });
        },
      );

      final newItems = pairs.map((pair) => StudyItem(
        title: pair.title,
        audioPath: pair.audioPath,
        scriptPath: pair.scriptPath,
        source: StudyItemSource.googleDrive,
      )).toList();

      await ref.read(studyItemsProvider.notifier).addItems(newItems);

      if (mounted) {
        setState(() { _downloading = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${newItems.length}개 항목을 라이브러리에 추가했습니다.'),
            backgroundColor: AppTheme.accentPrimary,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() { _downloading = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('가져오기 실패: $e'), backgroundColor: AppTheme.danger),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Google Drive', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            if (_service.currentUser != null)
              Text(
                _service.currentUser!.email,
                style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
              ),
          ],
        ),
        leading: _folderStack.length > 1
            ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: _navigateBack)
            : IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            tooltip: '로그아웃',
            onPressed: () async {
              await _service.signOut();
              if (mounted) Navigator.pop(context);
            },
          ),
        ],
      ),

      body: Stack(
        children: [
          Column(
            children: [
              // 브레드크럼
              if (_folderStack.length > 1)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _folderStack.map((f) {
                        final isLast = f == _folderStack.last;
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (f != _folderStack.first)
                              Icon(Icons.chevron_right, size: 16,
                                  color: theme.colorScheme.onSurfaceVariant),
                            Text(
                              f.name,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: isLast
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurfaceVariant,
                                fontWeight: isLast ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),

              // 파일 목록
              Expanded(child: _buildBody(theme)),
            ],
          ),

          // 다운로드 오버레이
          if (_downloading) _buildDownloadOverlay(theme),
        ],
      ),

      // 가져오기 버튼
      floatingActionButton: (!_loading && !_downloading && _hasAudioInCurrentFolder)
          ? FloatingActionButton.extended(
              onPressed: _importCurrentFolder,
              backgroundColor: AppTheme.accentPrimary,
              foregroundColor: Colors.black,
              icon: const Icon(Icons.download_outlined),
              label: const Text('이 폴더 가져오기', style: TextStyle(fontWeight: FontWeight.bold)),
            )
          : null,
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppTheme.danger),
            const SizedBox(height: 16),
            Text(_error!, style: TextStyle(color: theme.colorScheme.error), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _signInAndLoad, child: const Text('다시 시도')),
          ],
        ),
      );
    }
    if (_items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.folder_open, size: 48, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
            const SizedBox(height: 12),
            Text('폴더가 비어 있습니다.',
                style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      );
    }

    // 폴더 먼저, 그 다음 오디오, 스크립트 순으로 정렬
    final sorted = [..._items]..sort((a, b) {
        if (a.isFolder && !b.isFolder) return -1;
        if (!a.isFolder && b.isFolder) return 1;
        return a.name.compareTo(b.name);
      });

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: sorted.length,
      itemBuilder: (context, index) => _buildItem(sorted[index], theme),
    );
  }

  Widget _buildItem(DriveItem item, ThemeData theme) {
    final Color iconColor;
    final IconData iconData;

    if (item.isFolder) {
      iconColor = const Color(0xFFFFA726);
      iconData = Icons.folder_rounded;
    } else if (item.isAudio) {
      iconColor = AppTheme.accentPrimary;
      iconData = Icons.audio_file_outlined;
    } else {
      iconColor = theme.colorScheme.onSurfaceVariant;
      iconData = Icons.description_outlined;
    }

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(iconData, color: iconColor, size: 22),
      ),
      title: Text(item.name, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
      subtitle: item.sizeLabel.isNotEmpty
          ? Text(item.sizeLabel, style: theme.textTheme.labelMedium)
          : null,
      trailing: item.isFolder ? const Icon(Icons.chevron_right) : null,
      onTap: item.isFolder ? () => _navigateInto(item) : null,
    );
  }

  Widget _buildDownloadOverlay(ThemeData theme) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_download_outlined, size: 40, color: AppTheme.accentPrimary),
              const SizedBox(height: 16),
              Text('가져오는 중...', style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                _downloadStatus,
                style: theme.textTheme.labelMedium,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: _downloadProgress > 0 ? _downloadProgress : null,
                backgroundColor: theme.colorScheme.outline,
                color: AppTheme.accentPrimary,
              ),
              if (_downloadProgress > 0) ...[
                const SizedBox(height: 8),
                Text('${(_downloadProgress * 100).toStringAsFixed(0)}%',
                    style: theme.textTheme.labelMedium),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
