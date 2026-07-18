import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';

class FloatingParticlesWidget extends StatelessWidget {
  const FloatingParticlesWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final random = Random(42); // Fixed seed for consistent layout

    // Particle types for variety
    const particleEmojis = ['✨', '⭐', '💫', '♥️', '🎵', '🌟'];

    return IgnorePointer(
      child: Stack(
        children: [
          // Dot particles (original style, more of them)
          ...List.generate(24, (index) {
            final double left = random.nextDouble() * size.width;
            final double startY = size.height + (random.nextDouble() * 300);
            final double particleSize = 3.0 + (random.nextDouble() * 7.0);
            
            // Different "depth" layers: farther = smaller, slower, dimmer
            final int layer = index % 3; // 0=far, 1=mid, 2=near
            final double opacity = [0.05, 0.1, 0.18][layer];
            final int speedMultiplier = [8, 5, 3][layer];
            
            final List<Color> layerColors = [
              AppColors.gold,
              AppColors.lavender,
              AppColors.mint,
              AppColors.skyBlue,
              AppColors.coral,
              Colors.white,
            ];
            final Color color = layerColors[index % layerColors.length].withOpacity(opacity);
            
            final int durationSecs = speedMultiplier + random.nextInt(4);

            return Positioned(
              left: left,
              top: startY,
              child: Container(
                width: particleSize * [0.6, 0.8, 1.0][layer],
                height: particleSize * [0.6, 0.8, 1.0][layer],
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: layer == 2
                      ? [BoxShadow(color: color, blurRadius: 4)]
                      : null,
                ),
              )
                  .animate(onPlay: (c) => c.repeat())
                  .moveY(
                    begin: 0.0,
                    end: -startY - 50,
                    duration: Duration(seconds: durationSecs),
                    curve: Curves.easeInOut,
                  )
                  .fadeIn(duration: 500.ms)
                  .then(delay: Duration(milliseconds: (durationSecs * 800).toInt()))
                  .fadeOut(duration: 500.ms),
            );
          }),

          // Tiny emoji particles (subtle, drifting)
          ...List.generate(6, (index) {
            final double left = 20 + random.nextDouble() * (size.width - 40);
            final double startY = size.height * 0.3 + random.nextDouble() * size.height * 0.5;
            final int durationSecs = 6 + random.nextInt(6);
            final emoji = particleEmojis[index % particleEmojis.length];

            return Positioned(
              left: left,
              top: startY,
              child: Text(
                emoji,
                style: TextStyle(fontSize: 12 + random.nextDouble() * 8, color: Colors.white10),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .moveY(
                    begin: 0,
                    end: -(20 + random.nextDouble() * 40),
                    duration: Duration(seconds: durationSecs),
                    curve: Curves.easeInOut,
                  )
                  .moveX(
                    begin: 0,
                    end: -10 + random.nextDouble() * 20,
                    duration: Duration(seconds: durationSecs + 1),
                    curve: Curves.easeInOut,
                  ),
            );
          }),
        ],
      ),
    );
  }
}
