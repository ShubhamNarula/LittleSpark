import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../shared/widgets/gradient_app_bar.dart';
import '../shared/widgets/confetti_overlay_widget.dart';
import 'numbers_find_controller.dart';
import 'widgets/find_number_banner.dart';
import 'widgets/number_tile_widget.dart';

class NumbersFindGameScreen extends GetView<NumbersFindController> {
  NumbersFindGameScreen({Key? key}) : super(key: key);

  final GlobalKey<ConfettiOverlayWidgetState> _confettiKey = GlobalKey<ConfettiOverlayWidgetState>();

  @override
  Widget build(BuildContext context) {
    final stage = NumbersFindController.stages[controller.currentStageId.value - 1];
    final stageName = stage['label'] as String;
    final stageColor = Color(stage['color'] as int);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GradientAppBar(
                title: stageName,
                gradient: [stageColor, stageColor.withOpacity(0.7)],
                showLeading: true,
              ),
              const SizedBox(height: 8.0),
              FindNumberBanner(controller: controller),
              const SizedBox(height: 16.0),
              Expanded(
                child: SafeArea(
                  top: false,
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                      child: Obx(() {
                        return Wrap(
                          spacing: 16.0,
                          runSpacing: 16.0,
                          alignment: WrapAlignment.center,
                          children: List.generate(controller.displayedTiles.length, (index) {
                            final number = controller.displayedTiles[index];
                            return NumberTileWidget(
                              number: number,
                              controller: controller,
                            )
                                .animate(key: ValueKey('${number}_$index'), delay: (index * 60).ms)
                                .scale(
                                  begin: const Offset(0.5, 0.5),
                                  end: const Offset(1.0, 1.0),
                                  duration: 300.ms,
                                  curve: Curves.elasticOut,
                                )
                                .fadeIn(duration: 300.ms);
                          }),
                        );
                      }),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
            ],
          ),
          
          // Confetti overlay on correct tap
          Obx(() {
            if (controller.isCorrect.value) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _confettiKey.currentState?.startCelebration();
              });
            }
            return ConfettiOverlayWidget(key: _confettiKey);
          }),
        ],
      ),
    );
  }
}
