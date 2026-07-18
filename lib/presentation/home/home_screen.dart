import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/haptic_util.dart';
import '../../core/constants/app_routes.dart';
import 'home_controller.dart';
import 'widgets/floating_particles_widget.dart';
import 'widgets/star_counter_widget.dart';
import 'widgets/module_card_widget.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<HomeController>()) {
      Get.put(HomeController(), permanent: true);
    }

    // Refresh controller progress values every time the screen is displayed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.refreshProgress();
    });

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Stack(
        children: [
          // Ambient background particle system
          const FloatingParticlesWidget(),
          
          // Background floating clouds, butterflies, and stars
          Positioned(
            left: 20,
            top: 110,
            child: const Text("☁️", style: TextStyle(fontSize: 44.0, color: Colors.white12))
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveX(begin: 0, end: 30.0, duration: const Duration(seconds: 4), curve: Curves.easeInOut)
                .moveY(begin: 0, end: -10.0, duration: const Duration(seconds: 3), curve: Curves.easeInOut),
          ),
          Positioned(
            right: 30,
            top: 240,
            child: const Text("🦋", style: TextStyle(fontSize: 26.0))
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveY(begin: 0, end: -35.0, duration: const Duration(milliseconds: 3500), curve: Curves.easeInOut)
                .rotate(begin: -0.15, end: 0.15, duration: const Duration(seconds: 2)),
          ),
          Positioned(
            left: 40,
            top: 420,
            child: const Text("✨", style: TextStyle(fontSize: 22.0, color: Colors.white24))
                .animate(onPlay: (c) => c.repeat())
                .shimmer(duration: const Duration(seconds: 2)),
          ),
          // Extra floating decorations
          Positioned(
            right: 50,
            top: 500,
            child: const Text("🌈", style: TextStyle(fontSize: 20.0))
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveX(begin: -10, end: 15, duration: const Duration(seconds: 5), curve: Curves.easeInOut)
                .fadeIn(duration: const Duration(seconds: 1)),
          ),
          Positioned(
            left: 70,
            top: 600,
            child: const Text("🎵", style: TextStyle(fontSize: 18.0, color: Colors.white12))
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveY(begin: 0, end: -20, duration: const Duration(seconds: 3), curve: Curves.easeInOut)
                .rotate(begin: -0.1, end: 0.1, duration: const Duration(milliseconds: 2500)),
          ),
          Positioned(
            right: 20,
            top: 380,
            child: const Text("🍂", style: TextStyle(fontSize: 16.0, color: Colors.white10))
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveY(begin: -5, end: 25, duration: const Duration(seconds: 6), curve: Curves.easeInOut)
                .moveX(begin: 0, end: -15, duration: const Duration(seconds: 4), curve: Curves.easeInOut),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Premium Gamified Header Card
                Obx(() {
                  final avatar = controller.selectedAvatar.value;
                  final level = controller.level.value;
                  final xp = controller.xp.value;
                  final xpNeeded = level * 100;
                  final progressPercent = (xp / xpNeeded).clamp(0.0, 1.0);

                  return Container(
                    margin: const EdgeInsets.only(left: 12.0, right: 12.0, top: 12.0, bottom: 8.0),
                    padding: const EdgeInsets.all(14.0),
                    decoration: BoxDecoration(
                      color: AppColors.bgMid.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(24.0),
                      border: Border.all(color: Colors.white.withOpacity(0.12), width: 1.5),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8.0,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Avatar with circular XP indicator
                            GestureDetector(
                              onTap: () {
                                HapticUtil.light();
                                Get.toNamed(AppRoutes.profile);
                              },
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 72.0,
                                    height: 72.0,
                                    child: CircularProgressIndicator(
                                      value: progressPercent,
                                      strokeWidth: 5.0,
                                      backgroundColor: Colors.white10,
                                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.lavender),
                                    ),
                                  ),
                                  Container(
                                    width: 58.0,
                                    height: 58.0,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.bgDark,
                                    ),
                                    child: Center(
                                      child: Text(
                                        avatar,
                                        style: const TextStyle(fontSize: 32.0),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                                .animate(onPlay: (c) => c.repeat(reverse: true))
                                .scale(begin: const Offset(0.96, 0.96), end: const Offset(1.04, 1.04), duration: const Duration(seconds: 2)),
                            const SizedBox(width: 12.0),
                            
                            // Greet & Level Info with time-of-day greeting
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${controller.greetingEmoji} ${controller.greetingText}",
                                    style: AppTextStyles.bodyMediumBold.copyWith(color: Colors.white70),
                                  ),
                                  const SizedBox(height: 2.0),
                                  Row(
                                    children: [
                                      Text(
                                        "Level $level",
                                        style: AppTextStyles.displaySmall.copyWith(fontSize: 20.0, color: AppColors.gold),
                                      ),
                                      const SizedBox(width: 6.0),
                                      const Text("✨"),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12.0),
                        
                        // Mini stats Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildHeaderStatCell("⭐", "${controller.totalStars.value}", AppColors.gold),
                            _buildHeaderStatCell("🪙", "${controller.coins.value}", AppColors.warningOrange),
                            _buildHeaderStatCell("🔥", "${controller.dailyStreak.value}d", AppColors.coral),
                          ],
                        ),
                      ],
                    ),
                  );
                }),

                // Daily Challenge Card
                Obx(() {
                  final info = controller.currentChallengeInfo;
                  if (info == null) return const SizedBox.shrink();

                  final target = controller.dailyChallengeTarget.value;
                  final progress = controller.dailyChallengeProgress.value;
                  final completed = controller.dailyChallengeCompleted.value;
                  final challengeProgress = target > 0 ? (progress / target).clamp(0.0, 1.0) : 0.0;

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: completed
                            ? [AppColors.successGreen.withOpacity(0.15), AppColors.mint.withOpacity(0.1)]
                            : [AppColors.lavender.withOpacity(0.12), AppColors.skyBlue.withOpacity(0.08)],
                      ),
                      borderRadius: BorderRadius.circular(18.0),
                      border: Border.all(
                        color: completed
                            ? AppColors.successGreen.withOpacity(0.3)
                            : AppColors.lavender.withOpacity(0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Challenge emoji with glow
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: completed
                                ? AppColors.successGreen.withOpacity(0.2)
                                : AppColors.lavender.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              completed ? "✅" : (info['emoji'] as String? ?? "🎯"),
                              style: const TextStyle(fontSize: 22),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                completed ? "Challenge Done! 🎉" : "Daily Challenge",
                                style: AppTextStyles.bodySmallBold.copyWith(
                                  color: completed ? AppColors.successGreen : AppColors.gold,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                info['text'] as String? ?? '',
                                style: AppTextStyles.bodySmallBold.copyWith(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 6),
                              // Progress bar
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: challengeProgress,
                                  backgroundColor: Colors.white.withOpacity(0.1),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    completed ? AppColors.successGreen : AppColors.lavender,
                                  ),
                                  minHeight: 5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "$progress/$target",
                          style: AppTextStyles.bodySmallBold.copyWith(
                            color: completed ? AppColors.successGreen : Colors.white54,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(duration: const Duration(milliseconds: 500))
                      .slideY(begin: 0.2, end: 0, duration: const Duration(milliseconds: 400));
                }),
                
                const SizedBox(height: 4.0),
                
                // Module Grid (Reactive)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: GetBuilder<HomeController>(
                      init: controller,
                      builder: (_) {
                        return GridView.builder(
                          physics: const BouncingScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12.0,
                            mainAxisSpacing: 12.0,
                            childAspectRatio: 0.95,
                          ),
                          itemCount: controller.modules.length,
                          itemBuilder: (ctx, i) {
                            final module = controller.modules[i];
                            return ModuleCardWidget(module: module)
                                .animate(delay: (i * 80).ms)
                                .slideY(begin: 0.3, end: 0.0, duration: 400.ms, curve: Curves.easeOutBack)
                                .fadeIn(duration: 400.ms);
                          },
                        );
                      },
                    ),
                  ),
                ),

                // Motivational quote bar
                Container(
                  margin: const EdgeInsets.only(left: 12, right: 12, bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.gold.withOpacity(0.12)),
                  ),
                  child: Text(
                    controller.dailyQuote,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.gold.withOpacity(0.7),
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStatCell(String icon, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: color.withOpacity(0.25), width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 16.0),
          ),
          const SizedBox(width: 6.0),
          Text(
            value,
            style: AppTextStyles.bodySmallBold.copyWith(
              fontSize: 14.0,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
