class SudokuCell {
  int value;
  final int solution;
  final bool isGiven;
  final Set<int> notes;
  bool isError;

  SudokuCell({
    this.value = 0,
    required this.solution,
    this.isGiven = false,
    Set<int>? notes,
    this.isError = false,
  }) : notes = notes ?? <int>{};

  bool get isEmpty => value == 0;
  bool get isCorrect => value == solution;

  SudokuCell copyWith({
    int? value,
    int? solution,
    bool? isGiven,
    Set<int>? notes,
    bool? isError,
  }) {
    return SudokuCell(
      value: value ?? this.value,
      solution: solution ?? this.solution,
      isGiven: isGiven ?? this.isGiven,
      notes: notes ?? Set<int>.from(this.notes),
      isError: isError ?? this.isError,
    );
  }

  Map<String, dynamic> toJson() => {
        'value': value,
        'solution': solution,
        'isGiven': isGiven,
        'notes': notes.toList(),
        'isError': isError,
      };

  factory SudokuCell.fromJson(Map<String, dynamic> json) {
    return SudokuCell(
      value: json['value'] as int? ?? 0,
      solution: json['solution'] as int? ?? 0,
      isGiven: json['isGiven'] as bool? ?? false,
      notes: Set<int>.from((json['notes'] as List?)?.cast<int>() ?? const []),
      isError: json['isError'] as bool? ?? false,
    );
  }
}
