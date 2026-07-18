import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../data/models/shape_model.dart';

class ShapePainter extends CustomPainter {
  final ShapeType shapeType;
  final double progress;
  final Color color;

  ShapePainter(
    this.shapeType,
    this.progress, {
    this.color = Colors.white,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Path path = _getShapePath(shapeType, size);

    if (progress >= 1.0) {
      canvas.drawPath(path, paint);
    } else {
      // Animate path stroke drawing using PathMetrics
      final Path extractPath = Path();
      for (final PathMetric metric in path.computeMetrics()) {
        final double extractLength = metric.length * progress;
        extractPath.addPath(metric.extractPath(0.0, extractLength), Offset.zero);
      }
      canvas.drawPath(extractPath, paint);
    }
  }

  Path _getShapePath(ShapeType type, Size size) {
    final Path path = Path();
    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;
    final double cy = h / 2;
    final double radius = math.min(cx, cy) * 0.9;

    switch (type) {
      case ShapeType.circle:
        path.addOval(Rect.fromCircle(center: Offset(cx, cy), radius: radius));
        break;

      case ShapeType.square:
        final double side = radius * math.sqrt(2);
        path.addRect(Rect.fromCenter(center: Offset(cx, cy), width: side, height: side));
        break;

      case ShapeType.triangle:
        path.moveTo(cx, cy - radius);
        path.lineTo(cx + radius * math.cos(math.pi / 6), cy + radius * math.sin(math.pi / 6));
        path.lineTo(cx - radius * math.cos(math.pi / 6), cy + radius * math.sin(math.pi / 6));
        path.close();
        break;

      case ShapeType.rectangle:
        final double width = radius * 1.6;
        final double height = radius * 1.0;
        path.addRect(Rect.fromCenter(center: Offset(cx, cy), width: width, height: height));
        break;

      case ShapeType.star:
        const int numPoints = 5;
        const double step = math.pi / numPoints;
        final double outerRadius = radius;
        final double innerRadius = radius * 0.4;
        
        double angle = -math.pi / 2;
        path.moveTo(cx + outerRadius * math.cos(angle), cy + outerRadius * math.sin(angle));
        
        for (int i = 0; i < numPoints; i++) {
          angle += step;
          path.lineTo(cx + innerRadius * math.cos(angle), cy + innerRadius * math.sin(angle));
          angle += step;
          path.lineTo(cx + outerRadius * math.cos(angle), cy + outerRadius * math.sin(angle));
        }
        path.close();
        break;

      case ShapeType.heart:
        // Draw heart using cubic curves
        final double topY = cy - radius * 0.5;
        final double botY = cy + radius;
        path.moveTo(cx, topY + radius * 0.4);
        
        // Left curve
        path.cubicTo(
          cx - radius * 0.8, topY - radius * 0.3,
          cx - radius * 1.2, cy - radius * 0.1,
          cx, botY,
        );
        // Right curve
        path.cubicTo(
          cx + radius * 1.2, cy - radius * 0.1,
          cx + radius * 0.8, topY - radius * 0.3,
          cx, topY + radius * 0.4,
        );
        path.close();
        break;

      case ShapeType.diamond:
        path.moveTo(cx, cy - radius); // Top
        path.lineTo(cx + radius * 0.8, cy); // Right
        path.lineTo(cx, cy + radius); // Bottom
        path.lineTo(cx - radius * 0.8, cy); // Left
        path.close();
        break;

      case ShapeType.oval:
        path.addOval(Rect.fromCenter(center: Offset(cx, cy), width: radius * 1.5, height: radius * 0.9));
        break;

      case ShapeType.pentagon:
        const int points = 5;
        final double angleStep = (2 * math.pi) / points;
        const double startAngle = -math.pi / 2;
        
        path.moveTo(
          cx + radius * math.cos(startAngle),
          cy + radius * math.sin(startAngle),
        );
        
        for (int i = 1; i < points; i++) {
          final double angle = startAngle + i * angleStep;
          path.lineTo(
            cx + radius * math.cos(angle),
            cy + radius * math.sin(angle),
          );
        }
        path.close();
        break;

      case ShapeType.hexagon:
        const int points = 6;
        final double angleStep = (2 * math.pi) / points;
        const double startAngle = -math.pi / 2;
        
        path.moveTo(
          cx + radius * math.cos(startAngle),
          cy + radius * math.sin(startAngle),
        );
        
        for (int i = 1; i < points; i++) {
          final double angle = startAngle + i * angleStep;
          path.lineTo(
            cx + radius * math.cos(angle),
            cy + radius * math.sin(angle),
          );
        }
        path.close();
        break;
    }

    return path;
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  @override
  bool shouldRepaint(covariant ShapePainter oldDelegate) {
    return oldDelegate.shapeType != shapeType ||
        oldDelegate.progress != progress ||
        oldDelegate.color != color;
  }
}
