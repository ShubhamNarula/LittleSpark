import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../data/models/badge_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class BadgeCardWidget extends StatelessWidget {
  final BadgeModel badge;
  final bool isUnlocked;

  const BadgeCardWidget({
    Key? key,
    required this.badge,
    required this.isUnlocked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardDecoration = BoxDecoration(
      gradient: isUnlocked
          ? LinearGradient(
              colors: badge.gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
          : LinearGradient(
              colors: [Colors.grey.shade800, Colors.grey.shade900],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
      borderRadius: BorderRadius.circular(20.0),
      boxShadow: isUnlocked
          ? [
              BoxShadow(
                color: badge.color.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              )
            ]
          : null,
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: cardDecoration,
      child: Stack(
        children: [
          // Badge Details
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Badge Emoji
                  Text(
                    badge.emoji,
                    style: TextStyle(
                      fontSize: isUnlocked ? 48.0 : 36.0,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  
                  // Badge Title
                  Text(
                    badge.name,
                    style: AppTextStyles.bodySmallBold.copyWith(
                      fontSize: 14.0, // Minimum 14sp restriction
                      color: isUnlocked ? Colors.white : Colors.white.withOpacity(0.4),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4.0),
                  
                  // Description
                  Text(
                    badge.description,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 14.0, // Enforce 14sp minimum constraint
                      color: isUnlocked ? Colors.white.withOpacity(0.7) : Colors.white.withOpacity(0.3),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          
          // Lock overlay for unearned badges
          if (!isUnlocked)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: const Center(
                  child: Text(
                    "🔒",
                    style: TextStyle(fontSize: 32.0),
                  ),
                ),
              ),
            ),
          
          // Checkmark overlay for earned badges
          if (isUnlocked)
            Positioned(
              top: 8,
              right: 8,
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
    )
        .animate(target: isUnlocked ? 1.0 : 0.0)
        .shimmer(duration: 1500.ms, delay: 200.ms);
  }
}
