import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static final FavoritesService _instance = FavoritesService._internal();
  factory FavoritesService() => _instance;
  FavoritesService._internal();

  static const String _key = 'favorite_tools';
  final ValueNotifier<List<String>> favoritesNotifier = ValueNotifier([]);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_key) ?? [];
    favoritesNotifier.value = favorites;
  }

  Future<void> toggleFavorite(String toolId) async {
    final prefs = await SharedPreferences.getInstance();
    final currentFavorites = List<String>.from(favoritesNotifier.value);

    if (currentFavorites.contains(toolId)) {
      currentFavorites.remove(toolId);
    } else {
      currentFavorites.add(toolId);
    }

    await prefs.setStringList(_key, currentFavorites);
    favoritesNotifier.value = currentFavorites;
  }

  bool isFavorite(String toolId) {
    return favoritesNotifier.value.contains(toolId);
  }
}
