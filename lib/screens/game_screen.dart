import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants.dart';
import '../core/theme/app_theme.dart';
import '../providers/game_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/formatters.dart';
import '../widgets/number_pad.dart';
import '../widgets/sudoku_board.dart';

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  Future<bool> _confirmExit(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Leave Game?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Your progress will be saved.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Leave', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showWinDialog(BuildContext context, WidgetRef ref) {
    final game = ref.read(gameProvider);
    if (game == null) return;
    Future.microtask(() {
      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppColors.goldGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withOpacity(0.5),
                      blurRadius: 24,
                    ),
                  ],
                ),
                child: const Icon(Icons.emoji_events_rounded, size: 40, color: Colors.white),
              ),
              const SizedBox(height: 12),
              const Text(
                'Puzzle Solved!',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _winRow('Difficulty', game.difficulty.label, game.difficulty.color),
              _winRow('Time', formatDuration(game.elapsedSeconds), AppColors.blue),
              _winRow('Hints Used', '${game.hintsUsed}/${AppConstants.maxHints}', AppColors.purple),
              _winRow('Mistakes', '${game.mistakes}', AppColors.error),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: const Text('Home', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await ref.read(gameProvider.notifier).startNewGame(game.difficulty);
              },
              child: const Text('New Game'),
            ),
          ],
        ),
      );
    });
  }

  Widget _winRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    final settings = ref.watch(settingsProvider);

    ref.listen<dynamic>(gameProvider, (previous, next) {
      if (previous?.isCompleted != true && next?.isCompleted == true) {
        _showWinDialog(context, ref);
      }
    });

    if (game == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final ok = await _confirmExit(context);
        if (ok && context.mounted) Navigator.pop(context);
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppColors.darkGradient),
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(context, ref, game, settings),
                const SizedBox(height: 12),
                _buildInfoBar(game, settings),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: const SudokuBoard(),
                  ),
                ),
                const SizedBox(height: 18),
                _buildActionRow(context, ref, game),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: const NumberPad(),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, game, settings) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
            onPressed: () async {
              final ok = await _confirmExit(context);
              if (ok && context.mounted) Navigator.pop(context);
            },
          ),
          Expanded(
            child: Center(
              child: Text(
                game.isDailyChallenge ? 'Daily Challenge' : game.difficulty.label,
                style: TextStyle(
                  color: game.difficulty.color,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              game.isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
              color: AppColors.textPrimary,
            ),
            onPressed: () {
              if (game.isPaused) {
                ref.read(gameProvider.notifier).resume();
              } else {
                ref.read(gameProvider.notifier).pause();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBar(game, settings) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _infoBlock(Icons.close_rounded, AppColors.error, 'Mistakes',
              '${game.mistakes}/${AppConstants.maxMistakes}'),
          _infoBlock(Icons.lightbulb_rounded, AppColors.gold, 'Hints',
              '${AppConstants.maxHints - game.hintsUsed}'),
          if (settings.showTimer)
            _infoBlock(Icons.timer_rounded, AppColors.blue, 'Time',
                formatDuration(game.elapsedSeconds)),
        ],
      ),
    );
  }

  Widget _infoBlock(IconData icon, Color color, String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ],
    );
  }

  Widget _buildActionRow(BuildContext context, WidgetRef ref, game) {
    final notesMode = ref.read(gameProvider.notifier).notesMode;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _actionButton(
            icon: Icons.undo_rounded,
            label: 'Undo',
            color: AppColors.textSecondary,
            onTap: () => ref.read(gameProvider.notifier).undo(),
          ),
          _actionButton(
            icon: Icons.clear_rounded,
            label: 'Erase',
            color: AppColors.error,
            onTap: () => ref.read(gameProvider.notifier).clearCell(),
          ),
          _actionButton(
            icon: notesMode ? Icons.edit_note_rounded : Icons.edit_outlined,
            label: 'Notes',
            color: notesMode ? AppColors.purple : AppColors.textSecondary,
            active: notesMode,
            onTap: () => ref.read(gameProvider.notifier).toggleNotesMode(),
          ),
          _actionButton(
            icon: Icons.lightbulb_outline_rounded,
            label: 'Hint',
            color: game.hintsUsed >= AppConstants.maxHints ? AppColors.textMuted : AppColors.gold,
            onTap: () {
              final used = ref.read(gameProvider.notifier).useHint();
              if (!used && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.card,
                    content: const Text(
                      'No hints remaining',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool active = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: active ? color.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.35)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
