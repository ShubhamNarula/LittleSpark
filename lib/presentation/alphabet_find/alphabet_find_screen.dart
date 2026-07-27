import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../shared/widgets/gradient_app_bar.dart';
import 'alphabet_find_controller.dart';
import 'widgets/stage_card_widget.dart';

class AlphabetFindScreen extends GetView<AlphabetFindController> {
  const AlphabetFindScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const GradientAppBar(
            title: "Find the Letter! 🔤",
            gradient: AppColors.alphabetGradient,
            showLeading: true,
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 16.0,
                    right: 16.0,
                    top: 16.0,
                    bottom: 24.0 + (MediaQuery.of(context).padding.bottom > 0 ? MediaQuery.of(context).padding.bottom : 0.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Choose your stage 👇",
                        style: AppTextStyles.bodyExtraLarge.copyWith(
                          fontSize: 20.0,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: AlphabetFindController.stages.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12.0),
                        itemBuilder: (ctx, index) {
                          return StageCardWidget(
                            stageId: index + 1,
                            controller: controller,
                          )
                              .animate(delay: (index * 100).ms)
                              .slideX(begin: 0.2, end: 0.0, duration: 300.ms, curve: Curves.easeOutCubic)
                              .fadeIn(duration: 300.ms);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
