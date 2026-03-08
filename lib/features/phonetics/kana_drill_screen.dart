import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'tts_service.dart';

/// 히라가나/가타카나 TTS 발음 연습 화면
class KanaDrillScreen extends ConsumerStatefulWidget {
  const KanaDrillScreen({super.key});

  @override
  ConsumerState<KanaDrillScreen> createState() => _KanaDrillScreenState();
}

class _KanaDrillScreenState extends ConsumerState<KanaDrillScreen>
    with SingleTickerProviderStateMixin {
  final TtsService _tts = TtsService();
  late TabController _tabController;
  String? _lastSpoken;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tts.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('히라가나 · 가타카나 드릴'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'ひらがな'), Tab(text: 'カタカナ')],
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
          indicatorColor: theme.colorScheme.primary,
        ),
      ),
      body: Column(
        children: [
          if (_lastSpoken != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00FFD1).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('방금 재생: $_lastSpoken',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF00FFD1))),
              ),
            ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildKanaGrid(context, _hiragana, theme),
                _buildKanaGrid(context, _katakana, theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKanaGrid(BuildContext context, List<List<String?>> rows, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text('글자를 탭하면 TTS로 발음이 재생됩니다',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 12),
          ...rows.map((row) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: row.map((kana) {
                if (kana == null) return const SizedBox(width: 52, height: 52);
                return Padding(
                  padding: const EdgeInsets.all(3),
                  child: InkWell(
                    onTap: () async {
                      setState(() => _lastSpoken = kana);
                      await _tts.speakJapanese(kana);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(alpha: 0.3)),
                      ),
                      child: Center(
                        child: Text(kana,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          )),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          )),
        ],
      ),
    );
  }

  static const List<List<String?>> _hiragana = [
    ['あ', 'い', 'う', 'え', 'お'],
    ['か', 'き', 'く', 'け', 'こ'],
    ['さ', 'し', 'す', 'せ', 'そ'],
    ['た', 'ち', 'つ', 'て', 'と'],
    ['な', 'に', 'ぬ', 'ね', 'の'],
    ['は', 'ひ', 'ふ', 'へ', 'ほ'],
    ['ま', 'み', 'む', 'め', 'も'],
    ['や', null, 'ゆ', null, 'よ'],
    ['ら', 'り', 'る', 'れ', 'ろ'],
    ['わ', null, null, null, 'を'],
    ['ん', null, null, null, null],
    ['が', 'ぎ', 'ぐ', 'げ', 'ご'],
    ['ざ', 'じ', 'ず', 'ぜ', 'ぞ'],
    ['だ', 'ぢ', 'づ', 'で', 'ど'],
    ['ば', 'び', 'ぶ', 'べ', 'ぼ'],
    ['ぱ', 'ぴ', 'ぷ', 'ぺ', 'ぽ'],
  ];

  static const List<List<String?>> _katakana = [
    ['ア', 'イ', 'ウ', 'エ', 'オ'],
    ['カ', 'キ', 'ク', 'ケ', 'コ'],
    ['サ', 'シ', 'ス', 'セ', 'ソ'],
    ['タ', 'チ', 'ツ', 'テ', 'ト'],
    ['ナ', 'ニ', 'ヌ', 'ネ', 'ノ'],
    ['ハ', 'ヒ', 'フ', 'ヘ', 'ホ'],
    ['マ', 'ミ', 'ム', 'メ', 'モ'],
    ['ヤ', null, 'ユ', null, 'ヨ'],
    ['ラ', 'リ', 'ル', 'レ', 'ロ'],
    ['ワ', null, null, null, 'ヲ'],
    ['ン', null, null, null, null],
    ['ガ', 'ギ', 'グ', 'ゲ', 'ゴ'],
    ['ザ', 'ジ', 'ズ', 'ゼ', 'ゾ'],
    ['ダ', 'ヂ', 'ヅ', 'デ', 'ド'],
    ['バ', 'ビ', 'ブ', 'ベ', 'ボ'],
    ['パ', 'ピ', 'プ', 'ペ', 'ポ'],
  ];
}
