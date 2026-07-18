import 'dart:math';
import 'package:flutter/material.dart';
import '../controllers/adventure_controller.dart';
import '../models/adventure_world_model.dart';

class GamePainter extends CustomPainter {
  final AdventureController controller;
  final AdventureWorld world;
  final double animTick; // increases every frame for animations

  GamePainter({
    required this.controller,
    required this.world,
    required this.animTick,
  });

  // ─────────────────────────────────────────────────────────────────
  // PERSPECTIVE TRANSFORMATION UTILITIES
  // ─────────────────────────────────────────────────────────────────
  Offset getPerspectivePos(double laneIndex, double y, double w, double h) {
    final horizonY = h * 0.46; // horizon where lanes meet
    final bottomY = h * 0.95;  // bottom limit of the road/lanes
    final vanishingX = w / 2.0; // center vanishing point
    final bottomLaneSpacing = w * 0.32; // width of each lane at the bottom

    // Non-linear perspective vertical progress (objects accelerate as they get closer)
    final double progress = pow(y.clamp(0.0, 1.5), 1.6).toDouble();

    final double screenY = horizonY + (bottomY - horizonY) * progress;
    final double laneOffset = laneIndex - 1.0; // lane 0 -> -1.0, 1 -> 0.0, 2 -> 1.0
    final double screenX = vanishingX + laneOffset * bottomLaneSpacing * progress;

    return Offset(screenX, screenY);
  }

  double getPerspectiveScale(double y) {
    // scale ranges from 0.15 at the horizon to 1.0 at the bottom
    final double progress = pow(y.clamp(0.0, 1.5), 1.6).toDouble();
    return 0.12 + (1.0 - 0.12) * progress;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    _drawBackground(canvas, size);
    _drawGround(canvas, size);
    _drawLanes(canvas, size);
    _drawObstacles(canvas, size);
    _drawCollectibles(canvas, size);
    _drawPlayer(canvas, size);
    _drawFloatingTexts(canvas, size);
    _drawComboFlame(canvas, size);
  }

  // ─────────────────────────────────────────────────────────────────
  // BACKGROUND — 3-layer parallax
  // ─────────────────────────────────────────────────────────────────
  void _drawBackground(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final scroll = controller.bgScrollOffset.value;

    // Sky gradient
    final skyPaint = Paint()
      ..shader = LinearGradient(
        colors: world.skyColors,
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h * 0.46));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h * 0.46), skyPaint);

    // Far background layer — floating dots/stars
    final starPaint = Paint()..color = Colors.white.withOpacity(0.2);
    for (int i = 0; i < 20; i++) {
      final sx = (i * 53.0 + scroll * w * 0.1) % w;
      final sy = (i * 29.0) % (h * 0.4);
      canvas.drawCircle(Offset(sx, sy), 2.0, starPaint);
    }

    // Mid layer — trees/buildings scrolling in 3D perspective along sides
    _drawMidLayer(canvas, size, scroll);
  }

  void _drawMidLayer(Canvas canvas, Size size, double scroll) {
    final w = size.width;
    final h = size.height;

    // Draw 6 trees on each side of the road in 3D perspective
    for (int i = 0; i < 6; i++) {
      final double yProgress = ((i / 6.0) + scroll * 0.4) % 1.0;

      // Left side trees (outside left lane boundaries)
      final leftPos = getPerspectivePos(-0.7, yProgress, w, h);
      final leftScale = getPerspectiveScale(yProgress);
      _drawTree(canvas, leftPos, leftScale, true);

      // Right side trees (outside right lane boundaries)
      final rightPos = getPerspectivePos(2.7, yProgress, w, h);
      final rightScale = getPerspectiveScale(yProgress);
      _drawTree(canvas, rightPos, rightScale, false);
    }
  }

  void _drawTree(Canvas canvas, Offset pos, double scale, bool isLeft) {
    final treeH = (75.0 + (pos.dx.toInt() % 3) * 20.0) * scale;
    final treeW = (28.0 + (pos.dy.toInt() % 2) * 10.0) * scale;
    final baseX = pos.dx;
    final baseY = pos.dy;

    // Trunk
    final trunkPaint = Paint()..color = world.groundColors[0].withOpacity(0.7);
    canvas.drawRect(Rect.fromLTWH(baseX - 4 * scale, baseY - treeH * 0.25, 8 * scale, treeH * 0.25), trunkPaint);

    // Foliage
    final crownPaint = Paint()..color = world.groundColors[1].withOpacity(0.85);
    final path = Path()
      ..moveTo(baseX, baseY - treeH)
      ..lineTo(baseX - treeW, baseY - treeH * 0.2)
      ..lineTo(baseX + treeW, baseY - treeH * 0.2)
      ..close();
    canvas.drawPath(path, crownPaint);
  }

  // ─────────────────────────────────────────────────────────────────
  // GROUND
  // ─────────────────────────────────────────────────────────────────
  void _drawGround(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final horizonY = h * 0.46;

    // Ground fill
    final groundPaint = Paint()
      ..shader = LinearGradient(
        colors: [world.groundColors[0], world.groundColors[1].withOpacity(0.7)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, horizonY, w, h - horizonY));
    canvas.drawRect(Rect.fromLTWH(0, horizonY, w, h - horizonY), groundPaint);
  }

  // ─────────────────────────────────────────────────────────────────
  // 3D CONVERGING ROAD & LANES
  // ─────────────────────────────────────────────────────────────────
  void _drawLanes(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final horizonY = h * 0.46;
    final bottomY = h * 0.95;
    final vanishingX = w / 2.0;
    final bottomLaneSpacing = w * 0.32;

    // Road surface path (converges to vanishing point)
    final roadPath = Path()
      ..moveTo(vanishingX, horizonY)
      ..lineTo(vanishingX + 1.55 * bottomLaneSpacing, bottomY)
      ..lineTo(vanishingX - 1.55 * bottomLaneSpacing, bottomY)
      ..close();

    final roadPaint = Paint()..color = const Color(0xFF1E293B).withOpacity(0.92); // dark grey asphalt road
    canvas.drawPath(roadPath, roadPaint);

    // Lane dividers
    final divPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..strokeWidth = 2.0;

    // Left divider (separates lane 0 and 1)
    canvas.drawLine(
      Offset(vanishingX, horizonY),
      Offset(vanishingX - 0.5 * bottomLaneSpacing, bottomY),
      divPaint,
    );

    // Right divider (separates lane 1 and 2)
    canvas.drawLine(
      Offset(vanishingX, horizonY),
      Offset(vanishingX + 0.5 * bottomLaneSpacing, bottomY),
      divPaint,
    );

    // Road borders
    final borderPaint = Paint()
      ..color = Colors.white70.withOpacity(0.4)
      ..strokeWidth = 3.5;
    canvas.drawLine(
      Offset(vanishingX, horizonY),
      Offset(vanishingX - 1.5 * bottomLaneSpacing, bottomY),
      borderPaint,
    );
    canvas.drawLine(
      Offset(vanishingX, horizonY),
      Offset(vanishingX + 1.5 * bottomLaneSpacing, bottomY),
      borderPaint,
    );

    // Center dash markings in each lane scrolling forward
    final dashPaint = Paint()
      ..color = Colors.yellow.withOpacity(0.25)
      ..strokeWidth = 4.0;
    final scroll = controller.bgScrollOffset.value;

    for (int lane = 0; lane < 3; lane++) {
      for (int i = 0; i < 5; i++) {
        final double yVal = ((i / 5.0) + scroll * 0.6) % 1.0;
        final pos = getPerspectivePos(lane.toDouble(), yVal, w, h);
        final scale = getPerspectiveScale(yVal);
        canvas.drawCircle(pos, 3.5 * scale, dashPaint);
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // COLLECTIBLES (With 3D scaling)
  // ─────────────────────────────────────────────────────────────────
  void _drawCollectibles(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    for (final c in controller.liveCollectibles) {
      if (c.collected || c.missed) continue;

      final pos = getPerspectivePos(c.lane.toDouble(), c.y, w, h);
      final scale = getPerspectiveScale(c.y);
      final radius = 28.0 * scale;

      // Glow background
      final glowColor = c.data.isCorrect
          ? const Color(0xFF4ADE80)
          : const Color(0xFFFF6B6B);

      final glowPaint = Paint()
        ..color = glowColor.withOpacity(0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawCircle(pos, radius + 8 * scale, glowPaint);

      // Bubble background
      final bubblePaint = Paint()
        ..color = (c.data.isCorrect
            ? const Color(0xFF065F46)
            : const Color(0xFF7F1D1D))
            .withOpacity(0.85);
      canvas.drawCircle(pos, radius, bubblePaint);

      // Border
      final borderPaint = Paint()
        ..color = glowColor.withOpacity(0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5 * scale;
      canvas.drawCircle(pos, radius, borderPaint);

      // Emoji text
      _drawEmoji(canvas, c.data.emoji, pos, 26.0 * scale);

      // Label below
      if (c.data.label.length <= 4) {
        _drawLabel(
          canvas,
          c.data.label,
          Offset(pos.dx, pos.dy + radius + 13 * scale),
          Colors.white.withOpacity(0.8),
          11.0 * scale,
        );
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // OBSTACLES (With 3D scaling)
  // ─────────────────────────────────────────────────────────────────
  void _drawObstacles(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    for (final o in controller.liveObstacles) {
      if (o.hit) continue;

      final pos = getPerspectivePos(o.lane.toDouble(), o.y, w, h);
      final scale = getPerspectiveScale(o.y);
      final sizeW = 56.0 * scale;
      final sizeH = 56.0 * scale;

      // Red danger glow
      final glowPaint = Paint()
        ..color = Colors.redAccent.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
      canvas.drawCircle(pos, 32 * scale, glowPaint);

      // Obstacle background
      final bgPaint = Paint()..color = const Color(0xFF450A0A).withOpacity(0.85);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: pos, width: sizeW, height: sizeH),
          Radius.circular(12 * scale),
        ),
        bgPaint,
      );

      // Border
      final borderPaint = Paint()
        ..color = Colors.redAccent.withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0 * scale;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: pos, width: sizeW, height: sizeH),
          Radius.circular(12 * scale),
        ),
        borderPaint,
      );

      _drawEmoji(canvas, o.emoji, pos, 28.0 * scale);
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // PLAYER CHARACTER (Positioned at bottom center with 3D projection)
  // ─────────────────────────────────────────────────────────────────
  void _drawPlayer(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final state = controller.playerState.value;
    final lane = controller.playerLane.value;
    final jumpProg = controller.jumpProgress.value;
    final slideProg = controller.slideProgress.value;
    final activePowerUp = controller.activePowerUp.value;

    // Player runs at y progress = 0.85 (close to the bottom)
    final double playerYProgress = 0.85;
    final pos = getPerspectivePos(lane.toDouble(), playerYProgress, w, h);
    final scale = getPerspectiveScale(playerYProgress);

    // Jump offset (arc)
    final jumpOffset = jumpProg * h * 0.15;
    final playerCenter = Offset(pos.dx, pos.dy - jumpOffset);

    // Slide: squish dimensions
    final playerH = (slideProg > 0 ? 44.0 : 60.0) * scale;
    final playerW = (slideProg > 0 ? 72.0 : 52.0) * scale;

    // Hit: red flash
    if (state == PlayerState.hit) {
      final flashPaint = Paint()
        ..color = Colors.redAccent.withOpacity(0.4 * (sin(animTick * 20) * 0.5 + 0.5))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
      canvas.drawCircle(playerCenter, 40 * scale, flashPaint);
    }

    // Power-up aura
    if (activePowerUp == PowerUpType.shield) {
      final shieldPaint = Paint()
        ..color = Colors.cyanAccent.withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0 * scale;
      canvas.drawCircle(playerCenter, 42 * scale, shieldPaint);
    } else if (activePowerUp == PowerUpType.jetpack) {
      final jetPaint = Paint()
        ..color = Colors.orangeAccent.withOpacity(0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
      canvas.drawCircle(Offset(playerCenter.dx, playerCenter.dy + 20 * scale), 30 * scale, jetPaint);
    } else if (activePowerUp == PowerUpType.rainbow) {
      final rainPaint = Paint()
        ..color = Colors.purpleAccent.withOpacity(0.3 + 0.2 * sin(animTick * 5))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
      canvas.drawCircle(playerCenter, 45 * scale, rainPaint);
    }

    // Shadow on the ground (doesn't jump with the player, just shrinks)
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.35 - jumpProg * 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(pos.dx, pos.dy + 10 * scale),
        width: playerW * (1.0 - jumpProg * 0.4),
        height: 14 * scale,
      ),
      shadowPaint,
    );

    // Player body gradient background
    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF7C3AED), Color(0xFF2563EB)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromCenter(center: playerCenter, width: playerW, height: playerH));

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: playerCenter, width: playerW, height: playerH),
        Radius.circular((slideProg > 0 ? 16 : 24) * scale),
      ),
      bodyPaint,
    );

    // Player emoji
    final emoji = state == PlayerState.celebrating
        ? '🐼🏆'
        : state == PlayerState.hit
            ? '🐼🩹'
            : state == PlayerState.jumping
                ? '🐼🚀'
                : state == PlayerState.sliding
                    ? '🐼🐾'
                    : '🐼';

    _drawEmoji(canvas, emoji, playerCenter, 32.0 * scale);

    // Running legs animation
    if (state == PlayerState.running || state == PlayerState.jumping) {
      final legAnim = sin(animTick * 8) * 8.0 * scale;
      _drawLabel(canvas, '—', Offset(playerCenter.dx - 10 * scale + legAnim, playerCenter.dy + playerH * 0.4), Colors.white38, 14.0 * scale);
      _drawLabel(canvas, '—', Offset(playerCenter.dx + 10 * scale - legAnim, playerCenter.dy + playerH * 0.4), Colors.white38, 14.0 * scale);
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // FLOATING TEXTS (With 3D scaling)
  // ─────────────────────────────────────────────────────────────────
  void _drawFloatingTexts(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    for (final ft in controller.floatingTexts) {
      final double laneIndex = ft.x < 0.3 ? 0.0 : ft.x < 0.6 ? 1.0 : 2.0;
      final pos = getPerspectivePos(laneIndex, ft.y, w, h);
      final scale = getPerspectiveScale(ft.y);

      _drawLabel(
        canvas,
        ft.text,
        pos,
        ft.color.withOpacity(ft.opacity),
        16.0 * scale,
        bold: true,
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // COMBO FLAME INDICATOR (With 3D scaling)
  // ─────────────────────────────────────────────────────────────────
  void _drawComboFlame(Canvas canvas, Size size) {
    final combo = controller.combo.value;
    if (combo < 5) return;

    final w = size.width;
    final h = size.height;
    final lane = controller.playerLane.value;

    final double playerYProgress = 0.85;
    final pos = getPerspectivePos(lane.toDouble(), playerYProgress, w, h);
    final scale = getPerspectiveScale(playerYProgress);

    final jumpOffset = controller.jumpProgress.value * h * 0.15;
    final playerCenter = Offset(pos.dx, pos.dy - jumpOffset);

    // Flame trail behind player
    for (int i = 0; i < 4; i++) {
      final flameY = playerCenter.dy + (20 + i * 12.0) * scale;
      final flameOpacity = (0.6 - i * 0.12) * (sin(animTick * 6 + i) * 0.3 + 0.7);
      final flamePaint = Paint()
        ..color = (combo >= 10 ? Colors.purpleAccent : Colors.orangeAccent)
            .withOpacity(flameOpacity.clamp(0.0, 1.0))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(Offset(playerCenter.dx, flameY), (6.0 - i * 1.0) * scale, flamePaint);
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // HELPERS — Text Paragraph rendering
  // ─────────────────────────────────────────────────────────────────
  void _drawEmoji(Canvas canvas, String emoji, Offset center, double fontSize) {
    final tp = TextPainter(
      text: TextSpan(
        text: emoji,
        style: TextStyle(fontSize: fontSize),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
  }

  void _drawLabel(Canvas canvas, String text, Offset center, Color color, double fontSize, {bool bold = false}) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          color: color,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          fontFamily: 'Nunito',
          shadows: [
            Shadow(color: Colors.black54, blurRadius: 3, offset: const Offset(0, 1)),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(GamePainter oldDelegate) => true;
}
