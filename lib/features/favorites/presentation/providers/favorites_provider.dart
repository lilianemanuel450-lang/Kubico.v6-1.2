import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesNotifier extends StateNotifier<AsyncValue<Set<String>>> {
  static const _key = 'kubico_favorites';

  FavoritesNotifier() : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList(_key) ?? [];
      state = AsyncValue.data(saved.toSet());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggle(String propertyId) async {
    final current = Set<String>.from(state.valueOrNull ?? {});
    if (current.contains(propertyId)) {
      current.remove(propertyId);
    } else {
      current.add(propertyId);
    }
    state = AsyncValue.data(current);
    await _persist(current);
  }

  bool isFavorite(String propertyId) {
    return state.valueOrNull?.contains(propertyId) ?? false;
  }

  Future<void> _persist(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, ids.toList());
  }
}

final favoritesNotifierProvider =
    StateNotifierProvider<FavoritesNotifier, AsyncValue<Set<String>>>(
  (ref) => FavoritesNotifier(),
);
