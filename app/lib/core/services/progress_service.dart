import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sync_item.dart';

class ProgressService {
  static const String _prefixPosition = 'progress_pos_';
  static const String _prefixTimestamp = 'progress_ts_';
  static const String _prefixDuration = 'progress_dur_';
  static const String _keyRecentPaths = 'recent_paths';

  Future<void> saveProgress(String audioPath, Duration position, Duration? totalDuration) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _sanitizeKey(audioPath);
    await prefs.setInt('$_prefixPosition$key', position.inMilliseconds);
    await prefs.setString('$_prefixTimestamp$key', DateTime.now().toIso8601String());
    if (totalDuration != null) {
      await prefs.setInt('$_prefixDuration$key', totalDuration.inMilliseconds);
    }
    // Update recent paths list (max 10)
    final recent = prefs.getStringList(_keyRecentPaths) ?? [];
    recent.remove(audioPath);
    recent.insert(0, audioPath);
    if (recent.length > 10) recent.removeLast();
    await prefs.setStringList(_keyRecentPaths, recent);
  }

  Future<Map<String, dynamic>> loadProgress(String audioPath) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _sanitizeKey(audioPath);
    final posMs = prefs.getInt('$_prefixPosition$key') ?? 0;
    final tsStr = prefs.getString('$_prefixTimestamp$key');
    final durMs = prefs.getInt('$_prefixDuration$key');
    return {
      'position': Duration(milliseconds: posMs),
      'lastPlayedAt': tsStr != null ? DateTime.tryParse(tsStr) : null,
      'totalDuration': durMs != null ? Duration(milliseconds: durMs) : null,
    };
  }

  Future<List<String>> getRecentAudioPaths() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyRecentPaths) ?? [];
  }

  Future<void> saveSpeed(String audioPath, double speed) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _sanitizeKey(audioPath);
    await prefs.setDouble('progress_speed_$key', speed);
  }

  Future<double> loadSpeed(String audioPath, {double defaultSpeed = 1.0}) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _sanitizeKey(audioPath);
    return prefs.getDouble('progress_speed_$key') ?? defaultSpeed;
  }

  Future<void> saveSyncItems(String audioPath, List<SyncItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _sanitizeKey(audioPath);
    final jsonList = items.map((i) => {
      'startTime': i.startTime.inMilliseconds,
      'endTime': i.endTime.inMilliseconds,
      'sentence': i.sentence,
    }).toList();
    await prefs.setString('progress_sync_$key', jsonEncode(jsonList));
  }

  Future<List<SyncItem>?> loadSyncItems(String audioPath) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _sanitizeKey(audioPath);
    final str = prefs.getString('progress_sync_$key');
    if (str == null) return null;
    try {
      final List<dynamic> jsonList = jsonDecode(str);
      return jsonList.map((e) => SyncItem(
        startTime: Duration(milliseconds: e['startTime'] as int),
        endTime: Duration(milliseconds: e['endTime'] as int),
        sentence: e['sentence'] as String,
      )).toList();
    } catch (_) {
      return null;
    }
  }

  String _sanitizeKey(String path) {
    return path.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
  }
}
