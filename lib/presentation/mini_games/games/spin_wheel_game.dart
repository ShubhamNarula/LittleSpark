import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hive/hive.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/haptic_util.dart';
import '../../../services/progress_service.dart';
import '../../../services/audio_service.dart';
import '../../shared/widgets/celebration_overlay.dart';

/// A daily reward spin wheel that kids can spin once per day.
class SpinWheelGame extends StatefulWidget {
  const SpinWheelGame({Key? key}) : super(key: key);

  @override
  State<SpinWheelGame> createState() => _SpinWheelGameState();
}

class _SpinWheelGameState extends State<SpinWheelGame>
    with SingleTickerProviderStateMixin {
  final _rand = Random();
  final _progress = ProgressService.to;

  bool _isSpinning = false;
  bool _showResult = false;
  bool _alreadySpunToday = false;
  int _wonRewardIndex = 0;

  late AnimationController _spinController;
  double _currentRotation = 0;

  static const List<Map<String, dynamic>> _rewards = [
    {'emoji': '🪙', 'label': '10 Coins', 'coins': 10, 'xp': 0, 'color': Color(0xFFFFD700)},
    {'emoji': '⭐', 'label': '1 Star', 'coins': 0, 'xp': 15, 'color': Color(0xFF60A5FA)},
    {'emoji': '💎', 'label': '25 Coins', 'coins': 25, 'xp': 0, 'color': Color(0xFFC084FC)},
    {'emoji': '🔥', 'label': '20 XP', 'coins': 0, 'xp': 20, 'color': Color(0xFFFF6B6B)},
    {'emoji': '🌟', 'label': '2 Stars', 'coins': 0, 'xp': 30, 'color': Color(0xFF22C55E)},
    {'emoji': '🏆', 'label': '50 Coins!', 'coins': 50, 'xp': 10, 'color': Color(0xFFFB923C)},
    {'emoji': '🎁', 'label': '15 Coins', 'coins': 15, 'xp': 5, 'color': Color(0xFFF472B6)},
    {'emoji': '✨', 'label': '30 XP', 'coins': 5, 'xp': 30, 'color': Color(0xFF4ECDC4)},
  ];

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _spinController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _onSpinComplete();
      }
    });

    _checkIfAlreadySpun();
  }

  void _checkIfAlreadySpun() {
    try {
      final box = Hive.box('progress');
      final lastSpin = box.get('lastSpinDate', defaultValue: '') as String;
      final today = DateTime.now().toIso8601String().substring(0, 10);
      _alreadySpunToday = lastSpin == today;
    } catch (_) {}
    setState(() {});
  }

  void _spin() {
    if (_isSpinning || _alreadySpunToday) return;
    HapticUtil.medium();

    // Pick random reward
    _wonRewardIndex = _rand.nextInt(_rewards.length);
    _showResult = false;

    // Calculate target rotation (multiple full spins + land on segment)
    final segmentAngle = 2 * pi / _rewards.length;
    final targetSegment = _wonRewardIndex * segmentAngle;
    final fullSpins = 5 + _rand.nextInt(3); // 5 to 7 full spins
    final targetRotation = fullSpins * 2 * pi + (2 * pi - targetSegment);

    setState(() {
      _isSpinning = true;
    });

    _spinController.reset();
    _currentRotation = targetRotation;
    _spinController.forward();
  }

  void _onSpinComplete() {
    final reward = _rewards[_wonRewardIndex];
    final coinsWon = reward['coins'] as int;
    final xpWon = reward['xp'] as int;

    if (coinsWon > 0) _progress.addCoins(coinsWon);
    if (xpWon > 0) _progress.addXP(xpWon);
    if (reward['label'].toString().contains('Star')) {
      _progress.addStar();
      if (reward['label'].toString().contains('2')) _progress.addStar();
    }

    // Mark as spun today
    try {
      final box = Hive.box('progress');
      final today = DateTime.now().toIso8601String().substring(0, 10);
      box.put('lastSpinDate', today);
    } catch (_) {}

    setState(() {
      _isSpinning = false;
      _showResult = true;
      _alreadySpunToday = true;
    });

    HapticUtil.heavy();
    AudioService.to.playStar();

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) showCelebration(context);
    });
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white54),
                  ),
                  const Spacer(),
                  Text("Daily Spin 🎡",
                      style: AppTextStyles.displaySmall.copyWith(color: AppColors.gold, fontSize: 24)),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            const Spacer(),

            // Spin instruction
            if (!_showResult && !_alreadySpunToday)
              Text("Spin the wheel for free rewards!",
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70))
                  .animate()
                  .fadeIn(),

            if (_alreadySpunToday && !_showResult)
              Column(
                children: [
                  const Text("😴", style: TextStyle(fontSize: 60)),
                  const SizedBox(height: 12),
                  Text("Come back tomorrow!",
                      style: AppTextStyles.bodyLargeBold.copyWith(color: Colors.white54)),
                  Text("You already spun today.",
                      style: AppTextStyles.bodySmall.copyWith(color: Colors.white38)),
                ],
              ),

            const SizedBox(height: 24),

            // The Wheel
            SizedBox(
              width: 300,
              height: 300,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Wheel segments
                  AnimatedBuilder(
                    animation: _spinController,
                    builder: (ctx, child) {
                      final rotation = _isSpinning
                          ? Curves.easeOutCubic.transform(_spinController.value) * _currentRotation
                          : (_showResult ? _currentRotation : 0.0);

                      return Transform.rotate(
                        angle: rotation,
                        child: child,
                      );
                    },
                    child: CustomPaint(
                      size: const Size(280, 280),
                      painter: _WheelPainter(_rewards),
                    ),
                  ),

                  // Center button
                  GestureDetector(
                    onTap: _spin,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: _alreadySpunToday
                            ? LinearGradient(colors: [Colors.grey.shade700, Colors.grey.shade800])
                            : const LinearGradient(colors: [AppColors.gold, Color(0xFFF59E0B)]),
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: (_alreadySpunToday ? Colors.grey : AppColors.gold).withOpacity(0.4),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _alreadySpunToday ? "✓" : "SPIN",
                          style: AppTextStyles.bodyMediumBold.copyWith(
                            color: _alreadySpunToday ? Colors.white54 : AppColors.bgDark,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Pointer arrow at top
                  Positioned(
                    top: -6,
                    child: const Text("🔻", style: TextStyle(fontSize: 28)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Result
            if (_showResult)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: (_rewards[_wonRewardIndex]['color'] as Color).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: (_rewards[_wonRewardIndex]['color'] as Color).withOpacity(0.4),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Text("🎉 You Won!", style: AppTextStyles.bodyLargeBold.copyWith(color: AppColors.gold, fontSize: 20)),
                    const SizedBox(height: 12),
                    Text(_rewards[_wonRewardIndex]['emoji'] as String, style: const TextStyle(fontSize: 50)),
                    const SizedBox(height: 8),
                    Text(
                      _rewards[_wonRewardIndex]['label'] as String,
                      style: AppTextStyles.displaySmall.copyWith(
                        color: _rewards[_wonRewardIndex]['color'] as Color,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .scale(begin: const Offset(0.5, 0.5), duration: const Duration(milliseconds: 500), curve: Curves.elasticOut),

            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class _WheelPainter extends CustomPainter {
  final List<Map<String, dynamic>> rewards;

  _WheelPainter(this.rewards);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final segmentAngle = 2 * pi / rewards.length;

    for (int i = 0; i < rewards.length; i++) {
      final startAngle = i * segmentAngle - pi / 2;
      final paint = Paint()
        ..color = (rewards[i]['color'] as Color).withOpacity(0.7)
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        segmentAngle,
        true,
        paint,
      );

      // Draw segment border
      final borderPaint = Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        segmentAngle,
        true,
        borderPaint,
      );

      // Draw emoji text at the center of each segment
      final midAngle = startAngle + segmentAngle / 2;
      final textRadius = radius * 0.65;
      final textX = center.dx + cos(midAngle) * textRadius;
      final textY = center.dy + sin(midAngle) * textRadius;

      final textPainter = TextPainter(
        text: TextSpan(
          text: rewards[i]['emoji'] as String,
          style: const TextStyle(fontSize: 26),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(textX - textPainter.width / 2, textY - textPainter.height / 2));
    }

    // Outer ring
    final ringPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(center, radius, ringPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
