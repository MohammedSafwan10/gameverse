import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/game_types.dart';
import '../theme/game_theme.dart';

class WhackAMoleScoreController extends GetxController {
  final currentScore = 0.0.obs;
  final consecutiveHits = 0.obs;
  final highestCombo = 0.obs;

  double getComboMultiplier() {
    if (consecutiveHits.value < GameConstants.comboThreshold) {
      return 1.0;
    }
    return 1.0 +
        (consecutiveHits.value - GameConstants.comboThreshold) *
            GameConstants.comboMultiplier;
  }

  void incrementCombo() {
    consecutiveHits.value++;
    if (consecutiveHits.value > highestCombo.value) {
      highestCombo.value = consecutiveHits.value;
    }
  }

  void addScore(MoleType moleType) {
    double points = 0;

    switch (moleType) {
      case MoleType.normal:
        points = GameConstants.baseScore;
        incrementCombo();
        break;
      case MoleType.golden:
        points = GameConstants.baseScore * GameConstants.goldenMultiplier;
        incrementCombo();
        break;
      case MoleType.bomb:
        points = GameConstants.bombPenalty;
        resetCombo();
        break;
    }

    // Apply combo multiplier
    points *= getComboMultiplier();
    currentScore.value += points;
  }

  bool shouldShowComboText() {
    return consecutiveHits.value >= GameConstants.comboThreshold;
  }

  void resetCombo() {
    consecutiveHits.value = 0;
  }

  void resetScore() {
    currentScore.value = 0;
    consecutiveHits.value = 0;
    highestCombo.value = 0;
  }

  Color getScoreColor(MoleType moleType) {
    return switch (moleType) {
      MoleType.normal => WhackAMoleTheme.normalScoreColor,
      MoleType.golden => WhackAMoleTheme.goldenScoreColor,
      MoleType.bomb => WhackAMoleTheme.bombScoreColor,
    };
  }
}
