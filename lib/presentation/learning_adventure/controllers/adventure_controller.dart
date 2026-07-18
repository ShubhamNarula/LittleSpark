import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/progress_service.dart';
import '../../../services/tts_service.dart';
import '../../../services/audio_service.dart';
import '../../../core/utils/haptic_util.dart';
import '../data/adventure_content_data.dart';
import '../models/adventure_collectible_model.dart';
import '../models/adventure_stage_model.dart';

// ─────────────────────────────────────────────────────────────────
// Enums
// ─────────────────────────────────────────────────────────────────
enum GameState { lobby, playing, paused, gameOver, stageComplete }
enum PlayerState { running, jumping, sliding, hit, celebrating }
enum PowerUpType { none, magnet, shield, doubleScore, slowMotion, jetpack, rainbow }

// ─────────────────────────────────────────────────────────────────
// Live collectible on the track (position + data)
// ─────────────────────────────────────────────────────────────────
class LiveCollectible {
  final String id;
  final AdventureCollectible data;
  int lane; // 0 left, 1 center, 2 right
  double y; // 0.0 (top) → 1.0 (bottom)
  bool collected = false;
  bool missed = false;

  LiveCollectible({
    required this.id,
    required this.data,
    required this.lane,
    required this.y,
  });
}

// ─────────────────────────────────────────────────────────────────
// Live obstacle
// ─────────────────────────────────────────────────────────────────
class LiveObstacle {
  final String id;
  final String emoji;
  int lane;
  double y;
  bool hit = false;

  LiveObstacle({
    required this.id,
    required this.emoji,
    required this.lane,
    required this.y,
  });
}

// ─────────────────────────────────────────────────────────────────
// Floating score popup
// ─────────────────────────────────────────────────────────────────
class FloatingText {
  final String text;
  final Color color;
  double x;
  double y;
  double opacity;
  double age; // 0.0 → 1.0

  FloatingText({
    required this.text,
    required this.color,
    required this.x,
    required this.y,
    this.opacity = 1.0,
    this.age = 0.0,
  });
}

// ─────────────────────────────────────────────────────────────────
// Adventure Controller
// ─────────────────────────────────────────────────────────────────
class AdventureController extends GetxController {
  static AdventureController get to => Get.find();

  final ProgressService _progress = ProgressService.to;
  final _rng = Random();

  // ── State ──────────────────────────────────────────────────────
  final Rx<GameState> gameState = GameState.lobby.obs;
  final Rx<PlayerState> playerState = PlayerState.running.obs;

  // ── Player position ───────────────────────────────────────────
  final RxInt playerLane = 1.obs; // 0=left, 1=center, 2=right
  final RxDouble jumpProgress = 0.0.obs; // 0→1→0 arc
  final RxDouble slideProgress = 0.0.obs; // 0→1 when sliding
  bool _isJumping = false;
  bool _isSliding = false;

  // ── Score / XP / Lives ────────────────────────────────────────
  final RxInt score = 0.obs;
  final RxInt combo = 0.obs;
  final RxInt lives = 3.obs;
  final RxInt correctCollected = 0.obs;
  final RxInt xpEarned = 0.obs;
  final RxInt coinsEarned = 0.obs;
  final RxInt starsEarned = 0.obs;

  // ── Combo multiplier ──────────────────────────────────────────
  int get multiplier {
    if (combo.value >= 15) return 4;
    if (combo.value >= 10) return 3;
    if (combo.value >= 5) return 2;
    return 1;
  }

  // ── Stage data ────────────────────────────────────────────────
  final Rx<AdventureStage?> currentStage = Rxn<AdventureStage>();

  // ── Power-up ──────────────────────────────────────────────────
  final Rx<PowerUpType> activePowerUp = PowerUpType.none.obs;
  final RxDouble powerUpTimeLeft = 0.0.obs;

  // ── Game speed ────────────────────────────────────────────────
  final RxDouble gameSpeed = 1.0.obs; // base speed multiplier

  // ── Live entities (managed by game loop) ─────────────────────
  final RxList<LiveCollectible> liveCollectibles = <LiveCollectible>[].obs;
  final RxList<LiveObstacle> liveObstacles = <LiveObstacle>[].obs;
  final RxList<FloatingText> floatingTexts = <FloatingText>[].obs;

  // ── Background scroll ─────────────────────────────────────────
  final RxDouble bgScrollOffset = 0.0.obs;

  // ── Feedback ──────────────────────────────────────────────────
  final RxString feedbackMessage = ''.obs;
  final RxBool showFeedback = false.obs;

  // ── Timers ────────────────────────────────────────────────────
  Timer? _spawnTimer;
  Timer? _obstacleSpawnTimer;
  Timer? _powerUpSpawnTimer;
  Timer? _jumpTimer;
  Timer? _slideTimer;
  Timer? _hitTimer;
  Timer? _powerUpTimer;

  int _collectibleIdCounter = 0;
  int _obstacleIdCounter = 0;

  // ─────────────────────────────────────────────────────────────────
  // GAME LOOP — called every frame by AdventureGameWidget
  // ─────────────────────────────────────────────────────────────────
  void tick(double dt) {
    if (gameState.value != GameState.playing) return;

    final speed = gameSpeed.value * dt * 0.20;

    // Scroll background
    bgScrollOffset.value = (bgScrollOffset.value + speed * 0.3) % 1.0;

    // Move collectibles down
    final toRemoveC = <LiveCollectible>[];
    for (final c in liveCollectibles) {
      c.y += speed;
      if (c.y > 1.1) {
        c.missed = true;
        toRemoveC.add(c);
      }
    }
    if (toRemoveC.isNotEmpty) {
      liveCollectibles.removeWhere((c) => c.missed);
    }

    // Move obstacles down
    final toRemoveO = <LiveObstacle>[];
    for (final o in liveObstacles) {
      o.y += speed;
      if (o.y > 1.1) toRemoveO.add(o);
    }
    if (toRemoveO.isNotEmpty) {
      liveObstacles.removeWhere((o) => toRemoveO.contains(o));
    }

    // Animate floating texts
    final toRemoveF = <FloatingText>[];
    for (final f in floatingTexts) {
      f.age += dt * 1.2;
      f.y -= dt * 0.08;
      f.opacity = (1.0 - f.age).clamp(0.0, 1.0);
      if (f.age >= 1.0) toRemoveF.add(f);
    }
    if (toRemoveF.isNotEmpty) {
      floatingTexts.removeWhere((f) => toRemoveF.contains(f));
    }

    // Power-up countdown
    if (activePowerUp.value != PowerUpType.none) {
      powerUpTimeLeft.value -= dt;
      if (powerUpTimeLeft.value <= 0) {
        activePowerUp.value = PowerUpType.none;
      }
    }

    // Check collision between player and collectibles
    _checkCollisions();

    // Check obstacle collisions
    _checkObstacleCollisions();

    // Gradually increase speed
    if (gameSpeed.value < 1.5) {
      gameSpeed.value += dt * 0.001;
    }

    liveCollectibles.refresh();
    liveObstacles.refresh();
    floatingTexts.refresh();
  }

  // ─────────────────────────────────────────────────────────────────
  // COLLISION DETECTION
  // ─────────────────────────────────────────────────────────────────
  void _checkCollisions() {
    final stage = currentStage.value;
    if (stage == null) return;

    final collectZoneY = 0.72;
    final collectZoneYEnd = 0.85;

    for (final c in List<LiveCollectible>.from(liveCollectibles)) {
      if (c.collected || c.missed) continue;
      if (c.lane != playerLane.value) continue;
      if (c.y < collectZoneY || c.y > collectZoneYEnd) continue;
      if (_isJumping && jumpProgress.value > 0.1) continue;

      c.collected = true;
      _onCollectItem(c.data);
      liveCollectibles.remove(c);
    }
  }

  void _checkObstacleCollisions() {
    if (playerState.value == PlayerState.hit) return;
    if (activePowerUp.value == PowerUpType.shield ||
        activePowerUp.value == PowerUpType.jetpack) return;

    final hitZoneY = 0.72;
    final hitZoneYEnd = 0.85;

    for (final o in List<LiveObstacle>.from(liveObstacles)) {
      if (o.hit) continue;
      if (o.lane != playerLane.value) continue;
      if (o.y < hitZoneY || o.y > hitZoneYEnd) continue;
      if (_isJumping && jumpProgress.value > 0.2) continue;
      if (_isSliding && o.emoji == '🌿') continue;

      o.hit = true;
      liveObstacles.remove(o);
      _onHitObstacle();
      return;
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // COLLECT ITEM
  // ─────────────────────────────────────────────────────────────────
  void _onCollectItem(AdventureCollectible item) {
    final stage = currentStage.value;
    if (stage == null) return;

    if (item.isCorrect) {
      final points = 10 * multiplier;
      score.value += points;
      combo.value++;
      correctCollected.value++;
      xpEarned.value += 5;
      coinsEarned.value += 2;

      // Power-up active bonus
      if (activePowerUp.value == PowerUpType.doubleScore ||
          activePowerUp.value == PowerUpType.rainbow) {
        score.value += points;
      }

      // Speak pronunciation
      TtsService.to.speak(item.pronunciation);
      HapticUtil.light();

      // Floating text
      _spawnFloatingText('+$points', Colors.greenAccent, playerLane.value);

      // Feedback every 5 correct
      if (combo.value % 5 == 0) {
        final msg = AdventureContentData.correctFeedback[_rng.nextInt(AdventureContentData.correctFeedback.length)];
        _showFeedback(msg);
      }

      _progress.incrementAdventureCollected();

      // Check stage complete
      if (correctCollected.value >= stage.targetCollectCount &&
          score.value >= stage.targetScore) {
        _completeStage();
      }
    } else {
      // Wrong item
      combo.value = 0;
      score.value = (score.value - 5).clamp(0, 99999);
      HapticUtil.medium();
      _spawnFloatingText('Oops!', Colors.orangeAccent, playerLane.value);
      TtsService.to.speak('Try again!');
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // HIT OBSTACLE
  // ─────────────────────────────────────────────────────────────────
  void _onHitObstacle() {
    if (activePowerUp.value == PowerUpType.shield) {
      activePowerUp.value = PowerUpType.none;
      _showFeedback('Shield saved you! 🛡️');
      return;
    }

    lives.value--;
    combo.value = 0;
    playerState.value = PlayerState.hit;
    HapticUtil.heavy();
    AudioService.to.playStar(); // reuse existing sound

    _spawnFloatingText('💥 Ouch!', Colors.redAccent, playerLane.value);

    // Temporary slow down after hit
    gameSpeed.value = (gameSpeed.value * 0.7).clamp(0.5, 1.5);

    _hitTimer?.cancel();
    _hitTimer = Timer(const Duration(milliseconds: 1200), () {
      if (gameState.value == GameState.playing) {
        playerState.value = PlayerState.running;
      }
    });

    if (lives.value <= 0) {
      _gameOver();
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // STAGE COMPLETE
  // ─────────────────────────────────────────────────────────────────
  void _completeStage() {
    _cancelAllTimers();
    gameState.value = GameState.stageComplete;
    playerState.value = PlayerState.celebrating;

    final stage = currentStage.value!;

    // Calculate stars (1–3)
    final ratio = score.value / stage.targetScore;
    if (ratio >= 1.5) starsEarned.value = 3;
    else if (ratio >= 1.0) starsEarned.value = 2;
    else starsEarned.value = 1;

    // Reward
    final bonusCoins = starsEarned.value * 10;
    final bonusXp = starsEarned.value * 20;
    coinsEarned.value += bonusCoins;
    xpEarned.value += bonusXp;

    _progress.addCoins(coinsEarned.value);
    _progress.addXP(xpEarned.value);
    for (int i = 0; i < starsEarned.value; i++) {
      _progress.addStar();
      _progress.addAdventureStar();
    }
    _progress.updateAdventureHighScore(score.value);
    _progress.unlockAdventureStage(stage.stageNumber + 1);

    Get.offNamed('/learning-adventure-result');
  }

  // ─────────────────────────────────────────────────────────────────
  // GAME OVER
  // ─────────────────────────────────────────────────────────────────
  void _gameOver() {
    _cancelAllTimers();
    gameState.value = GameState.gameOver;
    playerState.value = PlayerState.hit;
    starsEarned.value = 0;

    _progress.updateAdventureHighScore(score.value);
    if (coinsEarned.value > 0) _progress.addCoins(coinsEarned.value ~/ 2);

    Get.offNamed('/learning-adventure-result');
  }

  // ─────────────────────────────────────────────────────────────────
  // START STAGE — only prepares state and navigates.
  // Spawning is deferred until the game screen calls beginSpawning().
  // ─────────────────────────────────────────────────────────────────
  void startStage(AdventureStage stage) {
    _cancelAllTimers();
    liveCollectibles.clear();
    liveObstacles.clear();
    floatingTexts.clear();

    currentStage.value = stage;
    score.value = 0;
    combo.value = 0;
    lives.value = stage.lives;
    correctCollected.value = 0;
    xpEarned.value = 0;
    coinsEarned.value = 0;
    starsEarned.value = 0;
    playerLane.value = 1;
    playerState.value = PlayerState.running;
    activePowerUp.value = PowerUpType.none;
    gameSpeed.value = stage.speedMultiplier;
    bgScrollOffset.value = 0.0;
    _isJumping = false;
    _isSliding = false;

    // Set state to playing but do NOT start spawning yet.
    // The game screen will call beginSpawning() once it is mounted.
    gameState.value = GameState.playing;

    Get.toNamed('/learning-adventure-game', arguments: stage);
  }

  /// Called by AdventureGameScreen once it is fully mounted and ready
  /// to receive game entities on screen.
  void beginSpawning() {
    final stage = currentStage.value;
    if (stage == null) return;
    _startSpawning(stage);
  }

  void _startSpawning(AdventureStage stage) {
    // Cancel any existing timers first to avoid duplicates
    _spawnTimer?.cancel();
    _obstacleSpawnTimer?.cancel();
    _powerUpSpawnTimer?.cancel();

    // Spawn collectibles
    _spawnTimer = Timer.periodic(const Duration(milliseconds: 1800), (_) {
      if (gameState.value != GameState.playing) return;
      _spawnCollectible(stage);
    });

    // Spawn obstacles
    _obstacleSpawnTimer = Timer.periodic(const Duration(milliseconds: 4200), (_) {
      if (gameState.value != GameState.playing) return;
      _spawnObstacle();
    });

    // Spawn power-ups occasionally
    _powerUpSpawnTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (gameState.value != GameState.playing) return;
      _spawnPowerUp();
    });
  }

  void _spawnCollectible(AdventureStage stage) {
    final lane = _rng.nextInt(3);
    final isCorrect = _rng.nextDouble() < 0.45; // ~45% chance correct
    
    AdventureCollectible item;
    if (isCorrect) {
      item = stage.correctItems[_rng.nextInt(stage.correctItems.length)];
    } else {
      final distractors = stage.distractorItems;
      if (distractors.isEmpty) {
        item = AdventureContentData.obstacleDistractors[_rng.nextInt(AdventureContentData.obstacleDistractors.length)];
      } else {
        item = distractors[_rng.nextInt(distractors.length)];
      }
    }

    final live = LiveCollectible(
      id: 'c_${_collectibleIdCounter++}',
      data: item.copyWith(isCorrect: isCorrect),
      lane: lane,
      y: -0.05,
    );

    // Magnet: place correct items in player's lane
    if (activePowerUp.value == PowerUpType.magnet && isCorrect) {
      live.lane = playerLane.value;
    }

    liveCollectibles.add(live);
  }

  void _spawnObstacle() {
    final lane = _rng.nextInt(3);
    final obstacles = AdventureContentData.obstacles;
    final obs = obstacles[_rng.nextInt(obstacles.length)];

    liveObstacles.add(LiveObstacle(
      id: 'o_${_obstacleIdCounter++}',
      emoji: obs['emoji'] as String,
      lane: lane,
      y: -0.05,
    ));
  }

  void _spawnPowerUp() {
    // Spawn as a special collectible in a random lane
    final lane = _rng.nextInt(3);
    final powerUps = AdventureContentData.powerUps;
    final pu = powerUps[_rng.nextInt(powerUps.length)];

    liveCollectibles.add(LiveCollectible(
      id: 'pu_${_collectibleIdCounter++}',
      data: AdventureCollectible(
        emoji: pu['emoji'] as String,
        label: pu['label'] as String,
        pronunciation: '${pu['label']} power-up!',
        category: 'powerup',
        isCorrect: true,
      ),
      lane: lane,
      y: -0.05,
    ));
  }

  // ─────────────────────────────────────────────────────────────────
  // SWIPE CONTROLS
  // ─────────────────────────────────────────────────────────────────
  void onSwipeLeft() {
    if (gameState.value != GameState.playing) return;
    if (playerLane.value > 0) {
      playerLane.value--;
      HapticUtil.light();
    }
  }

  void onSwipeRight() {
    if (gameState.value != GameState.playing) return;
    if (playerLane.value < 2) {
      playerLane.value++;
      HapticUtil.light();
    }
  }

  void onSwipeUp() {
    if (gameState.value != GameState.playing) return;
    if (_isJumping) return;
    if (activePowerUp.value == PowerUpType.jetpack) return;

    _isJumping = true;
    playerState.value = PlayerState.jumping;
    HapticUtil.light();

    // Animate jump arc
    int tick = 0;
    _jumpTimer = Timer.periodic(const Duration(milliseconds: 30), (t) {
      tick++;
      final progress = tick / 28.0;
      jumpProgress.value = sin(progress * pi).clamp(0.0, 1.0);
      if (tick >= 28) {
        t.cancel();
        _isJumping = false;
        jumpProgress.value = 0.0;
        if (gameState.value == GameState.playing) {
          playerState.value = PlayerState.running;
        }
      }
    });
  }

  void onSwipeDown() {
    if (gameState.value != GameState.playing) return;
    if (_isJumping) return;

    _isSliding = true;
    playerState.value = PlayerState.sliding;
    slideProgress.value = 1.0;
    HapticUtil.light();

    _slideTimer?.cancel();
    _slideTimer = Timer(const Duration(milliseconds: 950), () {
      _isSliding = false;
      slideProgress.value = 0.0;
      if (gameState.value == GameState.playing) {
        playerState.value = PlayerState.running;
      }
    });
  }

  // ─────────────────────────────────────────────────────────────────
  // PAUSE / RESUME
  // ─────────────────────────────────────────────────────────────────
  void pauseGame() {
    if (gameState.value == GameState.playing) {
      gameState.value = GameState.paused;
      _spawnTimer?.cancel();
      _obstacleSpawnTimer?.cancel();
      _powerUpSpawnTimer?.cancel();
    }
  }

  void resumeGame() {
    if (gameState.value == GameState.paused) {
      gameState.value = GameState.playing;
      final stage = currentStage.value;
      if (stage != null) _startSpawning(stage);
    }
  }

  void quitToLobby() {
    _cancelAllTimers();
    gameState.value = GameState.lobby;
    liveCollectibles.clear();
    liveObstacles.clear();
    floatingTexts.clear();
    Get.offAllNamed('/home');
    Get.toNamed('/learning-adventure');
  }

  // ─────────────────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────────────────
  void _spawnFloatingText(String text, Color color, int lane) {
    final x = lane == 0 ? 0.2 : lane == 1 ? 0.5 : 0.8;
    floatingTexts.add(FloatingText(
      text: text,
      color: color,
      x: x,
      y: 0.7,
    ));
  }

  void _showFeedback(String msg) {
    feedbackMessage.value = msg;
    showFeedback.value = true;
    Timer(const Duration(milliseconds: 1500), () {
      showFeedback.value = false;
    });
  }

  void _cancelAllTimers() {
    _spawnTimer?.cancel();
    _obstacleSpawnTimer?.cancel();
    _powerUpSpawnTimer?.cancel();
    _jumpTimer?.cancel();
    _slideTimer?.cancel();
    _hitTimer?.cancel();
    _powerUpTimer?.cancel();
  }

  @override
  void onClose() {
    _cancelAllTimers();
    super.onClose();
  }
}
