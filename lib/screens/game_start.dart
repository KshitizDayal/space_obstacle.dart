import 'package:flutter/material.dart';
import 'package:space_obstacle/constants/game_color.dart';
import 'package:space_obstacle/constants/textstyle_assets.dart';

import '../constants/screen_id.dart';
import '../game/main_game.dart';

class GameStart extends StatelessWidget {
  final MainGame game;
  static const String id = ScreenId.gameStart;

  const GameStart({super.key, required this.game});

  final String backgroundImage = "assets/images/background.jpg";
  final String ufoImage = "assets/images/ufo.png";

  @override
  Widget build(BuildContext context) {
    game.pauseEngine();
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(backgroundImage),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.info),
                ),
              ),
              const SizedBox(height: 20),
              const Text("Space Obstacle Game", style: TextstyleAsset.bold45),
              const SizedBox(height: 40),
              Image.asset(
                ufoImage,
                height: 200,
              ),
              const SizedBox(height: 40),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: startGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: GameColor.secondary,
                ),
                child: const Text(
                  "Press here to start the game",
                  style: TextStyle(fontSize: 20, color: GameColor.text),
                ),
              ),
              const SizedBox(height: 60),
              const Text(
                "Highest Score: 0",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: GameColor.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void startGame() {
    game.overlays.remove("gameStart");
    game.resumeEngine();
  }
}
