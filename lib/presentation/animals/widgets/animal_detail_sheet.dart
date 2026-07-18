import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../data/models/animal_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../animals_controller.dart';
import '../../../services/tts_service.dart';
import '../../../core/utils/haptic_util.dart';

class AnimalDetailSheet extends StatelessWidget {
  final AnimalModel animal;

  const AnimalDetailSheet({
    Key? key,
    required this.animal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AnimalsController>();

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

                // Big spring scale emoji
                Text(
                  animal.emoji,
                  style: const TextStyle(fontSize: 90.0),
                )
                    .animate()
                    .scale(
                      begin: const Offset(0.3, 0.3),
                      end: const Offset(1.0, 1.0),
                      duration: 600.ms,
                      curve: Curves.elasticOut,
                    ),
                const SizedBox(height: 12.0),

                // Bubbly title
                Text(
                  animal.name,
                  style: AppTextStyles.displayLarge.copyWith(
                    fontSize: 48.0,
                    color: AppColors.gold,
                  ),
                ),
                const SizedBox(height: 16.0),

                // Info Chips Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      _buildInfoChip("Baby", animal.babyName, AppColors.skyBlue),
                      const SizedBox(width: 8),
                      _buildInfoChip("Diet", animal.diet, AppColors.coral),
                      const SizedBox(width: 8),
                      _buildInfoChip("Sound", animal.sound, AppColors.warningOrange),
                      const SizedBox(width: 8),
                      _buildInfoChip("Habitat", "${animal.habitat} ${animal.habitatEmoji}", AppColors.mint),
                    ],
                  ),
                ),
                const SizedBox(height: 24.0),

                // Sound Wave Visualization Simulator
                Text(
                  "Animal Voice Wave 🎵",
                  style: AppTextStyles.bodyMediumBold.copyWith(color: AppColors.white60),
                ),
                const SizedBox(height: 12.0),
                const SoundWaveVisualizer(),
                const SizedBox(height: 24.0),

                // Fun Fact Container
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
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
                          animal.funFact,
                          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28.0),

                // Hear name button
                GestureDetector(
                  onTap: () {
                    HapticUtil.light();
                    controller.speak("This is a ${animal.name}. It goes ${animal.sound.split('!')[0]}!");
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 14.0),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: AppColors.animalsGradient,
                      ),
                      borderRadius: BorderRadius.circular(16.0),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.animalsGradient[0].withOpacity(0.4),
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
                          "Hear Sound!",
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

  Widget _buildInfoChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 14.0, // Enforce 14sp minimum
              color: Colors.white60,
            ),
          ),
          const SizedBox(height: 2.0),
          Text(
            value,
            style: AppTextStyles.bodySmallBold.copyWith(
              fontSize: 14.0, // Enforce 14sp minimum
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class SoundWaveVisualizer extends StatefulWidget {
  const SoundWaveVisualizer({Key? key}) : super(key: key);

  @override
  State<SoundWaveVisualizer> createState() => _SoundWaveVisualizerState();
}

class _SoundWaveVisualizerState extends State<SoundWaveVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double scale = 1.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(8, (index) {
        // Staggered height transitions
        final double baseDelay = index * 0.125;

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final double value = math.sin((_controller.value * 2 * math.pi) - (baseDelay * 2 * math.pi));
            final double height = 8.0 + (12.0 * (value + 1.0)); // Maps -1..1 to 8..32px

            return Container(
              width: 6.0,
              height: height,
              margin: const EdgeInsets.symmetric(horizontal: 3.0),
              decoration: BoxDecoration(
                color: AppColors.successGreen,
                borderRadius: BorderRadius.circular(3.0),
              ),
            );
          },
        );
      }),
    );
  }
}
