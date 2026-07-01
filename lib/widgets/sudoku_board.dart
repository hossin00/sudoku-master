import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../models/settings.dart';
import '../models/sudoku_cell.dart';
import '../providers/game_provider.dart';
import '../providers/settings_provider.dart';

class SudokuBoard extends ConsumerWidget {
  const SudokuBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    if (game == null) return const SizedBox.shrink();
    final settings = ref.watch(settingsProvider);
    final selected = ref.read(gameProvider.notifier).selected;

    final selectedValue = selected != null
        ? game.board[selected.row][selected.col].value
        : 0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth;
        final cellSize = size / 9;
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.blue.withOpacity(0.6), width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.blue.withOpacity(0.15),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Stack(
            children: [
              _buildCells(context, ref, game.board, cellSize, selected, selectedValue, settings),
              _buildGridLines(size),
              if (game.isPaused) _buildPausedOverlay(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCells(
    BuildContext context,
    WidgetRef ref,
    List<List<SudokuCell>> board,
    double cellSize,
    SelectedCell? selected,
    int selectedValue,
    AppSettings settings,
  ) {
    return Column(
      children: List.generate(9, (row) {
        return Expanded(
          child: Row(
            children: List.generate(9, (col) {
              final cell = board[row][col];
              final isSelected = selected?.row == row && selected?.col == col;
              final isPeer = selected != null &&
                  (selected.row == row ||
                      selected.col == col ||
                      (selected.row ~/ 3 == row ~/ 3 && selected.col ~/ 3 == col ~/ 3));
              final isSameNumber = selectedValue != 0 && cell.value == selectedValue;
              return Expanded(
                child: GestureDetector(
                  onTap: () => ref.read(gameProvider.notifier).selectCell(row, col),
                  child: _SudokuCellWidget(
                    cell: cell,
                    size: cellSize,
                    isSelected: isSelected,
                    isPeer: isPeer,
                    isSameNumber: isSameNumber,
                    settings: settings,
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  Widget _buildGridLines(double size) {
    return IgnorePointer(
      child: CustomPaint(
        size: Size(size, size),
        painter: _GridPainter(),
      ),
    );
  }

  Widget _buildPausedOverlay() {
    return Positioned.fill(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          color: AppColors.background.withOpacity(0.94),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.pause_circle_filled, size: 64, color: AppColors.blue),
                SizedBox(height: 12),
                Text(
                  'Paused',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SudokuCellWidget extends StatelessWidget {
  final SudokuCell cell;
  final double size;
  final bool isSelected;
  final bool isPeer;
  final bool isSameNumber;
  final AppSettings settings;

  const _SudokuCellWidget({
    required this.cell,
    required this.size,
    required this.isSelected,
    required this.isPeer,
    required this.isSameNumber,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    Color? bgColor;
    if (isSelected) {
      bgColor = AppColors.blue.withOpacity(0.35);
    } else if (isSameNumber && cell.value != 0) {
      bgColor = AppColors.purple.withOpacity(0.25);
    } else if (isPeer) {
      bgColor = AppColors.blue.withOpacity(0.08);
    }

    Color textColor;
    if (cell.isError && settings.highlightErrors) {
      textColor = AppColors.error;
    } else if (cell.isGiven) {
      textColor = AppColors.textPrimary;
    } else {
      textColor = AppColors.blue;
    }

    return Container(
      color: bgColor,
      alignment: Alignment.center,
      child: cell.value == 0
          ? _buildNotes()
          : Text(
              '${cell.value}',
              style: TextStyle(
                fontSize: size * 0.5,
                fontWeight: cell.isGiven ? FontWeight.w700 : FontWeight.w500,
                color: textColor,
              ),
            ),
    );
  }

  Widget _buildNotes() {
    if (cell.notes.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.all(size * 0.06),
      child: GridView.count(
        crossAxisCount: 3,
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(9, (i) {
          final n = i + 1;
          final hasNote = cell.notes.contains(n);
          return Center(
            child: Text(
              hasNote ? '$n' : '',
              style: TextStyle(
                fontSize: size * 0.2,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final thin = Paint()
      ..color = AppColors.border.withOpacity(0.6)
      ..strokeWidth = 0.5;
    final thick = Paint()
      ..color = AppColors.blue.withOpacity(0.7)
      ..strokeWidth = 2;

    final cellSize = size.width / 9;
    for (int i = 0; i <= 9; i++) {
      final paint = i % 3 == 0 ? thick : thin;
      canvas.drawLine(Offset(i * cellSize, 0), Offset(i * cellSize, size.height), paint);
      canvas.drawLine(Offset(0, i * cellSize), Offset(size.width, i * cellSize), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
