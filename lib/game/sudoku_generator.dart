import 'dart:math';
import '../core/constants.dart';
import '../models/difficulty.dart';
import '../models/sudoku_cell.dart';

class SudokuGenerator {
  final Random _random;

  SudokuGenerator({int? seed}) : _random = Random(seed);

  List<List<int>> emptyGrid() {
    return List.generate(
      AppConstants.boardSize,
      (_) => List<int>.filled(AppConstants.boardSize, 0),
    );
  }

  List<List<int>> generateFullSolution() {
    final grid = emptyGrid();
    _fillGrid(grid);
    return grid;
  }

  bool _fillGrid(List<List<int>> grid) {
    for (int r = 0; r < AppConstants.boardSize; r++) {
      for (int c = 0; c < AppConstants.boardSize; c++) {
        if (grid[r][c] == 0) {
          final numbers = List<int>.generate(9, (i) => i + 1)..shuffle(_random);
          for (final n in numbers) {
            if (_isValidPlacement(grid, r, c, n)) {
              grid[r][c] = n;
              if (_fillGrid(grid)) return true;
              grid[r][c] = 0;
            }
          }
          return false;
        }
      }
    }
    return true;
  }

  bool _isValidPlacement(List<List<int>> grid, int row, int col, int value) {
    for (int i = 0; i < AppConstants.boardSize; i++) {
      if (grid[row][i] == value) return false;
      if (grid[i][col] == value) return false;
    }
    final boxRow = (row ~/ 3) * 3;
    final boxCol = (col ~/ 3) * 3;
    for (int r = boxRow; r < boxRow + 3; r++) {
      for (int c = boxCol; c < boxCol + 3; c++) {
        if (grid[r][c] == value) return false;
      }
    }
    return true;
  }

  int _countSolutions(List<List<int>> grid, {int limit = 2}) {
    int count = 0;
    bool solve(List<List<int>> g) {
      for (int r = 0; r < AppConstants.boardSize; r++) {
        for (int c = 0; c < AppConstants.boardSize; c++) {
          if (g[r][c] == 0) {
            for (int n = 1; n <= 9; n++) {
              if (_isValidPlacement(g, r, c, n)) {
                g[r][c] = n;
                if (solve(g)) {
                  if (count >= limit) return true;
                }
                g[r][c] = 0;
              }
            }
            return false;
          }
        }
      }
      count++;
      return count >= limit;
    }

    final gridCopy = grid.map((r) => List<int>.from(r)).toList();
    solve(gridCopy);
    return count;
  }

  List<List<int>> generatePuzzle(List<List<int>> solution, Difficulty difficulty) {
    final puzzle = solution.map((r) => List<int>.from(r)).toList();
    final targetClues = difficulty.cluesForPuzzle;
    final cellsToRemove = 81 - targetClues;

    final positions = <int>[];
    for (int i = 0; i < 81; i++) {
      positions.add(i);
    }
    positions.shuffle(_random);

    int removed = 0;
    for (final pos in positions) {
      if (removed >= cellsToRemove) break;
      final r = pos ~/ 9;
      final c = pos % 9;
      if (puzzle[r][c] == 0) continue;

      final backup = puzzle[r][c];
      puzzle[r][c] = 0;

      final solutions = _countSolutions(puzzle, limit: 2);
      if (solutions != 1) {
        puzzle[r][c] = backup;
      } else {
        removed++;
      }
    }
    return puzzle;
  }

  List<List<SudokuCell>> generateBoard(Difficulty difficulty) {
    final solution = generateFullSolution();
    final puzzle = generatePuzzle(solution, difficulty);
    return List.generate(9, (r) {
      return List.generate(9, (c) {
        final value = puzzle[r][c];
        return SudokuCell(
          value: value,
          solution: solution[r][c],
          isGiven: value != 0,
        );
      });
    });
  }

  static List<List<SudokuCell>> generateForDaily(String dateKey) {
    final seed = dateKey.hashCode;
    final gen = SudokuGenerator(seed: seed);
    final dailyDifficulty = Difficulty.medium;
    return gen.generateBoard(dailyDifficulty);
  }
}
