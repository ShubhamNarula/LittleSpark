import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/haptic_util.dart';
import '../../../services/audio_service.dart';
import '../../../services/progress_service.dart';
import '../home_controller.dart';

class ModuleCardWidget extends StatelessWidget {
  final ModuleInfo module;

  const ModuleCardWidget({
    Key? key,
    required this.module,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isNew = module.progress < 0.1;

    return GestureDetector(
      onTap: () {
        HapticUtil.light();
        AudioService.to.playTap();
        Get.toNamed(module.route);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: module.colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24.0),
          boxShadow: [
            BoxShadow(
              color: module.colors[0].withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Main content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Bouncing Emoji icon
                  Text(
                    module.emoji,
                    style: const TextStyle(fontSize: 48.0),
                  )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .moveY(
                        begin: 0.0,
                        end: -4.0,
                        duration: const Duration(seconds: 2),
                        curve: Curves.easeInOut,
                      ),
                  const SizedBox(height: 8.0),
                  
                  // Module Name
                  Text(
                    module.name,
                    style: AppTextStyles.bodyMediumBold.copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8.0),
                  
                  // Progress Indicator
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4.0),
                    child: LinearProgressIndicator(
                      value: module.progress,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
                      minHeight: 5.0,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  
                  // Progress Text (minimum 14sp to follow typography guideline)
                  Text(
                    "${(module.progress * 100).toInt()}% done",
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),

            // "NEW" shimmer badge for modules with < 10% progress
            if (isNew)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withOpacity(0.5),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Text(
                    "NEW",
                    style: AppTextStyles.bodySmallBold.copyWith(
                      color: AppColors.bgDark,
                      fontSize: 10,
                      letterSpacing: 1.0,
                    ),
                  ),
                )
                    .animate(onPlay: (c) => c.repeat())
                    .shimmer(duration: const Duration(seconds: 2), color: Colors.white.withOpacity(0.5)),
              ),
          ],
        ),
      ),
    );
  }
}
