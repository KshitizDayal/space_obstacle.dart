# Space Obstacle

A side-scrolling space game built with Flutter and [Flame](https://flame-engine.org/). You fly a UFO through columns of rocks, collect fuel, coins and power-ups along the way, and survive event waves that get harder as your score climbs.

## How to play

- **Move:** drag up and down, or use the arrow keys. Holding a key keeps the UFO moving.
- **Score:** +1 for every column you pass, +3 for every coin.
- **Lives:** you start with 3. A hit costs one, then the UFO blinks invincible for 1.5 seconds.
- **Fuel:** drains constantly. Fly through fuel cells (**F**) to refill, or the run ends when the tank is empty.
- **Pause:** tap the pause button, or press `P` or `Esc`.
- **High score:** saved on the device, so it survives restarts.
- **Settings** (gear icon on the start screen, or from the pause menu): mute, music volume, sound-effects volume and vibration. Your choices are saved.

### Power-ups

| Badge | Power-up | Effect |
|---|---|---|
| **S** | Shield | Absorbs one hit |
| **-** | Shrink | Smaller UFO (and hitbox) for 6 seconds |
| **T** | Slow-mo | The world runs at half speed for 5 seconds |
| **M** | Magnet | Pulls nearby coins towards you for 7 seconds |
| **B** | Blaster | 3 shots that destroy rocks: tap **FIRE** or press `Space` |

### Difficulty

The game ramps up as your score rises:

- Rocks scroll faster (200 → 420 px/s) and new columns arrive more often (every 2.2s → 1.3s).
- From score 10, some columns bob up and down, so their gaps keep moving.
- From score 40, about half the columns have only one gap.

### Event waves

Every 25 points, one of these events hits, in rotation. Survive it for +5 points.

1. **Meteor shower:** small, fast rocks streak in diagonally from the top.
2. **Asteroids incoming:** large rocks steer towards your height as they approach.
3. **Black hole:** pulls the UFO towards it while columns keep coming.

The in-game **How to play** screen (the info button on the start screen) covers the same rules.

## Getting started

### Requirements

- Flutter (stable channel). The project is currently developed on Flutter 3.47 / Dart 3.13; `pubspec.yaml` requires Dart `^3.5.3`.
- The usual platform tooling for whichever target you run: Xcode for iOS/macOS, Android Studio or the Android SDK for Android, Chrome for web.

### Run

```sh
flutter pub get
flutter run            # pick a connected device
flutter run -d chrome  # or a specific target: chrome, macos, windows, linux, an emulator...
```

The project includes Android, iOS, web, macOS, Linux and Windows targets.

### Test

```sh
flutter test
flutter analyze
```

The tests in [`test/widget_test.dart`](test/widget_test.dart) boot the game headlessly at phone resolution and simulate real frames. They cover scoring, collisions, lives and shields, fuel, every power-up, the difficulty ramp, event waves, the play-area bounds, pause/restart, high-score saving and the settings screen. Sound and haptics are switched off in tests (`GameFeedback.silent`), so check those by playing.

## Project structure

```
lib/
├── main.dart                 # GameWidget + overlay screens
├── constants/
│   ├── game_constants.dart   # every gameplay tuning value
│   ├── power_up_type.dart    # power-up symbols, colours, durations
│   ├── wave_event.dart       # event wave definitions
│   ├── screen_id.dart        # overlay IDs
│   └── ...                   # asset names, colours, text styles
├── game/
│   ├── main_game.dart        # game state, lives, fuel, power-ups, input
│   ├── spawner.dart          # column spawning, difficulty ramp, event waves
│   ├── save_game.dart        # high score + settings, stored with shared_preferences
│   └── game_feedback.dart    # music, sound effects and haptics, following the settings
├── screens/                  # Flutter overlays: start, pause, game over, how to play, settings
└── sprites/                  # Flame components: player, obstacles, pickups,
                              # meteors, chasers, black hole, bullets, HUD
assets/
├── images/                   # background, UFO, rock, pause icon
├── audio/                    # background music and sound effects
└── fonts/                    # "Game" display font
```

The overall design:

- **`MainGame`** owns the state of a run (menu, playing, paused, over) along with score, lives, fuel and active power-ups.
- Everything that belongs to one run (columns, pickups, bullets, event hazards) is added to a single `entities` container, so restarting clears it in one call.
- **`Spawner`** decides what comes next: obstacle columns, and an event wave every 25 points.
- Rocks, meteors and chasers share a `Hazard` mixin, which is how the player and the blaster's bullets recognise them.
- Pickups, the black hole and the HUD are drawn in code, so they need no image assets.

### Tuning

All gameplay numbers live in [`lib/constants/game_constants.dart`](lib/constants/game_constants.dart): speeds, intervals, score thresholds, fuel rates, power-up strengths and event timing. Balancing the game means editing that one file.

## Built with

- [Flutter](https://flutter.dev/)
- [Flame](https://pub.dev/packages/flame) 1.38: game loop, components, collision detection
- [flame_audio](https://pub.dev/packages/flame_audio): background music and sound effects
- [shared_preferences](https://pub.dev/packages/shared_preferences): high score and settings

The coin, power-up, blaster and alarm sound effects are short synthesised tones. Replace the files in `assets/audio/` with your own (same names) to change them.

## Roadmap

- [x] Save the high score
- [x] Music and sound effects
- [x] Settings: mute, volumes, vibration
- [ ] **Level mode.** `GameLevel` is an empty placeholder screen.
- [ ] Game feel: parallax starfield, rotating rocks, screen shake and particles on hits.
- [ ] Progression: spend coins on unlockable ships, plus achievements.
