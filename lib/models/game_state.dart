import 'sudoku_cell.dart';
import 'difficulty.dart';

class SelectedCell {
  final int row;
  final int col;
  const SelectedCell(this.row, this.col);

  Map<String, dynamic> toJson() => {'row': row, 'col': col};

  factory SelectedCell.fromJson(Map<String, dynamic> json) =>
      SelectedCell(json['row'] as int, json['col'] as int);
}

class GameState {
  final List<List<SudokuCell>> board;
  final Difficulty difficulty;
  final int hintsUsed;
  final int mistakes;
  final int elapsedSeconds;
  final bool isCompleted;
  final bool isPaused;
  final DateTime startedAt;
  final List<Move> moveHistory;
  final bool isDailyChallenge;
  final String? dailyDate;
  final SelectedCell? selected;
  final bool notesMode;

  GameState({
    required this.board,
    required this.difficulty,
    this.hintsUsed = 0,
    this.mistakes = 0,
    this.elapsedSeconds = 0,
    this.isCompleted = false,
    this.isPaused = false,
    required this.startedAt,
    List<Move>? moveHistory,
    this.isDailyChallenge = false,
    this.dailyDate,
    this.selected,
    this.notesMode = false,
  }) : moveHistory = moveHistory ?? <Move>[];

  GameState copyWith({
    List<List<SudokuCell>>? board,
    Difficulty? difficulty,
    int? hintsUsed,
    int? mistakes,
    int? elapsedSeconds,
    bool? isCompleted,
    bool? isPaused,
    DateTime? startedAt,
    List<Move>? moveHistory,
    bool? isDailyChallenge,
    String? dailyDate,
    SelectedCell? selected,
    bool clearSelected = false,
    bool? notesMode,
  }) {
    return GameState(
      board: board ?? this.board,
      difficulty: difficulty ?? this.difficulty,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      mistakes: mistakes ?? this.mistakes,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      isCompleted: isCompleted ?? this.isCompleted,
      isPaused: isPaused ?? this.isPaused,
      startedAt: startedAt ?? this.startedAt,
      moveHistory: moveHistory ?? this.moveHistory,
      isDailyChallenge: isDailyChallenge ?? this.isDailyChallenge,
      dailyDate: dailyDate ?? this.dailyDate,
      selected: clearSelected ? null : (selected ?? this.selected),
      notesMode: notesMode ?? this.notesMode,
    );
  }

  Map<String, dynamic> toJson() => {
        'board': board.map((row) => row.map((c) => c.toJson()).toList()).toList(),
        'difficulty': difficulty.name,
        'hintsUsed': hintsUsed,
        'mistakes': mistakes,
        'elapsedSeconds': elapsedSeconds,
        'isCompleted': isCompleted,
        'isPaused': isPaused,
        'startedAt': startedAt.toIso8601String(),
        'moveHistory': moveHistory.map((m) => m.toJson()).toList(),
        'isDailyChallenge': isDailyChallenge,
        'dailyDate': dailyDate,
        'selected': selected?.toJson(),
        'notesMode': notesMode,
      };

  factory GameState.fromJson(Map<String, dynamic> json) {
    final boardRaw = json['board'] as List;
    final board = boardRaw
        .map<List<SudokuCell>>((row) => (row as List)
            .map<SudokuCell>((c) => SudokuCell.fromJson(Map<String, dynamic>.from(c as Map)))
            .toList())
        .toList();
    return GameState(
      board: board,
      difficulty: Difficulty.fromString(json['difficulty'] as String? ?? 'easy'),
      hintsUsed: json['hintsUsed'] as int? ?? 0,
      mistakes: json['mistakes'] as int? ?? 0,
      elapsedSeconds: json['elapsedSeconds'] as int? ?? 0,
      isCompleted: json['isCompleted'] as bool? ?? false,
      isPaused: json['isPaused'] as bool? ?? false,
      startedAt: DateTime.tryParse(json['startedAt'] as String? ?? '') ?? DateTime.now(),
      moveHistory: (json['moveHistory'] as List?)
              ?.map((m) => Move.fromJson(Map<String, dynamic>.from(m as Map)))
              .toList() ??
          <Move>[],
      isDailyChallenge: json['isDailyChallenge'] as bool? ?? false,
      dailyDate: json['dailyDate'] as String?,
      selected: json['selected'] != null
          ? SelectedCell.fromJson(Map<String, dynamic>.from(json['selected'] as Map))
          : null,
      notesMode: json['notesMode'] as bool? ?? false,
    );
  }
}

class Move {
  final int row;
  final int col;
  final int previousValue;
  final int newValue;
  final Set<int> previousNotes;
  final Set<int> newNotes;
  final bool isNotes;

  Move({
    required this.row,
    required this.col,
    required this.previousValue,
    required this.newValue,
    Set<int>? previousNotes,
    Set<int>? newNotes,
    this.isNotes = false,
  })  : previousNotes = previousNotes ?? <int>{},
        newNotes = newNotes ?? <int>{};

  Map<String, dynamic> toJson() => {
        'row': row,
        'col': col,
        'previousValue': previousValue,
        'newValue': newValue,
        'previousNotes': previousNotes.toList(),
        'newNotes': newNotes.toList(),
        'isNotes': isNotes,
      };

  factory Move.fromJson(Map<String, dynamic> json) => Move(
        row: json['row'] as int,
        col: json['col'] as int,
        previousValue: json['previousValue'] as int? ?? 0,
        newValue: json['newValue'] as int? ?? 0,
        previousNotes: Set<int>.from((json['previousNotes'] as List?)?.cast<int>() ?? const []),
        newNotes: Set<int>.from((json['newNotes'] as List?)?.cast<int>() ?? const []),
        isNotes: json['isNotes'] as bool? ?? false,
      );
}
