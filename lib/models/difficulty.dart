import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

enum Difficulty {
  easy(label: 'Easy', minClues: 40, maxClues: 50, color: AppColors.success),
  medium(label: 'Medium', minClues: 32, maxClues: 39, color: AppColors.blue),
  hard(label: 'Hard', minClues: 26, maxClues: 31, color: AppColors.gold),
  expert(label: 'Expert', minClues: 20, maxClues: 25, color: AppColors.purple);

  const Difficulty({
    required this.label,
    required this.minClues,
    required this.maxClues,
    required this.color,
  });

  final String label;
  final int minClues;
  final int maxClues;
  final Color color;

  int get cluesForPuzzle {
    return (minClues + maxClues) ~/ 2;
  }

  static Difficulty fromString(String name) {
    return Difficulty.values.firstWhere(
      (d) => d.name == name,
      orElse: () => Difficulty.easy,
    );
  }
}
