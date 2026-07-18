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

class WordScrambleGame extends StatefulWidget {
  const WordScrambleGame({Key? key}) : super(key: key);

  @override
  State<WordScrambleGame> createState() => _WordScrambleGameState();
}

class _WordScrambleGameState extends State<WordScrambleGame> {
  final _rand = Random();
  final _progress = ProgressService.to;
  final GlobalKey<ConfettiOverlayWidgetState> _confettiKey =
      GlobalKey<ConfettiOverlayWidgetState>();

  int _score = 0;
  int _round = 0;
  int _totalRounds = 8;
  bool _gameStarted = false;
  bool _gameOver = false;
  bool _wordComplete = false;

  String _currentWord = '';
  String _currentEmoji = '';
  List<String> _scrambledLetters = [];
  List<String> _enteredLetters = [];
  List<bool> _letterUsed = [];
  int _hintsUsed = 0;

  static const List<Map<String, String>> _words = [
    {'word': 'CAT', 'emoji': '🐱'},
    {'word': 'DOG', 'emoji': '🐶'},
    {'word': 'SUN', 'emoji': '☀️'},
    {'word': 'CUP', 'emoji': '☕'},
    {'word': 'HAT', 'emoji': '🎩'},
    {'word': 'BUS', 'emoji': '🚌'},
    {'word': 'PIG', 'emoji': '🐷'},
    {'word': 'FISH', 'emoji': '🐟'},
    {'word': 'STAR', 'emoji': '⭐'},
    {'word': 'FROG', 'emoji': '🐸'},
    {'word': 'BEAR', 'emoji': '🐻'},
    {'word': 'CAKE', 'emoji': '🎂'},
    {'word': 'MOON', 'emoji': '🌙'},
    {'word': 'BIRD', 'emoji': '🐦'},
    {'word': 'TREE', 'emoji': '🌳'},
    {'word': 'LION', 'emoji': '🦁'},
    {'word': 'APPLE', 'emoji': '🍎'},
    {'word': 'HOUSE', 'emoji': '🏠'},
    {'word': 'HEART', 'emoji': '❤️'},
    {'word': 'HORSE', 'emoji': '🐴'},
  ];

  void _startGame() {
    setState(() {
      _gameStarted = true;
      _score = 0;
      _round = 0;
      _gameOver = false;
      _hintsUsed = 0;
    });
    _generateRound();
  }

  void _generateRound() {
    if (_round >= _totalRounds) {
      _endGame();
      return;
    }

    // Progressive difficulty: shorter words first
    List<Map<String, String>> pool;
    if (_round < 3) {
      pool = _words.where((w) => (w['word']!).length == 3).toList();
    } else if (_round < 6) {
      pool = _words.where((w) => (w['word']!).length == 4).toList();
    } else {
      pool = _words.where((w) => (w['word']!).length >= 4).toList();
    }
    pool.shuffle(_rand);
    
    final wordData = pool.first;
    _currentWord = wordData['word']!;
    _currentEmoji = wordData['emoji']!;

    _scrambledLetters = _currentWord.split('')..shuffle(_rand);
    // Make sure it's not accidentally in order
    while (_scrambledLetters.join() == _currentWord && _currentWord.length > 2) {
      _scrambledLetters.shuffle(_rand);
    }

    _enteredLetters = [];
    _letterUsed = List.filled(_scrambledLetters.length, false);
    _wordComplete = false;

    setState(() {});

    Future.delayed(const Duration(milliseconds: 400), () {
      TtsService.to.speak("Spell ${_currentEmoji == '☀️' ? 'sun' : _currentWord.toLowerCase()}!");
    });
  }

  void _onLetterTap(int index) {
    if (_letterUsed[index] || _wordComplete) return;
    HapticUtil.light();
    AudioService.to.playTap();

    setState(() {
      _letterUsed[index] = true;
      _enteredLetters.add(_scrambledLetters[index]);
    });

    // Check if word is complete
    if (_enteredLetters.length == _currentWord.length) {
      final enteredWord = _enteredLetters.join();
      if (enteredWord == _currentWord) {
        _onCorrect();
      } else {
        _onWrong();
      }
    }
  }

  void _undoLetter() {
    if (_enteredLetters.isEmpty || _wordComplete) return;
    HapticUtil.light();

    final lastLetter = _enteredLetters.removeLast();
    // Find the last used index with this letter
    for (int i = _letterUsed.length - 1; i >= 0; i--) {
      if (_letterUsed[i] && _scrambledLetters[i] == lastLetter) {
        _letterUsed[i] = false;
        break;
      }
    }
    setState(() {});
  }

  void _useHint() {
    if (_wordComplete) return;
    if (_progress.coins < 5) {
      Get.rawSnackbar(
        message: "Not enough coins! Need 5 🪙",
        backgroundColor: AppColors.coral,
        duration: const Duration(seconds: 2),
        borderRadius: 16,
        margin: const EdgeInsets.all(16),
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    // Clear current progress and fill first N+1 letters
    _progress.addCoins(-5);
    _hintsUsed++;

    final nextPos = _enteredLetters.length;
    if (nextPos >= _currentWord.length) return;

    final correctLetter = _currentWord[nextPos];

    // Find this letter in scrambled letters
    for (int i = 0; i < _scrambledLetters.length; i++) {
      if (!_letterUsed[i] && _scrambledLetters[i] == correctLetter) {
        _onLetterTap(i);
        break;
      }
    }
  }

  void _onCorrect() {
    _wordComplete = true;
    _score += 15;
    _progress.addCoins(5);
    _progress.addStar();
    AudioService.to.playStar();
    HapticUtil.medium();
    _confettiKey.currentState?.startCelebration();
    TtsService.to.speak("Great job! ${_currentWord.toLowerCase()}!");

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _round++);
        _generateRound();
      }
    });
  }

  void _onWrong() {
    _wordComplete = true;
    HapticUtil.heavy();
    TtsService.to.speak("Oops! Let's try again!");

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        // Reset this round
        _generateRound();
      }
    });
  }

  void _endGame() {
    setState(() => _gameOver = true);
    _progress.incrementMiniGamesPlayed();
    _progress.updateGameHighScore('word_scramble', _score);
    _progress.addXP(20);

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
          const Text("🔤", style: TextStyle(fontSize: 80))
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(begin: const Offset(0.85, 0.85), end: const Offset(1.15, 1.15), duration: const Duration(seconds: 2)),
          const SizedBox(height: 16),
          Text("Word Scramble",
              style: AppTextStyles.displaySmall.copyWith(color: AppColors.gold, fontSize: 32)),
          const SizedBox(height: 8),
          Text("Unscramble the letters to\nspell the word!",
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
              textAlign: TextAlign.center),
          const SizedBox(height: 40),
          GestureDetector(
            onTap: _startGame,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFF472B6), Color(0xFFEC4899)]),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: const Color(0xFFF472B6).withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6)),
                ],
              ),
              child: Text("SPELL IT! 🔤",
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

        const SizedBox(height: 20),

        // Emoji clue
        Text(_currentEmoji, style: const TextStyle(fontSize: 80))
            .animate(key: ValueKey('emoji_$_round'))
            .scale(begin: const Offset(0.5, 0.5), duration: const Duration(milliseconds: 500), curve: Curves.elasticOut),

        const SizedBox(height: 24),

        // Answer slots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_currentWord.length, (i) {
            final bool filled = i < _enteredLetters.length;
            final bool isCorrectPos = filled && _enteredLetters[i] == _currentWord[i];
            
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 50,
              height: 58,
              decoration: BoxDecoration(
                color: filled
                    ? (_wordComplete
                        ? (isCorrectPos ? AppColors.successGreen.withOpacity(0.25) : Colors.redAccent.withOpacity(0.2))
                        : AppColors.lavender.withOpacity(0.15))
                    : Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: filled
                      ? AppColors.lavender
                      : Colors.white.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  filled ? _enteredLetters[i] : '',
                  style: AppTextStyles.displaySmall.copyWith(
                    fontSize: 26,
                    color: Colors.white,
                  ),
                ),
              ),
            )
                .animate(
                  target: filled ? 1.0 : 0.0,
                )
                .scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1.0, 1.0),
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                );
          }),
        ),

        const SizedBox(height: 32),

        // Scrambled letter buttons
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: List.generate(_scrambledLetters.length, (i) {
            final used = _letterUsed[i];
            return GestureDetector(
              onTap: () => _onLetterTap(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: used
                      ? null
                      : const LinearGradient(colors: [Color(0xFFF472B6), Color(0xFFEC4899)]),
                  color: used ? Colors.white.withOpacity(0.05) : null,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: used ? Colors.white12 : const Color(0xFFF472B6),
                    width: 2,
                  ),
                  boxShadow: used
                      ? []
                      : [
                          BoxShadow(
                            color: const Color(0xFFF472B6).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                ),
                child: Center(
                  child: Text(
                    _scrambledLetters[i],
                    style: AppTextStyles.displaySmall.copyWith(
                      fontSize: 24,
                      color: used ? Colors.white24 : Colors.white,
                    ),
                  ),
                ),
              ),
            )
                .animate(delay: Duration(milliseconds: i * 80))
                .scale(begin: const Offset(0.5, 0.5), duration: const Duration(milliseconds: 300), curve: Curves.elasticOut);
          }),
        ),

        const SizedBox(height: 24),

        // Action buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Undo
            GestureDetector(
              onTap: _undoLetter,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.15)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.undo_rounded, color: Colors.white54, size: 20),
                    const SizedBox(width: 6),
                    Text("Undo", style: AppTextStyles.bodySmallBold.copyWith(color: Colors.white54)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Hint
            Obx(() => GestureDetector(
                  onTap: _useHint,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppColors.gold, Color(0xFFF59E0B)]),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("💡", style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text("Hint (5 🪙)",
                            style: AppTextStyles.bodySmallBold.copyWith(color: AppColors.bgDark)),
                      ],
                    ),
                  ),
                )),
          ],
        ),

        const Spacer(),

        // Feedback
        if (_wordComplete)
          Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: Text(
              _enteredLetters.join() == _currentWord
                  ? "🎉 Perfect! +15 points!"
                  : "❌ Not quite! Try again...",
              style: AppTextStyles.bodyMediumBold.copyWith(
                color: _enteredLetters.join() == _currentWord ? AppColors.mint : AppColors.coral,
                fontSize: 16,
              ),
            )
                .animate()
                .fadeIn(duration: const Duration(milliseconds: 300))
                .scale(begin: const Offset(0.8, 0.8), duration: const Duration(milliseconds: 300)),
          ),
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
            Text(_score >= 80 ? "🏆" : "🔤", style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 12),
            Text("Word Scramble Done!",
                style: AppTextStyles.displaySmall.copyWith(color: AppColors.gold, fontSize: 24)),
            Text("Score: $_score | Hints: $_hintsUsed",
                style: AppTextStyles.bodyLargeBold.copyWith(color: Colors.white, fontSize: 18)),
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
