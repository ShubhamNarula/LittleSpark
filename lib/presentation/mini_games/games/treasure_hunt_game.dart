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
import '../../shared/widgets/confetti_overlay_widget.dart';

class TreasureHuntGame extends StatefulWidget {
  const TreasureHuntGame({Key? key}) : super(key: key);

  @override
  State<TreasureHuntGame> createState() => _TreasureHuntGameState();
}

class _TreasureHuntGameState extends State<TreasureHuntGame> {
  final _rand = Random();
  final _progress = ProgressService.to;
  final GlobalKey<ConfettiOverlayWidgetState> _confettiKey =
      GlobalKey<ConfettiOverlayWidgetState>();

  int _score = 0;
  int _round = 0;
  int _totalRounds = 8;
  bool _gameStarted = false;
  bool _gameOver = false;
  bool _roundAnswered = false;
  bool _isCorrect = false;
  bool _chestOpen = false;

  String _treasureEmoji = '💎';
  int _correctCount = 0;
  List<String> _options = [];
  List<String> _displayItems = [];

  static const _treasures = [
    {'emoji': '💎', 'name': 'gems'},
    {'emoji': '🪙', 'name': 'coins'},
    {'emoji': '⭐', 'name': 'stars'},
    {'emoji': '🍬', 'name': 'candies'},
    {'emoji': '🎁', 'name': 'gifts'},
    {'emoji': '🔑', 'name': 'keys'},
    {'emoji': '🧁', 'name': 'cupcakes'},
    {'emoji': '🏅', 'name': 'medals'},
  ];

  void _startGame() {
    setState(() {
      _gameStarted = true;
      _score = 0;
      _round = 0;
      _gameOver = false;
    });
    _generateRound();
  }

  void _generateRound() {
    if (_round >= _totalRounds) {
      _endGame();
      return;
    }

    final treasure = _treasures[_rand.nextInt(_treasures.length)];
    _treasureEmoji = treasure['emoji']!;
    final name = treasure['name']!;

    // Count between 2 and 9
    _correctCount = 2 + _rand.nextInt(8);

    // Build display items
    _displayItems = List.generate(_correctCount, (_) => _treasureEmoji);

    _roundAnswered = false;
    _isCorrect = false;
    _chestOpen = false;

    // Generate 3 options
    final opt1 = _correctCount;
    int opt2 = _correctCount + (_rand.nextBool() ? 1 : -1);
    if (opt2 < 1) opt2 = _correctCount + 2;
    int opt3 = _correctCount + (_rand.nextBool() ? 2 : -2);
    if (opt3 < 1) opt3 = _correctCount + 3;
    if (opt3 == opt2) opt3++;

    final optList = [opt1, opt2, opt3]..shuffle(_rand);
    _options = optList.map((e) => '$e').toList();

    setState(() {});

    // Animate chest opening
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() => _chestOpen = true);
        TtsService.to.speak("Count the $name!");
      }
    });
  }

  void _checkAnswer(String answer) {
    if (_roundAnswered) return;
    HapticUtil.light();

    setState(() {
      _roundAnswered = true;
      _isCorrect = answer == '$_correctCount';
    });

    if (_isCorrect) {
      _score += 10;
      _progress.addCoins(3);
      AudioService.to.playStar();
      HapticUtil.medium();
      _confettiKey.currentState?.startCelebration();
      TtsService.to.speak("Correct! $_correctCount is right!");
    } else {
      AudioService.to.playTap();
      HapticUtil.heavy();
      TtsService.to.speak("Oops! The answer was $_correctCount.");
    }

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _round++);
        _generateRound();
      }
    });
  }

  void _endGame() {
    setState(() => _gameOver = true);
    _progress.incrementMiniGamesPlayed();
    _progress.updateGameHighScore('treasure_hunt', _score);
    _progress.addXP(15);
    _progress.addStar();

    if (_score >= 40) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) showCelebration(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Stack(
          children: [
            _gameStarted ? (_gameOver ? _buildGameOver() : _buildGameView()) : _buildStartView(),
            ConfettiOverlayWidget(key: _confettiKey),
          ],
        ),
      ),
    );
  }

  Widget _buildStartView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("💰", style: TextStyle(fontSize: 80))
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .moveY(begin: 0, end: -12, duration: const Duration(seconds: 1), curve: Curves.easeInOut),
          const SizedBox(height: 16),
          Text("Treasure Hunt",
              style: AppTextStyles.displaySmall.copyWith(color: AppColors.gold, fontSize: 32)),
          const SizedBox(height: 8),
          Text("Count the treasure items that\nbounce out of the chest!",
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
              textAlign: TextAlign.center),
          const SizedBox(height: 40),
          GestureDetector(
            onTap: _startGame,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFF59E0B)]),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: AppColors.gold.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6)),
                ],
              ),
              child: Text("HUNT! 💰",
                  style: AppTextStyles.bodyLargeBold.copyWith(color: AppColors.bgDark, fontSize: 20)),
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
    return Column(
      children: [
        // HUD
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.close_rounded, color: Colors.white54),
              ),
              Text("Round ${_round + 1}/$_totalRounds",
                  style: AppTextStyles.bodyMediumBold.copyWith(color: Colors.white70)),
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
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Treasure Chest
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: Text(
            _chestOpen ? "📭" : "📦",
            key: ValueKey(_chestOpen),
            style: const TextStyle(fontSize: 80),
          ),
        )
            .animate(key: ValueKey('chest_$_round'))
            .scale(begin: const Offset(0.6, 0.6), duration: const Duration(milliseconds: 500), curve: Curves.elasticOut),

        const SizedBox(height: 20),

        // Scattered items with bouncy entrance
        if (_chestOpen)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.gold.withOpacity(0.15)),
            ),
            child: Wrap(
              spacing: 14,
              runSpacing: 14,
              alignment: WrapAlignment.center,
              children: List.generate(_displayItems.length, (i) {
                return Text(
                  _displayItems[i],
                  style: const TextStyle(fontSize: 38),
                )
                    .animate(delay: Duration(milliseconds: i * 120))
                    .scale(begin: const Offset(0.0, 0.0), end: const Offset(1.0, 1.0),
                        duration: const Duration(milliseconds: 400), curve: Curves.elasticOut)
                    .moveY(begin: -20, end: 0, duration: const Duration(milliseconds: 300));
              }),
            ),
          ),

        const Spacer(),

        // Question
        if (_chestOpen) ...[
          Text(
            "How many $_treasureEmoji did you count?",
            style: AppTextStyles.bodyLargeBold.copyWith(color: Colors.white, fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Options
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _options.map((opt) {
              Color bg = Colors.white.withOpacity(0.08);
              Color border = Colors.white.withOpacity(0.15);

              if (_roundAnswered) {
                if (opt == '$_correctCount') {
                  bg = AppColors.successGreen.withOpacity(0.25);
                  border = AppColors.successGreen;
                } else if (opt != '$_correctCount' && !_isCorrect) {
                  bg = Colors.redAccent.withOpacity(0.15);
                  border = Colors.redAccent.withOpacity(0.5);
                }
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: GestureDetector(
                  onTap: () => _checkAnswer(opt),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: border, width: 2),
                    ),
                    child: Center(
                      child: Text(opt,
                          style: AppTextStyles.displaySmall.copyWith(fontSize: 30, color: Colors.white)),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],

        // Feedback
        if (_roundAnswered)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              _isCorrect ? "🎉 Correct! +10 points!" : "❌ It was $_correctCount!",
              style: AppTextStyles.bodyMediumBold.copyWith(
                color: _isCorrect ? AppColors.mint : AppColors.coral,
                fontSize: 16,
              ),
            )
                .animate()
                .fadeIn(duration: const Duration(milliseconds: 300))
                .scale(begin: const Offset(0.8, 0.8), duration: const Duration(milliseconds: 300)),
          ),

        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildGameOver() {
    return Center(
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
            Text(_score >= 50 ? "🏆" : "💰", style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 12),
            Text("Treasure Hunt Complete!",
                style: AppTextStyles.displaySmall.copyWith(color: AppColors.gold, fontSize: 24)),
            Text("Score: $_score / ${_totalRounds * 10}",
                style: AppTextStyles.bodyLargeBold.copyWith(color: Colors.white, fontSize: 20)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _startGame,
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
    );
  }
}
