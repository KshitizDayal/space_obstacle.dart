import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Text that drifts upwards and fades out, for pickups and event banners.
class FloatingText extends TextComponent {
  final Color color;
  final double fontSize;
  final double lifetime;
  final double rise;
  double _age = 0;

  FloatingText({
    required super.text,
    required Vector2 position,
    required this.color,
    this.fontSize = 18,
    this.lifetime = 0.8,
    this.rise = 50,
  }) : super(position: position.clone(), anchor: Anchor.center, priority: 5);

  @override
  void update(double dt) {
    super.update(dt);
    _age += dt;
    if (_age >= lifetime) {
      removeFromParent();
      return;
    }
    position.y -= rise * dt;
    textRenderer = TextPaint(
      style: TextStyle(
        fontSize: fontSize,
        fontFamily: "Game",
        color: color.withValues(alpha: 1 - _age / lifetime),
      ),
    );
  }
}
