import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../shared/widgets/gradient_app_bar.dart';
import '../shared/widgets/bouncy_button.dart';
import '../../core/utils/haptic_util.dart';
import 'colors_shapes_controller.dart';
import 'widgets/color_swatch_card.dart';
import 'widgets/shape_card_widget.dart';
import 'widgets/coloring_canvas_widget.dart';

class ColorsShapesScreen extends GetView<ColorsShapesController> {
  const ColorsShapesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.bgDark,
        body: Column(
          children: [
            // Custom Gradient App Bar
            const GradientAppBar(
              title: "Colors & Shapes 🎨",
              gradient: AppColors.colorsShapesGradient,
            ),
            
            // Custom TabBar
            TabBar(
              indicatorColor: AppColors.gold,
              labelStyle: AppTextStyles.bodyMediumBold.copyWith(
                fontFamily: 'FredokaOne',
                fontSize: 15.0,
              ),
              labelColor: AppColors.gold,
              unselectedLabelColor: Colors.white.withOpacity(0.6),
              dividerColor: Colors.white10,
              tabs: const [
                Tab(
                  icon: Icon(Icons.palette_rounded),
                  text: "Colors",
                ),
                Tab(
                  icon: Icon(Icons.interests_rounded),
                  text: "Shapes",
                ),
                Tab(
                  icon: Icon(Icons.brush_rounded),
                  text: "Paint Book",
                ),
              ],
            ),
            
            // Tab View contents
            Expanded(
              child: TabBarView(
                physics: const BouncingScrollPhysics(),
                children: [
                  // Colors Tab grid
                  _buildColorsTab(),
                  
                  // Shapes Tab grid
                  _buildShapesTab(),

                  // Paint Book Tab
                  _buildColoringBookTab(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorsTab() {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 12.0,
        childAspectRatio: 1.3,
      ),
      itemCount: controller.colorsList.length,
      itemBuilder: (ctx, i) {
        return ColorSwatchCard(colorItem: controller.colorsList[i]);
      },
    );
  }

  Widget _buildShapesTab() {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 12.0,
        childAspectRatio: 1.05,
      ),
      itemCount: controller.shapesList.length,
      itemBuilder: (ctx, i) {
        return ShapeCardWidget(shape: controller.shapesList[i]);
      },
    );
  }

  Widget _buildColoringBookTab(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12.0),
        // Horizontal list of painting objects
        SizedBox(
          height: 48.0,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            itemCount: controller.paintingObjects.length,
            itemBuilder: (ctx, index) {
              final obj = controller.paintingObjects[index];
              return Obx(() {
                final isSelected = controller.activePaintingObject.value == obj;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: BouncyButton(
                    onTap: () {
                      HapticUtil.light();
                      controller.activePaintingObject.value = obj;
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.gold : Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(
                          color: isSelected ? AppColors.gold : Colors.white.withOpacity(0.12),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        obj,
                        style: AppTextStyles.bodySmallBold.copyWith(
                          fontSize: 14.0,
                          color: isSelected ? AppColors.bgDark : Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              });
            },
          ),
        ),
        const SizedBox(height: 16.0),

        // Interactive Canvas
        Obx(() => ColoringCanvasWidget(
              activeObject: controller.activePaintingObject.value,
              activeColor: controller.activeColor.value,
            )),
        const SizedBox(height: 20.0),

        // Paint Color Palette Tray
        Text(
          "Color Tray 🎨",
          style: AppTextStyles.bodyMediumBold.copyWith(color: AppColors.white70),
        ),
        const SizedBox(height: 8.0),
        SizedBox(
          height: 60.0,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: controller.colorsList.length,
            itemBuilder: (ctx, index) {
              final colorItem = controller.colorsList[index];
              final col = Color(colorItem.colorHex);
              
              return Obx(() {
                final isSelected = controller.activeColor.value.value == col.value;
                return GestureDetector(
                  onTap: () {
                    HapticUtil.light();
                    controller.selectPaletteColor(colorItem);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6.0),
                    width: 44.0,
                    height: 44.0,
                    decoration: BoxDecoration(
                      color: col,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.transparent,
                        width: 3.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: col.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 20.0,
                          )
                        : null,
                  ),
                );
              });
            },
          ),
        ),
      ],
    );
  }
}
