import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../numbers_find_controller.dart';

class NumberTileWidget extends StatelessWidget {
  final int number;
  final NumbersFindController controller;

  const NumberTileWidget({
    Key? key,
    required this.number,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLastTapped = number == controller.lastTappedNumber.value;
      final wasCorrect = isLastTapped && controller.isCorrect.value;
      final wasWrong = isLastTapped && controller.isWrong.value;

      return GestureDetector(
        onTap: () => controller.onNumberTapped(number),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 80.0,
          height: 80.0,
          decoration: BoxDecoration(
            color: wasCorrect
                ? AppColors.successGreen
                : wasWrong
                    ? AppColors.coral.withOpacity(0.8)
                    : Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20.0),
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
              number.toString(),
              style: const TextStyle(
                fontFamily: 'FredokaOne',
                fontSize: 32.0,
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
