import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ipa_data.dart';
import 'ipa_lookup_service.dart';
import 'tts_service.dart';
import 'phoneme_eval_service.dart';

final _ttsServiceProvider = Provider.autoDispose((ref) {
  final service = TtsService();
  ref.onDispose(service.dispose);
  return service;
});

final _phonemeEvalProvider = Provider.autoDispose((ref) {
  final service = PhonemeEvalService();
  ref.onDispose(service.dispose);
  return service;
});

class TtsPracticeScreen extends ConsumerStatefulWidget {
  const TtsPracticeScreen({super.key});

  @override
  ConsumerState<TtsPracticeScreen> createState() => _TtsPracticeScreenState();
}

class _TtsPracticeScreenState extends ConsumerState<TtsPracticeScreen> {
  final _ipaService = IpaLookupService();

  // Language toggle
  String _language = 'English';

  // Separate category state per language
  String _selectedCategoryEn = IpaData.categories.keys.first;
  String _selectedCategoryEs = IpaData.spanishCategories.keys.first;

  int _currentIndex = 0;
  bool _isSpeaking = false;
  bool _isListening = false;
  PronunciationResult? _result;
  bool _sttAvailable = false;

  Map<String, List<String>> get _activeCategories =>
      _language == 'Spanish' ? IpaData.spanishCategories : IpaData.categories;

  String get _selectedCategory =>
      _language == 'Spanish' ? _selectedCategoryEs : _selectedCategoryEn;

  List<({String word, String ipa})> get _words {
    if (_language == 'Spanish') {
      final wordList = IpaData.spanishCategories[_selectedCategoryEs] ?? [];
      return wordList
          .map((w) {
            final ipa = IpaData.spanish[w];
            if (ipa == null) return null;
            return (word: w, ipa: ipa);
          })
          .whereType<({String word, String ipa})>()
          .toList();
    }
    return _ipaService.getWordsWithIpa(_selectedCategoryEn);
  }

  ({String word, String ipa})? get _current =>
      _words.isEmpty ? null : _words[_currentIndex];

  @override
  void initState() {
    super.initState();
    _initStt();
  }

  Future<void> _initStt() async {
    final eval = ref.read(_phonemeEvalProvider);
    final available = await eval.initialize();
    if (mounted) setState(() => _sttAvailable = available);
  }

  Future<void> _speak({bool slow = false}) async {
    final word = _current?.word;
    if (word == null) return;
    setState(() => _isSpeaking = true);
    final tts = ref.read(_ttsServiceProvider);
    if (_language == 'Spanish') {
      if (slow) {
        await tts.speakSlow(word, language: 'es-ES');
      } else {
        await tts.speakSpanish(word);
      }
    } else {
      if (slow) {
        await tts.speakSlow(word);
      } else {
        await tts.speak(word);
      }
    }
    if (mounted) setState(() => _isSpeaking = false);
  }

  Future<void> _startListening() async {
    final eval = ref.read(_phonemeEvalProvider);
    if (!_sttAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이 기기에서 음성 인식을 사용할 수 없습니다.')));
      return;
    }
    setState(() { _isListening = true; _result = null; });

    final localeId = _language == 'Spanish' ? 'es-ES' : 'en-US';
    await eval.startListening(
      localeId: localeId,
      onResult: (text) {
        if (mounted) {
          final result = eval.evaluate(
            recognized: text,
            target: _current?.word ?? '',
          );
          setState(() { _result = result; _isListening = false; });
        }
      },
    );

    // Timeout fallback
    await Future.delayed(const Duration(seconds: 6));
    if (mounted && _isListening) {
      await eval.stopListening();
      setState(() => _isListening = false);
    }
  }

  void _next() {
    if (_words.isEmpty) return;
    setState(() {
      _currentIndex = (_currentIndex + 1) % _words.length;
      _result = null;
    });
  }

  void _prev() {
    if (_words.isEmpty) return;
    setState(() {
      _currentIndex = (_currentIndex - 1 + _words.length) % _words.length;
      _result = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final current = _current;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('TTS 발음 연습'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Language toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: ['English', 'Spanish'].map((lang) {
                final isSelected = lang == _language;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(lang, style: TextStyle(
                      color: isSelected ? Colors.black : null,
                      fontWeight: isSelected ? FontWeight.bold : null,
                    )),
                    selected: isSelected,
                    selectedColor: const Color(0xFF00FFD1),
                    onSelected: (_) => setState(() {
                      _language = lang;
                      _currentIndex = 0;
                      _result = null;
                    }),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 4),

          // Category selector
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: _activeCategories.keys.map((cat) {
                final isSelected = cat == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat, style: TextStyle(
                      color: isSelected ? Colors.black : theme.colorScheme.onSurfaceVariant,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    )),
                    selected: isSelected,
                    selectedColor: const Color(0xFF00FFD1),
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    onSelected: (_) => setState(() {
                      if (_language == 'Spanish') {
                        _selectedCategoryEs = cat;
                      } else {
                        _selectedCategoryEn = cat;
                      }
                      _currentIndex = 0;
                      _result = null;
                    }),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 8),

          // Progress indicator
          if (_words.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Text('${_currentIndex + 1} / ${_words.length}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (_currentIndex + 1) / _words.length,
                        backgroundColor: theme.colorScheme.outline.withValues(alpha: 0.2),
                        valueColor: const AlwaysStoppedAnimation(Color(0xFF00FFD1)),
                        minHeight: 4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 24),

          // Main word card
          Expanded(
            child: current == null
                ? Center(child: Text('단어 없음', style: theme.textTheme.bodyLarge))
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        // Word display card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.surfaceContainerHighest,
                                theme.colorScheme.surface,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: theme.colorScheme.primary.withValues(alpha: 0.2)),
                          ),
                          child: Column(
                            children: [
                              Text(
                                current.word,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  '[${current.ipa}]',
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontSize: 22,
                                    letterSpacing: 1.5,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // TTS buttons row
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _isSpeaking ? null : () => _speak(slow: true),
                                icon: const Icon(Icons.slow_motion_video, size: 18),
                                label: const Text('천천히'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: ElevatedButton.icon(
                                onPressed: _isSpeaking ? null : _speak,
                                icon: _isSpeaking
                                    ? const SizedBox(width: 18, height: 18,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                                    : const Icon(Icons.volume_up, size: 20),
                                label: Text(_isSpeaking ? '재생 중...' : '발음 듣기'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00FFD1),
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // STT button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: (_isListening || !_sttAvailable) ? null : _startListening,
                            icon: _isListening
                                ? const SizedBox(width: 20, height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Icon(Icons.mic),
                            label: Text(_isListening ? '듣는 중... (크게 말해보세요)' : '따라 말하고 채점받기'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isListening
                                  ? Colors.red.withValues(alpha: 0.8)
                                  : theme.colorScheme.primary.withValues(alpha: 0.15),
                              foregroundColor: _isListening ? Colors.white : theme.colorScheme.primary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ),

                        // Result card
                        if (_result != null) ...[
                          const SizedBox(height: 16),
                          _ResultCard(result: _result!, theme: theme),
                        ],

                        const Spacer(),

                        // Navigation
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: _prev,
                              icon: const Icon(Icons.arrow_back_ios),
                              style: IconButton.styleFrom(
                                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                            Text('← 이전 / 다음 →',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant)),
                            IconButton(
                              onPressed: _next,
                              icon: const Icon(Icons.arrow_forward_ios),
                              style: IconButton.styleFrom(
                                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final PronunciationResult result;
  final ThemeData theme;
  const _ResultCard({required this.result, required this.theme});

  @override
  Widget build(BuildContext context) {
    final color = result.score >= 80
        ? const Color(0xFF00FFD1)
        : result.score >= 50
            ? Colors.orange
            : Colors.red;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('${result.score}점',
                style: TextStyle(
                  color: color, fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Text(result.score >= 80 ? '🎉' : result.score >= 50 ? '👍' : '💪',
                style: const TextStyle(fontSize: 24)),
            ],
          ),
          const SizedBox(height: 8),
          Text(result.feedback,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center),
          if (result.recognized != null && result.recognized!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text('인식됨: "${result.recognized}"',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6)),
            ),
          ],
        ],
      ),
    );
  }
}
