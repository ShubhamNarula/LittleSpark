import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../data/models/letter_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../alphabet_controller.dart';
import 'slicing_emoji_widget.dart';
import 'fill_missing_letter_game.dart';
import '../../../core/utils/haptic_util.dart';

class LetterDetailSheet extends StatelessWidget {
  final LetterModel letter;

  const LetterDetailSheet({
    Key? key,
    required this.letter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AlphabetController>();
    final letterColor = Color(letter.colorHex);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgDark,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28.0),
          topRight: Radius.circular(28.0),
        ),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (ctx, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // Drag handle bar
                Container(
                  width: 40.0,
                  height: 4.0,
                  margin: const EdgeInsets.only(top: 12.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
                const SizedBox(height: 16.0),

                // Big slicing Emoji (Interactive!)
                SlicingEmojiWidget(
                  emoji: letter.emoji,
                  size: 90.0,
                )
                    .animate()
                    .scale(
                      begin: const Offset(0.0, 0.0),
                      end: const Offset(1.0, 1.0),
                      duration: 600.ms,
                      curve: Curves.elasticOut,
                    ),
                const SizedBox(height: 12.0),

                // Huge Letter with soft rotation sway loop
                Text(
                  letter.letter,
                  style: AppTextStyles.displayLarge.copyWith(
                    fontSize: 100.0,
                    color: letterColor,
                  ),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .rotate(
                      begin: -0.02,
                      end: 0.02,
                      duration: const Duration(seconds: 2),
                      curve: Curves.easeInOut,
                    ),
                const SizedBox(height: 4.0),
                
                // Lowercase and Uppercase guide
                Text(
                  "${letter.letter.toLowerCase()}   ${letter.letter.toUpperCase()}",
                  style: AppTextStyles.bodyExtraLarge.copyWith(
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 20.0),

                // Word Display
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  margin: const EdgeInsets.symmetric(horizontal: 24.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Text(
                    "${letter.letter} is for ${letter.word}",
                    style: AppTextStyles.bodyExtraLarge.copyWith(fontSize: 24.0),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16.0),

                // Fun Fact Container
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.gold.withOpacity(0.2),
                        AppColors.warningOrange.withOpacity(0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        "💡",
                        style: TextStyle(fontSize: 24.0),
                      ),
                      const SizedBox(width: 10.0),
                      Expanded(
                        child: Text(
                          letter.funFact,
                          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20.0),

                // Speak Button
                GestureDetector(
                  onTap: () => controller.speak("${letter.letter}, ${letter.word}"),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 14.0),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.coral, AppColors.warningOrange],
                      ),
                      borderRadius: BorderRadius.circular(16.0),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.coral.withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "🔊",
                          style: TextStyle(fontSize: 24.0),
                        ),
                        const SizedBox(width: 8.0),
                        Text(
                          "Hear it!",
                          style: AppTextStyles.bodyLargeBold.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),

                // Solve Puzzle Button
                GestureDetector(
                  onTap: () {
                    HapticUtil.light();
                    Get.back(); // close letter sheet
                    Get.dialog(
                      FillMissingLetterGame(letter: letter),
                      barrierDismissible: false,
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24.0),
                    padding: const EdgeInsets.symmetric(vertical: 18.0),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.mint, Color(0xFF44A08D)],
                      ),
                      borderRadius: BorderRadius.circular(20.0),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.mint.withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "🧩",
                          style: TextStyle(fontSize: 26.0),
                        ),
                        const SizedBox(width: 8.0),
                        Text(
                          "Play Spelling Puzzle!",
                          style: AppTextStyles.bodyLargeBold.copyWith(color: Colors.white, fontSize: 18.0),
                        ),
                      ],
                    ),
                  ),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(begin: const Offset(0.97, 0.97), end: const Offset(1.03, 1.03), duration: const Duration(milliseconds: 1500), curve: Curves.easeInOut),
                const SizedBox(height: 32.0),
              ],
            ),
          );
        },
      ),
    );
  }
}
