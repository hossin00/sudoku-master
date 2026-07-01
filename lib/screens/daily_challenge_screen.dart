import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../providers/game_provider.dart';
import '../providers/stats_provider.dart';
import '../utils/formatters.dart';
import '../widgets/glow_card.dart';
import '../widgets/gradient_button.dart';
import 'game_screen.dart';

class DailyChallengeScreen extends ConsumerWidget {
  const DailyChallengeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider);
    final today = todayDateKey();
    final alreadyCompleted = stats.lastDailyDate == today;

    return Scaffold(
      appBar: AppBar(title: const Text('Daily Challenge')),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: AppColors.goldGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withOpacity(0.4),
                        blurRadius: 30,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.calendar_today_rounded,
                          color: Colors.white, size: 40),
                      const SizedBox(height: 12),
                      Text(
                        friendlyDate(today),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Today's Puzzle",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                GlowCard(
                  borderColor: const Color(0xFFFF6B6B),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B6B).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.local_fire_department_rounded,
                            color: const Color(0xFFFF6B6B), size: 26),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Current Streak',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            ),
                            Text(
                              '${stats.currentStreak} day${stats.currentStreak == 1 ? '' : 's'}',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Longest', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                          Text(
                            '${stats.longestStreak}',
                            style: const TextStyle(color: AppColors.gold, fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                GlowCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.card_giftcard_rounded, color: AppColors.purple, size: 22),
                          const SizedBox(width: 8),
                          const Text(
                            'Reward',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Complete daily challenges to build your streak. Reach 7 days in a row to unlock the Weekly Warrior achievement.',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (alreadyCompleted)
                  GlowCard(
                    borderColor: AppColors.success,
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_rounded, color: AppColors.success, size: 30),
                        const SizedBox(width: 12),
                        Expanded(
                          child: const Text(
                            "Today's challenge is complete!\nCome back tomorrow.",
                            style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  GradientButton(
                    label: 'Start Challenge',
                    icon: Icons.play_arrow_rounded,
                    gradient: AppColors.goldGradient,
                    glow: true,
                    onPressed: () async {
                      await ref.read(gameProvider.notifier).startDailyChallenge(today);
                      if (!context.mounted) return;
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const GameScreen()),
                      );
                    },
                  ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
