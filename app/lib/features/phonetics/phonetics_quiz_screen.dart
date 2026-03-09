import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ipa_data.dart';
import 'tts_service.dart';
import 'dart:math';

/// 발음 퀴즈 게임 - IPA 보고 단어 맞추기 OR 단어 보고 IPA 고르기
class PhoneticsQuizScreen extends ConsumerStatefulWidget {
  const PhoneticsQuizScreen({super.key});

  @override
  ConsumerState<PhoneticsQuizScreen> createState() => _PhoneticsQuizScreenState();
}

class _PhoneticsQuizScreenState extends ConsumerState<PhoneticsQuizScreen> {
  final TtsService _tts = TtsService();
  final Random _random = Random();

  int _score = 0;
  int _streak = 0;
  int _total = 0;
  String? _selectedAnswer;
  bool _answered = false;
  late _QuizQuestion _current;

  final List<MapEntry<String, String>> _allWords =
      IpaData.english.entries.toList();

  @override
  void initState() {
    super.initState();
    _generateQuestion();
  }

  @override
  void dispose() {
    _tts.dispose();
    super.dispose();
  }

  void _generateQuestion() {
    _allWords.shuffle(_random);
    final correct = _allWords.first;

    // Generate 3 wrong options
    final wrongPool = _allWords.skip(1).take(20).toList()..shuffle(_random);
    final wrongs = wrongPool.take(3).toList();

    // Randomly choose question type
    final isIpaToWord = _random.nextBool();

    final options = [correct, ...wrongs]..shuffle(_random);

    setState(() {
      _current = _QuizQuestion(
        correctWord: correct.key,
        correctIpa: correct.value,
        options: options,
        isIpaToWord: isIpaToWord,
      );
      _selectedAnswer = null;
      _answered = false;
    });
  }

  void _answer(String chosen) {
    if (_answered) return;
    final isCorrect = chosen == _current.correctWord;
    setState(() {
      _selectedAnswer = chosen;
      _answered = true;
      _total++;
      if (isCorrect) {
        _score++;
        _streak++;
      } else {
        _streak = 0;
      }
    });
    // Auto-advance after 1.5s
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) _generateQuestion();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('발음 퀴즈'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                const Icon(Icons.local_fire_department, color: Color(0xFFFF6B00), size: 20),
                Text(' $_streak',
                  style: const TextStyle(color: Color(0xFFFF6B00), fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Score bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('정답: $_score / $_total',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                Text(_total > 0 ? '정확도: ${(_score * 100 ~/ _total)}%' : '',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
            const SizedBox(height: 24),

            // Question card
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _current.isIpaToWord ? '이 IPA 발음기호의 단어는?' : '이 단어의 IPA 발음기호는?',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        _current.isIpaToWord
                            ? '[${_current.correctIpa}]'
                            : _current.correctWord,
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: _current.isIpaToWord ? 24 : 36,
                          fontWeight: FontWeight.bold,
                          letterSpacing: _current.isIpaToWord ? 1.5 : 0,
                          fontFamily: _current.isIpaToWord ? 'monospace' : null,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // TTS button (always show the word)
                    OutlinedButton.icon(
                      onPressed: () => _tts.speak(_current.correctWord),
                      icon: const Icon(Icons.volume_up, size: 16),
                      label: const Text('발음 듣기'),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Answer options
            Expanded(
              flex: 3,
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2.2,
                physics: const NeverScrollableScrollPhysics(),
                children: _current.options.map((opt) {
                  final word = opt.key;
                  final ipa = opt.value;
                  final isCorrect = word == _current.correctWord;
                  final isSelected = word == _selectedAnswer;

                  Color? bgColor;
                  Color? borderColor;
                  if (_answered) {
                    if (isCorrect) {
                      bgColor = const Color(0xFF00FFD1).withValues(alpha: 0.15);
                      borderColor = const Color(0xFF00FFD1);
                    } else if (isSelected) {
                      bgColor = Colors.red.withValues(alpha: 0.1);
                      borderColor = Colors.red;
                    }
                  }

                  return InkWell(
                    onTap: _answered ? null : () => _answer(word),
                    borderRadius: BorderRadius.circular(14),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: bgColor ?? theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: borderColor ?? theme.colorScheme.outline.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _current.isIpaToWord ? word : '[$ipa]',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: _current.isIpaToWord ? 18 : 13,
                              color: _answered && isCorrect
                                  ? const Color(0xFF00FFD1)
                                  : _answered && isSelected
                                      ? Colors.red
                                      : theme.colorScheme.onSurface,
                              fontFamily: _current.isIpaToWord ? null : 'monospace',
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (_answered && isCorrect)
                            const Text('✅', style: TextStyle(fontSize: 14)),
                          if (_answered && isSelected && !isCorrect)
                            const Text('❌', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            if (_streak >= 3)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('🔥 연속 ${_streak}개 정답!',
                  style: const TextStyle(
                    color: Color(0xFFFF6B00),
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
              ),
          ],
        ),
        ),
      ),
    );
  }
}

class _QuizQuestion {
  final String correctWord;
  final String correctIpa;
  final List<MapEntry<String, String>> options;
  final bool isIpaToWord;

  const _QuizQuestion({
    required this.correctWord,
    required this.correctIpa,
    required this.options,
    required this.isIpaToWord,
  });
}
