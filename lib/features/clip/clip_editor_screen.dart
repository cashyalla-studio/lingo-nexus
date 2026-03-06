import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/models/study_item.dart';
import '../../core/models/sync_item.dart';
import '../../core/services/clip_service.dart';
import '../../core/theme/app_theme.dart';
import '../player/player_provider.dart';
import '../scanner/scanner_provider.dart';

class ClipEditorScreen extends ConsumerStatefulWidget {
  final StudyItem item;
  final Duration? initialStart;
  final Duration? initialEnd;
  final List<SyncItem> syncItems;

  const ClipEditorScreen({
    super.key,
    required this.item,
    this.initialStart,
    this.initialEnd,
    this.syncItems = const [],
  });

  @override
  ConsumerState<ClipEditorScreen> createState() => _ClipEditorScreenState();
}

class _ClipEditorScreenState extends ConsumerState<ClipEditorScreen> {
  late Duration _start;
  late Duration _end;
  Duration _total = Duration.zero;
  bool _isPreviewing = false;
  bool _isSaving = false;
  bool _isDetectingSilence = false;
  List<(Duration, Duration)> _silenceSegments = [];

  // 미리듣기용 전용 플레이어
  final _previewPlayer = AudioPlayer();

  // 파형 데이터 (해시 기반 일관된 pseudo 데이터)
  late List<double> _waveformData;

  @override
  void initState() {
    super.initState();
    _start = widget.initialStart ?? Duration.zero;
    _end = widget.initialEnd ?? const Duration(seconds: 30);
    _waveformData = _generateWaveform(widget.item.audioPath, 120);

    // 전체 길이 로드
    _loadDuration();
  }

  Future<void> _loadDuration() async {
    try {
      await _previewPlayer.setFilePath(widget.item.audioPath);
      final dur = _previewPlayer.duration;
      if (dur != null && mounted) {
        setState(() {
          _total = dur;
          if (widget.initialEnd == null) {
            _end = dur < const Duration(seconds: 30) ? dur : const Duration(seconds: 30);
          }
          _end = _end > _total ? _total : _end;
        });
      }
    } catch (_) {}
  }

  List<double> _generateWaveform(String seed, int count) {
    final rng = math.Random(seed.hashCode);
    return List.generate(count, (i) {
      // 중간 대역 강조 (실제 음성 파형과 유사)
      final base = 0.15 + rng.nextDouble() * 0.7;
      final envelope = math.sin(i / count * math.pi);
      return (base * (0.4 + 0.6 * envelope)).clamp(0.05, 1.0);
    });
  }

  Future<void> _togglePreview() async {
    if (_isPreviewing) {
      await _previewPlayer.stop();
      setState(() => _isPreviewing = false);
      return;
    }
    setState(() => _isPreviewing = true);
    try {
      await _previewPlayer.setAudioSource(
        ClippingAudioSource(
          child: AudioSource.file(widget.item.audioPath),
          start: _start,
          end: _end,
        ),
      );
      await _previewPlayer.play();
      await _previewPlayer.processingStateStream
          .firstWhere((s) => s == ProcessingState.completed);
    } catch (_) {}
    if (mounted) setState(() => _isPreviewing = false);
  }

  Future<void> _detectSilence() async {
    setState(() => _isDetectingSilence = true);
    final service = ClipService();
    final segs = await service.detectSpeechSegments(
      widget.item.audioPath,
      totalDuration: _total,
    );
    if (mounted) {
      setState(() {
        _silenceSegments = segs;
        _isDetectingSilence = false;
      });
    }
  }

  Future<void> _saveClip(String title) async {
    setState(() => _isSaving = true);
    final service = ClipService();

    final audioPath = await service.trimAudio(
      sourcePath: widget.item.audioPath,
      start: _start,
      end: _end,
      title: title,
    );

    if (audioPath == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('클립 저장에 실패했습니다. ffmpeg 설정을 확인해주세요.')),
        );
        setState(() => _isSaving = false);
      }
      return;
    }

    String? scriptPath;
    if (widget.syncItems.isNotEmpty) {
      scriptPath = await service.saveClipScript(
        clipAudioPath: audioPath,
        syncItems: widget.syncItems,
        start: _start,
        end: _end,
      );
    }

    final clip = StudyItem(
      title: title,
      audioPath: audioPath,
      scriptPath: scriptPath,
      source: StudyItemSource.local,
    );
    ref.read(studyItemsProvider.notifier).addItems([clip]);

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('클립 "$title" 이 라이브러리에 추가되었습니다.'),
          action: SnackBarAction(label: '닫기', onPressed: () {}),
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _showSaveDialog() async {
    final ctrl = TextEditingController(
      text: '${widget.item.title} [${_formatDuration(_start)}-${_formatDuration(_end)}]',
    );
    final title = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('클립 이름'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: '클립 제목 입력'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('저장'),
          ),
        ],
      ),
    );
    if (title != null && title.isNotEmpty) await _saveClip(title);
  }

  Future<void> _exportClip() async {
    // 먼저 클립을 저장한 뒤 공유
    final service = ClipService();
    final ctrl = TextEditingController(
      text: '${widget.item.title} clip',
    );
    final title = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('내보내기 클립 이름'),
        content: TextField(controller: ctrl, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
          FilledButton(onPressed: () => Navigator.pop(ctx, ctrl.text.trim()), child: const Text('다음')),
        ],
      ),
    );
    if (title == null || title.isEmpty) return;

    setState(() => _isSaving = true);
    final audioPath = await service.trimAudio(
      sourcePath: widget.item.audioPath,
      start: _start,
      end: _end,
      title: title,
    );
    setState(() => _isSaving = false);
    if (audioPath == null) return;

    String? scriptPath;
    if (widget.syncItems.isNotEmpty) {
      scriptPath = await service.saveClipScript(
        clipAudioPath: audioPath,
        syncItems: widget.syncItems,
        start: _start,
        end: _end,
      );
    }

    final clip = StudyItem(title: title, audioPath: audioPath, scriptPath: scriptPath);
    final zipPath = await service.exportClipAsZip(clip);
    if (zipPath != null && mounted) {
      await Share.shareXFiles([XFile(zipPath)], subject: title);
    }
  }

  @override
  void dispose() {
    _previewPlayer.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final ms = (d.inMilliseconds.remainder(1000) ~/ 100).toString();
    return '$m:$s.$ms';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clipDuration = _end - _start;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          children: [
            const Text('클립 편집', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(
              widget.item.title,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share_outlined),
            tooltip: '내보내기 (zip)',
            onPressed: _isSaving ? null : _exportClip,
          ),
        ],
      ),
      body: Column(
        children: [
          // ─── 파형 + 핸들 영역 ───────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _WaveformRangeSelector(
              waveformData: _waveformData,
              total: _total,
              start: _start,
              end: _end,
              syncItems: widget.syncItems,
              silenceSegments: _silenceSegments,
              onRangeChanged: (s, e) => setState(() {
                _start = s;
                _end = e;
              }),
            ),
          ),

          // ─── 시간 표시 ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _TimeChip(label: '시작', time: _start, color: AppTheme.accentPrimary),
                Column(children: [
                  Text(_formatDuration(clipDuration),
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  Text('선택 길이', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                ]),
                _TimeChip(label: '끝', time: _end, color: theme.colorScheme.error),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ─── 컨트롤 버튼들 ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _togglePreview,
                    icon: Icon(_isPreviewing ? Icons.stop : Icons.play_arrow),
                    label: Text(_isPreviewing ? '정지' : '미리듣기'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isDetectingSilence ? null : _detectSilence,
                    icon: _isDetectingSilence
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.graphic_eq),
                    label: const Text('구간 감지'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ─── 문장 목록 (싱크 있을 때) ─────────────────────
          if (widget.syncItems.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(children: [
                Icon(Icons.format_list_bulleted, size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 6),
                Text('문장 선택', style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary)),
              ]),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: widget.syncItems.length,
                itemBuilder: (ctx, i) {
                  final s = widget.syncItems[i];
                  final isSelected = _start <= s.startTime && _end >= s.endTime;
                  return _SentenceSegmentTile(
                    syncItem: s,
                    isSelected: isSelected,
                    onTap: () => setState(() {
                      _start = s.startTime;
                      _end = s.endTime;
                    }),
                    onAddToRange: () => setState(() {
                      if (s.startTime < _start) _start = s.startTime;
                      if (s.endTime > _end) _end = s.endTime;
                    }),
                  );
                },
              ),
            ),
          ] else if (_silenceSegments.isNotEmpty) ...[
            // 무음 감지로 나눈 구간 표시
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(children: [
                Icon(Icons.graphic_eq, size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 6),
                Text('감지된 말하기 구간', style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary)),
              ]),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _silenceSegments.length,
                itemBuilder: (ctx, i) {
                  final (s, e) = _silenceSegments[i];
                  final isSelected = _start == s && _end == e;
                  return _SegmentTile(
                    index: i + 1,
                    start: s,
                    end: e,
                    isSelected: isSelected,
                    onTap: () => setState(() { _start = s; _end = e; }),
                  );
                },
              ),
            ),
          ] else
            const Spacer(),

          // ─── 저장 버튼 ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isSaving ? null : _showSaveDialog,
                icon: _isSaving
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.content_cut),
                label: const Text('클립으로 저장', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 파형 + 드래그 핸들 위젯 ───────────────────────────────────────────
class _WaveformRangeSelector extends StatefulWidget {
  final List<double> waveformData;
  final Duration total;
  final Duration start;
  final Duration end;
  final List<SyncItem> syncItems;
  final List<(Duration, Duration)> silenceSegments;
  final void Function(Duration start, Duration end) onRangeChanged;

  const _WaveformRangeSelector({
    required this.waveformData,
    required this.total,
    required this.start,
    required this.end,
    required this.syncItems,
    required this.silenceSegments,
    required this.onRangeChanged,
  });

  @override
  State<_WaveformRangeSelector> createState() => _WaveformRangeSelectorState();
}

class _WaveformRangeSelectorState extends State<_WaveformRangeSelector> {
  static const _handleWidth = 20.0;
  static const _height = 120.0;
  bool _draggingStart = false;
  bool _draggingEnd = false;

  double _toX(Duration d, double w) {
    if (widget.total <= Duration.zero) return 0;
    return (d.inMilliseconds / widget.total.inMilliseconds) * w;
  }

  Duration _toDuration(double x, double w) {
    if (widget.total <= Duration.zero || w <= 0) return Duration.zero;
    final ratio = (x / w).clamp(0.0, 1.0);
    return Duration(milliseconds: (ratio * widget.total.inMilliseconds).round());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: _height,
      child: LayoutBuilder(
        builder: (ctx, constraints) {
          final w = constraints.maxWidth;
          final startX = _toX(widget.start, w);
          final endX = _toX(widget.end, w);

          return GestureDetector(
            onHorizontalDragStart: (d) {
              final x = d.localPosition.dx;
              if ((x - startX).abs() < _handleWidth) {
                _draggingStart = true;
                _draggingEnd = false;
              } else if ((x - endX).abs() < _handleWidth) {
                _draggingEnd = true;
                _draggingStart = false;
              }
            },
            onHorizontalDragUpdate: (d) {
              final x = d.localPosition.dx;
              if (_draggingStart) {
                final newStart = _toDuration(x, w);
                if (newStart < widget.end - const Duration(milliseconds: 500)) {
                  widget.onRangeChanged(newStart, widget.end);
                }
              } else if (_draggingEnd) {
                final newEnd = _toDuration(x, w);
                if (newEnd > widget.start + const Duration(milliseconds: 500)) {
                  widget.onRangeChanged(widget.start, newEnd);
                }
              }
            },
            onHorizontalDragEnd: (_) {
              _draggingStart = false;
              _draggingEnd = false;
            },
            child: CustomPaint(
              size: Size(w, _height),
              painter: _WaveformRangePainter(
                waveformData: widget.waveformData,
                total: widget.total,
                start: widget.start,
                end: widget.end,
                syncItems: widget.syncItems,
                primaryColor: theme.colorScheme.primary,
                dimColor: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                handleColor: theme.colorScheme.primary,
                endHandleColor: theme.colorScheme.error,
                markerColor: theme.colorScheme.secondary,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _WaveformRangePainter extends CustomPainter {
  final List<double> waveformData;
  final Duration total;
  final Duration start;
  final Duration end;
  final List<SyncItem> syncItems;
  final Color primaryColor;
  final Color dimColor;
  final Color handleColor;
  final Color endHandleColor;
  final Color markerColor;

  _WaveformRangePainter({
    required this.waveformData,
    required this.total,
    required this.start,
    required this.end,
    required this.syncItems,
    required this.primaryColor,
    required this.dimColor,
    required this.handleColor,
    required this.endHandleColor,
    required this.markerColor,
  });

  double _toX(Duration d, double w) {
    if (total <= Duration.zero) return 0;
    return (d.inMilliseconds / total.inMilliseconds) * w;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final midY = h / 2;
    final startX = _toX(start, w);
    final endX = _toX(end, w);
    final barW = w / waveformData.length;

    // 선택 구간 배경
    final selBg = Paint()
      ..color = primaryColor.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromLTRBR(startX, 0, endX, h, const Radius.circular(4)),
      selBg,
    );

    // 파형 막대
    for (int i = 0; i < waveformData.length; i++) {
      final x = i * barW + barW / 2;
      final barH = waveformData[i] * (h * 0.85);
      final inRange = x >= startX && x <= endX;
      final paint = Paint()
        ..color = inRange ? primaryColor.withValues(alpha: 0.85) : dimColor
        ..strokeCap = StrokeCap.round
        ..strokeWidth = math.max(barW - 1, 1.5)
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(x, midY - barH / 2), Offset(x, midY + barH / 2), paint);
    }

    // 문장 경계 마커 (파란 세로선)
    final markerPaint = Paint()
      ..color = markerColor.withValues(alpha: 0.6)
      ..strokeWidth = 1.5;
    for (final s in syncItems) {
      final mx = _toX(s.startTime, w);
      canvas.drawLine(Offset(mx, 0), Offset(mx, h), markerPaint);
    }

    // 선택 구간 경계선
    final borderPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.4)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(startX, 0), Offset(startX, h), borderPaint);
    canvas.drawLine(Offset(endX, 0), Offset(endX, h), borderPaint);

    // 시작 핸들 (초록)
    _drawHandle(canvas, startX, h, handleColor, isLeft: true);
    // 끝 핸들 (빨강)
    _drawHandle(canvas, endX, h, endHandleColor, isLeft: false);
  }

  void _drawHandle(Canvas canvas, double x, double h, Color color, {required bool isLeft}) {
    const hw = 12.0;
    const hh = 36.0;
    final rx = isLeft ? x : x - hw;
    final ry = (h - hh) / 2;

    final handlePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromLTRBR(rx, ry, rx + hw, ry + hh, const Radius.circular(4)),
      handlePaint,
    );

    // 세 줄 그립 표시
    final gripPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 3; i++) {
      final ly = ry + hh / 2 - 6 + i * 6.0;
      canvas.drawLine(Offset(rx + 3, ly), Offset(rx + hw - 3, ly), gripPaint);
    }
  }

  @override
  bool shouldRepaint(_WaveformRangePainter old) =>
      old.start != start || old.end != end || old.total != total;
}

// ─── 서브 위젯들 ────────────────────────────────────────────────────────
class _TimeChip extends StatelessWidget {
  final String label;
  final Duration time;
  final Color color;
  const _TimeChip({required this.label, required this.time, required this.color});

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final ms = (d.inMilliseconds.remainder(1000) ~/ 100).toString();
    return '$m:$s.$ms';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
        Text(_fmt(time), style: TextStyle(fontSize: 15, color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _SentenceSegmentTile extends StatelessWidget {
  final SyncItem syncItem;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onAddToRange;

  const _SentenceSegmentTile({
    required this.syncItem,
    required this.isSelected,
    required this.onTap,
    required this.onAddToRange,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withValues(alpha: 0.12)
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary.withValues(alpha: 0.4)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Text(syncItem.formattedTime,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  )),
              const SizedBox(width: 10),
              Expanded(
                child: Text(syncItem.sentence,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isSelected ? theme.colorScheme.primary : null,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ),
              IconButton(
                icon: Icon(Icons.add_circle_outline, size: 18,
                    color: theme.colorScheme.onSurfaceVariant),
                tooltip: '범위에 추가',
                onPressed: onAddToRange,
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SegmentTile extends StatelessWidget {
  final int index;
  final Duration start;
  final Duration end;
  final bool isSelected;
  final VoidCallback onTap;

  const _SegmentTile({
    required this.index,
    required this.start,
    required this.end,
    required this.isSelected,
    required this.onTap,
  });

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withValues(alpha: 0.12)
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.4) : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Text('$index', style: theme.textTheme.labelLarge?.copyWith(
                  color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant)),
              const SizedBox(width: 12),
              Text('${_fmt(start)} → ${_fmt(end)}', style: theme.textTheme.bodyMedium),
              const Spacer(),
              Text('${(end - start).inSeconds}초',
                  style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }
}
