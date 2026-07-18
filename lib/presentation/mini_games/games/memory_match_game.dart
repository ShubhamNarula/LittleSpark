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
import '../../../data/models/memory_match_level.dart';
import '../../../data/datasources/memory_match_data.dart';
import '../../shared/widgets/celebration_overlay.dart';

class MemoryMatchGame extends StatefulWidget {
  const MemoryMatchGame({Key? key}) : super(key: key);

  @override
  State<MemoryMatchGame> createState() => _MemoryMatchGameState();
}

enum _GamePhase { introReveal, levelSelect, countdown, playing, won }

class _MemoryMatchGameState extends State<MemoryMatchGame> with TickerProviderStateMixin {
  final _rand = Random();
  final _progress = ProgressService.to;

  _GamePhase _phase = _GamePhase.introReveal;
  late MemoryMatchLevel _currentLevel;
  int _moves = 0;
  int _matchesFound = 0;
  int _countdownValue = 3;
  int _elapsedSeconds = 0;
  int _hintsRemaining = 2;
  bool _hintActive = false;

  Timer? _gameTimer;
  Timer? _countdownTimer;
  Timer? _introTimer;

  List<_MemoryCard> _cards = [];
  List<_MemoryCard> _introCards = [];
  int? _firstFlippedIndex;
  bool _isChecking = false;

  late AnimationController _countdownAnimController;

  @override
  void initState() {
    super.initState();
    _countdownAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _setupIntroReveal();
  }

  void _setupIntroReveal() {
    final introEmojis = ['🦄', '🦊', '🐯', '🦁', '🐼', '🐨', '🐸', '🐙', '🦖', '🐝', '🍎', '🎈'];
    introEmojis.shuffle(_rand);
    _introCards = introEmojis.take(12).map((e) => _MemoryCard(emoji: e)).toList();

    _phase = _GamePhase.introReveal;

    // Start sequence: briefly delay then reveal cards
    _introTimer = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      setState(() {
        for (final card in _introCards) {
          card.isFlipped = true;
        }
      });
      TtsService.to.speak("Welcome! Let's match the cards!");

      // After 3 seconds, flip them back
      _introTimer = Timer(const Duration(seconds: 3), () {
        if (!mounted) return;
        setState(() {
          for (final card in _introCards) {
            card.isFlipped = false;
          }
        });

        // After 600ms (to let the card flip animation finish), go to levelSelect
        _introTimer = Timer(const Duration(milliseconds: 600), () {
          if (!mounted) return;
          setState(() {
            _phase = _GamePhase.levelSelect;
          });
        });
      });
    });
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _countdownTimer?.cancel();
    _introTimer?.cancel();
    _countdownAnimController.dispose();
    super.dispose();
  }

  // --- Level Selection ---
  void _selectLevel(MemoryMatchLevel level) {
    HapticUtil.light();
    AudioService.to.playTap();
    _currentLevel = level;
    _setupGame();
  }

  void _setupGame() {
    _moves = 0;
    _matchesFound = 0;
    _elapsedSeconds = 0;
    _firstFlippedIndex = null;
    _isChecking = false;
    _hintsRemaining = _currentLevel.totalPairs <= 4 ? 1 : 2;
    _hintActive = false;

    final emojis = MemoryMatchData.getEmojisForCategory(
      _currentLevel.category,
      _currentLevel.totalPairs,
    );
    final allCards = [...emojis, ...emojis]..shuffle(_rand);
    _cards = allCards.map((e) => _MemoryCard(emoji: e)).toList();

    // Start countdown reveal phase
    setState(() {
      _phase = _GamePhase.countdown;
      _countdownValue = _currentLevel.revealSeconds;
      // Reveal all cards
      for (final card in _cards) {
        card.isFlipped = true;
      }
    });

    TtsService.to.speak("Memorize the cards!");
    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _countdownValue--;
      });
      _countdownAnimController.forward(from: 0);
      HapticUtil.light();

      if (_countdownValue <= 0) {
        timer.cancel();
        // Flip all cards back
        setState(() {
          for (final card in _cards) {
            card.isFlipped = false;
          }
          _phase = _GamePhase.playing;
        });
        _startGameTimer();
        TtsService.to.speak("Go!");
      }
    });
  }

  void _startGameTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _elapsedSeconds++;
      });
      // Time's up!
      if (_elapsedSeconds >= _currentLevel.timeLimitSeconds) {
        timer.cancel();
        TtsService.to.speak("Time's up! Try again!");
        HapticUtil.heavy();
        // Reset game to level select
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _phase = _GamePhase.levelSelect;
            });
          }
        });
      }
    });
  }

  void _onCardTap(int index) {
    if (_phase != _GamePhase.playing) return;
    if (_isChecking || _cards[index].isFlipped || _cards[index].isMatched || _hintActive) return;
    HapticUtil.light();
    AudioService.to.playTap();

    setState(() {
      _cards[index].isFlipped = true;
    });

    if (_firstFlippedIndex == null) {
      _firstFlippedIndex = index;
    } else {
      _moves++;
      _isChecking = true;
      final firstIndex = _firstFlippedIndex!;

      if (_cards[firstIndex].emoji == _cards[index].emoji) {
        // Match!
        Future.delayed(const Duration(milliseconds: 400), () {
          if (!mounted) return;
          setState(() {
            _cards[firstIndex].isMatched = true;
            _cards[index].isMatched = true;
            _matchesFound++;
            _isChecking = false;
            _firstFlippedIndex = null;
          });
          HapticUtil.medium();
          AudioService.to.playStar();

          if (_matchesFound == _currentLevel.totalPairs) {
            _winGame();
          }
        });
      } else {
        // No match
        Future.delayed(const Duration(milliseconds: 800), () {
          if (!mounted) return;
          setState(() {
            _cards[firstIndex].isFlipped = false;
            _cards[index].isFlipped = false;
            _isChecking = false;
            _firstFlippedIndex = null;
          });
          HapticUtil.heavy();
        });
      }
    }
  }

  void _useHint() {
    if (_hintsRemaining <= 0 || _hintActive || _phase != _GamePhase.playing) return;
    final cost = 5;
    if (_progress.coins < cost) {
      TtsService.to.speak("Not enough coins for a hint!");
      return;
    }

    HapticUtil.medium();
    _progress.addCoins(-cost);
    _hintsRemaining--;
    _hintActive = true;

    // Briefly reveal all unmatched cards
    setState(() {
      for (final card in _cards) {
        if (!card.isMatched) {
          card.isFlipped = true;
        }
      }
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        for (final card in _cards) {
          if (!card.isMatched) {
            card.isFlipped = false;
          }
        }
        _hintActive = false;
        _firstFlippedIndex = null;
      });
    });
  }

  void _winGame() {
    _gameTimer?.cancel();
    final int stars;
    if (_moves <= _currentLevel.threeStarMoves) {
      stars = 3;
    } else if (_moves <= _currentLevel.twoStarMoves) {
      stars = 2;
    } else {
      stars = 1;
    }

    _progress.completeMemoryMatchLevel(_currentLevel.level, stars, _elapsedSeconds);
    _progress.incrementMiniGamesPlayed();
    _progress.addStar();
    _progress.addCoins(stars * 5 + 5);
    _progress.addXP(stars * 10 + 10);

    setState(() {
      _phase = _GamePhase.won;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        showCelebration(context);
        TtsService.to.speak("Awesome! You won with $stars stars!");
      }
    });
  }

  int get _earnedStars {
    if (_moves <= _currentLevel.threeStarMoves) return 3;
    if (_moves <= _currentLevel.twoStarMoves) return 2;
    return 1;
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  // =================================================================
  // BUILD
  // =================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: _buildCurrentPhase(),
      ),
    );
  }

  Widget _buildCurrentPhase() {
    switch (_phase) {
      case _GamePhase.introReveal:
        return _buildIntroReveal();
      case _GamePhase.levelSelect:
        return _buildLevelSelect();
      case _GamePhase.countdown:
        return _buildGameBoard(showCountdown: true);
      case _GamePhase.playing:
        return _buildGameBoard(showCountdown: false);
      case _GamePhase.won:
        return _buildWinScreen();
    }
  }

  Widget _buildIntroReveal() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        Text(
          "Ready to Match? 🧠",
          style: AppTextStyles.displaySmall.copyWith(
            color: AppColors.gold,
            fontSize: 28,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.9, 0.9)),
        const SizedBox(height: 8),
        Text(
          "Watch the cards closely...",
          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
        const SizedBox(height: 24),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Center(
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.0,
                ),
                itemCount: _introCards.length,
                itemBuilder: (ctx, i) => _buildIntroCard(_introCards[i], i),
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildIntroCard(_MemoryCard card, int index) {
    final bool showFace = card.isFlipped;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: showFace
            ? const LinearGradient(colors: [AppColors.bgMid, Color(0xFF251860)])
            : const LinearGradient(
                colors: [Color(0xFF2D1B69), Color(0xFF1A0F42)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: showFace
              ? AppColors.lavender.withOpacity(0.6)
              : Colors.white.withOpacity(0.12),
          width: 2,
        ),
        boxShadow: [
          if (showFace)
            BoxShadow(
              color: AppColors.lavender.withOpacity(0.15),
              blurRadius: 8,
            ),
        ],
      ),
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: showFace
              ? Text(
                  card.emoji,
                  key: ValueKey('intro_face_${card.emoji}_$index'),
                  style: const TextStyle(fontSize: 32),
                )
              : Container(
                  key: ValueKey('intro_back_$index'),
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppColors.lavender, AppColors.skyBlue],
                    ),
                  ),
                  child: const Center(
                    child: Text("?", style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'FredokaOne',
                    )),
                  ),
                ),
        ),
      ),
    );
  }

  // =================================================================
  // LEVEL SELECT
  // =================================================================
  Widget _buildLevelSelect() {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white70),
              ),
              const SizedBox(width: 8),
              Text("Memory Match 🧠",
                  style: AppTextStyles.displaySmall.copyWith(color: AppColors.gold, fontSize: 24)),
              const Spacer(),
              _buildStatBadge("🏆", "${_progress.memoryMatchTotalWins}"),
            ],
          ),
        ),

        // Stats row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMiniStat("Levels", "${_progress.memoryMatchMaxLevel - 1}/30", AppColors.mint),
              _buildMiniStat("Wins", "${_progress.memoryMatchTotalWins}", AppColors.gold),
              _buildMiniStat("Coins", "${_progress.coins}", AppColors.warningOrange),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Level Grid
        Expanded(
          child: GridView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.8,
            ),
            itemCount: MemoryMatchData.levels.length,
            itemBuilder: (ctx, i) {
              final level = MemoryMatchData.levels[i];
              final isUnlocked = level.level <= _progress.memoryMatchMaxLevel;
              final stars = _progress.getMemoryMatchLevelStars(level.level);
              return _buildLevelCell(level, isUnlocked, stars, i);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLevelCell(MemoryMatchLevel level, bool isUnlocked, int stars, int animIndex) {
    final Color bgColor;
    final Color borderColor;

    if (!isUnlocked) {
      bgColor = Colors.white.withOpacity(0.03);
      borderColor = Colors.white.withOpacity(0.08);
    } else if (stars > 0) {
      bgColor = AppColors.successGreen.withOpacity(0.12);
      borderColor = AppColors.successGreen.withOpacity(0.4);
    } else {
      bgColor = AppColors.gold.withOpacity(0.1);
      borderColor = AppColors.gold.withOpacity(0.4);
    }

    return GestureDetector(
      onTap: isUnlocked ? () => _selectLevel(level) : null,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isUnlocked)
              const Icon(Icons.lock_rounded, color: Colors.white24, size: 22)
            else ...[
              Text(level.categoryEmoji,
                  style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 2),
              Text("${level.level}",
                  style: AppTextStyles.bodyMediumBold.copyWith(
                    color: isUnlocked ? Colors.white : Colors.white30,
                    fontSize: 16,
                  )),
            ],
            const SizedBox(height: 4),
            // Star rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (si) {
                return Icon(
                  si < stars ? Icons.star_rounded : Icons.star_border_rounded,
                  color: si < stars ? AppColors.gold : Colors.white24,
                  size: 14,
                );
              }),
            ),
          ],
        ),
      ),
    ).animate(delay: (animIndex * 20).ms)
        .scale(begin: const Offset(0.8, 0.8), duration: 200.ms);
  }

  Widget _buildStatBadge(String emoji, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.bgMid,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 4),
          Text(value, style: AppTextStyles.bodySmallBold.copyWith(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.bodyLargeBold.copyWith(color: color)),
        Text(label, style: AppTextStyles.bodySmall.copyWith(color: Colors.white54, fontSize: 14)),
      ],
    );
  }

  // =================================================================
  // GAME BOARD (countdown + playing)
  // =================================================================
  Widget _buildGameBoard({required bool showCountdown}) {
    final timeLeft = _currentLevel.timeLimitSeconds - _elapsedSeconds;
    final timePercent = (_elapsedSeconds / _currentLevel.timeLimitSeconds).clamp(0.0, 1.0);

    return Stack(
      children: [
        Column(
          children: [
            // HUD
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  // Close
                  IconButton(
                    onPressed: () {
                      _gameTimer?.cancel();
                      _countdownTimer?.cancel();
                      setState(() => _phase = _GamePhase.levelSelect);
                    },
                    icon: const Icon(Icons.close_rounded, color: Colors.white54),
                  ),
                  // Category badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.bgMid,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      "${_currentLevel.categoryEmoji} ${_currentLevel.category}",
                      style: AppTextStyles.bodySmallBold.copyWith(color: Colors.white70, fontSize: 14),
                    ),
                  ),
                  const Spacer(),
                  // Hint button
                  if (!showCountdown)
                    GestureDetector(
                      onTap: _useHint,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: _hintsRemaining > 0
                              ? AppColors.lavender.withOpacity(0.15)
                              : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _hintsRemaining > 0
                                ? AppColors.lavender.withOpacity(0.4)
                                : Colors.white12,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.lightbulb_rounded,
                                color: _hintsRemaining > 0 ? AppColors.gold : Colors.white30,
                                size: 16),
                            const SizedBox(width: 4),
                            Text("$_hintsRemaining",
                                style: AppTextStyles.bodySmallBold.copyWith(
                                    color: _hintsRemaining > 0 ? Colors.white : Colors.white30,
                                    fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  // Level label
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text("Lv. ${_currentLevel.level}",
                        style: AppTextStyles.bodySmallBold.copyWith(color: AppColors.gold, fontSize: 14)),
                  ),
                ],
              ),
            ),

            // Timer bar
            if (!showCountdown)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Moves: $_moves",
                            style: AppTextStyles.bodySmallBold.copyWith(color: Colors.white60, fontSize: 14)),
                        Text("$_matchesFound / ${_currentLevel.totalPairs} ✅",
                            style: AppTextStyles.bodySmallBold.copyWith(color: AppColors.mint, fontSize: 14)),
                        Row(
                          children: [
                            Icon(Icons.timer_rounded,
                                color: timeLeft < 15 ? Colors.redAccent : Colors.white60,
                                size: 16),
                            const SizedBox(width: 4),
                            Text(_formatTime(max(0, timeLeft)),
                                style: AppTextStyles.bodySmallBold.copyWith(
                                    color: timeLeft < 15 ? Colors.redAccent : Colors.white60,
                                    fontSize: 14)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: 1.0 - timePercent,
                        backgroundColor: Colors.white10,
                        valueColor: AlwaysStoppedAnimation(
                          timeLeft < 15 ? Colors.redAccent : AppColors.mint,
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 8),

            // Card Grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Center(
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _currentLevel.cols,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: _currentLevel.rows >= 5 ? 0.9 : 1.0,
                    ),
                    itemCount: _cards.length,
                    itemBuilder: (ctx, i) => _buildCard(_cards[i], i),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),

        // Countdown overlay
        if (showCountdown)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "MEMORIZE! 🧠",
                      style: AppTextStyles.displaySmall.copyWith(
                        color: AppColors.gold,
                        fontSize: 28,
                      ),
                    ),
                    const SizedBox(height: 20),
                    AnimatedBuilder(
                      animation: _countdownAnimController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 1.0 + (1 - _countdownAnimController.value) * 0.5,
                          child: Opacity(
                            opacity: _countdownAnimController.value.clamp(0.3, 1.0),
                            child: child,
                          ),
                        );
                      },
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [AppColors.coral, AppColors.warningOrange],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.coral.withOpacity(0.5),
                              blurRadius: 20,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            "$_countdownValue",
                            style: AppTextStyles.displayLarge.copyWith(
                              color: Colors.white,
                              fontSize: 48,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Remember the positions!",
                      style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  // =================================================================
  // CARD WIDGET
  // =================================================================
  Widget _buildCard(_MemoryCard card, int index) {
    final bool showFace = card.isFlipped || card.isMatched;

    return GestureDetector(
      onTap: () => _onCardTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: card.isMatched
              ? LinearGradient(
                  colors: [AppColors.successGreen.withOpacity(0.25), AppColors.mint.withOpacity(0.15)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : showFace
                  ? const LinearGradient(colors: [AppColors.bgMid, Color(0xFF251860)])
                  : const LinearGradient(
                      colors: [Color(0xFF2D1B69), Color(0xFF1A0F42)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: card.isMatched
                ? AppColors.successGreen
                : showFace
                    ? AppColors.lavender.withOpacity(0.6)
                    : Colors.white.withOpacity(0.12),
            width: 2,
          ),
          boxShadow: [
            if (card.isMatched)
              BoxShadow(
                color: AppColors.successGreen.withOpacity(0.3),
                blurRadius: 10,
              ),
            if (showFace && !card.isMatched)
              BoxShadow(
                color: AppColors.lavender.withOpacity(0.15),
                blurRadius: 8,
              ),
          ],
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: showFace
                ? Text(
                    card.emoji,
                    key: ValueKey('face_${card.emoji}_$index'),
                    style: TextStyle(fontSize: _currentLevel.cols >= 5 ? 24 : 32),
                  )
                : Container(
                    key: ValueKey('back_$index'),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppColors.lavender, AppColors.skyBlue],
                      ),
                    ),
                    child: const Center(
                      child: Text("?", style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'FredokaOne',
                      )),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  // =================================================================
  // WIN SCREEN
  // =================================================================
  Widget _buildWinScreen() {
    final stars = _earnedStars;
    final coinsEarned = stars * 5 + 5;
    final xpEarned = stars * 10 + 10;
    final hasNextLevel = _currentLevel.level < 30;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Trophy
            const Text("🏆", style: TextStyle(fontSize: 72))
                .animate()
                .scale(begin: const Offset(0.3, 0.3), duration: 600.ms, curve: Curves.elasticOut)
                .then()
                .shake(duration: 500.ms),
            const SizedBox(height: 16),

            Text("Level ${_currentLevel.level} Complete!",
                style: AppTextStyles.displaySmall.copyWith(color: AppColors.gold, fontSize: 26)),
            const SizedBox(height: 16),

            // Stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                final earned = i < stars;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    earned ? Icons.star_rounded : Icons.star_border_rounded,
                    color: earned ? AppColors.gold : Colors.white24,
                    size: 44,
                  ),
                ).animate(delay: (i * 200).ms)
                    .scale(begin: const Offset(0.3, 0.3), duration: 400.ms, curve: Curves.elasticOut);
              }),
            ),
            const SizedBox(height: 24),

            // Stats card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.bgMid,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  _buildStatRow("⏱ Time", _formatTime(_elapsedSeconds)),
                  const SizedBox(height: 10),
                  _buildStatRow("👆 Moves", "$_moves"),
                  const SizedBox(height: 10),
                  _buildStatRow("🪙 Coins", "+$coinsEarned"),
                  const SizedBox(height: 10),
                  _buildStatRow("✨ XP", "+$xpEarned"),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Replay
                GestureDetector(
                  onTap: () {
                    HapticUtil.light();
                    _setupGame();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Text("Replay 🔄",
                        style: AppTextStyles.bodyMediumBold.copyWith(color: Colors.white70)),
                  ),
                ),
                const SizedBox(width: 12),
                // Next Level
                if (hasNextLevel)
                  GestureDetector(
                    onTap: () {
                      HapticUtil.light();
                      final nextIndex = _currentLevel.level; // levels are 1-indexed, list is 0-indexed
                      if (nextIndex < MemoryMatchData.levels.length) {
                        _selectLevel(MemoryMatchData.levels[nextIndex]);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [AppColors.mint, Color(0xFF44A08D)]),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.mint.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text("Next Level ➔",
                          style: AppTextStyles.bodyMediumBold.copyWith(color: Colors.white)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Back to levels
            TextButton(
              onPressed: () {
                setState(() => _phase = _GamePhase.levelSelect);
              },
              child: Text("Back to Levels",
                  style: AppTextStyles.bodySmallBold.copyWith(color: Colors.white54, fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium.copyWith(color: Colors.white60)),
        Text(value, style: AppTextStyles.bodyMediumBold.copyWith(color: Colors.white)),
      ],
    );
  }
}

class _MemoryCard {
  final String emoji;
  bool isFlipped;
  bool isMatched;

  _MemoryCard({
    required this.emoji,
    this.isFlipped = false,
    this.isMatched = false,
  });
}
