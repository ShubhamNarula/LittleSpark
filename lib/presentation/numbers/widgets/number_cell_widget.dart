import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class NumberCellWidget extends StatelessWidget {
  final int number;
  final Color colorBand;
  final bool isVisited;
  final bool isHighlighted;
  final VoidCallback onTap;

  const NumberCellWidget({
    Key? key,
    required this.number,
    required this.colorBand,
    required this.isVisited,
    required this.isHighlighted,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine cell background color
    final Color cellColor = isHighlighted
        ? AppColors.gold
        : (isVisited ? colorBand.withOpacity(0.9) : colorBand.withOpacity(0.35));

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: cellColor,
          borderRadius: BorderRadius.circular(8.0),
          border: isVisited
              ? Border.all(color: AppColors.gold.withOpacity(0.7), width: 1.5)
              : Border.all(color: Colors.white.withOpacity(0.08), width: 1.0),
          boxShadow: isHighlighted
              ? [
                  BoxShadow(
                    color: AppColors.gold.withOpacity(0.6),
                    blurRadius: 10,
                    spreadRadius: 1.0,
                  )
                ]
              : null,
        ),
        child: Center(
          child: Text(
            "$number",
            style: AppTextStyles.bodySmallBold.copyWith(
              fontSize: 14.0, // Minimum 14sp restriction
              color: isHighlighted ? AppColors.bgDark : Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      )
          .animate(target: isHighlighted ? 1.0 : 0.0)
          .scale(
            begin: const Offset(1.0, 1.0),
            end: const Offset(1.25, 1.25),
            duration: 200.ms,
            curve: Curves.easeInOut,
          ),
    );
  }
}
