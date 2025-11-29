import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryService {
  static final HistoryService _instance = HistoryService._internal();
  factory HistoryService() => _instance;
  HistoryService._internal();

  static const String _key = 'tool_history';
  static const int _maxHistory = 10;
  final ValueNotifier<List<String>> historyNotifier = ValueNotifier([]);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_key) ?? [];
    historyNotifier.value = history;
  }

  Future<void> addToHistory(String toolId) async {
    final prefs = await SharedPreferences.getInstance();
    final currentHistory = List<String>.from(historyNotifier.value);

    // Remove if exists to move to top
    currentHistory.remove(toolId);

    // Add to front
    currentHistory.insert(0, toolId);

    // Limit size
    if (currentHistory.length > _maxHistory) {
      currentHistory.removeLast();
    }

    await prefs.setStringList(_key, currentHistory);
    historyNotifier.value = currentHistory;
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    historyNotifier.value = [];
  }
}
