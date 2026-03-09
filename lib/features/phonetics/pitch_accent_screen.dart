import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pitch_accent_data.dart';
import 'pitch_accent_widget.dart';
import 'tts_service.dart';

class PitchAccentScreen extends ConsumerStatefulWidget {
  const PitchAccentScreen({super.key});

  @override
  ConsumerState<PitchAccentScreen> createState() => _PitchAccentScreenState();
}

class _PitchAccentScreenState extends ConsumerState<PitchAccentScreen> {
  final TtsService _tts = TtsService();
  int _currentIndex = 0;
  bool _showMeaning = false;

  final List<MapEntry<String, PitchEntry>> _entries =
      PitchAccentData.words.entries.toList();

  PitchEntry get _current => _entries[_currentIndex].value;
  String get _currentKey => _entries[_currentIndex].key;

  @override
  void dispose() {
    _tts.dispose();
    super.dispose();
  }

  void _next() => setState(() {
    _currentIndex = (_currentIndex + 1) % _entries.length;
    _showMeaning = false;
  });

  void _prev() => setState(() {
    _currentIndex = (_currentIndex - 1 + _entries.length) % _entries.length;
    _showMeaning = false;
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entry = _current;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('일본어 피치 악센트'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        top: false,
        child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Info banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2)),
              ),
              child: Text(
                '일본어는 음의 높낮이(피치)가 의미를 구별합니다.\n같은 글자라도 H(高)·L(低) 패턴에 따라 뜻이 달라집니다.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant, height: 1.5),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 32),

            // Progress
            Text('${_currentIndex + 1} / ${_entries.length}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 16),

            // Main card
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: const Color(0xFF00FFD1).withValues(alpha: 0.2)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Pitch accent visualizer
                    PitchAccentWidget(
                      entry: entry,
                      word: _currentKey,
                      fontSize: 32,
                    ),

                    const SizedBox(height: 28),

                    // Meaning reveal
                    GestureDetector(
                      onTap: () => setState(() => _showMeaning = !_showMeaning),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: _showMeaning
                              ? const Color(0xFF00FFD1).withValues(alpha: 0.1)
                              : theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF00FFD1).withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          _showMeaning ? entry.meaning : '탭하여 의미 확인',
                          style: TextStyle(
                            color: _showMeaning
                                ? const Color(0xFF00FFD1)
                                : theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // TTS button
                    ElevatedButton.icon(
                      onPressed: () => _tts.speakJapanese(entry.reading),
                      icon: const Icon(Icons.volume_up),
                      label: const Text('원어민 발음 듣기'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00FFD1),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton.icon(
                  onPressed: _prev,
                  icon: const Icon(Icons.arrow_back_ios, size: 16),
                  label: const Text('이전'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _next,
                  icon: const Icon(Icons.arrow_forward_ios, size: 16),
                  label: const Text('다음'),
                  iconAlignment: IconAlignment.end,
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
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
