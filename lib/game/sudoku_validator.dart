import '../core/constants.dart';
import '../models/sudoku_cell.dart';

class SudokuValidator {
  static bool isBoardComplete(List<List<SudokuCell>> board) {
    for (int r = 0; r < AppConstants.boardSize; r++) {
      for (int c = 0; c < AppConstants.boardSize; c++) {
        if (board[r][c].isEmpty) return false;
        if (board[r][c].value != board[r][c].solution) return false;
      }
    }
    return true;
  }

  static bool isValidMove(List<List<SudokuCell>> board, int row, int col, int value) {
    for (int i = 0; i < AppConstants.boardSize; i++) {
      if (i != col && board[row][i].value == value) return false;
      if (i != row && board[i][col].value == value) return false;
    }
    final boxRow = (row ~/ 3) * 3;
    final boxCol = (col ~/ 3) * 3;
    for (int r = boxRow; r < boxRow + 3; r++) {
      for (int c = boxCol; c < boxCol + 3; c++) {
        if ((r != row || c != col) && board[r][c].value == value) return false;
      }
    }
    return true;
  }

  static Set<int> findDuplicatesInPeers(
    List<List<SudokuCell>> board,
    int row,
    int col,
  ) {
    final duplicates = <int>{};
    final target = board[row][col].value;
    if (target == 0) return duplicates;

    for (int i = 0; i < AppConstants.boardSize; i++) {
      if (i != col && board[row][i].value == target) duplicates.add(target);
      if (i != row && board[i][col].value == target) duplicates.add(target);
    }
    final boxRow = (row ~/ 3) * 3;
    final boxCol = (col ~/ 3) * 3;
    for (int r = boxRow; r < boxRow + 3; r++) {
      for (int c = boxCol; c < boxCol + 3; c++) {
        if ((r != row || c != col) && board[r][c].value == target) {
          duplicates.add(target);
        }
      }
    }
    return duplicates;
  }

  static int countRemaining(List<List<SudokuCell>> board, int value) {
    int count = 0;
    for (int r = 0; r < AppConstants.boardSize; r++) {
      for (int c = 0; c < AppConstants.boardSize; c++) {
        if (board[r][c].value == value) count++;
      }
    }
    return 9 - count;
  }
}
