import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../tutor/tutor_provider.dart';

class VocabularyBottomSheet extends ConsumerWidget {
  final String word;
  final String contextSentence;

  const VocabularyBottomSheet({
    super.key,
    required this.word,
    required this.contextSentence,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vocabAsync = ref.watch(vocabularyProvider((word: word, context: contextSentence)));

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117).withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        border: Border.all(color: const Color(0xFF00FFD1).withValues(alpha: 0.5), width: 1.5),
        boxShadow: [BoxShadow(color: const Color(0xFF00FFD1).withValues(alpha: 0.15), blurRadius: 40)],
      ),
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.white38, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Icon(
              Icons.menu_book,
              color: const Color(0xFF00FFD1), size: 36,
              shadows: const [Shadow(color: Color(0xFF00FFD1), blurRadius: 15)],
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              '"$word"',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              contextSentence,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxHeight: 280),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: vocabAsync.when(
              data: (text) => SingleChildScrollView(
                child: Text(
                  text,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.9), height: 1.6, fontSize: 15),
                ),
              ),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(color: Color(0xFF00FFD1)),
                ),
              ),
              error: (err, _) => Text("오류: $err", style: const TextStyle(color: Colors.red)),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
