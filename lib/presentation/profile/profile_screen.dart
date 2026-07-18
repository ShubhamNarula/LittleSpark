import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../shared/widgets/gradient_app_bar.dart';
import '../shared/widgets/bouncy_button.dart';
import 'profile_controller.dart';
import '../../data/datasources/badges_data.dart';
import '../../core/utils/haptic_util.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Column(
        children: [
          // Custom Gradient App Bar
          const GradientAppBar(
            title: "My Profile 🧑‍🚀",
            gradient: AppColors.colorsShapesGradient,
            showLeading: true,
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Column(
                  children: [
                    // Kid profile header card
                    _buildProfileHeaderCard(context),
                    const SizedBox(height: 20.0),

                    // Badges section title
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "My Badges 🏅",
                        style: AppTextStyles.displaySmall.copyWith(fontSize: 22.0),
                      ),
                    ),
                    const SizedBox(height: 12.0),

                    // Grid of Badges
                    _buildBadgesGrid(),
                    const SizedBox(height: 32.0),

                    // Parent Zone Button
                    _buildParentZoneButton(context),
                    const SizedBox(height: 24.0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeaderCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppColors.bgMid,
        borderRadius: BorderRadius.circular(28.0),
        border: Border.all(color: Colors.white.withOpacity(0.12), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 12.0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar Editor Trigger
          Obx(() {
            final avatar = controller.progress.selectedAvatar;
            return GestureDetector(
              onTap: () => _showAvatarPicker(context),
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 110.0,
                    height: 110.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: AppColors.colorsShapesGradient,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.lavender.withOpacity(0.5),
                          blurRadius: 12.0,
                          spreadRadius: 2.0,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        avatar,
                        style: const TextStyle(fontSize: 60.0),
                      ),
                    ),
                  )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scale(begin: const Offset(0.96, 0.96), end: const Offset(1.04, 1.04), duration: const Duration(seconds: 2), curve: Curves.easeInOut),
                  Container(
                    padding: const EdgeInsets.all(6.0),
                    decoration: const BoxDecoration(
                      color: AppColors.gold,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit_rounded,
                      color: AppColors.bgDark,
                      size: 16.0,
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 16.0),

          // Name and Level Badge
          Text(
            "Little Explorer 🌟",
            style: AppTextStyles.displaySmall.copyWith(fontSize: 24.0),
          ),
          const SizedBox(height: 6.0),
          Obx(() {
            final level = controller.progress.level;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
              decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: AppColors.gold.withOpacity(0.3), width: 1.0),
              ),
              child: Text(
                "Level $level",
                style: AppTextStyles.bodyMediumBold.copyWith(color: AppColors.gold),
              ),
            );
          }),
          const SizedBox(height: 16.0),

          // XP Progress Bar
          Obx(() {
            final xp = controller.progress.xp;
            final level = controller.progress.level;
            final xpNeeded = level * 100;
            final progressPercent = (xp / xpNeeded).clamp(0.0, 1.0);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "XP Progress",
                      style: AppTextStyles.bodySmallBold.copyWith(color: Colors.white70),
                    ),
                    Text(
                      "$xp / $xpNeeded XP",
                      style: AppTextStyles.bodySmallBold.copyWith(color: AppColors.lavender),
                    ),
                  ],
                ),
                const SizedBox(height: 6.0),
                Stack(
                  children: [
                    Container(
                      height: 16.0,
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      height: 16.0,
                      width: MediaQuery.of(context).size.width * 0.75 * progressPercent,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.lavender, AppColors.skyBlue],
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.lavender.withOpacity(0.4),
                            blurRadius: 4.0,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
          const SizedBox(height: 20.0),

          // Stats grid row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatCell("Stars", "⭐", controller.progress.totalStarsRx),
              _buildStatCell("Coins", "🪙", controller.progress.coinsRx),
              _buildStatCell("Streak", "🔥", controller.progress.dailyStreakRx),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCell(String label, String icon, RxInt valObservable) {
    return Column(
      children: [
        Text(
          icon,
          style: const TextStyle(fontSize: 28.0),
        ),
        const SizedBox(height: 4.0),
        Obx(() => Text(
              "${valObservable.value}",
              style: AppTextStyles.bodyExtraLarge.copyWith(color: Colors.white),
            )),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(color: Colors.white60),
        ),
      ],
    );
  }

  Widget _buildBadgesGrid() {
    return Obx(() {
      final unlocked = controller.unlockedBadges.toList();

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
          childAspectRatio: 0.9,
        ),
        itemCount: BadgesData.badges.length,
        itemBuilder: (context, index) {
          final badge = BadgesData.badges[index];
          final isUnlocked = unlocked.contains(badge.id);

          return Container(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
            decoration: BoxDecoration(
              color: isUnlocked ? AppColors.bgMid : Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(
                color: isUnlocked ? Color(badge.colorHex).withOpacity(0.5) : Colors.white.withOpacity(0.08),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon (Greyed out if locked)
                Opacity(
                  opacity: isUnlocked ? 1.0 : 0.25,
                  child: Text(
                    badge.emoji,
                    style: const TextStyle(fontSize: 34.0),
                  ),
                ),
                const SizedBox(height: 6.0),
                Text(
                  badge.name,
                  style: AppTextStyles.bodySmallBold.copyWith(
                    color: isUnlocked ? Colors.white : Colors.white30,
                    fontSize: 14.0,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2.0),
                Text(
                  isUnlocked ? "Unlocked!" : "Locked",
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 14.0,
                    color: isUnlocked ? AppColors.mint : Colors.white30,
                  ),
                ),
              ],
            ),
          )
              .animate(delay: (index * 50).ms)
              .scale(begin: const Offset(0.8, 0.8), duration: 250.ms);
        },
      );
    });
  }

  Widget _buildParentZoneButton(BuildContext context) {
    return BouncyButton(
      onTap: () => _showParentVerification(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: Colors.white.withOpacity(0.12), width: 1.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.family_restroom_rounded,
              color: Colors.white70,
              size: 20.0,
            ),
            const SizedBox(width: 8.0),
            Text(
              "Parent Zone: Reset Progress 🔄",
              style: AppTextStyles.bodySmallBold.copyWith(
                color: Colors.white70,
                fontSize: 14.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAvatarPicker(BuildContext context) {
    HapticUtil.light();
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24.0),
        decoration: const BoxDecoration(
          color: AppColors.bgDark,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28.0),
            topRight: Radius.circular(28.0),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.0,
              height: 4.0,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              "Choose Your Animal Friend! 🦁",
              style: AppTextStyles.displaySmall.copyWith(fontSize: 22.0),
            ),
            const SizedBox(height: 20.0),
            SizedBox(
              height: 220.0,
              child: GridView.builder(
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemCount: controller.avatars.length,
                itemBuilder: (ctx, i) {
                  final avatarEmoji = controller.avatars[i];
                  return Obx(() {
                    final isSelected = controller.progress.selectedAvatar == avatarEmoji;
                    return GestureDetector(
                      onTap: () {
                        controller.updateAvatar(avatarEmoji);
                        Get.back();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.gold.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? AppColors.gold : Colors.white.withOpacity(0.1),
                            width: 2.0,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            avatarEmoji,
                            style: const TextStyle(fontSize: 28.0),
                          ),
                        ),
                      ),
                    );
                  });
                },
              ),
            ),
            const SizedBox(height: 12.0),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }

  void _showParentVerification(BuildContext context) {
    HapticUtil.light();
    controller.generateParentEquation();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.0)),
        backgroundColor: AppColors.bgMid,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Parent Verification Gate 🔒",
                style: TextStyle(
                  fontFamily: 'FredokaOne',
                  fontSize: 22.0,
                  color: AppColors.gold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12.0),
              Text(
                "Please solve this math equation to prove you are an adult. This keeps children from resetting game data.",
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24.0),
              Obx(() => Text(
                    "${controller.parentGateNum1} + ${controller.parentGateNum2} = ?",
                    style: AppTextStyles.displayMedium.copyWith(
                      fontSize: 34.0,
                      color: AppColors.skyBlue,
                    ),
                    textAlign: TextAlign.center,
                  )),
              const SizedBox(height: 16.0),
              TextField(
                controller: controller.mathAnswerController,
                keyboardType: TextInputType.number,
                autofocus: true,
                style: AppTextStyles.bodyExtraLarge.copyWith(color: Colors.white),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: "Enter result",
                  hintStyle: const TextStyle(color: Colors.white24),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              Obx(() {
                final err = controller.validationError.value;
                if (err.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    err,
                    style: AppTextStyles.bodySmallBold.copyWith(
                      color: Colors.redAccent,
                      fontSize: 14.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              }),
              const SizedBox(height: 24.0),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        "Cancel",
                        style: AppTextStyles.bodyMediumBold.copyWith(
                          fontSize: 14.0,
                          color: Colors.white54,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final answer = controller.mathAnswerController.text;
                        if (controller.verifyParentGate(answer)) {
                          controller.executeWipe();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                      ),
                      child: Text(
                        "Wipe & Reset 🔄",
                        style: AppTextStyles.bodySmallBold.copyWith(
                          fontSize: 14.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierColor: Colors.black87,
      useSafeArea: true,
    );
  }
}
