import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../shared/widgets/gradient_app_bar.dart';
import '../shared/widgets/progress_chip_widget.dart';
import 'alphabet_controller.dart';
import 'widgets/letter_card_widget.dart';

class AlphabetScreen extends GetView<AlphabetController> {
  const AlphabetScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Column(
        children: [
          // Gradient Custom App Bar
          Obx(() => GradientAppBar(
                title: "A to Z 🔤",
                gradient: AppColors.alphabetGradient,
                trailing: ProgressChipWidget(
                  done: controller.visitedLetters.length,
                  total: 26,
                ),
              )),

          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12.0),
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
                childAspectRatio: 0.9,
              ),
              itemCount: controller.letters.length,
              itemBuilder: (ctx, i) {
                final letter = controller.letters[i];
                
                return Obx(() {
                  final isVisited = controller.visitedLetters.contains(letter.letter);
                  return LetterCardWidget(
                    letter: letter,
                    isVisited: isVisited,
                    onTap: () => controller.onLetterTap(letter),
                  );
                })
                    .animate(delay: (i * 40).ms)
                    .scale(
                      begin: const Offset(0.5, 0.5),
                      duration: 300.ms,
                      curve: Curves.elasticOut,
                    );
              },
            ),
          ),

          // Encouraging Banner at the bottom
          Obx(() {
            final visitedCount = controller.visitedLetters.length;
            if (visitedCount < 26) {
              return Container(
                margin: const EdgeInsets.only(left: 12, right: 12, bottom: 16, top: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(
                    color: AppColors.gold.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  "🌟 Keep going! You've learned $visitedCount/26 letters!",
                  style: AppTextStyles.bodySmallBold.copyWith(color: AppColors.gold),
                  textAlign: TextAlign.center,
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }
}
