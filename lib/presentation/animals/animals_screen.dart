import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../shared/widgets/gradient_app_bar.dart';
import '../shared/widgets/confetti_overlay_widget.dart';
import '../shared/widgets/bouncy_button.dart';
import '../../core/utils/haptic_util.dart';
import 'animals_controller.dart';
import 'widgets/animal_card_widget.dart';

class AnimalsScreen extends GetView<AnimalsController> {
  const AnimalsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final filters = ["All 🌍", "Farm 🏡", "Wild 🌿", "Ocean 🌊", "Sky 🦅"];
    final GlobalKey<ConfettiOverlayWidgetState> confettiKey =
        GlobalKey<ConfettiOverlayWidgetState>();

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Stack(
        children: [
          Column(
            children: [
              // Gradient App Bar
              const GradientAppBar(
                title: "Animal Kingdom 🐾",
                gradient: AppColors.animalsGradient,
              ),

              Expanded(
                child: SafeArea(
                  top: false,
                  child: Column(
                    children: [
                      // Custom Tab Bar
                      _buildTabBar(),

                      // Tabs content
                      Expanded(
                        child: Obx(() {
                          if (controller.activeTab.value == 0) {
                            return _buildExploreTab(filters);
                          } else {
                            // Trigger confetti on correct quiz answer
                            if (controller.quizIsCorrect.value) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                confettiKey.currentState?.startCelebration();
                              });
                            }
                            return _buildQuizTab();
                          }
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // Confetti Overlay
          ConfettiOverlayWidget(key: confettiKey),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton("Explore Grid 🐾", 0),
          ),
          Expanded(
            child: _buildTabButton("Animal Quiz 🎮", 1),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    return Obx(() {
      final isSelected = controller.activeTab.value == index;
      return GestureDetector(
        onTap: () {
          HapticUtil.light();
          controller.activeTab.value = index;
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.gold : Colors.transparent,
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Text(
            label,
            style: AppTextStyles.bodyMediumBold.copyWith(
              fontSize: 14.0,
              color: isSelected ? AppColors.bgDark : Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    });
  }

  // --- Explore Tab UI ---
  Widget _buildExploreTab(List<String> filters) {
    return Column(
      children: [
        // Horizontal Filter Chips Bar
        SizedBox(
          height: 60.0,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            itemCount: filters.length,
            itemBuilder: (context, index) {
              final filter = filters[index];
              return Obx(() {
                final isSelected = controller.selectedFilter.value == filter;
                return _buildFilterChip(filter, isSelected);
              });
            },
          ),
        ),

        // Animals Grid Layout
        Expanded(
          child: Obx(() {
            final list = controller.filteredAnimals;
            if (list.isEmpty) {
              return Center(
                child: Text(
                  "No animals found! 🦁",
                  style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white60),
                ),
              );
            }

            return Builder(builder: (ctx) {
              final screenSize = MediaQuery.of(ctx).size;
              final bottomInset = MediaQuery.of(ctx).padding.bottom;
              final double dynamicRatio = screenSize.height < 680
                  ? 1.05
                  : (screenSize.height < 780 ? 1.0 : 0.95);

              return GridView.builder(
                padding: EdgeInsets.only(
                  left: 12.0,
                  right: 12.0,
                  top: 12.0,
                  bottom: 20.0 + (bottomInset > 0 ? bottomInset : 0.0),
                ),
                physics: const BouncingScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12.0,
                  mainAxisSpacing: 12.0,
                  childAspectRatio: dynamicRatio,
                ),
                itemCount: list.length,
                itemBuilder: (ctx, i) {
                  final animal = list[i];
                  final isVisited = controller.visitedAnimals.contains(animal.name);
                  
                  return AnimalCardWidget(
                    animal: animal,
                    isVisited: isVisited,
                    onTap: () => controller.onAnimalTap(animal),
                  )
                      .animate(key: ValueKey('${animal.name}_$i'))
                      .slideX(begin: 0.3, end: 0.0, duration: 400.ms, curve: Curves.easeOutCubic)
                      .fadeIn(duration: 400.ms);
                },
              );
            });
          }),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      child: BouncyButton(
        onTap: () {
          HapticUtil.light();
          controller.setFilter(label);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.gold : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
              color: isSelected ? AppColors.gold : Colors.white.withOpacity(0.15),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.bodySmallBold.copyWith(
                fontSize: 14.0,
                color: isSelected ? AppColors.bgDark : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Quiz Tab UI ---
  Widget _buildQuizTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Question card box
          Container(
            padding: const EdgeInsets.all(22.0),
            decoration: BoxDecoration(
              color: AppColors.bgMid,
              borderRadius: BorderRadius.circular(24.0),
              border: Border.all(color: Colors.white.withOpacity(0.12), width: 1.5),
            ),
            child: Column(
              children: [
                Text(
                  controller.quizType.value == 0 ? "Animal Voice Quiz 📣" : "Animal Fact Quiz 💡",
                  style: AppTextStyles.bodyMediumBold.copyWith(color: AppColors.gold, fontSize: 16.0),
                ),
                const SizedBox(height: 16.0),
                Text(
                  controller.quizQuestion.value,
                  style: AppTextStyles.displaySmall.copyWith(fontSize: 22.0),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
              .animate(key: ValueKey(controller.quizQuestion.value))
              .scale(begin: const Offset(0.95, 0.95), duration: 250.ms),
          const SizedBox(height: 32.0),

          // Multiple Choices Options
          Obx(() {
            return Column(
              children: [
                Wrap(
                  spacing: 16.0,
                  runSpacing: 16.0,
                  alignment: WrapAlignment.center,
                  children: controller.quizOptions.map((opt) {
                    final bool isOptSelected = controller.quizSelectedName.value == opt.name;
                    final bool isCorrect = opt.name == controller.quizCorrectAnimal.value.name;

                    Color cardBg = Colors.white.withOpacity(0.08);
                    Color borderCol = Colors.white.withOpacity(0.15);

                    if (controller.quizIsAnswered.value && isOptSelected) {
                      cardBg = isCorrect
                          ? AppColors.successGreen.withOpacity(0.25)
                          : Colors.redAccent.withOpacity(0.25);
                      borderCol = isCorrect ? AppColors.successGreen : Colors.redAccent;
                    }

                    return BouncyButton(
                      onTap: () => controller.checkQuizAnswer(opt.name),
                      child: Container(
                        width: 140.0,
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(20.0),
                          border: Border.all(color: borderCol, width: 2.0),
                          boxShadow: [
                            BoxShadow(
                              color: borderCol.withOpacity(0.1),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              opt.emoji,
                              style: const TextStyle(fontSize: 44.0),
                            ),
                            const SizedBox(height: 6.0),
                            Text(
                              opt.name,
                              style: AppTextStyles.bodySmallBold.copyWith(
                                fontSize: 14.0,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                )
                    .animate(target: controller.quizShakeOptions.value ? 1.0 : 0.0)
                    .shake(duration: 400.ms, hz: 6),
              ],
            );
          }),
          const SizedBox(height: 36.0),

          // Quiz Actions & Feedback
          Obx(() {
            if (controller.quizIsCorrect.value) {
              return Column(
                children: [
                  Text(
                    "🎉 Correct! You are an animal expert! +5 Coins 🪙",
                    style: AppTextStyles.bodyMediumBold.copyWith(color: AppColors.mint, fontSize: 16.0),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      HapticUtil.light();
                      controller.generateQuizQuestion();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mint,
                      padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 36.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                    ),
                    child: Text(
                      "Next Quiz ➔",
                      style: AppTextStyles.bodySmallBold.copyWith(
                        fontSize: 14.0,
                        color: AppColors.bgDark,
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return Text(
                "Listen to the clue and choose the correct animal!",
                style: AppTextStyles.bodySmall.copyWith(color: Colors.white30, fontSize: 14.0),
                textAlign: TextAlign.center,
              );
            }
          }),
        ],
      ),
    );
  }
}
