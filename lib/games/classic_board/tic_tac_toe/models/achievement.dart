import 'package:flutter/material.dart';

enum Achievement {
  firstWin,
  tenWins,
  threeInARow,
  impossibleWin;

  String get title {
    switch (this) {
      case Achievement.firstWin:
        return 'First Victory';
      case Achievement.tenWins:
        return 'Veteran Player';
      case Achievement.threeInARow:
        return 'Winning Streak';
      case Achievement.impossibleWin:
        return 'The Impossible';
    }
  }

  String get description {
    switch (this) {
      case Achievement.firstWin:
        return 'Win your first game';
      case Achievement.tenWins:
        return 'Win 10 games';
      case Achievement.threeInARow:
        return 'Win 3 games in a row';
      case Achievement.impossibleWin:
        return 'Win a game on impossible difficulty';
    }
  }

  IconData get icon {
    switch (this) {
      case Achievement.firstWin:
        return Icons.emoji_events;
      case Achievement.tenWins:
        return Icons.military_tech;
      case Achievement.threeInARow:
        return Icons.local_fire_department;
      case Achievement.impossibleWin:
        return Icons.psychology;
    }
  }
}
