import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../../core/theme/app_theme.dart';

class ScribeModeScreen extends ConsumerStatefulWidget {
  final String originalText;
  final String audioPath;
  final Duration startTime;
  final Duration endTime;

  const ScribeModeScreen({
    super.key,
    required this.originalText,
    required this.audioPath,
    required this.startTime,
    required this.endTime,
  });

  @override
  ConsumerState<ScribeModeScreen> createState() => _ScribeModeScreenState();
}

enum ScribeState { listening, typing, revealed }

class _ScribeModeScreenState extends ConsumerState<ScribeModeScreen> {
  final AudioPlayer _player = AudioPlayer();
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  ScribeState _state = ScribeState.listening;
  bool _isPlaying = false;
  double _playbackSpeed = 1.0;
  List<_WordResult>? _results;
  int _playCount = 0;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _loadAudio();
  }

  Future<void> _loadAudio() async {
    await _player.setFilePath(widget.audioPath);
    await _player.seek(widget.startTime);
    _playSegment();
  }

  Future<void> _playSegment() async {
    if (_isPlaying) {
      await _player.pause();
      setState(() => _isPlaying = false);
      return;
    }
    setState(() { _isPlaying = true; _playCount++; });
    await _player.seek(widget.startTime);
    await _player.setSpeed(_playbackSpeed);
    await _player.play();

    // Stop at endTime
    final segmentDuration = widget.endTime - widget.startTime;
    Timer(segmentDuration, () async {
      if (mounted) {
        await _player.pause();
        setState(() {
          _isPlaying = false;
          if (_state == ScribeState.listening) _state = ScribeState.typing;
        });
        _focusNode.requestFocus();
      }
    });
  }

  void _setSpeed(double speed) {
    setState(() => _playbackSpeed = speed);
  }

  void _check() {
    final input = _controller.text.trim();
    if (input.isEmpty) return;

    final origWords = _normalize(widget.originalText).split(RegExp(r'\s+'));
    final inputWords = _normalize(input).split(RegExp(r'\s+'));

    final results = <_WordResult>[];
    for (int i = 0; i < origWords.length; i++) {
      final orig = origWords[i];
      // Find best match in input (allows slight reordering)
      final isCorrect = inputWords.any((w) => _levenshtein(w, orig) <= 1);
      results.add(_WordResult(word: widget.originalText.split(RegExp(r'\s+'))[i], isCorrect: isCorrect));
    }

    final correctCount = results.where((r) => r.isCorrect).length;
    final score = origWords.isEmpty ? 0 : ((correctCount / origWords.length) * 100).round();

    setState(() {
      _results = results;
      _score = score;
      _state = ScribeState.revealed;
    });
    FocusScope.of(context).unfocus();
  }

  void _retry() {
    setState(() {
      _state = ScribeState.listening;
      _results = null;
      _score = 0;
      _controller.clear();
    });
    _playSegment();
  }

  String _normalize(String text) {
    return text.toLowerCase().replaceAll(RegExp(r"[^\w\s']"), '').trim();
  }

  int _levenshtein(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;
    final matrix = List.generate(a.length + 1, (i) => List.filled(b.length + 1, 0));
    for (int i = 0; i <= a.length; i++) matrix[i][0] = i;
    for (int j = 0; j <= b.length; j++) matrix[0][j] = j;
    for (int i = 1; i <= a.length; i++) {
      for (int j = 1; j <= b.length; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        matrix[i][j] = [matrix[i-1][j]+1, matrix[i][j-1]+1, matrix[i-1][j-1]+cost].reduce((a, b) => a < b ? a : b);
      }
    }
    return matrix[a.length][b.length];
  }

  @override
  void dispose() {
    _player.dispose();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text('받아쓰기 연습', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Audio player section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(24),
                  border: _isPlaying
                      ? Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.5), width: 1.5)
                      : null,
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.hearing,
                      size: 48,
                      color: _isPlaying ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _isPlaying ? '재생 중...' : '탭하여 재생',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: _isPlaying ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_playCount}회 재생',
                      style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: _playSegment,
                          child: Container(
                            width: 64, height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: theme.colorScheme.primary.withValues(alpha: 0.15),
                              border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.5)),
                            ),
                            child: Icon(
                              _isPlaying ? Icons.pause : Icons.play_arrow,
                              color: theme.colorScheme.primary, size: 32,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Speed selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [0.5, 0.75, 1.0].map((speed) {
                        final isSelected = _playbackSpeed == speed;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: GestureDetector(
                            onTap: () => _setSpeed(speed),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.15) : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline.withValues(alpha: 0.5),
                                ),
                              ),
                              child: Text('${speed}x', style: TextStyle(
                                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 13,
                              )),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              if (_state == ScribeState.revealed && _results != null) ...[
                // Score banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: (_score >= 90 ? AppTheme.success : _score >= 70 ? theme.colorScheme.primary : AppTheme.danger).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('$_score점', style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _score >= 90 ? AppTheme.success : _score >= 70 ? theme.colorScheme.primary : AppTheme.danger,
                      )),
                      const SizedBox(width: 8),
                      Text('/ 100', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Colored word result
                Wrap(
                  spacing: 6, runSpacing: 6,
                  children: _results!.map((r) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: r.isCorrect ? AppTheme.success.withValues(alpha: 0.15) : AppTheme.danger.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: r.isCorrect ? AppTheme.success.withValues(alpha: 0.4) : AppTheme.danger.withValues(alpha: 0.4)),
                    ),
                    child: Text(r.word, style: TextStyle(
                      color: r.isCorrect ? AppTheme.success : AppTheme.danger,
                      fontWeight: FontWeight.w500,
                    )),
                  )).toList(),
                ),
                const SizedBox(height: 8),
                // User's input
                Text('내가 쓴 내용: "${_controller.text}"',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ] else ...[
                // Text input area
                Text(
                  _state == ScribeState.listening ? '먼저 문장을 들어보세요.' : '들은 내용을 입력하세요:',
                  style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  enabled: _state == ScribeState.typing,
                  maxLines: 3,
                  style: theme.textTheme.bodyLarge,
                  onSubmitted: (_) => _check(),
                  decoration: InputDecoration(
                    hintText: _state == ScribeState.listening ? '재생 후 입력 가능합니다' : '들은 문장을 여기에 입력...',
                    hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: theme.colorScheme.primary),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ],

              const Spacer(),

              // Action button
              if (_state == ScribeState.typing)
                ElevatedButton.icon(
                  onPressed: _check,
                  icon: const Icon(Icons.check),
                  label: const Text('정답 확인'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                )
              else if (_state == ScribeState.revealed)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _retry,
                        icon: const Icon(Icons.refresh),
                        label: const Text('다시 듣기'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.done),
                        label: const Text('완료'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WordResult {
  final String word;
  final bool isCorrect;
  const _WordResult({required this.word, required this.isCorrect});
}
