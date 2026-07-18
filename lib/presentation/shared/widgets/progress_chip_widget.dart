import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class ProgressChipWidget extends StatelessWidget {
  final int done;
  final int total;

  const ProgressChipWidget({
    Key? key,
    required this.done,
    required this.total,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double percentage = total > 0 ? (done / total).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Text count (Nunito Bold, size 14sp to obey minimum)
          Text(
            "$done/$total",
            style: AppTextStyles.bodySmallBold.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 4.0),
          
          // Small Progress Indicator
          SizedBox(
            width: 32.0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2.0),
              child: LinearProgressIndicator(
                value: percentage,
                minHeight: 3.0,
                backgroundColor: Colors.white.withOpacity(0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
