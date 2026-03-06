import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/ai_provider.dart';
import '../tutor/tutor_provider.dart';
import 'minimal_pair_data.dart';

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
      body: TabBarView(
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

  Future<void> _loadAiExplanation() async {
    setState(() => _loadingAi = true);
    final activeAi = ref.read(activeAiProvider);
    final apiKey = await ref.read(currentApiKeyProvider.future);
    if (apiKey == null || apiKey.isEmpty) {
      setState(() {
        _aiExplanation = "API 키를 설정해야 AI 설명을 받을 수 있습니다.";
        _loadingAi = false;
      });
      return;
    }
    final service = ref.read(llmServiceProvider);
    final prompt =
        "${widget.pairSet.phonemeA} vs ${widget.pairSet.phonemeB} in ${widget.pairSet.language}: ${widget.pairSet.description}\n\nExamples: ${widget.pairSet.pairs.map((p) => '${p.wordA} / ${p.wordB}').join(', ')}\n\nPlease explain in Korean: 1) exact mouth/tongue position for each sound, 2) the key perceptual difference to listen for, 3) a memory tip.";
    final result = await service.askGrammar(activeAi, apiKey, prompt);
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
