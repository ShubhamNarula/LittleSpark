import 'package:flutter/material.dart';
import '../../../data/models/letter_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class LetterCardWidget extends StatelessWidget {
  final LetterModel letter;
  final bool isVisited;
  final VoidCallback onTap;

  const LetterCardWidget({
    Key? key,
    required this.letter,
    required this.isVisited,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardColor = Color(letter.colorHex);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16.0),
          border: isVisited
              ? Border.all(color: AppColors.gold, width: 2.5)
              : Border.all(color: Colors.white.withOpacity(0.1), width: 1.0),
          boxShadow: [
            BoxShadow(
              color: cardColor.withOpacity(0.4),
              blurRadius: 8.0,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Letter and Emoji content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    letter.letter,
                    style: AppTextStyles.displayMedium.copyWith(
                      fontSize: 38.0,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    letter.emoji,
                    style: const TextStyle(fontSize: 22.0),
                  ),
                ],
              ),
            ),
            
            // Checkmark overlay for visited items
            if (isVisited)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 20.0,
                  height: 20.0,
                  decoration: const BoxDecoration(
                    color: AppColors.successGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 12.0,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
