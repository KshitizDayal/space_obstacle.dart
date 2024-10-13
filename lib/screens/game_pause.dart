import 'package:flutter/material.dart';

import '../constants/screen_id.dart';
import '../game/main_game.dart';

class GamePause extends StatelessWidget {
  final MainGame game;
  static const String id = ScreenId.gamePause;

  const GamePause({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
  return Scaffold(
      body: Container(),
    );
  }
}
