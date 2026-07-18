import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/haptic_util.dart';
import '../../../services/progress_service.dart';
import '../../../services/tts_service.dart';
import '../../../services/audio_service.dart';
import '../../shared/widgets/celebration_overlay.dart';

class BubblePopGame extends StatefulWidget {
  const BubblePopGame({Key? key}) : super(key: key);

  @override
  State<BubblePopGame> createState() => _BubblePopGameState();
}

class _BubblePopGameState extends State<BubblePopGame> with TickerProviderStateMixin {
  final _rand = Random();
  final _progress = ProgressService.to;

  int _score = 0;
  int _streak = 0;
  int _lives = 5;
  bool _gameOver = false;
  bool _gameStarted = false;

  String _targetLetter = '';
  final List<_Bubble> _bubbles = [];
  Timer? _spawnTimer;
  late AnimationController _tickController;

  static const _letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const _bubbleColors = [
    Color(0xFFFF6B6B), Color(0xFF4ECDC4), Color(0xFFC084FC),
    Color(0xFF60A5FA), Color(0xFFFFD700), Color(0xFFF472B6),
    Color(0xFF22C55E), Color(0xFFFB923C), Color(0xFF818CF8),
  ];

  @override
  void initState() {
    super.initState();
    _tickController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(_tick);
  }

  void _startGame() {
    setState(() {
      _gameStarted = true;
      _score = 0;
      _streak = 0;
      _lives = 5;
      _gameOver = false;
      _bubbles.clear();
    });
    _pickNewTarget();
    _tickController.repeat();
    _spawnTimer = Timer.periodic(const Duration(milliseconds: 1200), (_) {
      if (!_gameOver) _spawnBubble();
    });
    // Spawn initial batch
    for (int i = 0; i < 4; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted && !_gameOver) _spawnBubble();
      });
    }
  }

  void _pickNewTarget() {
    _targetLetter = _letters[_rand.nextInt(26)];
    TtsService.to.speak("Pop the letter $_targetLetter!");
  }

  void _spawnBubble() {
    if (!mounted) return;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Ensure at least one correct letter in the batch sometimes
    final bool forceCorrect = _bubbles.where((b) => b.letter == _targetLetter && !b.popped).isEmpty && _rand.nextDouble() < 0.5;
    final letter = forceCorrect ? _targetLetter : _letters[_rand.nextInt(26)];

    setState(() {
      _bubbles.add(_Bubble(
        letter: letter,
        x: 30.0 + _rand.nextDouble() * (screenWidth - 90.0),
        y: MediaQuery.of(context).size.height + 20,
        speed: 0.4 + _rand.nextDouble() * 0.5,
        size: 54.0 + _rand.nextDouble() * 20.0,
        color: _bubbleColors[_rand.nextInt(_bubbleColors.length)],
        wobbleOffset: _rand.nextDouble() * pi * 2,
      ));
    });
  }

  void _tick() {
    if (_gameOver || !mounted) return;
    setState(() {
      for (final b in _bubbles) {
        if (!b.popped) {
          b.y -= b.speed;
          b.x += sin(b.y * 0.02 + b.wobbleOffset) * 0.5;
        }
      }
      // Remove bubbles that floated out of screen
      _bubbles.removeWhere((b) => b.y < -80 && !b.popped);
      _bubbles.removeWhere((b) => b.popped && b.popTimer > 20);
      
      // Increment pop timers
      for (final b in _bubbles) {
        if (b.popped) b.popTimer++;
      }
    });
  }

  void _onBubbleTap(_Bubble bubble) {
    if (bubble.popped || _gameOver) return;
    HapticUtil.light();

    setState(() {
      bubble.popped = true;
    });

    if (bubble.letter == _targetLetter) {
      // Correct!
      _score += 10 + (_streak * 2);
      _streak++;
      AudioService.to.playStar();
      HapticUtil.medium();

      if (_score > 0 && _score % 50 == 0) {
        _progress.addStar();
      }
      _progress.addCoins(2);

      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted && !_gameOver) _pickNewTarget();
      });
    } else {
      // Wrong bubble
      _streak = 0;
      _lives--;
      AudioService.to.playTap();
      HapticUtil.heavy();
      
      if (_lives <= 0) {
        _endGame();
      }
    }
  }

  void _endGame() {
    _gameOver = true;
    _spawnTimer?.cancel();
    _tickController.stop();
    _progress.incrementMiniGamesPlayed();
    _progress.updateGameHighScore('bubble_pop', _score);
    _progress.addXP(max(5, _score ~/ 5));

    if (_score >= 30) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) showCelebration(context);
      });
    }
  }

  @override
  void dispose() {
    _spawnTimer?.cancel();
    _tickController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: _gameStarted ? _buildGameView() : _buildStartView(),
      ),
    );
  }

  Widget _buildStartView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("🫧", style: TextStyle(fontSize: 80))
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2), duration: const Duration(seconds: 2)),
          const SizedBox(height: 16),
          Text("Bubble Pop ABCs",
              style: AppTextStyles.displaySmall.copyWith(color: AppColors.gold, fontSize: 32)),
          const SizedBox(height: 8),
          Text("Pop the correct letter bubbles!\nDon't pop wrong ones — you have 5 lives!",
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
              textAlign: TextAlign.center),
          const SizedBox(height: 40),
          GestureDetector(
            onTap: _startGame,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)]),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: const Color(0xFFFF6B6B).withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6)),
                ],
              ),
              child: Text("START! 🎮",
                  style: AppTextStyles.bodyLargeBold.copyWith(color: Colors.white, fontSize: 20)),
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.05, 1.05), duration: const Duration(milliseconds: 1200)),
          const SizedBox(height: 20),
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white54, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildGameView() {
    return Stack(
      children: [
        // HUD
        Positioned(
          top: 8, left: 16, right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 28),
              ),
              // Score
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.gold.withOpacity(0.3)),
                ),
                child: Text("⭐ $_score",
                    style: AppTextStyles.bodyMediumBold.copyWith(color: AppColors.gold, fontSize: 16)),
              ),
              Row(
                children: List.generate(5, (i) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      i < _lives ? "❤️" : "🖤",
                      style: const TextStyle(fontSize: 20),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),

        // Target letter prompt
        Positioned(
          top: 60, left: 0, right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.bgMid,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.lavender.withOpacity(0.4), width: 2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("🔊", style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 8),
                  Text("Pop: ",
                      style: AppTextStyles.bodyMediumBold.copyWith(color: Colors.white70, fontSize: 16)),
                  Text(_targetLetter,
                      style: AppTextStyles.displaySmall.copyWith(color: AppColors.gold, fontSize: 28)),
                  if (_streak > 1) ...[
                    const SizedBox(width: 12),
                    Text("🔥 x$_streak",
                        style: AppTextStyles.bodySmallBold.copyWith(color: AppColors.coral, fontSize: 14)),
                  ],
                ],
              ),
            )
                .animate(key: ValueKey(_targetLetter))
                .scale(begin: const Offset(0.8, 0.8), duration: const Duration(milliseconds: 300), curve: Curves.elasticOut),
          ),
        ),

        // Bubbles
        ..._bubbles.map((b) {
          if (b.popped) {
            return Positioned(
              left: b.x - b.size / 2,
              top: b.y - b.size / 2,
              child: SizedBox(
                width: b.size,
                height: b.size,
                child: Center(
                  child: Text(
                    b.letter == _targetLetter ? "✨" : "💨",
                    style: TextStyle(fontSize: b.size * 0.5),
                  ),
                ),
              )
                  .animate()
                  .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.8, 1.8), duration: const Duration(milliseconds: 300))
                  .fadeOut(duration: const Duration(milliseconds: 300)),
            );
          }
          return Positioned(
            left: b.x - b.size / 2,
            top: b.y - b.size / 2,
            child: GestureDetector(
              onTap: () => _onBubbleTap(b),
              child: Container(
                width: b.size,
                height: b.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      b.color.withOpacity(0.9),
                      b.color.withOpacity(0.4),
                    ],
                    center: const Alignment(-0.3, -0.3),
                  ),
                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: b.color.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    b.letter,
                    style: AppTextStyles.displaySmall.copyWith(
                      color: Colors.white,
                      fontSize: b.size * 0.45,
                      shadows: [
                        Shadow(color: Colors.black26, blurRadius: 4, offset: const Offset(1, 2)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }),

        // Game Over overlay
        if (_gameOver)
          Positioned.fill(
            child: Container(
              color: Colors.black54,
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(32),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.bgMid,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: AppColors.gold.withOpacity(0.4), width: 2),
                    boxShadow: [
                      BoxShadow(color: AppColors.gold.withOpacity(0.2), blurRadius: 30),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_score >= 50 ? "🏆" : "🫧", style: const TextStyle(fontSize: 64)),
                      const SizedBox(height: 12),
                      Text("Game Over!",
                          style: AppTextStyles.displaySmall.copyWith(color: AppColors.gold, fontSize: 28)),
                      const SizedBox(height: 8),
                      Text("Score: $_score",
                          style: AppTextStyles.bodyLargeBold.copyWith(color: Colors.white, fontSize: 22)),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _bubbles.clear();
                              });
                              _startGame();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [AppColors.mint, Color(0xFF44A08D)]),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Text("Play Again 🔄",
                                  style: AppTextStyles.bodyMediumBold.copyWith(color: Colors.white)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () => Get.back(),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: Text("Back",
                                  style: AppTextStyles.bodyMediumBold.copyWith(color: Colors.white70)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
                    .animate()
                    .scale(begin: const Offset(0.8, 0.8), duration: const Duration(milliseconds: 400), curve: Curves.elasticOut),
              ),
            ),
          ),
      ],
    );
  }
}

class _Bubble {
  String letter;
  double x;
  double y;
  double speed;
  double size;
  Color color;
  double wobbleOffset;
  bool popped;
  int popTimer;

  _Bubble({
    required this.letter,
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.color,
    required this.wobbleOffset,
    this.popped = false,
    this.popTimer = 0,
  });
}
