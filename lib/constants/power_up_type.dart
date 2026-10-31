import 'package:flutter/material.dart';

enum PowerUpType {
  // A duration of 0 means the power-up isn't timed (shield lasts until hit, blaster until out of ammo)
  shield('S', 'SHIELD', Color(0xFF4FC3F7), 0),
  shrink('-', 'SHRINK', Color(0xFFE4B1F0), 6),
  slowMo('T', 'SLOW-MO', Color(0xFF97FEED), 5),
  magnet('M', 'MAGNET', Color(0xFFFF6B6B), 7),
  blaster('B', 'BLASTER', Color(0xFFFFAD60), 0);

  const PowerUpType(this.symbol, this.label, this.color, this.duration);

  final String symbol;
  final String label;
  final Color color;
  final double duration;
}
