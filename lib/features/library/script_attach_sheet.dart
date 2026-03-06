import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import '../../core/theme/app_theme.dart';
import '../scanner/scanner_provider.dart';

/// 오디오 전용 항목에 스크립트(.txt / .srt)를 연결하는 바텀시트입니다.
class ScriptAttachSheet extends ConsumerStatefulWidget {
  final String audioPath;
  final String itemTitle;

  const ScriptAttachSheet({
    super.key,
    required this.audioPath,
    required this.itemTitle,
  });

  @override
  ConsumerState<ScriptAttachSheet> createState() => _ScriptAttachSheetState();
}

class _ScriptAttachSheetState extends ConsumerState<ScriptAttachSheet> {
  String? _selectedPath;
  String? _previewText;
  bool _loading = false;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt', 'srt'],
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return;

    final path = result.files.first.path;
    if (path == null) return;

    setState(() { _loading = true; });
    try {
      final content = await File(path).readAsString();
      setState(() {
        _selectedPath = path;
        _previewText = content.length > 300 ? '${content.substring(0, 300)}…' : content;
        _loading = false;
      });
    } catch (e) {
      setState(() { _loading = false; });
    }
  }

  void _confirm() {
    if (_selectedPath == null) return;
    ref.read(studyItemsProvider.notifier).attachScript(widget.audioPath, _selectedPath!);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Text('스크립트 연결', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            widget.itemTitle,
            style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 20),

          // 파일 선택 버튼
          OutlinedButton.icon(
            onPressed: _loading ? null : _pickFile,
            icon: const Icon(Icons.attach_file),
            label: Text(_selectedPath == null ? '.txt 또는 .srt 파일 선택' : p.basename(_selectedPath!)),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              side: BorderSide(
                color: _selectedPath != null
                    ? AppTheme.accentPrimary
                    : theme.colorScheme.outline,
              ),
              foregroundColor: _selectedPath != null ? AppTheme.accentPrimary : null,
            ),
          ),

          // 미리보기
          if (_previewText != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.accentPrimary.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(Icons.preview_outlined, size: 14, color: AppTheme.accentPrimary),
                    const SizedBox(width: 6),
                    Text('미리보기',
                        style: theme.textTheme.labelMedium?.copyWith(color: AppTheme.accentPrimary)),
                  ]),
                  const SizedBox(height: 8),
                  Text(
                    _previewText!,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: 13,
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.6,
                    ),
                    maxLines: 6,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          // 확인 버튼
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _selectedPath != null ? _confirm : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentPrimary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: const Text('연결하기', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
