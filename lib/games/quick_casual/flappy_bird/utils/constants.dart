class GameConstants {
  static const double birdSize = 40;
  static const double pipeWidth = 60;
  static const double pipeSpacing = 280; // Distance between pipe pairs

  // One carefully tuned ruleset for every flight.
  static const double gravity = 880;
  static const double pipeSpeed = 140;
  static const double pipeGap = 150;

  // Other constants
  static const double jumpForce = -340; // Negative for upward movement
  static const int fps = 60;
  static const String highScoreKey = 'flappy_bird_high_score';
}
