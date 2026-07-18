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

/// A simple addition & subtraction quiz game for young learners.
class MathWizardGame extends StatefulWidget {
  const MathWizardGame({Key? key}) : super(key: key);

  @override
  State<MathWizardGame> createState() => _MathWizardGameState();
}

class _MathWizardGameState extends State<MathWizardGame> {
  final _rand = Random();
  final _progress = ProgressService.to;
  final GlobalKey<ConfettiOverlayWidgetState> _confettiKey =
      GlobalKey<ConfettiOverlayWidgetState>();

  int _score = 0;
  int _round = 0;
  int _totalRounds = 10;
  bool _gameStarted = false;
  bool _gameOver = false;
  bool _answered = false;
  bool _correct = false;

  int _num1 = 0;
  int _num2 = 0;
  String _operator = '+';
  int _correctAnswer = 0;
  List<int> _options = [];

  // Fun emojis to display with the math problems
  static const _funEmojis = ['🧙‍♂️', '🔮', '🪄', '✨', '🌟', '💫', '🎩', '⚡', '🦉', '📐'];

  void _startGame() {
    setState(() {
      _gameStarted = true;
      _score = 0;
      _round = 0;
      _gameOver = false;
    });
    _generateProblem();
  }

  void _generateProblem() {
    if (_round >= _totalRounds) {
      _endGame();
      return;
    }

    _answered = false;
    _correct = false;

    // Progressive difficulty
    int maxNum;
    if (_round < 3) {
      maxNum = 5; // Easy: numbers 1-5
      _operator = '+';
    } else if (_round < 6) {
      maxNum = 10; // Medium: numbers 1-10
      _operator = _rand.nextBool() ? '+' : '-';
    } else {
      maxNum = 15; // Hard: numbers 1-15
      _operator = _rand.nextBool() ? '+' : '-';
    }

    _num1 = 1 + _rand.nextInt(maxNum);
    _num2 = 1 + _rand.nextInt(maxNum);

    // Ensure subtraction doesn't go negative
    if (_operator == '-' && _num2 > _num1) {
      final temp = _num1;
      _num1 = _num2;
      _num2 = temp;
    }

    _correctAnswer = _operator == '+' ? _num1 + _num2 : _num1 - _num2;

    // Generate 4 options
    final opts = <int>{_correctAnswer};
    while (opts.length < 4) {
      final offset = -3 + _rand.nextInt(7);
      final option = _correctAnswer + offset;
      if (option >= 0 && option != _correctAnswer) {
        opts.add(option);
      }
      // Safety: add nearby numbers if stuck
      if (opts.length < 4) {
        opts.add(_correctAnswer + opts.length);
      }
    }
    _options = opts.toList()..shuffle(_rand);

    setState(() {});

    Future.delayed(const Duration(milliseconds: 400), () {
      TtsService.to.speak("What is $_num1 ${_operator == '+' ? 'plus' : 'minus'} $_num2?");
    });
  }

  void _checkAnswer(int answer) {
    if (_answered) return;
    HapticUtil.light();

    setState(() {
      _answered = true;
      _correct = answer == _correctAnswer;
    });

    if (_correct) {
      _score += 10;
      AudioService.to.playStar();
      HapticUtil.medium();
      _confettiKey.currentState?.startCelebration();
      _progress.addCoins(3);
      TtsService.to.speak("Correct! $_num1 $_operator $_num2 equals $_correctAnswer!");
    } else {
      AudioService.to.playTap();
      HapticUtil.heavy();
      TtsService.to.speak("Oops! The answer is $_correctAnswer. Let's try the next one!");
    }

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _round++);
        _generateProblem();
      }
    });
  }

  void _endGame() {
    setState(() => _gameOver = true);
    _progress.incrementMiniGamesPlayed();
    _progress.updateGameHighScore('math_wizard', _score);
    _progress.addXP(max(10, _score ~/ 3));
    _progress.addStar();

    if (_score >= 60) {
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
            _gameStarted
                ? (_gameOver ? _buildGameOver() : _buildGameView())
                : _buildStartView(),
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
          const Text("🧙‍♂️", style: TextStyle(fontSize: 80))
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .rotate(begin: -0.05, end: 0.05, duration: const Duration(seconds: 2)),
          const SizedBox(height: 16),
          Text("Math Wizard",
              style: AppTextStyles.displaySmall.copyWith(color: AppColors.gold, fontSize: 32)),
          const SizedBox(height: 8),
          Text("Solve addition & subtraction\nproblems like a wizard! 🪄",
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
              textAlign: TextAlign.center),
          const SizedBox(height: 40),
          GestureDetector(
            onTap: _startGame,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF818CF8), Color(0xFFC084FC)]),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF818CF8).withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6)),
                ],
              ),
              child: Text("CAST SPELL! 🪄",
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
    final funEmoji = _funEmojis[_round % _funEmojis.length];

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
              // Progress dots
              Row(
                children: List.generate(_totalRounds, (i) {
                  Color dotColor;
                  if (i < _round) {
                    dotColor = AppColors.successGreen;
                  } else if (i == _round) {
                    dotColor = AppColors.gold;
                  } else {
                    dotColor = Colors.white24;
                  }
                  return Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                    ),
                  );
                }),
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
            ],
          ),
        ),

        const Spacer(),

        // Fun wizard emoji
        Text(funEmoji, style: const TextStyle(fontSize: 60))
            .animate(key: ValueKey('wizEmoji_$_round'))
            .scale(begin: const Offset(0.5, 0.5), duration: const Duration(milliseconds: 400), curve: Curves.elasticOut),

        const SizedBox(height: 24),

        // Math problem display
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
          decoration: BoxDecoration(
            color: AppColors.bgMid,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.lavender.withOpacity(0.3), width: 2),
            boxShadow: [
              BoxShadow(color: AppColors.lavender.withOpacity(0.15), blurRadius: 20),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildNumberBubble('$_num1', AppColors.skyBlue),
              const SizedBox(width: 16),
              Text(
                _operator,
                style: AppTextStyles.displayLarge.copyWith(
                  color: AppColors.gold,
                  fontSize: 42,
                ),
              ),
              const SizedBox(width: 16),
              _buildNumberBubble('$_num2', AppColors.coral),
              const SizedBox(width: 16),
              Text(
                "=",
                style: AppTextStyles.displayLarge.copyWith(
                  color: Colors.white54,
                  fontSize: 42,
                ),
              ),
              const SizedBox(width: 16),
              _buildNumberBubble('?', AppColors.mint),
            ],
          ),
        )
            .animate(key: ValueKey('prob_$_round'))
            .slideY(begin: 0.3, duration: const Duration(milliseconds: 400), curve: Curves.easeOutCubic)
            .fadeIn(),

        const SizedBox(height: 40),

        // Answer options (2x2 grid)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: _options.map((opt) {
              Color bg = Colors.white.withOpacity(0.08);
              Color border = Colors.white.withOpacity(0.15);

              if (_answered) {
                if (opt == _correctAnswer) {
                  bg = AppColors.successGreen.withOpacity(0.25);
                  border = AppColors.successGreen;
                } else {
                  bg = Colors.white.withOpacity(0.04);
                  border = Colors.white.withOpacity(0.08);
                }
              }

              return GestureDetector(
                onTap: () => _checkAnswer(opt),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: border, width: 2),
                    boxShadow: [
                      BoxShadow(color: border.withOpacity(0.2), blurRadius: 8),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '$opt',
                      style: AppTextStyles.displaySmall.copyWith(fontSize: 30, color: Colors.white),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 24),

        // Feedback text
        if (_answered)
          Text(
            _correct ? "🎉 Magical! +10 points!" : "❌ The answer was $_correctAnswer",
            style: AppTextStyles.bodyMediumBold.copyWith(
              color: _correct ? AppColors.mint : AppColors.coral,
              fontSize: 16,
            ),
          )
              .animate()
              .fadeIn(duration: const Duration(milliseconds: 300))
              .scale(begin: const Offset(0.8, 0.8), duration: const Duration(milliseconds: 300)),

        const Spacer(),
      ],
    );
  }

  Widget _buildNumberBubble(String text, Color color) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.4), width: 2),
      ),
      child: Center(
        child: Text(
          text,
          style: AppTextStyles.displaySmall.copyWith(
            fontSize: 28,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildGameOver() {
    final grade = _score >= 80
        ? "Grand Wizard 🧙‍♂️"
        : _score >= 50
            ? "Magic Scholar 📚"
            : "Apprentice 🪄";

    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.bgMid,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.lavender.withOpacity(0.4), width: 2),
          boxShadow: [
            BoxShadow(color: AppColors.lavender.withOpacity(0.15), blurRadius: 20),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("🧙‍♂️", style: TextStyle(fontSize: 64)),
            const SizedBox(height: 12),
            Text("Math Complete!",
                style: AppTextStyles.displaySmall.copyWith(color: AppColors.gold, fontSize: 26)),
            const SizedBox(height: 4),
            Text("Score: $_score / ${_totalRounds * 10}",
                style: AppTextStyles.bodyLargeBold.copyWith(color: Colors.white, fontSize: 20)),
            const SizedBox(height: 8),
            Text("Rank: $grade",
                style: AppTextStyles.bodyMediumBold.copyWith(color: AppColors.lavender)),
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
