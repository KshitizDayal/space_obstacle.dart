import 'package:flutter/material.dart';

import '../constants/screen_id.dart';
import '../game/main_game.dart';

class GameStart extends StatelessWidget {
  final MainGame game;
  static const String id = ScreenId.gameStart;

  const GameStart({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    game.pauseEngine();
    return Scaffold(
      body: Container(),
    );
  }
}
