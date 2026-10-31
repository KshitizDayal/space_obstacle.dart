import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/services.dart';
import 'package:space_obstacle/constants/game_audio.dart';
import 'package:space_obstacle/constants/power_up_type.dart';
import 'package:space_obstacle/constants/screen_id.dart';
import 'package:space_obstacle/game/game_feedback.dart';
import 'package:space_obstacle/game/save_game.dart';
import 'package:space_obstacle/game/spawner.dart';
import 'package:space_obstacle/sprites/background.dart';
import 'package:space_obstacle/sprites/bullet.dart';
import 'package:space_obstacle/sprites/fire_button.dart';
import 'package:space_obstacle/sprites/floating_text.dart';
import 'package:space_obstacle/sprites/hud.dart';

import '../constants/game_constants.dart';
import '../sprites/pause.dart';
import '../sprites/player.dart';

enum GameState { menu, playing, paused, over }

class MainGame extends FlameGame
    with VerticalDragDetector, KeyboardEvents, HasCollisionDetection {
  final SaveGame save;
  final GameFeedback feedback;

  MainGame({required this.save, required this.feedback});

  late Player player;
  late Spawner spawner;
  late Pause pause;

  /// Everything that belongs to a single run (obstacles, pickups, bullets...),
  /// so a restart can clear it in one go.
  final Component entities = Component();

  GameState state = GameState.menu;
  int score = 0;
  int coins = 0;
  int lives = GameConstants.startLives;
  double fuel = GameConstants.maxFuel;
  String gameOverReason = "";
  bool isNewBest = false;

  int get bestScore => save.highScore;

  bool hasShield = false;
  int blasterAmmo = 0;
  double invincibleTimer = 0;
  final Map<PowerUpType, double> powerUpTimers = {};

  bool isActive(PowerUpType type) => (powerUpTimers[type] ?? 0) > 0;
  bool get isInvincible => invincibleTimer > 0;
  double get timeScale =>
      isActive(PowerUpType.slowMo) ? GameConstants.slowMoScale : 1.0;

  // Layout scales down on short screens so the gaps always fit the player
  double get playTop => min(GameConstants.topHeight, size.y * 0.15);
  double get stoneSize => min(
        GameConstants.stoneSize,
        (size.y - playTop) / (GameConstants.totalStones + 2),
      );
  double get playerSize => stoneSize * 0.6;

  @override
  FutureOr<void> onLoad() async {
    await feedback.load();
    addAll([
      Background(),
      entities,
      player = Player(),
      spawner = Spawner(),
      Hud(),
      FireButton(),
      pause = Pause(),
    ]);
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (state == GameState.playing) {
      // Power-up timers and fuel run on real time, the world runs on slow-mo time
      invincibleTimer = max(0, invincibleTimer - dt);
      powerUpTimers.updateAll((_, time) => max(0, time - dt));
      fuel -= GameConstants.fuelDrainPerSecond * dt;
      if (fuel <= 0) {
        fuel = 0;
        gameOver("Out of fuel!");
      }
    }
    super.update(dt * timeScale);
  }

  void startGame() {
    _resetRun();
    overlays.clear();
    state = GameState.playing;
    resumeEngine();
    feedback.startMusic();
  }

  void pauseGame() {
    if (state != GameState.playing) return;
    state = GameState.paused;
    pauseEngine();
    feedback.pauseMusic();
    overlays.add(ScreenId.gamePause);
  }

  void resumeGame() {
    if (state != GameState.paused) return;
    overlays.removeAll([ScreenId.gamePause, ScreenId.gameSettings]);
    state = GameState.playing;
    resumeEngine();
    feedback.resumeMusic();
  }

  void goToMenu() {
    _resetRun();
    state = GameState.menu;
    overlays.clear();
    overlays.add(ScreenId.gameStart);
    resumeEngine();
    feedback.stopMusic();
  }

  void openSettings() => overlays.add(ScreenId.gameSettings);

  void closeSettings() => overlays.remove(ScreenId.gameSettings);

  void gameOver(String reason) {
    if (state != GameState.playing) return;
    state = GameState.over;
    gameOverReason = reason;
    isNewBest = score > save.highScore;
    if (isNewBest) save.highScore = score;
    pauseEngine();
    feedback.stopMusic();
    overlays.add(ScreenId.gameOver);
  }

  void _resetRun() {
    entities.removeAll(entities.children.toList());
    score = 0;
    coins = 0;
    lives = GameConstants.startLives;
    fuel = GameConstants.maxFuel;
    gameOverReason = "";
    isNewBest = false;
    hasShield = false;
    blasterAmmo = 0;
    invincibleTimer = 0;
    powerUpTimers.clear();
    player.resetPosition();
    spawner.reset();
  }

  void addScore(int points) {
    if (state == GameState.playing) score += points;
  }

  void onPlayerHit(PositionComponent hazard) {
    if (state != GameState.playing || isInvincible) return;
    hazard.removeFromParent();
    feedback.play(GameAudio.collision);

    if (hasShield) {
      feedback.lightHaptic();
      hasShield = false;
      invincibleTimer = 0.5;
      showText("SHIELD BROKEN", player.position.clone(),
          color: PowerUpType.shield.color);
      return;
    }

    lives--;
    feedback.heavyHaptic();
    if (lives <= 0) {
      gameOver("Your UFO was destroyed!");
      return;
    }
    invincibleTimer = GameConstants.invincibleTime;
  }

  void activatePowerUp(PowerUpType type) {
    feedback.play(GameAudio.powerUp);
    feedback.lightHaptic();
    switch (type) {
      case PowerUpType.shield:
        hasShield = true;
      case PowerUpType.blaster:
        blasterAmmo += GameConstants.blasterAmmo;
      default:
        powerUpTimers[type] = type.duration;
    }
  }

  void fireBlaster() {
    if (state != GameState.playing || blasterAmmo <= 0) return;
    blasterAmmo--;
    feedback.play(GameAudio.shoot);
    entities.add(
      Bullet(position: player.position + Vector2(player.width / 2, 0)),
    );
  }

  void showText(String text, Vector2 position,
      {Color color = Colors.white, double fontSize = 18}) {
    entities.add(FloatingText(
      text: text,
      position: position,
      color: color,
      fontSize: fontSize,
    ));
  }

  void showBanner(String text, {Color color = Colors.white}) {
    entities.add(FloatingText(
      text: text,
      position: Vector2(size.x / 2, size.y / 2),
      color: color,
      fontSize: 40,
      lifetime: 2,
      rise: 0,
    ));
  }

  @override
  void onVerticalDragUpdate(DragUpdateInfo info) {
    if (state == GameState.playing) player.move(info.delta.global.y);
    super.onVerticalDragUpdate(info);
  }

  @override
  KeyEventResult onKeyEvent(
      KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    const double movespeed = 55.0;

    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.escape &&
        overlays.isActive(ScreenId.gameSettings)) {
      closeSettings();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.escape || key == LogicalKeyboardKey.keyP) {
      state == GameState.paused ? resumeGame() : pauseGame();
      return KeyEventResult.handled;
    }
    if (state != GameState.playing) return KeyEventResult.ignored;

    if (key == LogicalKeyboardKey.arrowUp) {
      player.move(-movespeed);
    } else if (key == LogicalKeyboardKey.arrowDown) {
      player.move(movespeed);
    } else if (key == LogicalKeyboardKey.space && event is KeyDownEvent) {
      fireBlaster();
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }
}
