import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../services/tts_service.dart';
import '../../../services/audio_service.dart';
import '../../../services/progress_service.dart';
import '../../../core/utils/haptic_util.dart';
import '../colors_shapes_controller.dart';

class ColoringRegion {
  final String name;
  final Path path;
  Color color;

  ColoringRegion({
    required this.name,
    required this.path,
    this.color = Colors.white,
  });
}

class ColoringCanvasWidget extends StatefulWidget {
  final String activeObject;
  final Color activeColor;

  const ColoringCanvasWidget({
    Key? key,
    required this.activeObject,
    required this.activeColor,
  }) : super(key: key);

  @override
  State<ColoringCanvasWidget> createState() => _ColoringCanvasWidgetState();
}

class _ColoringCanvasWidgetState extends State<ColoringCanvasWidget> {
  List<ColoringRegion> _regions = [];
  String _loadedObject = '';

  @override
  void didUpdateWidget(covariant ColoringCanvasWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeObject != _loadedObject) {
      _initializeRegions();
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeRegions();
  }

  void _initializeRegions() {
    _loadedObject = widget.activeObject;
    _regions.clear();

    final size = const Size(260, 260);
    final w = size.width;
    final h = size.height;

    switch (widget.activeObject) {
      case 'House 🏠':
        // 1. Roof
        final roof = Path()
          ..moveTo(w * 0.5, h * 0.1)
          ..lineTo(w * 0.9, h * 0.45)
          ..lineTo(w * 0.1, h * 0.45)
          ..close();
        
        // 2. Body
        final body = Path()
          ..addRect(Rect.fromLTWH(w * 0.2, h * 0.45, w * 0.6, h * 0.45));

        // 3. Door
        final door = Path()
          ..addRect(Rect.fromLTWH(w * 0.4, h * 0.62, w * 0.2, h * 0.28));

        // 4. Window
        final window = Path()
          ..addOval(Rect.fromCircle(center: Offset(w * 0.5, h * 0.3), radius: 18.0));

        _regions.add(ColoringRegion(name: 'Roof', path: roof));
        _regions.add(ColoringRegion(name: 'Walls', path: body));
        _regions.add(ColoringRegion(name: 'Door', path: door));
        _regions.add(ColoringRegion(name: 'Window', path: window));
        break;

      case 'Tree 🌳':
        // 1. Trunk
        final trunk = Path()
          ..addRect(Rect.fromLTWH(w * 0.42, h * 0.6, w * 0.16, h * 0.3));

        // 2. Foliage (three circular blobs)
        final leaf1 = Path()
          ..addOval(Rect.fromCircle(center: Offset(w * 0.5, h * 0.3), radius: 50.0));
        final leaf2 = Path()
          ..addOval(Rect.fromCircle(center: Offset(w * 0.35, h * 0.45), radius: 42.0));
        final leaf3 = Path()
          ..addOval(Rect.fromCircle(center: Offset(w * 0.65, h * 0.45), radius: 42.0));

        // Combine leaves
        final foliage = Path.combine(PathOperation.union, leaf1, leaf2);
        final finalFoliage = Path.combine(PathOperation.union, foliage, leaf3);

        _regions.add(ColoringRegion(name: 'Trunk', path: trunk));
        _regions.add(ColoringRegion(name: 'Leaves', path: finalFoliage));
        break;

      case 'Balloon 🎈':
        // 1. Balloon
        final ball = Path()
          ..addOval(Rect.fromLTWH(w * 0.2, h * 0.1, w * 0.6, h * 0.65));

        // 2. String
        final str = Path()
          ..moveTo(w * 0.5, h * 0.75)
          ..quadraticBezierTo(w * 0.45, h * 0.82, w * 0.5, h * 0.92)
          ..lineTo(w * 0.52, h * 0.92)
          ..quadraticBezierTo(w * 0.47, h * 0.82, w * 0.52, h * 0.75)
          ..close();

        _regions.add(ColoringRegion(name: 'Balloon', path: ball));
        _regions.add(ColoringRegion(name: 'String', path: str));
        break;

      case 'Flower 🌸':
        // 1. Stem
        final stem = Path()
          ..addRect(Rect.fromLTWH(w * 0.47, h * 0.5, w * 0.06, h * 0.45));

        // 2. Leaves
        final leafL = Path()
          ..moveTo(w * 0.47, h * 0.7)
          ..quadraticBezierTo(w * 0.3, h * 0.62, w * 0.35, h * 0.75)
          ..quadraticBezierTo(w * 0.44, h * 0.76, w * 0.47, h * 0.72)
          ..close();

        // 3. Flower Center
        final center = Path()
          ..addOval(Rect.fromCircle(center: Offset(w * 0.5, h * 0.35), radius: 26.0));

        // 4. Petals (5 petals surrounding center)
        final petals = Path();
        final angles = [0.0, 72.0, 144.0, 216.0, 288.0];
        final double dist = 38.0;
        final double radius = 24.0;

        for (final angle in angles) {
          final rad = angle * 3.14159 / 180.0;
          final cx = w * 0.5 + dist * math.cos(rad);
          final cy = h * 0.35 + dist * math.sin(rad);
          petals.addOval(Rect.fromCircle(center: Offset(cx, cy), radius: radius));
        }

        _regions.add(ColoringRegion(name: 'Stem', path: stem));
        _regions.add(ColoringRegion(name: 'Leaves', path: leafL));
        _regions.add(ColoringRegion(name: 'Flower Center', path: center));
        _regions.add(ColoringRegion(name: 'Petals', path: petals));
        break;

      case 'Car 🚗':
        // 1. Top Cabin
        final cabin = Path()
          ..moveTo(w * 0.3, h * 0.32)
          ..lineTo(w * 0.45, h * 0.2)
          ..lineTo(w * 0.68, h * 0.2)
          ..lineTo(w * 0.8, h * 0.32)
          ..close();

        // 2. Lower Body
        final carBody = Path()
          ..moveTo(w * 0.1, h * 0.32)
          ..lineTo(w * 0.9, h * 0.32)
          ..lineTo(w * 0.9, h * 0.6)
          ..lineTo(w * 0.1, h * 0.6)
          ..close();

        // 3. Wheels
        final wheelF = Path()
          ..addOval(Rect.fromCircle(center: Offset(w * 0.28, h * 0.64), radius: 24.0));
        final wheelB = Path()
          ..addOval(Rect.fromCircle(center: Offset(w * 0.72, h * 0.64), radius: 24.0));

        _regions.add(ColoringRegion(name: 'Windows', path: cabin));
        _regions.add(ColoringRegion(name: 'Car Body', path: carBody));
        _regions.add(ColoringRegion(name: 'Front Wheel', path: wheelF));
        _regions.add(ColoringRegion(name: 'Back Wheel', path: wheelB));
        break;

      default:
        // Fallback default rectangle
        final r = Path()..addRect(Rect.fromLTWH(20, 20, 220, 220));
        _regions.add(ColoringRegion(name: 'Square', path: r));
        break;
    }
    setState(() {});
  }

  void _handleTap(TapUpDetails details) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localOffset = box.globalToLocal(details.globalPosition);

    for (int i = _regions.length - 1; i >= 0; i--) {
      final reg = _regions[i];
      if (reg.path.contains(localOffset)) {
        HapticUtil.light();
        AudioService.to.playTap(); // slice/splash sound

        setState(() {
          reg.color = widget.activeColor;
        });

        // TTS Feedback e.g., "This is Red. Beautiful!"
        final controller = Get.find<ColorsShapesController>();
        final activeColorName = controller.colorsList.firstWhere(
          (c) => c.colorHex == widget.activeColor.value,
          orElse: () => controller.colorsList[0],
        ).name;
        TtsService.to.speak("Painting ${reg.name} ${activeColorName}!");

        // Check if fully colored to trigger reward
        _checkFullyColored();
        break;
      }
    }
  }

  void _checkFullyColored() {
    final bool allColored = _regions.every((r) => r.color != Colors.white);
    if (allColored) {
      Future.delayed(const Duration(milliseconds: 600), () {
        HapticUtil.medium();
        AudioService.to.playStar(); // success sound
        
        final progress = Get.find<ColorsShapesController>().visitedColors;
        // Award star
        ProgressService.to.addStar();
        
        Get.rawSnackbar(
          titleText: const Text(
            "🎨 Artist Reward! 🎨",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
              fontFamily: 'FredokaOne',
            ),
          ),
          messageText: const Text(
            "You painted the whole object! +1 Star +5 Coins",
            style: TextStyle(color: Colors.white70, fontSize: 14.0),
          ),
          backgroundColor: AppColors.gold,
          borderRadius: 20,
          margin: const EdgeInsets.all(16.0),
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Coloring Canvas Box
        GestureDetector(
          onTapUp: _handleTap,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(24.0),
              border: Border.all(color: Colors.white.withOpacity(0.12), width: 2.0),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8.0,
                ),
              ],
            ),
            child: CustomPaint(
              size: const Size(260, 260),
              painter: ColoringBookPainter(regions: _regions),
            ),
          )
              .animate(key: ValueKey(widget.activeObject))
              .scale(begin: const Offset(0.9, 0.9), duration: 300.ms, curve: Curves.easeOutBack),
        ),
        const SizedBox(height: 12.0),
        Text(
          "Tap parts of the drawing to color them! 🎨",
          style: AppTextStyles.bodySmall.copyWith(color: Colors.white30, fontSize: 14.0),
        ),
      ],
    );
  }
}

class ColoringBookPainter extends CustomPainter {
  final List<ColoringRegion> regions;

  ColoringBookPainter({required this.regions});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw region fills
    for (final reg in regions) {
      final Paint fillPaint = Paint()
        ..color = reg.color
        ..style = PaintingStyle.fill;
      canvas.drawPath(reg.path, fillPaint);
    }

    // 2. Draw black stroke borders to define outlines
    final Paint strokePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final reg in regions) {
      canvas.drawPath(reg.path, strokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
