import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../models/difficulty.dart';
import '../providers/stats_provider.dart';
import '../utils/formatters.dart';
import '../widgets/glow_card.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildOverallCard(stats),
              const SizedBox(height: 16),
              GlowCard(
                borderColor: AppColors.gold,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.local_fire_department_rounded,
                            color: const Color(0xFFFF6B6B), size: 26),
                        const SizedBox(width: 10),
                        const Text(
                          'Streak',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _statTile('Current', '${stats.currentStreak}', const Color(0xFFFF6B6B)),
                        ),
                        Expanded(
                          child: _statTile('Longest', '${stats.longestStreak}', AppColors.gold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                child: Text(
                  'By Difficulty',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
              ),
              ...Difficulty.values.map((d) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _difficultyCard(d, stats),
                  )),
              const SizedBox(height: 16),
              GlowCard(
                child: Row(
                  children: [
                    Expanded(
                      child: _iconStat(
                        Icons.lightbulb_rounded,
                        AppColors.gold,
                        'Hints Used',
                        '${stats.totalHintsUsed}',
                      ),
                    ),
                    Container(width: 1, height: 40, color: AppColors.border.withOpacity(0.5)),
                    Expanded(
                      child: _iconStat(
                        Icons.timer_rounded,
                        AppColors.blue,
                        'Total Time',
                        formatDuration(stats.totalPlayTimeSeconds),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverallCard(stats) {
    return GlowCard(
      borderColor: AppColors.blue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events_rounded, color: AppColors.blue, size: 26),
              const SizedBox(width: 10),
              const Text(
                'Overall',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _statTile('Played', '${stats.totalGamesPlayed()}', AppColors.blue)),
              Expanded(child: _statTile('Won', '${stats.totalGamesWon()}', AppColors.gold)),
              Expanded(
                child: _statTile(
                  'Win Rate',
                  '${(stats.winRate() * 100).toStringAsFixed(0)}%',
                  AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statTile(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 26,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
        ),
      ],
    );
  }

  Widget _difficultyCard(Difficulty d, stats) {
    final played = stats.gamesPlayedFor(d);
    final won = stats.gamesWonFor(d);
    final best = stats.bestTimeFor(d);
    return GlowCard(
      borderColor: d.color,
      child: Row(
        children: [
          Container(
            width: 8,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [d.color, d.color.withOpacity(0.3)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  d.label,
                  style: TextStyle(
                    color: d.color,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Played: $played • Won: $won',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('Best', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
              const SizedBox(height: 2),
              Text(
                best > 0 ? formatDuration(best) : '--:--',
                style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _iconStat(IconData icon, Color color, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: color, size: 26),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w700)),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
      ],
    );
  }
}
