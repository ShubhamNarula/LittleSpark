import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/letter_model.dart';
import '../../../services/progress_service.dart';
import '../../../services/tts_service.dart';
import '../../../services/audio_service.dart';
import '../../../core/utils/haptic_util.dart';
import '../../shared/widgets/confetti_overlay_widget.dart';
import '../../shared/widgets/bouncy_button.dart';

class FillMissingLetterGame extends StatefulWidget {
  final LetterModel letter;

  const FillMissingLetterGame({
    Key? key,
    required this.letter,
  }) : super(key: key);

  @override
  State<FillMissingLetterGame> createState() => _FillMissingLetterGameState();
}

class _FillMissingLetterGameState extends State<FillMissingLetterGame> {
  final GlobalKey<ConfettiOverlayWidgetState> _confettiKey =
      GlobalKey<ConfettiOverlayWidgetState>();

  late String _word;
  late int _missingIndex;
  late String _missingChar;
  late List<String> _options;

  bool _isAnswered = false;
  bool _isCorrect = false;
  String _selectedOption = '';
  bool _shakeTrigger = false;

  @override
  void initState() {
    super.initState();
    _setupGame();
  }

  void _setupGame() {
    _word = widget.letter.word.toUpperCase();
    
    // Choose index 1 as missing (e.g. A _ P L E) if word is at least 3 chars,
    // otherwise choose a random index.
    if (_word.length >= 3) {
      _missingIndex = 1;
    } else {
      _missingIndex = Random().nextInt(_word.length);
    }
    
    _missingChar = _word[_missingIndex];

    // Distractors
    final List<String> alphabets = List.generate(26, (i) => String.fromCharCode(65 + i));
    alphabets.remove(_missingChar);
    alphabets.shuffle();

    // 3 options: Correct + 2 distractors
    _options = [_missingChar, alphabets[0], alphabets[1]];
    _options.shuffle();

    _isAnswered = false;
    _isCorrect = false;
    _selectedOption = '';
    _shakeTrigger = false;

    // Pronounce the challenge
    Future.delayed(const Duration(milliseconds: 400), () {
      TtsService.to.speak("Find the missing letter in ${_word.toLowerCase()}!");
    });
  }

  void _onOptionSelected(String option) {
    if (_isAnswered && _isCorrect) return; // prevent extra clicks

    setState(() {
      _selectedOption = option;
      _isAnswered = true;
    });

    if (option == _missingChar) {
      // Correct!
      setState(() {
        _isCorrect = true;
      });
      HapticUtil.medium();
      AudioService.to.playStar(); // success sound
      _confettiKey.currentState?.startCelebration(); // play confetti

      // Reward
      final progress = ProgressService.to;
      progress.addStar(); // adds star + 15 XP + 5 Coins
      progress.addXP(10); // Bonus XP
      progress.addCoins(10); // Bonus Coins

      TtsService.to.speak("Awesome! $option is correct! ${_word.toLowerCase()}!");
    } else {
      // Incorrect
      setState(() {
        _isCorrect = false;
        _shakeTrigger = true;
      });
      HapticUtil.heavy();
      AudioService.to.playTap(); // slice/wrong tap sound
      TtsService.to.speak("Oops! That's $option. Let's try again! Can you find $_missingChar?");

      // Reset shake state after animation runs
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _shakeTrigger = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Generate word template e.g. "A _ P L E"
    final List<Widget> letterRowChildren = [];
    for (int i = 0; i < _word.length; i++) {
      if (i == _missingIndex) {
        letterRowChildren.add(
          Container(
            width: 50.0,
            height: 60.0,
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.gold, width: 4.0),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              _isCorrect ? _missingChar : "?",
              style: AppTextStyles.displayLarge.copyWith(
                fontSize: 40.0,
                color: _isCorrect ? AppColors.mint : AppColors.gold,
              ),
            ),
          )
              .animate(target: _isCorrect ? 1.0 : 0.0)
              .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.2, 1.2), duration: const Duration(milliseconds: 500), curve: Curves.elasticOut),
        );
      } else {
        letterRowChildren.add(
          Text(
            _word[i],
            style: AppTextStyles.displayLarge.copyWith(
              fontSize: 40.0,
              color: Colors.white,
            ),
          ),
        );
      }
    }

    return Stack(
      children: [
        Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.0)),
          backgroundColor: AppColors.bgDark,
          insetPadding: const EdgeInsets.all(16.0),
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28.0),
              border: Border.all(color: Colors.white.withOpacity(0.12), width: 1.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Solve the Puzzle! 🧩",
                      style: AppTextStyles.displaySmall.copyWith(fontSize: 20.0, color: AppColors.gold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white54),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),

                // Emoji display
                Text(
                  widget.letter.emoji,
                  style: const TextStyle(fontSize: 64.0),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: const Duration(seconds: 2)),
                const SizedBox(height: 20.0),

                // Question Box
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: AppColors.bgMid,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: letterRowChildren,
                  ),
                ),
                const SizedBox(height: 28.0),

                // Options Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _options.map((opt) {
                    final bool isOptSelected = _selectedOption == opt;
                    final bool isCorrectOpt = opt == _missingChar;

                    Color cardBgColor = Colors.white.withOpacity(0.08);
                    Color borderCol = Colors.white.withOpacity(0.15);

                    if (_isAnswered && isOptSelected) {
                      cardBgColor = isCorrectOpt
                          ? AppColors.successGreen.withOpacity(0.25)
                          : Colors.redAccent.withOpacity(0.25);
                      borderCol = isCorrectOpt ? AppColors.successGreen : Colors.redAccent;
                    }

                    return BouncyButton(
                      onTap: () => _onOptionSelected(opt),
                      child: Container(
                        width: 72.0,
                        height: 72.0,
                        decoration: BoxDecoration(
                          color: cardBgColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: borderCol, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: borderCol.withOpacity(0.2),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          opt,
                          style: AppTextStyles.displayLarge.copyWith(fontSize: 34.0),
                        ),
                      ),
                    );
                  }).toList(),
                )
                    .animate(target: _shakeTrigger ? 1.0 : 0.0)
                    .shake(duration: 400.ms, hz: 6),
                const SizedBox(height: 24.0),

                // Success footer actions
                if (_isCorrect)
                  Column(
                    children: [
                      Text(
                        "🎉 Great Job! +10 Coins 🪙",
                        style: AppTextStyles.bodyMediumBold.copyWith(color: AppColors.mint),
                      ),
                      const SizedBox(height: 14.0),
                      ElevatedButton(
                        onPressed: () => Get.back(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mint,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(
                          "Next Letter! ➔",
                          style: AppTextStyles.bodySmallBold.copyWith(
                            fontSize: 14.0,
                            color: AppColors.bgDark,
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    "Tap the letter that fits in the word!",
                    style: AppTextStyles.bodySmall.copyWith(color: Colors.white30, fontSize: 14.0),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
        ),
        
        // Confetti emitter
        ConfettiOverlayWidget(key: _confettiKey),
      ],
    );
  }
}
