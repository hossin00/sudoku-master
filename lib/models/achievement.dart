import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

enum AchievementId {
  firstWin,
  winWithoutHints,
  dailyStreak7,
  speedSolver,
  expertConqueror,
}

class Achievement {
  final AchievementId id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool unlocked;
  final DateTime? unlockedAt;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.unlocked = false,
    this.unlockedAt,
  });

  Achievement copyWith({bool? unlocked, DateTime? unlockedAt}) {
    return Achievement(
      id: id,
      title: title,
      description: description,
      icon: icon,
      color: color,
      unlocked: unlocked ?? this.unlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  static List<Achievement> defaults() => [
        Achievement(
          id: AchievementId.firstWin,
          title: 'First Win',
          description: 'Complete your first Sudoku puzzle',
          icon: Icons.star_rounded,
          color: AppColors.gold,
        ),
        Achievement(
          id: AchievementId.winWithoutHints,
          title: 'Purist',
          description: 'Win a game without using any hints',
          icon: Icons.bolt_rounded,
          color: AppColors.blue,
        ),
        Achievement(
          id: AchievementId.dailyStreak7,
          title: 'Weekly Warrior',
          description: 'Complete daily challenge 7 days in a row',
          icon: Icons.local_fire_department_rounded,
          color: Color(0xFFFF6B6B),
        ),
        Achievement(
          id: AchievementId.speedSolver,
          title: 'Speed Solver',
          description: 'Beat an Easy puzzle in under 5 minutes',
          icon: Icons.speed_rounded,
          color: AppColors.success,
        ),
        Achievement(
          id: AchievementId.expertConqueror,
          title: 'Expert Conqueror',
          description: 'Complete an Expert difficulty puzzle',
          icon: Icons.workspace_premium_rounded,
          color: AppColors.purple,
        ),
      ];
}
