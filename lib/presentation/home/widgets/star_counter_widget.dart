import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class StarCounterWidget extends StatelessWidget {
  final RxInt stars;

  const StarCounterWidget({
    Key? key,
    required this.stars,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: AppColors.gold.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: AppColors.gold.withOpacity(0.3),
          width: 2.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "⭐",
            style: TextStyle(fontSize: 18.0),
          )
              .animate(onPlay: (c) => c.repeat())
              .shimmer(duration: const Duration(seconds: 2)),
          const SizedBox(width: 6.0),
          Obx(() => Text(
                "${stars.value}",
                style: AppTextStyles.bodyLargeBold.copyWith(
                  fontFamily: 'FredokaOne',
                  color: AppColors.gold,
                  fontSize: 18.0,
                ),
              )),
        ],
      ),
    );
  }
}
