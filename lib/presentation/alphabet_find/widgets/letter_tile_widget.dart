import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../alphabet_find_controller.dart';

class LetterTileWidget extends StatelessWidget {
  final String letter;
  final AlphabetFindController controller;

  const LetterTileWidget({
    Key? key,
    required this.letter,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLastTapped = letter == controller.lastTappedLetter.value;
      final wasCorrect = isLastTapped && controller.isCorrect.value;
      final wasWrong = isLastTapped && controller.isWrong.value;

      return GestureDetector(
        onTap: () => controller.onLetterTapped(letter),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: wasCorrect
                ? AppColors.successGreen
                : wasWrong
                    ? AppColors.coral.withOpacity(0.8)
                    : Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: wasCorrect
                  ? AppColors.successGreen
                  : wasWrong
                      ? AppColors.coral
                      : Colors.white24,
              width: 2.0,
            ),
            boxShadow: wasCorrect
                ? [
                    BoxShadow(
                      color: AppColors.successGreen.withOpacity(0.5),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              letter,
              style: const TextStyle(
                fontFamily: 'FredokaOne',
                fontSize: 36,
                color: Colors.white,
              ),
            ),
          ),
        )
            // Wrong tap: shake animation
            .animate(target: wasWrong ? 1 : 0)
            .shake(hz: 4, duration: 400.ms)
            // Correct tap: scale up celebration
            .animate(target: wasCorrect ? 1 : 0)
            .scale(
              begin: const Offset(1.0, 1.0),
              end: const Offset(1.15, 1.15),
              duration: 200.ms,
            )
            .then()
            .scale(
              begin: const Offset(1.15, 1.15),
              end: const Offset(1.0, 1.0),
              duration: 200.ms,
            ),
      );
    });
  }
}
