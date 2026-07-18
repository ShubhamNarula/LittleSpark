import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/shape_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../colors_shapes_controller.dart';
import 'shape_painter.dart';

class ShapeCardWidget extends StatefulWidget {
  final ShapeModel shape;

  const ShapeCardWidget({
    Key? key,
    required this.shape,
  }) : super(key: key);

  @override
  State<ShapeCardWidget> createState() => _ShapeCardWidgetState();
}

class _ShapeCardWidgetState extends State<ShapeCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ColorsShapesController>();

    return GestureDetector(
      onTap: () => controller.onShapeTap(widget.shape),
      child: Container(
        height: 150.0,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.lavender, Color(0xFF818CF8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: AppColors.lavender.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // CustomPaint drawing shape with animated stroke progress
            SizedBox(
              width: 70.0,
              height: 70.0,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return CustomPaint(
                    painter: ShapePainter(
                      widget.shape.type,
                      _animation.value,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10.0),
            
            // Shape Name
            Text(
              widget.shape.name,
              style: AppTextStyles.bodySmallBold.copyWith(
                fontSize: 14.0, // Minimum 14sp restriction
                color: Colors.white,
              ),
            ),
            
            // Side details
            Text(
              "${widget.shape.sides} sides",
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 14.0, // Minimum 14sp restriction
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
