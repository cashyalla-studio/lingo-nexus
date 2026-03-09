import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Playlist {
  final String id;
  final String name;
  final List<String> audioPaths;
  final String emoji;
  final String? description;

  Playlist({
    required this.id,
    required this.name,
    required this.audioPaths,
    this.emoji = '🎵',
    this.description,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'audioPaths': audioPaths,
        'emoji': emoji,
        'description': description,
      };

  factory Playlist.fromJson(Map<String, dynamic> json) => Playlist(
        id: json['id'],
        name: json['name'],
        audioPaths: List<String>.from(json['audioPaths']),
        emoji: json['emoji'] as String? ?? '🎵',
        description: json['description'] as String?,
      );

  Playlist copyWith({
    String? name,
    List<String>? audioPaths,
    String? emoji,
    String? description,
  }) {
    return Playlist(
      id: id,
      name: name ?? this.name,
      audioPaths: audioPaths ?? this.audioPaths,
      emoji: emoji ?? this.emoji,
      description: description ?? this.description,
    );
  }
}

final currentPlaylistIdProvider = StateProvider<String?>((ref) => null);

final playlistProvider = StateNotifierProvider<PlaylistNotifier, List<Playlist>>((ref) {
  return PlaylistNotifier();
});

class PlaylistNotifier extends StateNotifier<List<Playlist>> {
  static const _key = 'user_playlists';

  PlaylistNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data != null) {
      final List decoded = jsonDecode(data);
      state = decoded.map((e) => Playlist.fromJson(e)).toList();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(state.map((e) => e.toJson()).toList());
    await prefs.setString(_key, data);
  }

  void createPlaylist(String name, {String emoji = '🎵', String? description, List<String> initialItems = const []}) {
    final newPlaylist = Playlist(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      audioPaths: initialItems,
      emoji: emoji,
      description: description,
    );
    state = [...state, newPlaylist];
    _save();
  }

  void deletePlaylist(String id) {
    state = state.where((p) => p.id != id).toList();
    _save();
  }

  void addItemsToPlaylist(String id, List<String> paths) {
    state = state.map((p) {
      if (p.id == id) {
        final newPaths = {...p.audioPaths, ...paths}.toList();
        return p.copyWith(audioPaths: newPaths);
      }
      return p;
    }).toList();
    _save();
  }

  void removeItemsFromPlaylist(String id, List<String> paths) {
    state = state.map((p) {
      if (p.id == id) {
        return p.copyWith(
          audioPaths: p.audioPaths.where((path) => !paths.contains(path)).toList(),
        );
      }
      return p;
    }).toList();
    _save();
  }

  void renamePlaylist(String id, String newName) {
    state = state.map((p) {
      if (p.id == id) return p.copyWith(name: newName);
      return p;
    }).toList();
    _save();
  }

  void updatePlaylist(String id, {String? name, String? emoji, String? description}) {
    state = state.map((p) {
      if (p.id == id) {
        return Playlist(
          id: p.id,
          name: name ?? p.name,
          audioPaths: p.audioPaths,
          emoji: emoji ?? p.emoji,
          description: description ?? p.description,
        );
      }
      return p;
    }).toList();
    _save();
  }

  void reorderItems(String id, int oldIndex, int newIndex) {
    state = state.map((p) {
      if (p.id == id) {
        final paths = List<String>.from(p.audioPaths);
        final item = paths.removeAt(oldIndex);
        paths.insert(newIndex, item);
        return p.copyWith(audioPaths: paths);
      }
      return p;
    }).toList();
    _save();
  }
}
