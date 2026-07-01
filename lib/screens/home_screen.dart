import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../models/difficulty.dart';
import '../models/game_state.dart';
import '../providers/game_provider.dart';
import '../providers/stats_provider.dart';
import '../providers/storage_provider.dart';
import '../utils/formatters.dart';
import '../widgets/glow_card.dart';
import '../widgets/gradient_button.dart';
import '../widgets/icon_logo.dart';
import 'achievements_screen.dart';
import 'daily_challenge_screen.dart';
import 'game_screen.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Difficulty _selectedDifficulty = Difficulty.easy;

  Future<void> _startNewGame() async {
    await ref.read(gameProvider.notifier).startNewGame(_selectedDifficulty);
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const GameScreen()),
    );
  }

  Future<void> _continueGame() async {
    final ok = await ref.read(gameProvider.notifier).loadSavedGame();
    if (!ok || !mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const GameScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(statsProvider);
    final savedGame = ref.watch(storageServiceProvider).loadCurrentGame();
    final hasSaved = savedGame != null && !savedGame.isCompleted;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTopBar(),
                const SizedBox(height: 20),
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.blue.withOpacity(0.35),
                          blurRadius: 30,
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color: AppColors.gold.withOpacity(0.2),
                          blurRadius: 40,
                        ),
                      ],
                    ),
                    child: const IconLogo(size: 100, borderRadius: 24),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: ShaderMask(
                    shaderCallback: (bounds) =>
                        AppColors.primaryGradient.createShader(bounds),
                    child: const Text(
                      'Sudoku Master',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ),
                const Center(
                  child: Text(
                    '2026 Edition',
                    style: TextStyle(
                      color: AppColors.gold,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                _buildDifficultySelector(),
                const SizedBox(height: 20),
                GradientButton(
                  label: 'New Game',
                  icon: Icons.play_arrow_rounded,
                  onPressed: _startNewGame,
                  glow: true,
                  height: 64,
                ),
                if (hasSaved) ...[
                  const SizedBox(height: 12),
                  _buildContinueCard(savedGame),
                ],
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _quickAction(
                        icon: Icons.calendar_today_rounded,
                        label: 'Daily',
                        color: AppColors.gold,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const DailyChallengeScreen()),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _quickAction(
                        icon: Icons.emoji_events_rounded,
                        label: 'Awards',
                        color: AppColors.purple,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AchievementsScreen()),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildStatsCard(
                  played: stats.totalGamesPlayed(),
                  won: stats.totalGamesWon(),
                  winRate: stats.winRate(),
                  streak: stats.currentStreak,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          icon: const Icon(Icons.bar_chart_rounded),
          color: AppColors.textPrimary,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const StatsScreen()),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.settings_rounded),
          color: AppColors.textPrimary,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildDifficultySelector() {
    return GlowCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Difficulty',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: Difficulty.values.map((d) {
              final selected = d == _selectedDifficulty;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedDifficulty = d),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: selected
                            ? d.color.withOpacity(0.25)
                            : AppColors.surface.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selected ? d.color : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        d.label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: selected ? d.color : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueCard(GameState game) {
    return GlowCard(
      borderColor: AppColors.gold,
      onTap: _continueGame,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.replay_rounded, color: AppColors.gold, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Continue Game',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${game.difficulty.label} • ${formatDuration(game.elapsedSeconds)}',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _quickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GlowCard(
      borderColor: color,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard({
    required int played,
    required int won,
    required double winRate,
    required int streak,
  }) {
    return GlowCard(
      child: Row(
        children: [
          Expanded(child: _statItem('Played', '$played', Icons.videogame_asset_rounded, AppColors.blue)),
          _divider(),
          Expanded(child: _statItem('Won', '$won', Icons.emoji_events_rounded, AppColors.gold)),
          _divider(),
          Expanded(
            child: _statItem(
              'Win Rate',
              '${(winRate * 100).toStringAsFixed(0)}%',
              Icons.trending_up_rounded,
              AppColors.success,
            ),
          ),
          _divider(),
          Expanded(
            child: _statItem(
              'Streak',
              '$streak',
              Icons.local_fire_department_rounded,
              const Color(0xFFFF6B6B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        height: 40,
        width: 1,
        color: AppColors.border.withOpacity(0.5),
      );

  Widget _statItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
