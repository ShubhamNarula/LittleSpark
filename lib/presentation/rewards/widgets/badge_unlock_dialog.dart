import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import '../../../data/datasources/badges_data.dart';
import '../../../data/models/badge_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/haptic_util.dart';

class BadgeUnlockDialog extends StatefulWidget {
  final String badgeId;
  const BadgeUnlockDialog({Key? key, required this.badgeId}) : super(key: key);

  @override
  State<BadgeUnlockDialog> createState() => _BadgeUnlockDialogState();
}

class _BadgeUnlockDialogState extends State<BadgeUnlockDialog> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final badge = BadgesData.badges.firstWhere(
      (b) => b.id == widget.badgeId,
      orElse: () => BadgesData.badges.first,
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        // Dialog Card
        Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24.0),
              padding: const EdgeInsets.all(28.0),
              decoration: BoxDecoration(
                color: AppColors.bgMid,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppColors.gold, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withOpacity(0.3),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Celebration Header
                  Text(
                    "CONGRATULATIONS! 🎉",
                    style: AppTextStyles.bodyExtraLarge.copyWith(color: AppColors.gold),
                    textAlign: centerTextIfAvailable,
                  ),
                  const SizedBox(height: 20),

                  // Badge Emoji
                  Text(
                    badge.emoji,
                    style: const TextStyle(fontSize: 84.0),
                  )
                      .animate()
                      .scale(
                        begin: const Offset(0.3, 0.3),
                        end: const Offset(1.0, 1.0),
                        duration: 600.ms,
                        curve: Curves.elasticOut,
                      )
                      .then()
                      .shake(duration: 500.ms),

                  const SizedBox(height: 20),

                  // Badge Name
                  Text(
                    badge.name,
                    style: AppTextStyles.displaySmall.copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  // Badge Description
                  Text(
                    badge.description,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),

                  // Got it Button
                  GestureDetector(
                    onTap: () {
                      HapticUtil.light();
                      Get.back();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: badge.gradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        "Awesome! 🌟",
                        style: AppTextStyles.displayButton.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Confetti Overlay
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              AppColors.gold,
              AppColors.coral,
              AppColors.mint,
              AppColors.lavender,
              AppColors.skyBlue
            ],
          ),
        ),
      ],
    );
  }

  TextAlign? get centerTextIfAvailable => TextAlign.center;
}
