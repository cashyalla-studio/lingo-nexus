import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui' as ui;
import '../player/player_provider.dart';
import '../player/audio_engine.dart';

class ActiveRecallScreen extends ConsumerStatefulWidget {
  final String sentence;
  final Duration? startTime;
  final Duration? endTime;
  final String audioPath;

  const ActiveRecallScreen({
    super.key,
    required this.sentence,
    required this.audioPath,
    this.startTime,
    this.endTime,
  });

  @override
  ConsumerState<ActiveRecallScreen> createState() => _ActiveRecallScreenState();
}

class _ActiveRecallScreenState extends ConsumerState<ActiveRecallScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _revealed = false;
  bool _submitted = false;
  int? _score;
  bool _isPlaying = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _playSegment() async {
    if (_isPlaying) return;
    setState(() => _isPlaying = true);

    final engine = ref.read(audioEngineProvider);
    if (widget.startTime != null && widget.endTime != null) {
      try {
        await engine.player.seek(widget.startTime!);
        await engine.player.play();
        final segDuration = widget.endTime! - widget.startTime!;
        await Future.delayed(segDuration);
        await engine.player.pause();
      } catch (_) {}
    }
    if (mounted) setState(() => _isPlaying = false);
  }

  void _submit() {
    final typed = _controller.text.trim().toLowerCase();
    final original = widget.sentence.trim().toLowerCase();

    final origWords = original.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    final typedWords = typed.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();

    int matched = 0;
    for (final word in origWords) {
      final clean = word.replaceAll(RegExp(r'[^\w]'), '');
      if (typedWords.any((tw) => tw.replaceAll(RegExp(r'[^\w]'), '') == clean)) matched++;
    }

    final score = origWords.isEmpty ? 0 : ((matched / origWords.length) * 100).round().clamp(0, 100);
    setState(() {
      _submitted = true;
      _revealed = true;
      _score = score;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('능동 회상 훈련'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text(
                      '오디오를 듣고 문장을 입력해보세요',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 16),
                    // Play button
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.surface,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _isPlaying ? null : _playSegment,
                      icon: _isPlaying
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.play_arrow),
                      label: Text(_isPlaying ? '재생 중...' : '구간 재생'),
                    ),
                    const SizedBox(height: 16),
                    // Blurred/revealed sentence
                    GestureDetector(
                      onTap: () => setState(() => _revealed = !_revealed),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            widget.sentence,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                          ),
                          if (!_revealed)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: BackdropFilter(
                                filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                                child: Container(
                                  color: theme.colorScheme.surface.withValues(alpha: 0.8),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  child: Text(
                                    '탭하여 정답 확인',
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      color: theme.colorScheme.primary),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Input area
              if (!_submitted) ...[
                TextField(
                  controller: _controller,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: '들은 내용을 입력하세요...',
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFF00FFD1)),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  maxLines: 3,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00FFD1),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _controller.text.trim().isEmpty ? null : _submit,
                  child: const Text('제출', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ] else ...[
                // Score result
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _scoreColor(_score!).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _scoreColor(_score!).withValues(alpha: 0.4)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '정확도 $_score%',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _scoreColor(_score!)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _scoreMessage(_score!),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 16),
                      Text('내 입력: ${_controller.text}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    setState(() {
                      _controller.clear();
                      _submitted = false;
                      _revealed = false;
                      _score = null;
                    });
                  },
                  child: const Text('다시 시도'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _scoreColor(int score) {
    if (score >= 80) return const Color(0xFF00FFD1);
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  String _scoreMessage(int score) {
    if (score >= 90) return '완벽합니다! 훌륭한 집중력이에요.';
    if (score >= 75) return '잘 하셨어요! 조금만 더 연습하면 완벽할 거예요.';
    if (score >= 60) return '좋은 시도입니다. 다시 듣고 도전해보세요.';
    return '괜찮아요. 오디오를 더 들어보고 다시 도전해보세요.';
  }
}
