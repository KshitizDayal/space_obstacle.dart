import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:space_obstacle/constants/power_up_type.dart';
import 'package:space_obstacle/game/main_game.dart';

/// On-screen fire button, only shown (and tappable) while the blaster has ammo.
class FireButton extends PositionComponent
    with HasGameReference<MainGame>, TapCallbacks {
  FireButton()
      : super(size: Vector2.all(72), anchor: Anchor.center, priority: 10);

  final _fill = Paint()..color = const Color(0x99000000);
  final _ring = Paint()
    ..color = PowerUpType.blaster.color
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3;
  final _label = TextPaint(
    style: TextStyle(
      fontSize: 16,
      fontFamily: "Game",
      color: PowerUpType.blaster.color,
    ),
  );

  bool get _visible => game.state == GameState.playing && game.blasterAmmo > 0;

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    position = Vector2(size.x - 56, size.y - 56);
  }

  @override
  bool containsLocalPoint(Vector2 point) =>
      _visible && super.containsLocalPoint(point);

  @override
  void onTapDown(TapDownEvent event) => game.fireBlaster();

  @override
  void render(Canvas canvas) {
    if (!_visible) return;
    final center = (size / 2).toOffset();
    canvas.drawCircle(center, size.x / 2, _fill);
    canvas.drawCircle(center, size.x / 2 - 2, _ring);
    _label.render(canvas, "FIRE x${game.blasterAmmo}", size / 2,
        anchor: Anchor.center);
  }
}
