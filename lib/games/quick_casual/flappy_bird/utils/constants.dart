enum GameDifficulty {
  easy,
  normal,
  hard,
}

class GameConstants {
  static const double birdSize = 40;
  static const double pipeWidth = 60;
  static const double pipeSpacing = 280; // Distance between pipe pairs

  // Gravity settings
  static const double easyGravity = 950; // Reduced for more forgiving gameplay
  static const double normalGravity = 1200; // Standard gravity
  static const double hardGravity = 1500; // Increased for more challenge

  // Pipe speed settings
  static const double easyPipeSpeed = 90; // Slower pipes for beginners
  static const double normalPipeSpeed = 140; // Standard speed
  static const double hardPipeSpeed = 180; // Faster pipes for challenge

  // Pipe gap settings
  static const double easyPipeGap = 190; // Wider gaps for easier gameplay
  static const double normalPipeGap = 150; // Standard gap
  static const double hardPipeGap = 120; // Narrower gaps for challenge

  // Other constants
  static const double jumpForce = -400; // Negative for upward movement
  static const int fps = 60;
  static const String highScoreKey = 'flappy_bird_high_score';
}
