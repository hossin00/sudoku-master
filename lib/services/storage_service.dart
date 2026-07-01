import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/game_state.dart';
import '../models/stats.dart';
import '../models/settings.dart';
import '../models/achievement.dart';

class StorageService {
  static const String _gameBoxName = 'game_box';
  static const String _statsBoxName = 'stats_box';
  static const String _settingsBoxName = 'settings_box';
  static const String _achievementsBoxName = 'achievements_box';

  static const String _currentGameKey = 'current_game';
  static const String _statsKey = 'stats';
  static const String _settingsKey = 'settings';
  static const String _achievementsKey = 'achievements';

  late Box<String> _gameBox;
  late Box<String> _statsBox;
  late Box<String> _settingsBox;
  late Box<String> _achievementsBox;

  Future<void> init() async {
    await Hive.initFlutter();
    _gameBox = await Hive.openBox<String>(_gameBoxName);
    _statsBox = await Hive.openBox<String>(_statsBoxName);
    _settingsBox = await Hive.openBox<String>(_settingsBoxName);
    _achievementsBox = await Hive.openBox<String>(_achievementsBoxName);
  }

  Future<void> saveCurrentGame(GameState state) async {
    await _gameBox.put(_currentGameKey, jsonEncode(state.toJson()));
  }

  Future<void> clearCurrentGame() async {
    await _gameBox.delete(_currentGameKey);
  }

  GameState? loadCurrentGame() {
    final raw = _gameBox.get(_currentGameKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return GameState.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveStats(GameStats stats) async {
    await _statsBox.put(_statsKey, jsonEncode(stats.toJson()));
  }

  GameStats loadStats() {
    final raw = _statsBox.get(_statsKey);
    if (raw == null || raw.isEmpty) return GameStats();
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return GameStats.fromJson(map);
    } catch (_) {
      return GameStats();
    }
  }

  Future<void> saveSettings(AppSettings settings) async {
    await _settingsBox.put(_settingsKey, jsonEncode(settings.toJson()));
  }

  AppSettings loadSettings() {
    final raw = _settingsBox.get(_settingsKey);
    if (raw == null || raw.isEmpty) return const AppSettings();
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return AppSettings.fromJson(map);
    } catch (_) {
      return const AppSettings();
    }
  }

  Future<void> saveAchievements(List<Achievement> achievements) async {
    final data = achievements
        .map((a) => {
              'id': a.id.name,
              'unlocked': a.unlocked,
              'unlockedAt': a.unlockedAt?.toIso8601String(),
            })
        .toList();
    await _achievementsBox.put(_achievementsKey, jsonEncode(data));
  }

  List<Achievement> loadAchievements() {
    final defaults = Achievement.defaults();
    final raw = _achievementsBox.get(_achievementsKey);
    if (raw == null || raw.isEmpty) return defaults;
    try {
      final list = jsonDecode(raw) as List;
      return defaults.map((a) {
        final saved = list.firstWhere(
          (e) => e is Map && e['id'] == a.id.name,
          orElse: () => null,
        );
        if (saved == null) return a;
        return a.copyWith(
          unlocked: saved['unlocked'] as bool? ?? false,
          unlockedAt: saved['unlockedAt'] != null
              ? DateTime.tryParse(saved['unlockedAt'] as String)
              : null,
        );
      }).toList();
    } catch (_) {
      return defaults;
    }
  }
}
