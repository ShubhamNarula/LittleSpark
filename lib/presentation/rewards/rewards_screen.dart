import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../shared/widgets/bouncy_button.dart';
import '../../core/utils/haptic_util.dart';
import 'rewards_controller.dart';
import 'widgets/badge_card_widget.dart';

class RewardsScreen extends GetView<RewardsController> {
  const RewardsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.bgDark, AppColors.bgMid],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Back Button & Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 44,
                      height: 44,
                      child: BouncyButton(
                        onTap: () {
                          HapticUtil.light();
                          Get.back();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 20.0,
                          ),
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          "My Rewards 🏅",
                          style: TextStyle(
                            fontFamily: 'FredokaOne',
                            fontSize: 24.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 44.0), // Spacer equal to back button
                  ],
                ),
              ),

              // Star Summary Section
              Container(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Giant Star Emoji
                    const Text(
                      "⭐",
                      style: const TextStyle(fontSize: 80.0),
                    )
                        .animate(onPlay: (c) => c.repeat())
                        .shimmer(duration: const Duration(seconds: 2)),
                    const SizedBox(height: 8.0),

                    // Star Count
                    Obx(() => Text(
                          "${controller.totalStars.value}",
                          style: AppTextStyles.displayLarge.copyWith(
                            fontSize: 64.0,
                            color: AppColors.gold,
                          ),
                        )),
                    Text(
                      "Total Stars Earned",
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white70),
                    ),
                    const SizedBox(height: 16.0),

                    // Progress Slider towards Legend status
                    Obx(() {
                      final stars = controller.totalStars.value;
                      final double progressVal = (stars / 100.0).clamp(0.0, 1.0);
                      return Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(5.0),
                            child: LinearProgressIndicator(
                              value: progressVal,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
                              minHeight: 10.0,
                            ),
                          ),
                          const SizedBox(height: 6.0),
                          Text(
                            "$stars/100 stars to LittleSpark Legend 💎",
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 14.0, // Minimum 14sp restriction
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),

              const Divider(color: Colors.white24, height: 1.0),

              // Badges Grid Section Header
              Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 16.0, right: 16.0),
                child: Text(
                  "My Badges 🏅",
                  style: AppTextStyles.bodyExtraLarge.copyWith(fontSize: 20.0),
                ),
              ),

              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16.0),
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12.0,
                    mainAxisSpacing: 12.0,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: controller.badges.length,
                  itemBuilder: (ctx, i) {
                    final badge = controller.badges[i];
                    
                    return Obx(() {
                      final isUnlocked = controller.unlockedBadges.contains(badge.id);
                      return BadgeCardWidget(
                        badge: badge,
                        isUnlocked: isUnlocked,
                      );
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
