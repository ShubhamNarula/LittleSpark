import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../data/models/fruit_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class FruitCardWidget extends StatelessWidget {
  final FruitModel item;
  final bool isVisited;
  final VoidCallback onTap;

  const FruitCardWidget({
    Key? key,
    required this.item,
    required this.isVisited,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dynamic gradient colors based on fruit/vegetable categorization
    final List<Color> gradientColors = item.isVegetable
        ? const [AppColors.mint, Color(0xFF44A08D)]
        : AppColors.fruitsVeggiesGradient;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.0),
          border: isVisited
              ? Border.all(color: AppColors.gold, width: 2.0)
              : Border.all(color: Colors.white.withOpacity(0.1), width: 1.0),
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Elastic scaled emoji
                    Text(
                      item.emoji,
                      style: const TextStyle(fontSize: 56.0),
                    )
                        .animate()
                        .scale(
                          curve: Curves.elasticOut,
                          duration: 400.ms,
                        ),
                    const SizedBox(height: 6.0),
                    
                    // Name label
                    Text(
                      item.name,
                      style: AppTextStyles.bodyMediumBold.copyWith(
                        color: Colors.white,
                        fontSize: 15.0, // Minimum 14sp restriction
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6.0),
                    
                    // Taste Tag
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Text(
                        item.taste,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 14.0, // Enforce 14sp minimum constraint
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Checkmark overlay for visited items
            if (isVisited)
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
      ),
    );
  }
}
