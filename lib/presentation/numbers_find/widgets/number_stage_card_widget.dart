import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_routes.dart';
import '../numbers_find_controller.dart';

class NumberStageCardWidget extends StatelessWidget {
  final int stageId;
  final NumbersFindController controller;

  const NumberStageCardWidget({
    Key? key,
    required this.stageId,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stage = NumbersFindController.stages[stageId - 1];

    return Obx(() {
      final isUnlocked = controller.isStageUnlocked(stageId);
      final isCompleted = controller.isStageCompleted(stageId);
      final progress = controller.stageProgress(stageId);

      return GestureDetector(
        onTap: () {
          if (!isUnlocked) {
            controller.startStage(stageId); // will trigger locked snackbar internally
          } else {
            controller.startStage(stageId);
            Get.toNamed(AppRoutes.numbersFindGame);
          }
        },
        child: Container(
          height: 80.0,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          decoration: _buildDecoration(isUnlocked, isCompleted, stage),
          child: Row(
            children: [
              _buildLeadingWidget(isUnlocked, isCompleted, stage),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stage['label'] as String,
                      style: const TextStyle(
                        fontFamily: 'FredokaOne',
                        fontSize: 18.0,
                        fontWeight: FontWeight.normal,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      isUnlocked
                          ? (isCompleted ? "All done! ⭐" : stage['subtitle'] as String)
                          : "Finish Stage ${stageId - 1} first!",
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 14.0,
                        color: isUnlocked
                            ? (isCompleted ? AppColors.gold : Colors.white.withOpacity(0.8))
                            : Colors.white.withOpacity(0.5),
                        fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8.0),
              if (isUnlocked) _buildProgressAndAction(isCompleted, progress),
            ],
          ),
        ),
      );
    });
  }

  BoxDecoration _buildDecoration(bool isUnlocked, bool isCompleted, Map<String, dynamic> stage) {
    if (!isUnlocked) {
      return BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4B5563), Color(0xFF374151)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: Colors.white.withOpacity(0.05), width: 1.5),
      );
    } else if (isCompleted) {
      return BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF22C55E), Color(0xFF15803D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF22C55E).withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
      );
    } else {
      final baseColor = Color(stage['color'] as int);
      return BoxDecoration(
        gradient: LinearGradient(
          colors: [baseColor, baseColor.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: baseColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
      );
    }
  }

  Widget _buildLeadingWidget(bool isUnlocked, bool isCompleted, Map<String, dynamic> stage) {
    if (!isUnlocked) {
      return const Icon(
        Icons.lock_outline_rounded,
        color: AppColors.white40,
        size: 28.0,
      );
    } else if (isCompleted) {
      return const Text(
        "✅",
        style: TextStyle(fontSize: 28.0),
      )
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: const Duration(seconds: 1));
    } else {
      return Text(
        stage['emoji'] as String,
        style: const TextStyle(fontSize: 28.0),
      )
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .moveY(begin: 0.0, end: -3.0, duration: const Duration(milliseconds: 1500), curve: Curves.easeInOut);
    }
  }

  Widget _buildProgressAndAction(bool isCompleted, double progress) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(
              width: 60.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3.0),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
                  minHeight: 5.0,
                ),
              ),
            ),
            const SizedBox(height: 2.0),
            Text(
              "${(progress * 100).toInt()}%",
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 12.0,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
        const SizedBox(width: 8.0),
        Container(
          padding: const EdgeInsets.all(3.0),
          decoration: const BoxDecoration(
            color: Colors.white24,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.play_arrow_rounded,
            color: Colors.white,
            size: 20.0,
          ),
        ),
      ],
    );
  }
}
