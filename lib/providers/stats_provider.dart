import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/difficulty.dart';
import '../models/stats.dart';
import 'storage_provider.dart';

class StatsNotifier extends StateNotifier<GameStats> {
  StatsNotifier(this._ref) : super(_ref.read(storageServiceProvider).loadStats());

  final Ref _ref;

  Future<void> _persist() async {
    await _ref.read(storageServiceProvider).saveStats(state);
  }

  Future<void> recordGameStarted(Difficulty d) async {
    final played = Map<String, int>.from(state.gamesPlayed);
    played[d.name] = (played[d.name] ?? 0) + 1;
    state = state.copyWith(gamesPlayed: played);
    await _persist();
  }

  Future<void> recordGameWon(Difficulty d, int seconds, int hintsUsed) async {
    final won = Map<String, int>.from(state.gamesWon);
    won[d.name] = (won[d.name] ?? 0) + 1;

    final best = Map<String, int>.from(state.bestTimes);
    final currentBest = best[d.name] ?? 0;
    if (currentBest == 0 || seconds < currentBest) {
      best[d.name] = seconds;
    }
    state = state.copyWith(
      gamesWon: won,
      bestTimes: best,
      totalHintsUsed: state.totalHintsUsed + hintsUsed,
      totalPlayTimeSeconds: state.totalPlayTimeSeconds + seconds,
    );
    await _persist();
  }

  Future<void> recordDailyCompleted(String dateKey) async {
    final today = dateKey;
    final last = state.lastDailyDate;

    int newStreak = 1;
    if (last != null) {
      final lastDate = DateTime.tryParse(last);
      final todayDate = DateTime.tryParse(today);
      if (lastDate != null && todayDate != null) {
        final diff = todayDate.difference(lastDate).inDays;
        if (diff == 1) {
          newStreak = state.currentStreak + 1;
        } else if (diff == 0) {
          newStreak = state.currentStreak;
        }
      }
    }

    final longest = newStreak > state.longestStreak ? newStreak : state.longestStreak;
    state = state.copyWith(
      currentStreak: newStreak,
      longestStreak: longest,
      lastDailyDate: today,
    );
    await _persist();
  }
}

final statsProvider = StateNotifierProvider<StatsNotifier, GameStats>((ref) {
  return StatsNotifier(ref);
});
