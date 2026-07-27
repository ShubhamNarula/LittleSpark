import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../shared/widgets/gradient_app_bar.dart';
import '../shared/widgets/progress_chip_widget.dart';
import 'fruits_controller.dart';
import 'widgets/fruit_card_widget.dart';

class FruitsScreen extends GetView<FruitsController> {
  const FruitsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.bgDark,
        body: Column(
          children: [
            // Custom Gradient App Bar
            Obx(() => GradientAppBar(
                  title: "Fruits & Veggies 🍎",
                  gradient: AppColors.fruitsVeggiesGradient,
                  trailing: ProgressChipWidget(
                    done: controller.visitedFruits.length,
                    total: 35,
                  ),
                )),

            // Category Tab Bar
            TabBar(
              indicatorColor: AppColors.gold,
              labelColor: AppColors.gold,
              unselectedLabelColor: Colors.white.withOpacity(0.6),
              labelStyle: AppTextStyles.bodyMediumBold.copyWith(
                fontFamily: 'FredokaOne',
                fontSize: 15.0,
              ),
              dividerColor: Colors.white10,
              tabs: const [
                Tab(
                  icon: Icon(Icons.apple_rounded),
                  text: "Fruits",
                ),
                Tab(
                  icon: Icon(Icons.grass_rounded),
                  text: "Vegetables",
                ),
              ],
            ),

            // Tab Pages View
            Expanded(
              child: TabBarView(
                physics: const BouncingScrollPhysics(),
                children: [
                  // Fruits Tab Grid
                  _buildGrid(controller.fruitsList),

                  // Vegetables Tab Grid
                  _buildGrid(controller.vegetablesList),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(List itemsList) {
    return Builder(builder: (context) {
      final screenSize = MediaQuery.of(context).size;
      final bottomInset = MediaQuery.of(context).padding.bottom;
      final double dynamicRatio = screenSize.height < 680
          ? 1.05
          : (screenSize.height < 780 ? 1.0 : 0.95);

      return GridView.builder(
        padding: EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 16.0,
          bottom: 20.0 + (bottomInset > 0 ? bottomInset : 0.0),
        ),
        physics: const BouncingScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12.0,
          mainAxisSpacing: 12.0,
          childAspectRatio: dynamicRatio,
        ),
      itemCount: itemsList.length,
      itemBuilder: (ctx, i) {
        final item = itemsList[i];
        
        return Obx(() {
          final isVisited = controller.visitedFruits.contains(item.name);
          return FruitCardWidget(
            item: item,
            isVisited: isVisited,
            onTap: () => controller.onFruitTap(item),
          );
        });
      },
    );
    });
  }
}
