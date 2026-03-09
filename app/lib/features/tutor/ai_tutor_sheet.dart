import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/chat_message.dart';
import '../../core/providers/ai_provider.dart';
import 'tutor_provider.dart';

class AiTutorBottomSheet extends ConsumerStatefulWidget {
  final String sentence;

  const AiTutorBottomSheet({super.key, required this.sentence});

  @override
  ConsumerState<AiTutorBottomSheet> createState() => _AiTutorBottomSheetState();
}

class _AiTutorBottomSheetState extends ConsumerState<AiTutorBottomSheet> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;
  bool _grammarAdded = false;

  @override
  void initState() {
    super.initState();
    // Clear previous chat history when sheet opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatHistoryProvider.notifier).clear();
      _grammarAdded = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSending) return;

    ref.read(chatHistoryProvider.notifier).addMessage(
      ChatMessage(role: 'user', content: text),
    );
    _controller.clear();
    setState(() => _isSending = true);
    _scrollToBottom();

    try {
      final response = await ref.read(sendChatMessageProvider(text).future);
      ref.read(chatHistoryProvider.notifier).addMessage(
        ChatMessage(role: 'assistant', content: response),
      );
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
        _scrollToBottom();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeAi = ref.watch(activeAiProvider);
    final grammarAsync = ref.watch(grammarExplanationProvider(widget.sentence));
    final chatHistory = ref.watch(chatHistoryProvider);

    // When grammar loads, add it as the first assistant message
    grammarAsync.whenData((explanation) {
      if (!_grammarAdded && explanation.isNotEmpty) {
        _grammarAdded = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && ref.read(chatHistoryProvider).isEmpty) {
            ref.read(chatHistoryProvider.notifier).addMessage(
              ChatMessage(role: 'assistant', content: explanation),
            );
            _scrollToBottom();
          }
        });
      }
    });

    IconData aiIcon;
    switch (activeAi) {
      case AiProviderType.openai: aiIcon = Icons.psychology; break;
      case AiProviderType.google: aiIcon = Icons.auto_awesome; break;
      case AiProviderType.claude: aiIcon = Icons.memory; break;
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117).withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        border: Border.all(color: const Color(0xFF00FFD1).withValues(alpha: 0.5), width: 1.5),
        boxShadow: [BoxShadow(color: const Color(0xFF00FFD1).withValues(alpha: 0.15), blurRadius: 40)]
      ),
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).viewPadding.bottom + 20
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.white38, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          // AI icon
          Center(
            child: Icon(
              aiIcon, color: const Color(0xFF00FFD1), size: 40,
              shadows: const [Shadow(color: Color(0xFF00FFD1), blurRadius: 15)],
            ),
          ),
          const SizedBox(height: 20),
          // Sentence display
          Center(
            child: Text(
              '"${widget.sentence}"',
              style: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic, fontSize: 14),
              textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 20),
          // Chat area
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 300),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: grammarAsync.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(color: Color(0xFF00FFD1)),
                  ),
                ),
                error: (err, _) => Text("오류: $err", style: const TextStyle(color: Colors.red)),
                data: (_) {
                  if (chatHistory.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(color: Color(0xFF00FFD1)),
                    );
                  }
                  return ListView.separated(
                    controller: _scrollController,
                    shrinkWrap: true,
                    itemCount: chatHistory.length + (_isSending ? 1 : 0),
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      if (_isSending && index == chatHistory.length) {
                        // Loading indicator for pending response
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const SizedBox(
                              width: 40,
                              child: LinearProgressIndicator(
                                color: Color(0xFF00FFD1),
                                backgroundColor: Colors.transparent,
                              ),
                            ),
                          ),
                        );
                      }
                      final msg = chatHistory[index];
                      final isUser = msg.role == 'user';
                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isUser
                                ? const Color(0xFF00FFD1).withValues(alpha: 0.25)
                                : Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: Radius.circular(isUser ? 16 : 4),
                              bottomRight: Radius.circular(isUser ? 4 : 16),
                            ),
                            border: isUser
                                ? Border.all(color: const Color(0xFF00FFD1).withValues(alpha: 0.4))
                                : null,
                          ),
                          child: Text(
                            msg.content,
                            style: TextStyle(
                              color: isUser
                                  ? const Color(0xFF00FFD1)
                                  : Colors.white.withValues(alpha: 0.9),
                              height: 1.5,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Input row
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: const Color(0xFF00FFD1).withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const SizedBox(width: 20),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Ask AI...",
                      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                    enabled: !_isSending,
                  ),
                ),
                IconButton(
                  icon: _isSending
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF00FFD1),
                          ),
                        )
                      : const Icon(Icons.send, color: Color(0xFF00FFD1)),
                  onPressed: _isSending ? null : _sendMessage,
                ),
                const SizedBox(width: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
