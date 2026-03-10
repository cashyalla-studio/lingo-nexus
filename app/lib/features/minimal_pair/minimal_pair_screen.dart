import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/llm_service.dart';
import '../tutor/tutor_provider.dart';
import 'minimal_pair_data.dart';
import '../phonetics/tts_service.dart';
import '../phonetics/phoneme_eval_service.dart';

class MinimalPairScreen extends ConsumerStatefulWidget {
  const MinimalPairScreen({super.key});

  @override
  ConsumerState<MinimalPairScreen> createState() => _MinimalPairScreenState();
}

class _MinimalPairScreenState extends ConsumerState<MinimalPairScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _languages = MinimalPairData.supportedLanguages;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _languages.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text('최소쌍 훈련', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: _languages.map((l) => Tab(text: l)).toList(),
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
          indicatorColor: theme.colorScheme.primary,
        ),
      ),
      body: SafeArea(
        top: false,
        child: TabBarView(
          controller: _tabController,
          children: _languages.map((language) {
            final sets = MinimalPairData.getAllForLanguage(language);
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sets.length,
              itemBuilder: (ctx, i) => _PhonemeSetCard(pairSet: sets[i], theme: theme),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _PhonemeSetCard extends ConsumerStatefulWidget {
  final MinimalPairSet pairSet;
  final ThemeData theme;
  const _PhonemeSetCard({required this.pairSet, required this.theme});

  @override
  ConsumerState<_PhonemeSetCard> createState() => _PhonemeSetCardState();
}

class _PhonemeSetCardState extends ConsumerState<_PhonemeSetCard> {
  bool _expanded = false;
  String? _aiExplanation;
  bool _loadingAi = false;
  final TtsService _tts = TtsService();
  final PhonemeEvalService _eval = PhonemeEvalService();
  bool _challengeMode = false;
  bool _isListening = false;
  String? _challengeTarget;
  PronunciationResult? _challengeResult;
  int _correctStreak = 0;
  bool _sttAvailable = false;

  @override
  void initState() {
    super.initState();
    _eval.initialize().then((ok) {
      if (mounted) setState(() => _sttAvailable = ok);
    });
  }

  @override
  void dispose() {
    _tts.dispose();
    _eval.dispose();
    super.dispose();
  }

  String _getLanguageCode() {
    switch (widget.pairSet.language) {
      case 'Japanese': return 'ja-JP';
      case 'Spanish': return 'es-ES';
      default: return 'en-US';
    }
  }

  Widget _buildChallengeMode(ThemeData theme) {
    final pair = widget.pairSet.pairs.isNotEmpty
        ? widget.pairSet.pairs[DateTime.now().second % widget.pairSet.pairs.length]
        : null;
    if (pair == null) return const SizedBox.shrink();

    // Randomly pick which word to test
    final target = _challengeTarget ??
        (DateTime.now().millisecond % 2 == 0 ? pair.wordA : pair.wordB);

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Text('이 단어를 발음해보세요:',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          Text(
            target.split(' ').first,
            style: const TextStyle(
              color: Colors.orange, fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text('연속 정답: $_correctStreak개 🔥',
            style: theme.textTheme.labelSmall?.copyWith(color: Colors.orange)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _tts.speak(target.split(' ').first, language: _getLanguageCode()),
                  icon: const Icon(Icons.volume_up, size: 16),
                  label: const Text('듣기'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _isListening ? null : () async {
                    setState(() { _isListening = true; _challengeTarget = target; _challengeResult = null; });
                    await _eval.startListening(
                      localeId: _getLanguageCode(),
                      onResult: (text) {
                        if (mounted) {
                          final result = _eval.evaluate(recognized: text, target: target.split(' ').first);
                          setState(() {
                            _challengeResult = result;
                            _isListening = false;
                            if (result.score >= 70) _correctStreak++;
                            else _correctStreak = 0;
                          });
                        }
                      },
                    );
                    await Future.delayed(const Duration(seconds: 6));
                    if (mounted && _isListening) {
                      await _eval.stopListening();
                      setState(() => _isListening = false);
                    }
                  },
                  icon: _isListening
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                      : const Icon(Icons.mic, size: 18),
                  label: Text(_isListening ? '듣는 중...' : '발음 도전'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
          if (_challengeResult != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (_challengeResult!.score >= 70
                    ? const Color(0xFF00FFD1)
                    : Colors.red).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text('${_challengeResult!.score}점 ${_challengeResult!.score >= 70 ? "✅" : "❌"}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: _challengeResult!.score >= 70 ? const Color(0xFF00FFD1) : Colors.red)),
                  const SizedBox(height: 4),
                  Text(_challengeResult!.feedback,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant),
                    textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => setState(() {
                      _challengeTarget = null;
                      _challengeResult = null;
                    }),
                    child: const Text('다음 도전 →'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _loadAiExplanation() async {
    setState(() => _loadingAi = true);
    final service = ref.read(llmServiceProvider);
    final sentence =
        "${widget.pairSet.phonemeA} vs ${widget.pairSet.phonemeB} in ${widget.pairSet.language}: ${widget.pairSet.description}. Examples: ${widget.pairSet.pairs.map((p) => '${p.wordA} / ${p.wordB}').join(', ')}. Explain: 1) exact mouth/tongue position for each sound, 2) the key perceptual difference, 3) a memory tip.";
    final result = await service.askGrammar(sentence);
    if (mounted) setState(() {
      _aiExplanation = result;
      _loadingAi = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: _expanded
              ? Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.4))
              : null,
        ),
        child: Column(
          children: [
            InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${widget.pairSet.phonemeA} / ${widget.pairSet.phonemeB}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${widget.pairSet.pairs.length}쌍',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Icon(
                      _expanded ? Icons.expand_less : Icons.expand_more,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
            if (_expanded) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  widget.pairSet.description,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
              ...widget.pairSet.pairs.map((pair) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  pair.wordA,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                if (pair.exampleSentenceA != null)
                                  Text(
                                    pair.exampleSentenceA!,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                IconButton(
                                  icon: const Icon(Icons.volume_up, size: 16),
                                  color: theme.colorScheme.primary,
                                  onPressed: () => _tts.speak(
                                    pair.wordA.split(' ').first,
                                    language: _getLanguageCode(),
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            'vs',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.orange.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  pair.wordB,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                                if (pair.exampleSentenceB != null)
                                  Text(
                                    pair.exampleSentenceB!,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                IconButton(
                                  icon: const Icon(Icons.volume_up, size: 16),
                                  color: Colors.orange,
                                  onPressed: () => _tts.speak(
                                    pair.wordB.split(' ').first,
                                    language: _getLanguageCode(),
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_aiExplanation == null && !_loadingAi)
                      OutlinedButton.icon(
                        onPressed: _loadAiExplanation,
                        icon: const Icon(Icons.auto_awesome, size: 18),
                        label: const Text('AI 발음 설명 듣기'),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      )
                    else if (_loadingAi)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (_aiExplanation != null)
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: theme.colorScheme.outline.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          _aiExplanation!,
                          style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
                        ),
                      ),
                    if (_sttAvailable) ...[
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () => setState(() {
                          _challengeMode = !_challengeMode;
                          _challengeResult = null;
                          _challengeTarget = null;
                        }),
                        icon: Icon(_challengeMode ? Icons.close : Icons.mic, size: 18),
                        label: Text(_challengeMode ? '도전 모드 종료' : '발음 도전 모드 (STT)'),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                          side: BorderSide(color: Colors.orange.withValues(alpha: 0.5)),
                          foregroundColor: Colors.orange,
                        ),
                      ),
                      if (_challengeMode) _buildChallengeMode(theme),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
