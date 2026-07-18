import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../data/models/fruit_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../fruits_controller.dart';
import '../../../services/tts_service.dart';
import '../../../core/utils/haptic_util.dart';

class FruitDetailSheet extends StatelessWidget {
  final FruitModel item;

  const FruitDetailSheet({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FruitsController>();
    final themeColor = item.isVegetable ? AppColors.mint : AppColors.coral;

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
                // Drag handle
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

                // Emoji (80sp with bounce)
                Text(
                  item.emoji,
                  style: const TextStyle(fontSize: 80.0),
                )
                    .animate()
                    .scale(
                      begin: const Offset(0.3, 0.3),
                      end: const Offset(1.0, 1.0),
                      duration: 500.ms,
                      curve: Curves.elasticOut,
                    ),
                const SizedBox(height: 12.0),

                // Title
                Text(
                  item.name,
                  style: AppTextStyles.displayLarge.copyWith(
                    fontSize: 40.0,
                    color: themeColor,
                  ),
                ),
                const SizedBox(height: 16.0),

                // Row of 3 Chips (Color, Taste, growsOn)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildDetailChip("🎨 ${item.color}", themeColor),
                    const SizedBox(width: 8.0),
                    _buildDetailChip("😋 ${item.taste}", themeColor),
                    const SizedBox(width: 8.0),
                    _buildDetailChip("🌱 ${item.growsOn}", themeColor),
                  ],
                ),
                const SizedBox(height: 24.0),

                // Health Benefit container
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                  decoration: BoxDecoration(
                    color: AppColors.successGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(color: AppColors.successGreen.withOpacity(0.3), width: 1.5),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        "💪",
                        style: TextStyle(fontSize: 28.0),
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Health Benefit:",
                              style: AppTextStyles.bodySmall.copyWith(
                                fontSize: 14.0, // Enforce 14sp minimum
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 2.0),
                            Text(
                              item.benefit,
                              style: AppTextStyles.bodyMediumBold.copyWith(
                                color: AppColors.successGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24.0),

                // Growth Journey Map
                Text(
                  "Growth Journey 🌱",
                  style: AppTextStyles.bodyMediumBold.copyWith(color: AppColors.white60),
                ),
                const SizedBox(height: 12.0),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildJourneyStep("🌱", "Seed"),
                      const Icon(Icons.arrow_forward_rounded, color: Colors.white24),
                      _buildJourneyStep("🌿", "Plant"),
                      const Icon(Icons.arrow_forward_rounded, color: Colors.white24),
                      _buildJourneyStep(item.emoji, item.name),
                    ],
                  ),
                ),
                const SizedBox(height: 24.0),

                // Fun Fact container
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  padding: const EdgeInsets.all(14.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Text(
                    item.funFact,
                    style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 28.0),

                // TTS audio speak button
                GestureDetector(
                  onTap: () {
                    HapticUtil.light();
                    controller.speak("This is a ${item.name}. It tastes ${item.taste}!");
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 14.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradientColors,
                      ),
                      borderRadius: BorderRadius.circular(16.0),
                      boxShadow: [
                        BoxShadow(
                          color: gradientColors[0].withOpacity(0.4),
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
                const SizedBox(height: 32.0),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Color> get gradientColors => item.isVegetable
      ? const [AppColors.mint, Color(0xFF44A08D)]
      : AppColors.fruitsVeggiesGradient;

  Widget _buildDetailChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodySmallBold.copyWith(
          fontSize: 14.0, // Enforce 14sp minimum constraint
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildJourneyStep(String emoji, String stepLabel) {
    return Column(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 28.0),
        ),
        const SizedBox(height: 4.0),
        Text(
          stepLabel,
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: 14.0, // Enforce 14sp minimum
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}
