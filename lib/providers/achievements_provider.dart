import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/achievement.dart';
import 'storage_provider.dart';

class AchievementsNotifier extends StateNotifier<List<Achievement>> {
  AchievementsNotifier(this._ref)
      : super(_ref.read(storageServiceProvider).loadAchievements());

  final Ref _ref;

  Future<void> unlock(AchievementId id) async {
    final index = state.indexWhere((a) => a.id == id);
    if (index == -1) return;
    if (state[index].unlocked) return;

    final updated = [...state];
    updated[index] = updated[index].copyWith(
      unlocked: true,
      unlockedAt: DateTime.now(),
    );
    state = updated;
    await _ref.read(storageServiceProvider).saveAchievements(state);
  }

  int get unlockedCount => state.where((a) => a.unlocked).length;
}

final achievementsProvider =
    StateNotifierProvider<AchievementsNotifier, List<Achievement>>((ref) {
  return AchievementsNotifier(ref);
});
