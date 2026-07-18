import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_routes.dart';
import '../../services/force_update_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    // Background music disabled — no auto-play

    // Start fetching the remote config in parallel with splash animation
    final checkUpdateFuture = ForceUpdateService.getUpdateConfig();
    final delayFuture = Future.delayed(const Duration(milliseconds: 3000));

    // Wait for both the delay (to let animations finish) and the update check
    final results = await Future.wait([checkUpdateFuture, delayFuture]);
    final config = results[0] as UpdateConfig;

    final isRequired = await ForceUpdateService.isUpdateRequired(config);

    if (isRequired) {
      Get.offAllNamed(AppRoutes.forceUpdate, arguments: config);
    } else {
      Get.offAllNamed(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const orbitEmojis = ['🎈', '🦋', '🌈', '⭐', '🎵', '🚀', '🎨', '📚'];

    return Scaffold(
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
              // Orbiting emoji parade
              ...List.generate(orbitEmojis.length, (i) {
                final angle = (i / orbitEmojis.length) * 2 * pi;
                final radius = 120.0;
                final offsetX = cos(angle) * radius;
                final offsetY = sin(angle) * radius;

                return Positioned(
                  left: size.width / 2 + offsetX - 16,
                  top: size.height * 0.32 + offsetY - 16,
                  child: Text(
                    orbitEmojis[i],
                    style: const TextStyle(fontSize: 28),
                  )
                      .animate(delay: Duration(milliseconds: i * 200))
                      .fadeIn(duration: const Duration(milliseconds: 400))
                      .then()
                      .animate(onPlay: (c) => c.repeat())
                      .rotate(
                        duration: Duration(seconds: 8 + i),
                        begin: 0,
                        end: 1,
                      ),
                );
              }),

              // Main content column
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  
                  // Animated Emoji "✨"
                  const Text(
                    "✨",
                    style: TextStyle(fontSize: 80.0),
                  )
                      .animate()
                      .scale(
                        begin: const Offset(0.0, 0.0),
                        end: const Offset(1.0, 1.0),
                        duration: 600.ms,
                        curve: Curves.elasticOut,
                      )
                      .then()
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scale(
                        begin: const Offset(1.0, 1.0),
                        end: const Offset(1.2, 1.2),
                        duration: 1200.ms,
                        curve: Curves.easeInOut,
                      ),
                  
                  const SizedBox(height: 16.0),
                  
                  // Main Title "LittleSpark"
                  Text(
                    "LittleSpark",
                    style: AppTextStyles.displayLarge.copyWith(
                      color: AppColors.gold,
                      fontSize: 52.0,
                      shadows: [
                        Shadow(
                          color: AppColors.gold.withOpacity(0.4),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 500.ms)
                      .slideY(begin: 0.3, end: 0.0, duration: 500.ms),
                  
                  const SizedBox(height: 8.0),
                  
                  // Tagline "Learn. Play. Grow!"
                  Text(
                    "Learn. Play. Grow!",
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: Colors.white.withOpacity(0.7),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 800.ms, duration: 400.ms),
                  
                  const Spacer(),
                  
                  // Custom Colored Progress Indicator
                  SizedBox(
                    width: 28.0,
                    height: 28.0,
                    child: const CircularProgressIndicator(
                      strokeWidth: 3.0,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
                    )
                        .animate()
                        .fadeIn(delay: 1000.ms, duration: 300.ms),
                  ),
                  const SizedBox(height: 48.0),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
