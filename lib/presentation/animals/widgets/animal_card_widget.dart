import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../data/models/animal_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class AnimalCardWidget extends StatelessWidget {
  final AnimalModel animal;
  final bool isVisited;
  final VoidCallback onTap;

  const AnimalCardWidget({
    Key? key,
    required this.animal,
    required this.isVisited,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: AppColors.animalsGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: AppColors.animalsGradient[0].withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Main card details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Floating animal emoji
                    Text(
                      animal.emoji,
                      style: const TextStyle(fontSize: 64.0),
                    )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .moveY(
                          begin: 0.0,
                          end: -5.0,
                          duration: 1800.ms,
                          curve: Curves.easeInOut,
                        ),
                    const SizedBox(height: 8.0),
                    // Animal name
                    Text(
                      animal.name,
                      style: AppTextStyles.bodyMediumBold.copyWith(
                        color: Colors.white,
                        fontSize: 16.0, // Minimum 14sp restriction
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Habitat Badge top right
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text(
                  animal.habitatEmoji,
                  style: const TextStyle(
                    fontSize: 14.0, // Enforce 14sp minimum constraint
                  ),
                ),
              ),
            ),
            
            // Completion Checkmark bottom right
            if (isVisited)
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  width: 22.0,
                  height: 22.0,
                  decoration: const BoxDecoration(
                    color: AppColors.successGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 14.0,
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
