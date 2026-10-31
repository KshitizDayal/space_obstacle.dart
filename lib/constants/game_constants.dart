class GameConstants {
  // Layout (sizes shrink on short screens, these are the maximums)
  static const double stoneSize = 100.0;
  static const int totalStones = 5;
  static const double topHeight = 120;
  static const double playerX = 75;

  // Difficulty ramp: each value moves from its start towards its limit as the score climbs
  static const double gameSpeed = 200.0;
  static const double maxGameSpeed = 420.0;
  static const double speedPerPoint = 4.0;
  static const double columnInterval = 2.2;
  static const double minColumnInterval = 1.3;
  static const double intervalPerPoint = 0.015;
  static const int emptySpots = 2;
  static const int oneGapFromScore = 40;
  static const int movingColumnsFromScore = 10;
  static const double maxMovingChance = 0.5;
  static const double columnWaveAmplitude = 45;
  static const double columnWaveSpeed = 2.0;

  // Lives & fuel
  static const int startLives = 3;
  static const double invincibleTime = 1.5;
  static const double maxFuel = 100;
  static const double fuelDrainPerSecond = 3;
  static const double fuelCellAmount = 35;
  static const double lowFuel = 40;

  // Pickups
  static const int coinScore = 3;
  static const double magnetRadius = 230;
  static const double magnetPull = 420;
  static const int blasterAmmo = 3;
  static const double bulletSpeed = 600;
  static const double shrinkScale = 0.55;
  static const double slowMoScale = 0.5;

  // Event waves
  static const int eventEveryScore = 25;
  static const double eventDuration = 8;
  static const int eventSurviveBonus = 5;
  static const double blackHolePull = 95;
}
