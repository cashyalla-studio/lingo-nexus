import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lingo_nexus/generated/l10n/app_localizations.dart';
import '../../core/models/chat_message.dart';
import '../../core/theme/app_theme.dart';
import 'conversation_provider.dart';

class ConversationScreen extends ConsumerStatefulWidget {
  const ConversationScreen({super.key});

  @override
  ConsumerState<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends ConsumerState<ConversationScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;
  bool _sessionStarted = false;

  static const List<String> _languages = ['English', 'Japanese', 'Korean', 'Spanish', 'French'];

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

  Future<void> _startSession() async {
    setState(() { _isSending = true; _sessionStarted = true; });
    ref.read(conversationHistoryProvider.notifier).clear();

    // Send an opening message
    final greeting = 'Hello! Let\'s start our conversation.';
    ref.read(conversationHistoryProvider.notifier).addMessage(
      ChatMessage(role: 'user', content: greeting));

    try {
      final response = await ref.read(sendConversationMessageProvider(greeting).future);
      ref.read(conversationHistoryProvider.notifier).addMessage(
        ChatMessage(role: 'assistant', content: response));
    } catch (_) {}

    if (mounted) setState(() => _isSending = false);
    _scrollToBottom();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSending) return;

    _controller.clear();
    ref.read(conversationHistoryProvider.notifier).addMessage(
      ChatMessage(role: 'user', content: text));
    setState(() => _isSending = true);
    _scrollToBottom();

    try {
      final response = await ref.read(sendConversationMessageProvider(text).future);
      if (mounted) {
        ref.read(conversationHistoryProvider.notifier).addMessage(
          ChatMessage(role: 'assistant', content: response));
      }
    } catch (_) {}

    if (mounted) setState(() => _isSending = false);
    _scrollToBottom();
  }

  void _suggestTopic() {
    final language = ref.read(conversationLanguageProvider);
    final topics = conversationTopics[language] ?? conversationTopics['English']!;
    final topic = (topics..shuffle()).first;
    _controller.text = topic;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: _controller.text.length));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final history = ref.watch(conversationHistoryProvider);
    final selectedLanguage = ref.watch(conversationLanguageProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.homeAiConversation, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Language selector
          PopupMenuButton<String>(
            initialValue: selectedLanguage,
            icon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(selectedLanguage, style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary)),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
            onSelected: (lang) {
              ref.read(conversationLanguageProvider.notifier).state = lang;
              ref.read(conversationHistoryProvider.notifier).clear();
              setState(() { _sessionStarted = false; _isSending = false; });
            },
            itemBuilder: (ctx) => _languages.map((l) =>
              PopupMenuItem(value: l, child: Text(l))).toList(),
            color: theme.colorScheme.surfaceContainerHighest,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Chat area
          Expanded(
            child: !_sessionStarted
                ? _buildStartScreen(context, theme, selectedLanguage)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: history.length + (_isSending ? 1 : 0),
                    itemBuilder: (ctx, i) {
                      if (i == history.length) {
                        return _buildTypingIndicator(theme);
                      }
                      final msg = history[i];
                      return _buildMessageBubble(msg, theme);
                    },
                  ),
          ),

          // Input area
          if (_sessionStarted)
            Container(
              padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(context).viewInsets.bottom + 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(top: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.3))),
              ),
              child: Row(
                children: [
                  // Topic suggestion
                  IconButton(
                    onPressed: _suggestTopic,
                    icon: Icon(Icons.lightbulb_outline, color: theme.colorScheme.primary),
                    tooltip: l10n.conversationTopicSuggest,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      enabled: !_isSending,
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: l10n.conversationInputHint(selectedLanguage),
                        hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _isSending ? null : _sendMessage,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isSending
                            ? theme.colorScheme.outline.withValues(alpha: 0.3)
                            : theme.colorScheme.primary,
                      ),
                      child: _isSending
                          ? Padding(
                              padding: const EdgeInsets.all(10),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            )
                          : Icon(Icons.send_rounded, color: theme.colorScheme.onPrimary, size: 20),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStartScreen(BuildContext context, ThemeData theme, String language) {
    final l10n = AppLocalizations.of(context)!;
    final topics = conversationTopics[language] ?? conversationTopics['English']!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.colorScheme.primary.withValues(alpha: 0.15), theme.colorScheme.surface],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Icon(Icons.chat_bubble_outline, size: 48, color: theme.colorScheme.primary),
                const SizedBox(height: 16),
                Text(l10n.conversationPracticeTitle(language), style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(l10n.conversationWelcomeMsg,
                  style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _startSession,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(l10n.conversationStartBtn),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(l10n.conversationTopicExamples, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ...topics.take(4).map((topic) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () {
                _controller.text = topic;
                _startSession();
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(Icons.arrow_forward_ios, size: 14, color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 12),
                    Expanded(child: Text(topic, style: theme.textTheme.bodyMedium)),
                  ],
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg, ThemeData theme) {
    final isUser = msg.role == 'user';
    return Padding(
      padding: EdgeInsets.only(
        bottom: 12,
        left: isUser ? 48 : 0,
        right: isUser ? 0 : 48,
      ),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isUser)
            Padding(
              padding: const EdgeInsets.only(bottom: 4, left: 4),
              child: Text('AI', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary)),
            ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isUser ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(isUser ? 18 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 18),
              ),
            ),
            child: Text(
              msg.content,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: isUser ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, right: 48),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) => AnimatedContainer(
            duration: Duration(milliseconds: 300 + i * 100),
            margin: const EdgeInsets.symmetric(horizontal: 2),
            width: 8, height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
            ),
          )),
        ),
      ),
    );
  }
}
