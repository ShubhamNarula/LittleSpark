import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// A full-screen celebration overlay with raining emojis and rotating praise text.
/// Use: showCelebration(context) or overlay it manually.
class CelebrationOverlay extends StatefulWidget {
  final VoidCallback? onComplete;
  final int durationMs;

  const CelebrationOverlay({
    Key? key,
    this.onComplete,
    this.durationMs = 2800,
  }) : super(key: key);

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _rainController;
  final _rand = Random();

  static const _emojis = ['🌟', '⭐', '🎉', '🎊', '🏆', '💎', '🪙', '🎈', '✨', '🔥', '💫', '🌈'];
  static const _praises = ['AMAZING!', 'SUPERSTAR!', 'GENIUS!', 'FANTASTIC!', 'WOW!', 'BRILLIANT!'];

  late final List<_FallingEmoji> _particles;
  late final String _praiseText;

  @override
  void initState() {
    super.initState();
    _praiseText = _praises[_rand.nextInt(_praises.length)];

    _particles = List.generate(35, (_) {
      return _FallingEmoji(
        emoji: _emojis[_rand.nextInt(_emojis.length)],
        x: _rand.nextDouble(),
        delay: _rand.nextDouble() * 0.6,
        speed: 0.3 + _rand.nextDouble() * 0.7,
        size: 20.0 + _rand.nextDouble() * 24.0,
        rotation: _rand.nextDouble() * 2 * pi,
      );
    });

    _rainController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.durationMs),
    )..forward();

    _rainController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _rainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return IgnorePointer(
      child: SizedBox.expand(
        child: Stack(
          children: [
            // Raining emoji particles
            ..._particles.map((p) {
              return AnimatedBuilder(
                animation: _rainController,
                builder: (ctx, _) {
                  final progress = ((_rainController.value - p.delay) / p.speed).clamp(0.0, 1.0);
                  final yPos = -50.0 + progress * (size.height + 100);
                  final opacity = progress < 0.1
                      ? progress / 0.1
                      : progress > 0.85
                          ? (1.0 - progress) / 0.15
                          : 1.0;

                  return Positioned(
                    left: p.x * size.width,
                    top: yPos,
                    child: Opacity(
                      opacity: opacity.clamp(0.0, 1.0),
                      child: Transform.rotate(
                        angle: p.rotation + progress * 3.0,
                        child: Text(
                          p.emoji,
                          style: TextStyle(fontSize: p.size),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),

            // Center praise text
            Center(
              child: Text(
                _praiseText,
                style: AppTextStyles.displayLarge.copyWith(
                  fontSize: 56.0,
                  color: AppColors.gold,
                  shadows: [
                    Shadow(
                      color: AppColors.gold.withOpacity(0.6),
                      blurRadius: 30,
                    ),
                    const Shadow(
                      color: Colors.black45,
                      blurRadius: 8,
                      offset: Offset(2, 4),
                    ),
                  ],
                ),
              )
                  .animate()
                  .scale(
                    begin: const Offset(0.0, 0.0),
                    end: const Offset(1.0, 1.0),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.elasticOut,
                  )
                  .then(delay: const Duration(milliseconds: 1500))
                  .fadeOut(duration: const Duration(milliseconds: 600)),
            ),
          ],
        ),
      ),
    );
  }
}

class _FallingEmoji {
  final String emoji;
  final double x;
  final double delay;
  final double speed;
  final double size;
  final double rotation;

  _FallingEmoji({
    required this.emoji,
    required this.x,
    required this.delay,
    required this.speed,
    required this.size,
    required this.rotation,
  });
}

/// Helper to show celebration as a full-screen overlay dialog.
void showCelebration(BuildContext context, {VoidCallback? onComplete}) {
  final overlay = OverlayEntry(
    builder: (_) => CelebrationOverlay(
      onComplete: () {
        onComplete?.call();
      },
    ),
  );

  Overlay.of(context).insert(overlay);

  Future.delayed(const Duration(milliseconds: 3000), () {
    overlay.remove();
  });
}
