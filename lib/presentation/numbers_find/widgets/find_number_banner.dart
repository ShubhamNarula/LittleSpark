import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../numbers_find_controller.dart';

class FindNumberBanner extends StatelessWidget {
  final NumbersFindController controller;

  const FindNumberBanner({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isCorrect = controller.isCorrect.value;
      final target = controller.targetNumber.value;

      if (target <= 0) {
        return const SizedBox.shrink();
      }

      final data = NumbersFindController.numberData[target] ?? {'word': '', 'emoji': '', 'fact': ''};
      final word = data['word'] ?? '';
      final emoji = data['emoji'] ?? '';
      final fact = data['fact'] ?? '';

      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isCorrect
                ? [const Color(0xFF22C55E), const Color(0xFF15803D)]
                : [AppColors.gold, const Color(0xFFFB923C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24.0),
          boxShadow: [
            BoxShadow(
              color: (isCorrect ? const Color(0xFF22C55E) : AppColors.gold).withOpacity(0.4),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.white.withOpacity(0.25), width: 1.5),
        ),
        child: Column(
          children: [
            Text(
              isCorrect ? "🎉 Amazing!" : "Find the number...",
              style: AppTextStyles.bodyMediumBold.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  target.toString(),
                  style: const TextStyle(
                    fontFamily: 'FredokaOne',
                    fontSize: 72.0,
                    fontWeight: FontWeight.normal,
                    color: Colors.white,
                    height: 1.0,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        offset: Offset(0, 3),
                        blurRadius: 6.0,
                      )
                    ],
                  ),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(
                      begin: const Offset(1.0, 1.0),
                      end: const Offset(1.08, 1.08),
                      duration: const Duration(milliseconds: 1500),
                      curve: Curves.easeInOut,
                    ),
                const SizedBox(width: 16.0),
                Text(
                  emoji,
                  style: const TextStyle(fontSize: 56.0),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .moveY(
                      begin: 0.0,
                      end: -8.0,
                      duration: const Duration(milliseconds: 1200),
                      curve: Curves.easeInOut,
                    ),
              ],
            ),
            const SizedBox(height: 8.0),
            Text(
              word,
              style: const TextStyle(
                fontFamily: 'FredokaOne',
                fontSize: 22.0,
                fontWeight: FontWeight.normal,
                color: Colors.white,
              ),
            ),
            if (isCorrect) ...[
              const SizedBox(height: 12.0),
              Text(
                fact,
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 14.0, // minimum font size limit
                  color: Colors.white.withOpacity(0.95),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              )
                  .animate()
                  .slideY(begin: 0.3, end: 0.0, duration: 400.ms, curve: Curves.easeOutQuad)
                  .fadeIn(duration: 400.ms),
            ],
          ],
        ),
      );
    });
  }
}
