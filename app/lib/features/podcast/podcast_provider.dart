import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'podcast_model.dart';
import 'podcast_service.dart';

final podcastServiceProvider = Provider((ref) => PodcastService());

// ── Subscribed feeds notifier ──
class PodcastFeedsNotifier extends StateNotifier<List<PodcastFeed>> {
  PodcastFeedsNotifier() : super([]) {
    _load();
  }

  static const _key = 'podcast_feeds_v1';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json != null) {
      try {
        final list = jsonDecode(json) as List;
        state = list
            .map((e) => PodcastFeed.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        state = [];
      }
    }
  }

  Future<void> addFeed(PodcastFeed feed) async {
    if (state.any((f) => f.id == feed.id || f.url == feed.url)) return;
    state = [...state, feed];
    await _save();
  }

  Future<void> removeFeed(String id) async {
    state = state.where((f) => f.id != id).toList();
    await _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _key, jsonEncode(state.map((f) => f.toJson()).toList()));
  }
}

final podcastFeedsProvider =
    StateNotifierProvider<PodcastFeedsNotifier, List<PodcastFeed>>(
  (ref) => PodcastFeedsNotifier(),
);

// ── Episode loading per feed (cached via autoDispose.family) ──
final podcastEpisodesProvider = FutureProvider.autoDispose
    .family<List<PodcastEpisode>, PodcastFeed>((ref, feed) async {
  final service = ref.read(podcastServiceProvider);
  final result = await service.parseFeed(feed.url, feed.id);
  return result.episodes;
});

// ── Download state ──
// Maps episode.id -> 'downloading' | 'done' | 'error'
class _DownloadStateNotifier extends StateNotifier<Map<String, String>> {
  _DownloadStateNotifier() : super({});

  void setDownloading(String id) =>
      state = {...state, id: 'downloading'};
  void setDone(String id) =>
      state = {...state, id: 'done'};
  void setError(String id) =>
      state = {...state, id: 'error'};
  String? statusOf(String id) => state[id];
}

final podcastDownloadStateProvider =
    StateNotifierProvider<_DownloadStateNotifier, Map<String, String>>(
  (ref) => _DownloadStateNotifier(),
);
