import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../services/audio_service.dart';
import '../../../core/utils/haptic_util.dart';

class SlicingEmojiWidget extends StatefulWidget {
  final String emoji;
  final double size;

  const SlicingEmojiWidget({
    Key? key,
    required this.emoji,
    this.size = 110.0,
  }) : super(key: key);

  @override
  State<SlicingEmojiWidget> createState() => _SlicingEmojiWidgetState();
}

class _SlicingEmojiWidgetState extends State<SlicingEmojiWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isSliced = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuad,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _triggerSlice() {
    if (_isSliced) return;
    HapticUtil.medium();
    AudioService.to.playTap(); // Plays slice.mp3

    setState(() {
      _isSliced = true;
    });

    _controller.forward().then((_) {
      // Hold for 1.2s then reset
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) {
          _controller.reverse().then((_) {
            setState(() {
              _isSliced = false;
            });
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _triggerSlice,
      onPanStart: (_) => _triggerSlice(),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Slice Effect container containing the halves
          SizedBox(
            width: widget.size * 2,
            height: widget.size * 2,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                final double t = _animation.value;
                
                // Translations & Rotations
                final double leftX = -25.0 * t;
                final double leftY = 40.0 * t;
                final double leftRot = -0.25 * t;

                final double rightX = 25.0 * t;
                final double rightY = 45.0 * t;
                final double rightRot = 0.25 * t;

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Left half
                    Transform.translate(
                      offset: Offset(leftX, leftY),
                      child: Transform.rotate(
                        angle: leftRot,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          widthFactor: 0.5,
                          child: Text(
                            widget.emoji,
                            style: TextStyle(fontSize: widget.size),
                          ),
                        ),
                      ),
                    ),
                    
                    // Right half
                    Transform.translate(
                      offset: Offset(rightX, rightY),
                      child: Transform.rotate(
                        angle: rightRot,
                        child: Align(
                          alignment: Alignment.centerRight,
                          widthFactor: 0.5,
                          child: Text(
                            widget.emoji,
                            style: TextStyle(fontSize: widget.size),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          
          // Diagonal slice visual flash overlay (swipe trail)
          if (_isSliced)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  final double progress = _animation.value;
                  if (progress > 0.4) return const SizedBox.shrink();

                  return CustomPaint(
                    painter: SliceSlashPainter(progress: progress),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class SliceSlashPainter extends CustomPainter {
  final double progress;

  SliceSlashPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white.withOpacity(1.0 - (progress * 2.5).clamp(0.0, 1.0))
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Line from top-right to bottom-left
    final start = Offset(size.width * 0.8, size.height * 0.2);
    final end = Offset(size.width * 0.2, size.height * 0.8);

    // Interpolate points based on progress
    final double currentLen = progress / 0.4;
    final currentEnd = Offset(
      start.dx + (end.dx - start.dx) * currentLen.clamp(0.0, 1.0),
      start.dy + (end.dy - start.dy) * currentLen.clamp(0.0, 1.0),
    );

    canvas.drawLine(start, currentEnd, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
