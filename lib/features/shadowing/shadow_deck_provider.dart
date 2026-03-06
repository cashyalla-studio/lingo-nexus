import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/shadow_deck_item.dart';
import '../../core/services/shadow_deck_service.dart';

final shadowDeckServiceProvider = Provider((ref) => ShadowDeckService());

class ShadowDeckNotifier extends StateNotifier<AsyncValue<List<ShadowDeckItem>>> {
  ShadowDeckNotifier(this._service) : super(const AsyncValue.loading()) {
    load();
  }

  final ShadowDeckService _service;

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final items = await _service.loadAll();
      state = AsyncValue.data(items);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> addItem(ShadowDeckItem item) async {
    final added = await _service.add(item);
    if (added) await load();
    return added;
  }

  Future<void> updateScore(String id, int score) async {
    final items = state.value ?? [];
    final idx = items.indexWhere((e) => e.id == id);
    if (idx < 0) return;
    final item = items[idx];
    item.scheduleNext(score);
    await _service.updateItem(item);
    await load();
  }

  Future<void> removeItem(String id) async {
    await _service.remove(id);
    await load();
  }

  List<ShadowDeckItem> get dueItems =>
      (state.value ?? []).where((e) => e.isDue).toList();
}

final shadowDeckProvider = StateNotifierProvider<ShadowDeckNotifier, AsyncValue<List<ShadowDeckItem>>>((ref) {
  return ShadowDeckNotifier(ref.watch(shadowDeckServiceProvider));
});
