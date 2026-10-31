// ignore_for_file: invalid_use_of_internal_member

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:space_obstacle/constants/game_constants.dart';
import 'package:space_obstacle/constants/power_up_type.dart';
import 'package:space_obstacle/constants/screen_id.dart';
import 'package:space_obstacle/constants/wave_event.dart';
import 'package:space_obstacle/game/game_feedback.dart';
import 'package:space_obstacle/game/main_game.dart';
import 'package:space_obstacle/game/save_game.dart';
import 'package:space_obstacle/screens/game_settings.dart';
import 'package:space_obstacle/sprites/bullet.dart';
import 'package:space_obstacle/sprites/collectible.dart';
import 'package:space_obstacle/sprites/obstacle.dart';
import 'package:space_obstacle/sprites/obstacles.dart';

/// Boots the game headlessly at a phone-sized resolution, the way GameWidget would.
/// Pass [save] to share stored data between games, as if the app had restarted.
Future<MainGame> loadGame({SaveGame? save}) async {
  save ??= await SaveGame.load();
  final game = MainGame(save: save, feedback: GameFeedback.silent(save));
  for (final id in [
    ScreenId.gameStart,
    ScreenId.gamePause,
    ScreenId.gameInfo,
    ScreenId.gameLevel,
    ScreenId.gameOver,
    ScreenId.gameSettings,
  ]) {
    game.overlays.addEntry(id, (_, __) => const SizedBox());
  }
  game.onGameResize(Vector2(400, 800));
  await game.load();
  game.mount();
  game.update(0);
  await game.ready();
  return game;
}

/// Advances the game by [seconds] at 60fps, letting async sprite loads finish.
Future<void> run(MainGame game, double seconds) async {
  for (var t = 0.0; t < seconds; t += 1 / 60) {
    game.update(1 / 60);
    await game.ready();
  }
}

Iterable<T> entitiesOf<T>(MainGame game) =>
    game.entities.children.whereType<T>();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('starting a run spawns columns and passing them scores', () async {
    final game = await loadGame();
    expect(game.state, GameState.menu);

    game.startGame();
    await run(game, 0.1);
    expect(game.state, GameState.playing);
    expect(entitiesOf<Obstacles>(game), isNotEmpty);

    game.invincibleTimer = 999; // dodge everything so we only measure scoring
    await run(game, 4);
    expect(game.score, greaterThan(0));
    expect(game.fuel, lessThan(GameConstants.maxFuel));
  });

  test('flying into a full column costs a life, then blinks invincible',
      () async {
    final game = await loadGame();
    game.startGame();
    game.spawner.reset();
    game.entities.add(Obstacles(emptySpots: 0));
    await run(game, 0.05);
    game.entities.children
        .whereType<Collectible>()
        .forEach((c) => c.removeFromParent());

    while (game.lives == GameConstants.startLives) {
      await run(game, 0.1);
    }
    expect(game.lives, GameConstants.startLives - 1);
    expect(game.isInvincible, isTrue);
  });

  test('shield absorbs a hit, the third life lost ends the game', () async {
    final game = await loadGame();
    game.startGame();

    game.activatePowerUp(PowerUpType.shield);
    game.onPlayerHit(ObstacleStone(y: 0, stoneSize: 10));
    expect(game.lives, GameConstants.startLives);
    expect(game.hasShield, isFalse);

    for (var i = 0; i < GameConstants.startLives; i++) {
      game.invincibleTimer = 0;
      game.onPlayerHit(ObstacleStone(y: 0, stoneSize: 10));
    }
    expect(game.state, GameState.over);
    expect(game.overlays.isActive(ScreenId.gameOver), isTrue);
  });

  test('running out of fuel ends the game, fuel cells refill it', () async {
    final game = await loadGame();
    game.startGame();

    game.fuel = 10;
    final cell = FuelCell(position: Vector2.zero());
    game.entities.add(cell);
    await game.ready();
    cell.collect();
    expect(game.fuel, 10 + GameConstants.fuelCellAmount);

    game.fuel = 0.01;
    game.update(0.1);
    expect(game.state, GameState.over);
    expect(game.gameOverReason, contains("fuel"));
  });

  test('coins add score, magnet pulls them in', () async {
    final game = await loadGame();
    game.startGame();

    final coin = Coin(
      position: game.player.position + Vector2(150, 0),
    );
    game.entities.add(coin);
    await game.ready();
    game.activatePowerUp(PowerUpType.magnet);
    final startDistance =
        coin.absolutePosition.distanceTo(game.player.absolutePosition);
    game.update(0.1);
    expect(
      coin.absolutePosition.distanceTo(game.player.absolutePosition),
      lessThan(startDistance),
    );

    coin.collect();
    expect(game.coins, 1);
    expect(game.score, GameConstants.coinScore);
  });

  test('slow-mo halves world time, shrink scales the player down', () async {
    final game = await loadGame();
    game.startGame();

    game.activatePowerUp(PowerUpType.slowMo);
    expect(game.timeScale, GameConstants.slowMoScale);

    game.activatePowerUp(PowerUpType.shrink);
    await run(game, 1);
    expect(game.player.scale.x, closeTo(GameConstants.shrinkScale, 0.05));

    await run(game, PowerUpType.slowMo.duration);
    expect(game.timeScale, 1.0);
  });

  test('blaster shots destroy hazards', () async {
    final game = await loadGame();
    game.startGame();
    game.activatePowerUp(PowerUpType.blaster);
    expect(game.blasterAmmo, GameConstants.blasterAmmo);

    final rock = ObstacleStone(
      y: game.player.y - 20,
      stoneSize: 40,
    )..position.x = game.player.x + 120;
    game.entities.add(rock);
    await game.ready();

    game.fireBlaster();
    expect(game.blasterAmmo, GameConstants.blasterAmmo - 1);
    await run(game, 0.5);
    expect(rock.isMounted, isFalse);
    expect(entitiesOf<Bullet>(game), isEmpty);
  });

  test('difficulty ramps with score and is capped', () async {
    final game = await loadGame();
    game.startGame();
    final startSpeed = game.spawner.scrollSpeed;
    final startInterval = game.spawner.columnInterval;

    game.score = 20;
    expect(game.spawner.scrollSpeed, greaterThan(startSpeed));
    expect(game.spawner.columnInterval, lessThan(startInterval));

    game.score = 10000;
    expect(game.spawner.scrollSpeed, GameConstants.maxGameSpeed);
    expect(game.spawner.columnInterval, GameConstants.minColumnInterval);
  });

  test('an event wave starts at the threshold and pays a bonus when survived',
      () async {
    final game = await loadGame();
    game.startGame();
    game.invincibleTimer = 999;
    game.fuel = 1000;

    game.score = GameConstants.eventEveryScore;
    await run(game, 0.1);
    expect(game.spawner.activeEvent, WaveEvent.meteorShower);

    final scoreBefore = game.score;
    game.invincibleTimer = 999;
    await run(game, GameConstants.eventDuration);
    expect(game.spawner.activeEvent, isNull);
    expect(game.score,
        greaterThanOrEqualTo(scoreBefore + GameConstants.eventSurviveBonus));
  });

  test('player stays inside the play area', () async {
    final game = await loadGame();
    game.startGame();

    game.player.move(-10000);
    expect(game.player.y - game.player.height / 2, closeTo(game.playTop, 0.01));
    game.player.move(10000);
    expect(game.player.y + game.player.height / 2, closeTo(game.size.y, 0.01));
  });

  test('pause, resume and restart', () async {
    final game = await loadGame();
    game.startGame();
    game.score = 7;

    game.pauseGame();
    expect(game.state, GameState.paused);
    expect(game.overlays.isActive(ScreenId.gamePause), isTrue);

    game.resumeGame();
    expect(game.state, GameState.playing);

    game.startGame();
    expect(game.score, 0);
    expect(game.lives, GameConstants.startLives);
  });

  test('high score is saved and survives a restart', () async {
    final save = await SaveGame.load();
    final game = await loadGame(save: save);
    game.startGame();
    game.score = 42;
    game.gameOver("test");
    expect(game.isNewBest, isTrue);

    // A worse run doesn't overwrite it
    game.startGame();
    game.score = 10;
    game.gameOver("test");
    expect(game.isNewBest, isFalse);

    final restarted = await loadGame(save: await SaveGame.load());
    expect(restarted.bestScore, 42);
  });

  test('settings are saved with sensible defaults', () async {
    final save = await SaveGame.load();
    expect(save.muted, isFalse);
    expect(save.musicVolume, 0.5);
    expect(save.sfxVolume, 0.8);
    expect(save.haptics, isTrue);

    save.muted = true;
    save.musicVolume = 0.2;
    save.haptics = false;

    final reloaded = await SaveGame.load();
    expect(reloaded.muted, isTrue);
    expect(reloaded.musicVolume, 0.2);
    expect(reloaded.haptics, isFalse);
  });

  testWidgets('settings screen toggles and closes', (tester) async {
    final save = await SaveGame.load();
    final game = MainGame(save: save, feedback: GameFeedback.silent(save));
    game.overlays.addEntry(ScreenId.gameSettings, (_, __) => const SizedBox());
    game.openSettings();

    await tester.pumpWidget(MaterialApp(home: GameSettings(game: game)));
    await tester.tap(find.text("Mute all sound"));
    await tester.pump();
    expect(save.muted, isTrue);

    await tester.tap(find.text("Vibration"));
    await tester.pump();
    expect(save.haptics, isFalse);

    await tester.tap(find.text("Back"));
    expect(game.overlays.isActive(ScreenId.gameSettings), isFalse);
  });
}
