import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_routes.dart';
import '../alphabet_find_controller.dart';

class StageCardWidget extends StatelessWidget {
  final int stageId;
  final AlphabetFindController controller;

  const StageCardWidget({
    Key? key,
    required this.stageId,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stage = AlphabetFindController.stages[stageId - 1];
    
    return Obx(() {
      final isUnlocked = controller.isStageUnlocked(stageId);
      final isCompleted = controller.isStageCompleted(stageId);
      final progress = controller.stageProgress(stageId);

      if (!isUnlocked) {
        return _buildLockedState(stage);
      } else if (isCompleted) {
        return _buildCompletedState(stage);
      } else {
        return _buildUnlockedState(stage, progress);
      }
    });
  }

  Widget _buildLockedState(Map<String, dynamic> stage) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4B5563), Color(0xFF374151)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(color: Colors.white.withOpacity(0.05), width: 1.5),
      ),
      child: Opacity(
        opacity: 0.7,
        child: Row(
          children: [
            const Icon(
              Icons.lock_outline_rounded,
              color: AppColors.white40,
              size: 32.0,
            ),
            const SizedBox(width: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stage['label'] as String,
                  style: const TextStyle(
                    fontFamily: 'FredokaOne',
                    fontSize: 20.0,
                    fontWeight: FontWeight.normal,
                    color: AppColors.white60,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  "Complete Stage ${stageId - 1} first!",
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.white40,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedState(Map<String, dynamic> stage) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF22C55E), Color(0xFF15803D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF22C55E).withOpacity(0.3),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
      ),
      child: Row(
        children: [
          const Text(
            "✅",
            style: TextStyle(fontSize: 36.0),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: const Duration(seconds: 1))
              .shimmer(delay: const Duration(seconds: 2), duration: const Duration(milliseconds: 1500)),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stage['label'] as String,
                  style: const TextStyle(
                    fontFamily: 'FredokaOne',
                    fontSize: 22.0,
                    fontWeight: FontWeight.normal,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  stage['subtitle'] as String,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  "All done! ⭐",
                  style: AppTextStyles.bodySmallBold.copyWith(
                    color: AppColors.gold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8.0),
          SizedBox(
            width: 80.0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4.0),
              child: const LinearProgressIndicator(
                value: 1.0,
                backgroundColor: Colors.white24,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
                minHeight: 6.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnlockedState(Map<String, dynamic> stage, double progress) {
    return GestureDetector(
      onTap: () {
        controller.startStage(stageId);
        Get.toNamed(AppRoutes.alphabetFindGame);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: AppColors.alphabetGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24.0),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF6B6B).withOpacity(0.4),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
        ),
        child: Row(
          children: [
            Text(
              stage['emoji'] as String,
              style: const TextStyle(fontSize: 36.0),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveY(begin: 0.0, end: -4.0, duration: const Duration(milliseconds: 1500), curve: Curves.easeInOut),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stage['label'] as String,
                    style: const TextStyle(
                      fontFamily: 'FredokaOne',
                      fontSize: 22.0,
                      fontWeight: FontWeight.normal,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    stage['subtitle'] as String,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4.0),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
                      minHeight: 6.0,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    "${(progress * 100).toInt()}% done",
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8.0),
            Container(
              padding: const EdgeInsets.all(4.0),
              decoration: const BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 28.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
