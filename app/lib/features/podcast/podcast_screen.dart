import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lingo_nexus/generated/l10n/app_localizations.dart';
import '../../core/models/language_option.dart';
import '../../core/models/study_item.dart';
import '../scanner/scanner_provider.dart';
import 'podcast_model.dart';
import 'podcast_provider.dart';

class PodcastScreen extends ConsumerWidget {
  const PodcastScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final feeds = ref.watch(podcastFeedsProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.podcastTitle,
                    style: theme.textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.add_circle_outline,
                        color: theme.colorScheme.primary, size: 28),
                    tooltip: l10n.podcastAddFeed,
                    onPressed: () => _showAddFeedDialog(context, ref, l10n),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: feeds.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.podcasts,
                                size: 64,
                                color: theme.colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.4)),
                            const SizedBox(height: 16),
                            Text(
                              l10n.podcastNoFeeds,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () =>
                                  _showAddFeedDialog(context, ref, l10n),
                              icon: const Icon(Icons.add),
                              label: Text(l10n.podcastAddFeed),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemCount: feeds.length,
                      itemBuilder: (context, index) {
                        final feed = feeds[index];
                        return _FeedCard(feed: feed);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddFeedDialog(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) async {
    final urlController = TextEditingController();
    String? selectedLang;
    bool loading = false;
    String? errorMsg;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(l10n.podcastAddFeed),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: urlController,
                decoration: InputDecoration(
                  labelText: l10n.podcastFeedUrl,
                  hintText: 'https://example.com/feed.xml',
                  border: const OutlineInputBorder(),
                  errorText: errorMsg,
                ),
                keyboardType: TextInputType.url,
                autocorrect: false,
              ),
              const SizedBox(height: 16),
              InputDecorator(
                decoration: InputDecoration(
                  labelText: l10n.syncAudioLanguage,
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedLang,
                    isExpanded: true,
                    hint: Text(l10n.syncAudioLanguage),
                    items: kStudyLanguages
                        .where((l) => l.code != 'other')
                        .map((l) => DropdownMenuItem(
                              value: l.code,
                              child: Text('${l.emoji} ${l.name}'),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => selectedLang = v),
                  ),
                ),
              ),
              if (loading) ...[
                const SizedBox(height: 16),
                const LinearProgressIndicator(),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: loading
                  ? null
                  : () async {
                      final url = urlController.text.trim();
                      if (url.isEmpty) {
                        setState(() => errorMsg = l10n.podcastFeedUrl);
                        return;
                      }
                      setState(() {
                        loading = true;
                        errorMsg = null;
                      });
                      try {
                        final service = ref.read(podcastServiceProvider);
                        final result = await service.parseFeed(
                            url, url.hashCode.abs().toString());
                        final feed = PodcastFeed(
                          id: url.hashCode.abs().toString(),
                          url: url,
                          title: result.title,
                          imageUrl: result.imageUrl,
                          language: selectedLang,
                          addedAt: DateTime.now(),
                        );
                        await ref
                            .read(podcastFeedsProvider.notifier)
                            .addFeed(feed);
                        if (ctx.mounted) Navigator.pop(ctx);
                      } catch (e) {
                        setState(() {
                          loading = false;
                          errorMsg = e.toString();
                        });
                      }
                    },
              child: Text(l10n.podcastSubscribe),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedCard extends ConsumerWidget {
  final PodcastFeed feed;

  const _FeedCard({required this.feed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => _EpisodesScreen(feed: feed),
          ));
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              // Thumbnail or icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: feed.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          feed.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.podcasts,
                            color: theme.colorScheme.primary,
                            size: 28,
                          ),
                        ),
                      )
                    : Icon(Icons.podcasts,
                        color: theme.colorScheme.primary, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feed.title,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (feed.language != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${langEmoji(feed.language)} ${langName(feed.language)}',
                        style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'remove') {
                    ref
                        .read(podcastFeedsProvider.notifier)
                        .removeFeed(feed.id);
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'remove',
                    child: Row(
                      children: [
                        const Icon(Icons.delete_outline, size: 18),
                        const SizedBox(width: 8),
                        Text(l10n.delete),
                      ],
                    ),
                  ),
                ],
              ),
              Icon(Icons.chevron_right,
                  color: theme.colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _EpisodesScreen extends ConsumerWidget {
  final PodcastFeed feed;

  const _EpisodesScreen({required this.feed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final episodesAsync = ref.watch(podcastEpisodesProvider(feed));
    final downloadState = ref.watch(podcastDownloadStateProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        title: Text(feed.title,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),
      body: episodesAsync.when(
        data: (episodes) => episodes.isEmpty
            ? Center(child: Text(l10n.podcastEpisodes,
                style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant)))
            : ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: episodes.length,
                itemBuilder: (ctx, i) {
                  final ep = episodes[i];
                  final status = downloadState[ep.id];
                  final isDownloading = status == 'downloading';
                  final isDone = status == 'done';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ep.title,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (ep.durationLabel.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    ep.durationLabel,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                        color: theme
                                            .colorScheme.onSurfaceVariant),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (isDownloading)
                            const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          else if (isDone)
                            IconButton(
                              icon: Icon(Icons.library_add_check,
                                  color: AppLocalizations.of(context) != null
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.primary),
                              tooltip: l10n.podcastAddToLibrary,
                              onPressed: () =>
                                  _addToLibrary(context, ref, ep, l10n, theme),
                            )
                          else
                            IconButton(
                              icon: Icon(Icons.download_outlined,
                                  color: theme.colorScheme.primary),
                              tooltip: l10n.podcastDownload,
                              onPressed: () =>
                                  _downloadEpisode(ref, ep, feed, l10n),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline,
                    color: theme.colorScheme.error, size: 48),
                const SizedBox(height: 12),
                Text(e.toString(),
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _downloadEpisode(
      WidgetRef ref, PodcastEpisode ep, PodcastFeed feed, AppLocalizations l10n) async {
    ref.read(podcastDownloadStateProvider.notifier).setDownloading(ep.id);
    final service = ref.read(podcastServiceProvider);
    final localPath = await service.downloadEpisode(ep);
    if (localPath != null) {
      ep.isDownloaded = true;
      ep.localPath = localPath;
      ref.read(podcastDownloadStateProvider.notifier).setDone(ep.id);
    } else {
      ref.read(podcastDownloadStateProvider.notifier).setError(ep.id);
    }
  }

  void _addToLibrary(BuildContext context, WidgetRef ref, PodcastEpisode ep,
      AppLocalizations l10n, ThemeData theme) {
    final localPath = ep.localPath;
    if (localPath == null) return;

    final item = StudyItem(
      title: ep.title,
      audioPath: localPath,
      language: feed.language,
      source: StudyItemSource.local,
    );
    ref.read(studyItemsProvider.notifier).addItems([item]);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(l10n.podcastAddToLibrary),
      backgroundColor: theme.colorScheme.primary,
    ));
  }
}
