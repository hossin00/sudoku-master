import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../game/sudoku_validator.dart';
import '../providers/game_provider.dart';

class NumberPad extends ConsumerWidget {
  const NumberPad({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    if (game == null) return const SizedBox.shrink();
    final notesMode = ref.read(gameProvider.notifier).notesMode;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: List.generate(9, (i) {
          final n = i + 1;
          final remaining = SudokuValidator.countRemaining(game.board, n);
          final isDone = remaining <= 0;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: _NumberButton(
                number: n,
                remaining: remaining,
                onTap: isDone ? null : () => ref.read(gameProvider.notifier).enterNumber(n),
                notesMode: notesMode,
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NumberButton extends StatelessWidget {
  final int number;
  final int remaining;
  final VoidCallback? onTap;
  final bool notesMode;

  const _NumberButton({
    required this.number,
    required this.remaining,
    required this.onTap,
    required this.notesMode,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 62,
          decoration: BoxDecoration(
            color: disabled
                ? AppColors.card.withOpacity(0.3)
                : (notesMode ? AppColors.purple.withOpacity(0.15) : AppColors.card),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: notesMode
                  ? AppColors.purple.withOpacity(0.6)
                  : AppColors.blue.withOpacity(0.35),
              width: 1.2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$number',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: disabled
                      ? AppColors.textMuted
                      : (notesMode ? AppColors.purple : AppColors.blue),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                remaining <= 0 ? '' : '$remaining',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
