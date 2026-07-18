import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../data/models/color_item_model.dart';
import '../../data/models/shape_model.dart';
import '../../data/datasources/colors_data.dart';
import '../../data/datasources/shapes_data.dart';
import '../../services/progress_service.dart';
import '../../services/tts_service.dart';
import 'widgets/shape_painter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/haptic_util.dart';

class ColorsShapesController extends GetxController {
  final ProgressService _progress = ProgressService.to;

  RxSet<String> get visitedColors => _progress.visitedColors;
  RxSet<String> get visitedShapes => _progress.visitedShapes;

  final List<ColorItemModel> colorsList = ColorsData.colors;
  final List<ShapeModel> shapesList = ShapesData.shapes;

  // Coloring Book States
  final Rx<Color> activeColor = const Color(0xFFFF6B6B).obs;
  final RxString activePaintingObject = 'House 🏠'.obs;
  final List<String> paintingObjects = [
    'House 🏠',
    'Tree 🌳',
    'Balloon 🎈',
    'Flower 🌸',
    'Car 🚗'
  ];

  void selectPaletteColor(ColorItemModel item) {
    activeColor.value = Color(item.colorHex);
    onColorTap(item);
    TtsService.to.speak("This is ${item.name}!");
  }

  void onColorTap(ColorItemModel colorItem) {
    if (!visitedColors.contains(colorItem.name)) {
      _progress.addVisitedColor(colorItem.name);
    }
  }

  void onShapeTap(ShapeModel shape) {
    if (!visitedShapes.contains(shape.name)) {
      _progress.addVisitedShape(shape.name);
    }
    showShapeDetail(shape);
  }

  void showShapeDetail(ShapeModel shape) {
    Get.dialog(
      Center(
        child: Container(
          margin: const EdgeInsets.all(28.0),
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: AppColors.bgMid,
            borderRadius: BorderRadius.circular(28.0),
            border: Border.all(color: AppColors.lavender.withOpacity(0.5), width: 2.0),
            boxShadow: [
              BoxShadow(
                color: AppColors.lavender.withOpacity(0.2),
                blurRadius: 16,
              )
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Big shape icon/visual
                Container(
                  width: 120,
                  height: 120,
                  alignment: Alignment.center,
                  child: CustomPaint(
                    size: const Size(100, 100),
                    painter: ShapePainter(shape.type, 1.0, color: AppColors.lavender),
                  ),
                ),
                const SizedBox(height: 16.0),

                // Name
                Text(
                  shape.name,
                  style: AppTextStyles.displaySmall,
                ),
                const SizedBox(height: 4.0),
                
                // Sides Info
                Text(
                  "${shape.sides} sides",
                  style: AppTextStyles.bodyMediumBold.copyWith(color: AppColors.white70),
                ),
                const SizedBox(height: 16.0),

                // Description
                Text(
                  shape.description,
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12.0),

                // Real-world examples
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Text(
                    "💡 ${shape.realWorldExample}",
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white80),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24.0),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          HapticUtil.light();
                          TtsService.to.speak(shape.name);
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.coral),
                        child: Text(
                          "🔊 Hear it!",
                          style: AppTextStyles.bodySmallBold.copyWith(
                            fontSize: 14.0, // Enforce 14sp minimum
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          HapticUtil.light();
                          Get.back();
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.15)),
                        child: Text(
                          "✓ Got it!",
                          style: AppTextStyles.bodySmallBold.copyWith(
                            fontSize: 14.0, // Enforce 14sp minimum
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      barrierColor: Colors.black.withOpacity(0.7),
      useSafeArea: true,
    );
  }

  @override
  void onClose() {
    TtsService.to.stop();
    super.onClose();
  }
}
