import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../data/models/number_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../services/tts_service.dart';
import '../../../core/utils/haptic_util.dart';

class NumberDetailOverlay extends StatelessWidget {
  final NumberModel number;

  const NumberDetailOverlay({
    Key? key,
    required this.number,
  }) : super(key: key);

  Color _getColorBand(int val) {
    if (val <= 10) return const Color(0xFF60A5FA); // blue
    if (val <= 20) return const Color(0xFF22C55E); // green
    if (val <= 30) return const Color(0xFFC084FC); // purple
    if (val <= 40) return const Color(0xFFFB923C); // orange
    if (val <= 50) return const Color(0xFFFF69B4); // pink
    if (val <= 60) return const Color(0xFF4ECDC4); // teal
    if (val <= 70) return const Color(0xFFFF6B6B); // red
    if (val <= 80) return const Color(0xFF84CC16); // lime
    if (val <= 90) return const Color(0xFF818CF8); // indigo
    return const Color(0xFFFFD700); // gold
  }

  Widget _buildGroupedDots(int val) {
    final int tens = val ~/ 10;
    final int ones = val % 10;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Group of tens represented as 10-dot bars
        if (tens > 0)
          Wrap(
            spacing: 6.0,
            runSpacing: 6.0,
            alignment: WrapAlignment.center,
            children: List.generate(tens, (i) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Colors.white.withOpacity(0.15)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("🟡", style: TextStyle(fontSize: 12.0)),
                    const SizedBox(width: 2.0),
                    Text(
                      "x10",
                      style: AppTextStyles.bodySmallBold.copyWith(
                        fontSize: 14.0, // Enforce minimum 14sp
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              )
                  .animate(delay: (i * 50).ms)
                  .scale(duration: 300.ms, curve: Curves.easeOutBack);
            }),
          ),
        
        if (ones > 0) ...[
          const SizedBox(height: 12.0),
          // Remaining single dots
          Wrap(
            spacing: 6.0,
            runSpacing: 6.0,
            alignment: WrapAlignment.center,
            children: List.generate(ones, (i) {
              return const Text("🟡", style: TextStyle(fontSize: 14.0))
                  .animate(delay: (i * 30).ms)
                  .scale(duration: 200.ms);
            }),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorBand = _getColorBand(number.number);

    return Center(
      child: Container(
        margin: const EdgeInsets.all(28.0),
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: AppColors.bgMid,
          borderRadius: BorderRadius.circular(28.0),
          border: Border.all(color: colorBand.withOpacity(0.5), width: 2.0),
          boxShadow: [
            BoxShadow(
              color: colorBand.withOpacity(0.2),
              blurRadius: 16,
              spreadRadius: 2.0,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Huge animated number display
              Text(
                "${number.number}",
                style: AppTextStyles.displayLarge.copyWith(
                  fontSize: 88.0,
                  color: colorBand,
                ),
              )
                  .animate()
                  .scale(
                    begin: const Offset(0.3, 0.3),
                    end: const Offset(1.0, 1.0),
                    duration: 500.ms,
                    curve: Curves.elasticOut,
                  ),
              const SizedBox(height: 4.0),

              // Bubbly number word text
              Text(
                number.word,
                style: AppTextStyles.displaySmall.copyWith(
                  color: Colors.white,
                  fontSize: 28.0,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16.0),

              // Visual Dot Representations
              if (number.number <= 20)
                Wrap(
                  spacing: 6.0,
                  runSpacing: 6.0,
                  alignment: WrapAlignment.center,
                  children: List.generate(number.number, (i) {
                    return const Text("🟡", style: TextStyle(fontSize: 14.0))
                        .animate(delay: (i * 40).ms)
                        .scale(duration: 250.ms, curve: Curves.easeOutBack);
                  }),
                )
              else
                _buildGroupedDots(number.number),
              
              const SizedBox(height: 20.0),

              // Facts container
              Container(
                padding: const EdgeInsets.all(14.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Text(
                  number.funFact,
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24.0),

              // Options Row buttons
              Row(
                children: [
                  // Hear pronunciation
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticUtil.light();
                        TtsService.to.speak(number.word);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        decoration: BoxDecoration(
                          color: AppColors.coral,
                          borderRadius: BorderRadius.circular(12.0),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.coral.withOpacity(0.3),
                              blurRadius: 8.0,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            "🔊 Hear it!",
                            style: AppTextStyles.bodySmallBold.copyWith(
                              fontSize: 14.0, // Enforce 14sp minimum
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  
                  // Dismiss
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticUtil.light();
                        Get.back();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Center(
                          child: Text(
                            "✓ Got it!",
                            style: AppTextStyles.bodySmallBold.copyWith(
                              fontSize: 14.0, // Enforce 14sp minimum
                              color: Colors.white,
                            ),
                          ),
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
    );
  }
}
