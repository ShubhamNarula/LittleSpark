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

/// What comes next in the pattern? A logic game for kids.
class PatternMatchGame extends StatefulWidget {
  const PatternMatchGame({Key? key}) : super(key: key);

  @override
  State<PatternMatchGame> createState() => _PatternMatchGameState();
}

class _PatternMatchGameState extends State<PatternMatchGame> {
  final _rand = Random();
  final _progress = ProgressService.to;
  final GlobalKey<ConfettiOverlayWidgetState> _confettiKey =
      GlobalKey<ConfettiOverlayWidgetState>();

  int _score = 0;
  int _round = 0;
  int _totalRounds = 8;
  bool _gameStarted = false;
  bool _gameOver = false;
  bool _answered = false;
  bool _correct = false;

  List<String> _pattern = [];
  String _correctNext = '';
  List<String> _options = [];

  // Pattern templates
  static const List<List<String>> _emojiSets = [
    ['🔴', '🔵', '🟢'],
    ['⭐', '🌙', '☀️'],
    ['🍎', '🍊', '🍋'],
    ['🐶', '🐱', '🐸'],
    ['❤️', '💙', '💚'],
    ['🌸', '🌺', '🌻'],
    ['🎈', '🎁', '🎉'],
    ['🦁', '🐻', '🐼'],
    ['🔺', '🟦', '⚪'],
    ['🍓', '🫐', '🥝'],
  ];

  void _startGame() {
    setState(() {
      _gameStarted = true;
      _score = 0;
      _round = 0;
      _gameOver = false;
    });
    _generatePattern();
  }

  void _generatePattern() {
    if (_round >= _totalRounds) {
      _endGame();
      return;
    }

    _answered = false;
    _correct = false;

    final setIndex = _rand.nextInt(_emojiSets.length);
    final set = _emojiSets[setIndex];

    // Pattern types:
    // 1. AB AB AB → A (repeating pair)
    // 2. ABC ABC → A (repeating triple)
    // 3. AAB AAB → A (double-single)
    // 4. AABB → A (double pair)

    int patternType;
    if (_round < 3) {
      patternType = 0; // Simple AB AB
    } else if (_round < 5) {
      patternType = _rand.nextInt(2); // AB or ABC
    } else {
      patternType = _rand.nextInt(3); // Any
    }

    switch (patternType) {
      case 0: // AB AB AB → ?
        _pattern = [set[0], set[1], set[0], set[1], set[0], set[1]];
        _correctNext = set[0];
        break;
      case 1: // ABC ABC → ?
        _pattern = [set[0], set[1], set[2], set[0], set[1], set[2]];
        _correctNext = set[0];
        break;
      case 2: // AAB AAB → ?
        _pattern = [set[0], set[0], set[1], set[0], set[0], set[1]];
        _correctNext = set[0];
        break;
      default:
        _pattern = [set[0], set[1], set[0], set[1], set[0], set[1]];
        _correctNext = set[0];
    }

    // Generate options
    final optSet = <String>{_correctNext};
    for (final s in set) {
      optSet.add(s);
    }
    // Add a distractor from another set if needed
    while (optSet.length < 4) {
      final otherSet = _emojiSets[_rand.nextInt(_emojiSets.length)];
      optSet.add(otherSet[_rand.nextInt(otherSet.length)]);
    }
    _options = optSet.take(4).toList()..shuffle(_rand);

    setState(() {});

    Future.delayed(const Duration(milliseconds: 400), () {
      TtsService.to.speak("What comes next in the pattern?");
    });
  }

  void _checkAnswer(String answer) {
    if (_answered) return;
    HapticUtil.light();

    setState(() {
      _answered = true;
      _correct = answer == _correctNext;
    });

    if (_correct) {
      _score += 10;
      AudioService.to.playStar();
      HapticUtil.medium();
      _confettiKey.currentState?.startCelebration();
      _progress.addCoins(3);
      TtsService.to.speak("That's right! Great pattern thinking!");
    } else {
      AudioService.to.playTap();
      HapticUtil.heavy();
      TtsService.to.speak("Not quite! The answer was $_correctNext. Let's try another!");
    }

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _round++);
        _generatePattern();
      }
    });
  }

  void _endGame() {
    setState(() => _gameOver = true);
    _progress.incrementMiniGamesPlayed();
    _progress.updateGameHighScore('pattern_match', _score);
    _progress.addXP(max(10, _score ~/ 3));
    _progress.addStar();

    if (_score >= 50) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text("🔴", style: TextStyle(fontSize: 36)),
              SizedBox(width: 4),
              Text("🔵", style: TextStyle(fontSize: 36)),
              SizedBox(width: 4),
              Text("🔴", style: TextStyle(fontSize: 36)),
              SizedBox(width: 4),
              Text("❓", style: TextStyle(fontSize: 36)),
            ],
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: const Duration(seconds: 2)),
          const SizedBox(height: 16),
          Text("Pattern Match",
              style: AppTextStyles.displaySmall.copyWith(color: AppColors.gold, fontSize: 32)),
          const SizedBox(height: 8),
          Text("Find what comes next\nin the pattern!",
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
              textAlign: TextAlign.center),
          const SizedBox(height: 40),
          GestureDetector(
            onTap: _startGame,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)]),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF4ECDC4).withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6)),
                ],
              ),
              child: Text("START! 🧩",
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
              Text("${_round + 1}/$_totalRounds",
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

        const Spacer(),

        // Pattern display
        Text("What comes next?",
            style: AppTextStyles.bodyLargeBold.copyWith(color: Colors.white70, fontSize: 18)),
        const SizedBox(height: 20),

        // Pattern items
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: BoxDecoration(
            color: AppColors.bgMid,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.lavender.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ..._pattern.asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Text(
                    entry.value,
                    style: const TextStyle(fontSize: 32),
                  )
                      .animate(delay: Duration(milliseconds: entry.key * 100))
                      .scale(begin: const Offset(0.3, 0.3), duration: const Duration(milliseconds: 300), curve: Curves.elasticOut),
                );
              }),
              const SizedBox(width: 6),
              // Question mark slot
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.gold.withOpacity(0.4), width: 2),
                ),
                child: Center(
                  child: Text(
                    _answered ? _correctNext : "?",
                    style: TextStyle(
                      fontSize: _answered ? 28 : 22,
                      color: AppColors.gold,
                    ),
                  ),
                ),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: const Duration(seconds: 1)),
            ],
          ),
        ),

        const SizedBox(height: 40),

        // Options
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: _options.map((opt) {
            Color bg = Colors.white.withOpacity(0.08);
            Color border = Colors.white.withOpacity(0.15);

            if (_answered) {
              if (opt == _correctNext) {
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
                ),
                child: Center(
                  child: Text(opt, style: const TextStyle(fontSize: 36)),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 24),

        if (_answered)
          Text(
            _correct ? "🎉 Pattern Master!" : "❌ It was $_correctNext!",
            style: AppTextStyles.bodyMediumBold.copyWith(
              color: _correct ? AppColors.mint : AppColors.coral,
              fontSize: 16,
            ),
          )
              .animate()
              .fadeIn(duration: const Duration(milliseconds: 300)),

        const Spacer(),
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
            const Text("🧩", style: TextStyle(fontSize: 64)),
            const SizedBox(height: 12),
            Text("Pattern Complete!",
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
