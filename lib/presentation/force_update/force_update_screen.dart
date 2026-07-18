import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../services/force_update_service.dart';

class ForceUpdateScreen extends StatelessWidget {
  final UpdateConfig config;

  const ForceUpdateScreen({
    Key? key,
    required this.config,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const backgroundStars = ['⭐', '✨', '🪐', '💫', '☄️'];

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
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
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Floating/Rotating Magical Stars in Background
                ...List.generate(backgroundStars.length, (i) {
                  final random = Random(i);
                  final angle = random.nextDouble() * 2 * pi;
                  final radius = 100.0 + random.nextDouble() * 80.0;
                  final offsetX = cos(angle) * radius;
                  final offsetY = sin(angle) * radius;

                  return Positioned(
                    left: size.width / 2 + offsetX - 16,
                    top: size.height * 0.35 + offsetY - 16,
                    child: Text(
                      backgroundStars[i],
                      style: const TextStyle(fontSize: 24),
                    )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .scale(
                          begin: const Offset(0.7, 0.7),
                          end: const Offset(1.3, 1.3),
                          duration: Duration(milliseconds: 1500 + (i * 200)),
                          curve: Curves.easeInOut,
                        )
                        .rotate(
                          begin: 0,
                          end: 0.15,
                          duration: Duration(milliseconds: 2000 + (i * 300)),
                        ),
                  );
                }),

                // Content Panel
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(flex: 3),

                      // Animated Rocket / Magic Spark Emoji
                      Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.white10,
                          border: Border.all(
                            color: AppColors.gold.withOpacity(0.3),
                            width: 2.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.gold.withOpacity(0.15),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            "🚀",
                            style: TextStyle(fontSize: 64.0),
                          ),
                        ),
                      )
                          .animate()
                          .scale(
                            begin: const Offset(0.0, 0.0),
                            end: const Offset(1.0, 1.0),
                            duration: 700.ms,
                            curve: Curves.elasticOut,
                          )
                          .then()
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .slideY(
                            begin: 0.0,
                            end: -0.12,
                            duration: 1200.ms,
                            curve: Curves.easeInOut,
                          ),

                      const SizedBox(height: 36.0),

                      // Title
                      Text(
                        "Time to Update!",
                        textAlign: TextAlign.center,
                        style: AppTextStyles.displayMedium.copyWith(
                          color: AppColors.gold,
                          shadows: [
                            Shadow(
                              color: AppColors.gold.withOpacity(0.3),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 200.ms, duration: 400.ms)
                          .slideY(begin: 0.2, end: 0.0, duration: 400.ms),

                      const SizedBox(height: 16.0),

                      // Card explaining the update details
                      Container(
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20.0),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          config.updateMessage.isNotEmpty
                              ? config.updateMessage
                              : "We have loaded new updates and features for your adventure! Please update your app to the latest version to keep learning and playing.",
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            height: 1.5,
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 450.ms, duration: 500.ms)
                          .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.0, 1.0), duration: 500.ms),

                      const Spacer(flex: 2),

                      // Call-to-action Action Button
                      SizedBox(
                        width: double.infinity,
                        height: 60.0,
                        child: ElevatedButton(
                          onPressed: () => ForceUpdateService.launchStore(config),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.coral,
                            foregroundColor: Colors.white,
                            elevation: 8,
                            shadowColor: AppColors.coral.withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                          child: Text(
                            "Update Now",
                            style: AppTextStyles.displayButton.copyWith(
                              fontSize: 22.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .scale(
                            begin: const Offset(1.0, 1.0),
                            end: const Offset(1.03, 1.03),
                            duration: 1000.ms,
                            curve: Curves.easeInOut,
                          ),

                      const SizedBox(height: 32.0),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
