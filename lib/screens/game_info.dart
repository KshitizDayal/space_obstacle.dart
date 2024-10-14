import 'package:flutter/material.dart';

import '../game/main_game.dart';
import '../constants/screen_id.dart';

class GameInfo extends StatelessWidget {
  final MainGame game;
  static const String id = ScreenId.gameInfo;

  const GameInfo({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
