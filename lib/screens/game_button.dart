import 'package:flutter/material.dart';
import 'package:space_obstacle/constants/game_color.dart';

class GameButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color color;

  const GameButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = GameColor.secondary,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 20, color: GameColor.text),
        ),
      ),
    );
  }
}
