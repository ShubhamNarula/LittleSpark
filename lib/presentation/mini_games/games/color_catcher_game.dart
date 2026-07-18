import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/haptic_util.dart';
import '../../../services/progress_service.dart';
import '../../../services/audio_service.dart';
import '../../../services/tts_service.dart';
import '../../shared/widgets/celebration_overlay.dart';

class ColorCatcherGame extends StatefulWidget {
  const ColorCatcherGame({Key? key}) : super(key: key);

  @override
  State<ColorCatcherGame> createState() => _ColorCatcherGameState();
}

class _ColorCatcherGameState extends State<ColorCatcherGame> with SingleTickerProviderStateMixin {
  final _rand = Random();
  final _progress = ProgressService.to;

  int _score = 0;
  int _combo = 0;
  int _lives = 5;
  bool _gameStarted = false;
  bool _gameOver = false;
  double _basketX = 0.5; // 0 to 1

  String _targetColorName = '';
  Color _targetColor = Colors.red;
  final List<_FallingItem> _items = [];

  Timer? _spawnTimer;
  late AnimationController _tickController;

  static const List<Map<String, dynamic>> _colorDefs = [
    {'name': 'RED', 'color': Color(0xFFFF6B6B), 'emoji': '🔴'},
    {'name': 'BLUE', 'color': Color(0xFF60A5FA), 'emoji': '🔵'},
    {'name': 'GREEN', 'color': Color(0xFF22C55E), 'emoji': '🟢'},
    {'name': 'YELLOW', 'color': Color(0xFFFFD700), 'emoji': '🟡'},
    {'name': 'PURPLE', 'color': Color(0xFFC084FC), 'emoji': '🟣'},
    {'name': 'ORANGE', 'color': Color(0xFFFB923C), 'emoji': '🟠'},
  ];

  static const List<String> _itemEmojis = [
    '🍎', '🍓', '🌹', '❤️', // red-ish
    '🫐', '💎', '🧊', '💙', // blue-ish
    '🍀', '🥒', '🐸', '💚', // green-ish
    '🌻', '⭐', '🍋', '💛', // yellow-ish
    '🍇', '🔮', '🦄', '💜', // purple-ish
    '🍊', '🥕', '🏀', '🧡', // orange-ish
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
      _combo = 0;
      _lives = 5;
      _gameOver = false;
      _basketX = 0.5;
      _items.clear();
    });
    _pickNewColor();
    _tickController.repeat();
    _spawnTimer = Timer.periodic(const Duration(milliseconds: 900), (_) {
      if (!_gameOver && mounted) _spawnItem();
    });
    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 250), () {
        if (mounted && !_gameOver) _spawnItem();
      });
    }
  }

  void _pickNewColor() {
    final colorDef = _colorDefs[_rand.nextInt(_colorDefs.length)];
    _targetColorName = colorDef['name'] as String;
    _targetColor = colorDef['color'] as Color;
    TtsService.to.speak("Catch all $_targetColorName things!");
  }

  void _spawnItem() {
    if (!mounted) return;
    final screenWidth = MediaQuery.of(context).size.width;
    final colorIndex = _rand.nextInt(_colorDefs.length);
    final itemGroupStart = colorIndex * 4;
    final emoji = _itemEmojis[itemGroupStart + _rand.nextInt(4)];
    final colorDef = _colorDefs[colorIndex];

    setState(() {
      _items.add(_FallingItem(
        emoji: emoji,
        colorName: colorDef['name'] as String,
        color: colorDef['color'] as Color,
        x: 20.0 + _rand.nextDouble() * (screenWidth - 60),
        y: -40,
        speed: 0.7 + _rand.nextDouble() * 0.7 + (_score ~/ 30) * 0.1,
        size: 36.0 + _rand.nextDouble() * 12,
      ));
    });
  }

  void _tick() {
    if (_gameOver || !mounted) return;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final basketLeft = _basketX * (screenWidth - 80);
    const basketWidth = 80.0;
    final basketTop = screenHeight - 160;

    setState(() {
      for (final item in _items) {
        if (item.caught || item.missed) continue;
        item.y += item.speed;
        item.x += sin(item.y * 0.03) * 0.4;

        // Check basket collision
        if (item.y >= basketTop - 20 && item.y <= basketTop + 30) {
          if (item.x >= basketLeft - 10 && item.x <= basketLeft + basketWidth + 10) {
            item.caught = true;
            if (item.colorName == _targetColorName) {
              // Correct catch!
              _score += 5 + _combo;
              _combo++;
              AudioService.to.playStar();
              HapticUtil.light();
            } else {
              // Wrong color caught
              _lives--;
              _combo = 0;
              HapticUtil.heavy();
              if (_lives <= 0) _endGame();
            }
          }
        }

        // Missed (fell off screen)
        if (item.y > screenHeight + 50) {
          item.missed = true;
          if (item.colorName == _targetColorName) {
            // Missed a target item
            _lives--;
            _combo = 0;
            if (_lives <= 0) _endGame();
          }
        }
      }
      _items.removeWhere((i) => i.caught || i.missed);
    });

    // Change target color every 20 points
    if (_score > 0 && _score % 40 == 0 && _items.isEmpty) {
      _pickNewColor();
    }
  }

  void _endGame() {
    _gameOver = true;
    _spawnTimer?.cancel();
    _tickController.stop();
    _progress.incrementMiniGamesPlayed();
    _progress.updateGameHighScore('color_catcher', _score);
    _progress.addXP(max(5, _score ~/ 4));

    if (_score >= 25) {
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
          const Text("🎨", style: TextStyle(fontSize: 80))
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .rotate(begin: -0.05, end: 0.05, duration: const Duration(seconds: 2)),
          const SizedBox(height: 16),
          Text("Color Catcher",
              style: AppTextStyles.displaySmall.copyWith(color: AppColors.gold, fontSize: 32)),
          const SizedBox(height: 8),
          Text("Swipe the basket to catch\nobjects of the right color!",
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
              textAlign: TextAlign.center),
          const SizedBox(height: 40),
          GestureDetector(
            onTap: _startGame,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFC084FC), Color(0xFF818CF8)]),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: const Color(0xFFC084FC).withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6)),
                ],
              ),
              child: Text("START! 🎨",
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        setState(() {
          _basketX = (_basketX + details.delta.dx / screenWidth).clamp(0.0, 1.0);
        });
      },
      onPanUpdate: (details) {
        setState(() {
          _basketX = (_basketX + details.delta.dx / screenWidth).clamp(0.0, 1.0);
        });
      },
      child: Stack(
        children: [
          // HUD
          Positioned(
            top: 8, left: 16, right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close_rounded, color: Colors.white54),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.gold.withOpacity(0.3)),
                  ),
                  child: Text("⭐ $_score",
                      style: AppTextStyles.bodyMediumBold.copyWith(color: AppColors.gold)),
                ),
                Row(
                  children: List.generate(5, (i) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 2),
                      child: Text(i < _lives ? "❤️" : "🖤", style: const TextStyle(fontSize: 16)),
                    );
                  }),
                ),
              ],
            ),
          ),

          // Target color banner
          Positioned(
            top: 56, left: 0, right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                decoration: BoxDecoration(
                  color: _targetColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _targetColor.withOpacity(0.5), width: 2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Catch: ", style: AppTextStyles.bodyMediumBold.copyWith(color: Colors.white70)),
                    Text(_targetColorName,
                        style: AppTextStyles.bodyLargeBold.copyWith(color: _targetColor, fontSize: 20)),
                    if (_combo > 1) ...[
                      const SizedBox(width: 12),
                      Text("🔥 x$_combo",
                          style: AppTextStyles.bodySmallBold.copyWith(color: AppColors.coral)),
                    ],
                  ],
                ),
              )
                  .animate(key: ValueKey(_targetColorName))
                  .scale(begin: const Offset(0.8, 0.8), duration: const Duration(milliseconds: 300), curve: Curves.elasticOut),
            ),
          ),

          // Falling items
          ..._items.map((item) {
            return Positioned(
              left: item.x - item.size / 2,
              top: item.y,
              child: Text(item.emoji, style: TextStyle(fontSize: item.size)),
            );
          }),

          // Basket
          Positioned(
            left: _basketX * (screenWidth - 80),
            bottom: 60,
            child: Container(
              width: 80,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_targetColor.withOpacity(0.7), _targetColor],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
                border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
                boxShadow: [
                  BoxShadow(color: _targetColor.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4)),
                ],
              ),
              child: const Center(
                child: Text("🧺", style: TextStyle(fontSize: 28)),
              ),
            ),
          ),

          // Game Over
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
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("🎨", style: TextStyle(fontSize: 64)),
                        const SizedBox(height: 12),
                        Text("Game Over!",
                            style: AppTextStyles.displaySmall.copyWith(color: AppColors.gold, fontSize: 28)),
                        Text("Score: $_score",
                            style: AppTextStyles.bodyLargeBold.copyWith(color: Colors.white, fontSize: 22)),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() => _items.clear());
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
      ),
    );
  }
}

class _FallingItem {
  String emoji;
  String colorName;
  Color color;
  double x;
  double y;
  double speed;
  double size;
  bool caught;
  bool missed;

  _FallingItem({
    required this.emoji,
    required this.colorName,
    required this.color,
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    this.caught = false,
    this.missed = false,
  });
}
