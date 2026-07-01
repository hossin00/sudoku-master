import 'difficulty.dart';

class GameStats {
  final Map<String, int> gamesPlayed;
  final Map<String, int> gamesWon;
  final Map<String, int> bestTimes;
  final int totalHintsUsed;
  final int totalPlayTimeSeconds;
  final int currentStreak;
  final int longestStreak;
  final String? lastDailyDate;

  GameStats({
    Map<String, int>? gamesPlayed,
    Map<String, int>? gamesWon,
    Map<String, int>? bestTimes,
    this.totalHintsUsed = 0,
    this.totalPlayTimeSeconds = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastDailyDate,
  })  : gamesPlayed = gamesPlayed ?? {},
        gamesWon = gamesWon ?? {},
        bestTimes = bestTimes ?? {};

  int totalGamesPlayed() {
    return gamesPlayed.values.fold(0, (a, b) => a + b);
  }

  int totalGamesWon() {
    return gamesWon.values.fold(0, (a, b) => a + b);
  }

  double winRate() {
    final played = totalGamesPlayed();
    if (played == 0) return 0.0;
    return totalGamesWon() / played;
  }

  int gamesPlayedFor(Difficulty d) => gamesPlayed[d.name] ?? 0;
  int gamesWonFor(Difficulty d) => gamesWon[d.name] ?? 0;
  int bestTimeFor(Difficulty d) => bestTimes[d.name] ?? 0;

  GameStats copyWith({
    Map<String, int>? gamesPlayed,
    Map<String, int>? gamesWon,
    Map<String, int>? bestTimes,
    int? totalHintsUsed,
    int? totalPlayTimeSeconds,
    int? currentStreak,
    int? longestStreak,
    String? lastDailyDate,
  }) {
    return GameStats(
      gamesPlayed: gamesPlayed ?? Map<String, int>.from(this.gamesPlayed),
      gamesWon: gamesWon ?? Map<String, int>.from(this.gamesWon),
      bestTimes: bestTimes ?? Map<String, int>.from(this.bestTimes),
      totalHintsUsed: totalHintsUsed ?? this.totalHintsUsed,
      totalPlayTimeSeconds: totalPlayTimeSeconds ?? this.totalPlayTimeSeconds,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastDailyDate: lastDailyDate ?? this.lastDailyDate,
    );
  }

  Map<String, dynamic> toJson() => {
        'gamesPlayed': gamesPlayed,
        'gamesWon': gamesWon,
        'bestTimes': bestTimes,
        'totalHintsUsed': totalHintsUsed,
        'totalPlayTimeSeconds': totalPlayTimeSeconds,
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        'lastDailyDate': lastDailyDate,
      };

  factory GameStats.fromJson(Map<String, dynamic> json) {
    Map<String, int> toIntMap(dynamic m) {
      if (m is Map) {
        return m.map((k, v) => MapEntry(k.toString(), (v as num).toInt()));
      }
      return {};
    }

    return GameStats(
      gamesPlayed: toIntMap(json['gamesPlayed']),
      gamesWon: toIntMap(json['gamesWon']),
      bestTimes: toIntMap(json['bestTimes']),
      totalHintsUsed: json['totalHintsUsed'] as int? ?? 0,
      totalPlayTimeSeconds: json['totalPlayTimeSeconds'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      lastDailyDate: json['lastDailyDate'] as String?,
    );
  }
}
