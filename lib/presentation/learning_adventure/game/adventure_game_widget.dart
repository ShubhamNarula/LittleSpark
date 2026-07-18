import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import '../controllers/adventure_controller.dart';
import '../models/adventure_world_model.dart';
import 'game_painter.dart';

class AdventureGameWidget extends StatefulWidget {
  final AdventureWorld world;

  const AdventureGameWidget({Key? key, required this.world}) : super(key: key);

  @override
  State<AdventureGameWidget> createState() => _AdventureGameWidgetState();
}

class _AdventureGameWidgetState extends State<AdventureGameWidget>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final AdventureController _controller = Get.find<AdventureController>();

  double _lastTime = 0.0;
  double _animTick = 0.0;

  // Swipe and Tap detection
  Offset? _swipeStart;
  static const double _swipeThreshold = 40.0; // 40 logical pixels drag distance to trigger swipe

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    final seconds = elapsed.inMicroseconds / 1e6;
    final dt = (seconds - _lastTime).clamp(0.0, 0.05); // cap at 50ms
    _lastTime = seconds;
    _animTick = seconds;

    _controller.tick(dt);

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  // ── Gestures ──────────────────────────────────────────────────
  void _onPanStart(DragStartDetails d) {
    _swipeStart = d.globalPosition;
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (_swipeStart == null) return;

    final currentPos = d.globalPosition;
    final dx = currentPos.dx - _swipeStart!.dx;
    final dy = currentPos.dy - _swipeStart!.dy;

    // Trigger swipe as soon as displacement exceeds the threshold
    if (dx.abs() > _swipeThreshold || dy.abs() > _swipeThreshold) {
      if (dx.abs() > dy.abs()) {
        // Horizontal swipe
        if (dx < 0) {
          _controller.onSwipeLeft();
        } else {
          _controller.onSwipeRight();
        }
      } else {
        // Vertical swipe
        if (dy < 0) {
          _controller.onSwipeUp();
        } else {
          _controller.onSwipeDown();
        }
      }
      // Reset swipe start so we don't trigger multiple times in one swipe drag
      _swipeStart = null;
    }
  }

  void _onTapUp(TapUpDetails d) {
    final width = MediaQuery.of(context).size.width;
    final localX = d.localPosition.dx;

    // Tapping left side moves left, tapping right side moves right, tapping center jumps
    if (localX < width * 0.35) {
      _controller.onSwipeLeft();
    } else if (localX > width * 0.65) {
      _controller.onSwipeRight();
    } else {
      _controller.onSwipeUp();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onTapUp: _onTapUp,
      behavior: HitTestBehavior.opaque,
      child: SizedBox.expand(
        child: CustomPaint(
          painter: GamePainter(
            controller: _controller,
            world: widget.world,
            animTick: _animTick,
          ),
        ),
      ),
    );
  }
}
