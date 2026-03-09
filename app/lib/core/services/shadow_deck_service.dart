import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/shadow_deck_item.dart';

class ShadowDeckService {
  static const String _key = 'shadow_deck_items';

  Future<List<ShadowDeckItem>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => ShadowDeckItem.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveAll(List<ShadowDeckItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(items.map((e) => e.toJson()).toList()));
  }

  Future<bool> add(ShadowDeckItem item) async {
    final items = await loadAll();
    if (items.any((e) => e.id == item.id)) return false; // already exists
    items.add(item);
    await saveAll(items);
    return true;
  }

  Future<void> updateItem(ShadowDeckItem updated) async {
    final items = await loadAll();
    final idx = items.indexWhere((e) => e.id == updated.id);
    if (idx >= 0) {
      items[idx] = updated;
      await saveAll(items);
    }
  }

  Future<void> remove(String id) async {
    final items = await loadAll();
    items.removeWhere((e) => e.id == id);
    await saveAll(items);
  }

  Future<List<ShadowDeckItem>> getDueItems() async {
    final items = await loadAll();
    return items.where((e) => e.isDue).toList();
  }
}
