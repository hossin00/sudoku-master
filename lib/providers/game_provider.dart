import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants.dart';
import '../game/sudoku_generator.dart';
import '../game/sudoku_validator.dart';
import '../models/achievement.dart';
import '../models/difficulty.dart';
import '../models/game_state.dart';
import '../models/sudoku_cell.dart';
import 'achievements_provider.dart';
import 'stats_provider.dart';
import 'storage_provider.dart';

class SelectedCell {
  final int row;
  final int col;
  const SelectedCell(this.row, this.col);
}

class GameNotifier extends StateNotifier<GameState?> {
  GameNotifier(this._ref) : super(null);

  final Ref _ref;
  Timer? _timer;
  bool _notesMode = false;
  SelectedCell? _selected;

  bool get notesMode => _notesMode;
  SelectedCell? get selected => _selected;

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final current = state;
      if (current == null || current.isCompleted || current.isPaused) return;
      state = current.copyWith(elapsedSeconds: current.elapsedSeconds + 1);
      _autoSave();
    });
  }

  void _autoSave() {
    final current = state;
    if (current == null) return;
    _ref.read(storageServiceProvider).saveCurrentGame(current);
  }

  Future<void> startNewGame(Difficulty difficulty) async {
    _timer?.cancel();
    final generator = SudokuGenerator();
    final board = generator.generateBoard(difficulty);
    state = GameState(
      board: board,
      difficulty: difficulty,
      startedAt: DateTime.now(),
    );
    _selected = null;
    _notesMode = false;
    await _ref.read(statsProvider.notifier).recordGameStarted(difficulty);
    _autoSave();
    _startTimer();
  }

  Future<void> startDailyChallenge(String dateKey) async {
    _timer?.cancel();
    final board = SudokuGenerator.generateForDaily(dateKey);
    state = GameState(
      board: board,
      difficulty: Difficulty.medium,
      startedAt: DateTime.now(),
      isDailyChallenge: true,
      dailyDate: dateKey,
    );
    _selected = null;
    _notesMode = false;
    await _ref.read(statsProvider.notifier).recordGameStarted(Difficulty.medium);
    _autoSave();
    _startTimer();
  }

  Future<bool> loadSavedGame() async {
    final loaded = _ref.read(storageServiceProvider).loadCurrentGame();
    if (loaded == null || loaded.isCompleted) return false;
    state = loaded.copyWith(isPaused: false);
    _startTimer();
    return true;
  }

  void selectCell(int row, int col) {
    _selected = SelectedCell(row, col);
    state = state?.copyWith();
  }

  void toggleNotesMode() {
    _notesMode = !_notesMode;
    state = state?.copyWith();
  }

  void pause() {
    final current = state;
    if (current == null || current.isCompleted) return;
    state = current.copyWith(isPaused: true);
    _autoSave();
  }

  void resume() {
    final current = state;
    if (current == null || current.isCompleted) return;
    state = current.copyWith(isPaused: false);
    _startTimer();
  }

  void enterNumber(int number) {
    final current = state;
    final sel = _selected;
    if (current == null || sel == null || current.isCompleted || current.isPaused) return;

    final cell = current.board[sel.row][sel.col];
    if (cell.isGiven) return;

    if (_notesMode) {
      _toggleNote(sel.row, sel.col, number);
    } else {
      _placeValue(sel.row, sel.col, number);
    }
  }

  void _placeValue(int row, int col, int value) {
    final current = state!;
    final cell = current.board[row][col];
    if (cell.value == value) {
      _placeValue(row, col, 0);
      return;
    }

    final move = Move(
      row: row,
      col: col,
      previousValue: cell.value,
      newValue: value,
      previousNotes: Set<int>.from(cell.notes),
      newNotes: const {},
    );

    final newBoard = _cloneBoard(current.board);
    newBoard[row][col] = cell.copyWith(
      value: value,
      notes: <int>{},
      isError: value != 0 && value != cell.solution,
    );

    if (value != 0) {
      for (int i = 0; i < AppConstants.boardSize; i++) {
        newBoard[row][i].notes.remove(value);
        newBoard[i][col].notes.remove(value);
      }
      final boxRow = (row ~/ 3) * 3;
      final boxCol = (col ~/ 3) * 3;
      for (int r = boxRow; r < boxRow + 3; r++) {
        for (int c = boxCol; c < boxCol + 3; c++) {
          newBoard[r][c].notes.remove(value);
        }
      }
    }

    _recomputeErrors(newBoard);

    final mistakes = value != 0 && value != cell.solution
        ? current.mistakes + 1
        : current.mistakes;

    var newState = current.copyWith(
      board: newBoard,
      mistakes: mistakes,
      moveHistory: [...current.moveHistory, move],
    );

    if (SudokuValidator.isBoardComplete(newBoard)) {
      newState = newState.copyWith(isCompleted: true);
      _timer?.cancel();
      _onCompletion(newState);
    }

    state = newState;
    _autoSave();
  }

  void _toggleNote(int row, int col, int number) {
    final current = state!;
    final cell = current.board[row][col];
    if (cell.value != 0) return;

    final newNotes = Set<int>.from(cell.notes);
    if (newNotes.contains(number)) {
      newNotes.remove(number);
    } else {
      newNotes.add(number);
    }

    final move = Move(
      row: row,
      col: col,
      previousValue: cell.value,
      newValue: cell.value,
      previousNotes: Set<int>.from(cell.notes),
      newNotes: Set<int>.from(newNotes),
      isNotes: true,
    );

    final newBoard = _cloneBoard(current.board);
    newBoard[row][col] = cell.copyWith(notes: newNotes);

    state = current.copyWith(
      board: newBoard,
      moveHistory: [...current.moveHistory, move],
    );
    _autoSave();
  }

  void clearCell() {
    final sel = _selected;
    if (sel == null) return;
    _placeValue(sel.row, sel.col, 0);
  }

  void undo() {
    final current = state;
    if (current == null || current.moveHistory.isEmpty) return;

    final history = List<Move>.from(current.moveHistory);
    final last = history.removeLast();
    final newBoard = _cloneBoard(current.board);
    final cell = newBoard[last.row][last.col];
    newBoard[last.row][last.col] = cell.copyWith(
      value: last.previousValue,
      notes: Set<int>.from(last.previousNotes),
      isError: last.previousValue != 0 && last.previousValue != cell.solution,
    );
    _recomputeErrors(newBoard);
    state = current.copyWith(board: newBoard, moveHistory: history);
    _autoSave();
  }

  bool useHint() {
    final current = state;
    if (current == null || current.isCompleted) return false;
    if (current.hintsUsed >= AppConstants.maxHints) return false;

    final emptyCells = <SelectedCell>[];
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (current.board[r][c].isEmpty || current.board[r][c].value != current.board[r][c].solution) {
          emptyCells.add(SelectedCell(r, c));
        }
      }
    }
    if (emptyCells.isEmpty) return false;

    final target = _selected != null &&
            (current.board[_selected!.row][_selected!.col].isEmpty ||
                current.board[_selected!.row][_selected!.col].value !=
                    current.board[_selected!.row][_selected!.col].solution)
        ? _selected!
        : emptyCells.first;

    final solutionVal = current.board[target.row][target.col].solution;
    final newBoard = _cloneBoard(current.board);
    newBoard[target.row][target.col] = newBoard[target.row][target.col].copyWith(
      value: solutionVal,
      notes: <int>{},
      isError: false,
      isGiven: true,
    );
    _recomputeErrors(newBoard);

    var newState = current.copyWith(
      board: newBoard,
      hintsUsed: current.hintsUsed + 1,
    );

    if (SudokuValidator.isBoardComplete(newBoard)) {
      newState = newState.copyWith(isCompleted: true);
      _timer?.cancel();
      _onCompletion(newState);
    }

    state = newState;
    _autoSave();
    return true;
  }

  void _recomputeErrors(List<List<SudokuCell>> board) {
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        final cell = board[r][c];
        if (cell.isGiven || cell.value == 0) continue;
        board[r][c] = cell.copyWith(isError: cell.value != cell.solution);
      }
    }
  }

  List<List<SudokuCell>> _cloneBoard(List<List<SudokuCell>> board) {
    return board.map((r) => r.map((c) => c.copyWith()).toList()).toList();
  }

  Future<void> _onCompletion(GameState finalState) async {
    _ref.read(storageServiceProvider).clearCurrentGame();
    await _ref.read(statsProvider.notifier).recordGameWon(
          finalState.difficulty,
          finalState.elapsedSeconds,
          finalState.hintsUsed,
        );

    final ach = _ref.read(achievementsProvider.notifier);
    await ach.unlock(AchievementId.firstWin);
    if (finalState.hintsUsed == 0) {
      await ach.unlock(AchievementId.winWithoutHints);
    }
    if (finalState.difficulty == Difficulty.easy && finalState.elapsedSeconds < 300) {
      await ach.unlock(AchievementId.speedSolver);
    }
    if (finalState.difficulty == Difficulty.expert) {
      await ach.unlock(AchievementId.expertConqueror);
    }

    if (finalState.isDailyChallenge && finalState.dailyDate != null) {
      await _ref.read(statsProvider.notifier).recordDailyCompleted(finalState.dailyDate!);
      final streak = _ref.read(statsProvider).currentStreak;
      if (streak >= 7) {
        await ach.unlock(AchievementId.dailyStreak7);
      }
    }
  }

  Future<void> abandonGame() async {
    _timer?.cancel();
    await _ref.read(storageServiceProvider).clearCurrentGame();
    state = null;
    _selected = null;
    _notesMode = false;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final gameProvider = StateNotifierProvider<GameNotifier, GameState?>((ref) {
  return GameNotifier(ref);
});

final hasSavedGameProvider = Provider<bool>((ref) {
  final saved = ref.watch(storageServiceProvider).loadCurrentGame();
  return saved != null && !saved.isCompleted;
});
