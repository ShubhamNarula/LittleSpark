import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../shared/widgets/gradient_app_bar.dart';
import '../shared/widgets/progress_chip_widget.dart';
import '../shared/widgets/confetti_overlay_widget.dart';
import '../shared/widgets/bouncy_button.dart';
import '../../core/utils/haptic_util.dart';
import 'numbers_controller.dart';
import '../../services/tts_service.dart';
import 'widgets/number_cell_widget.dart';

class NumbersScreen extends GetView<NumbersController> {
  const NumbersScreen({Key? key}) : super(key: key);

  Color _getColorBand(int val) {
    if (val <= 10) return const Color(0xFF60A5FA); // blue
    if (val <= 20) return const Color(0xFF22C55E); // green
    if (val <= 50) return const Color(0xFFC084FC); // purple
    if (val <= 100) return const Color(0xFFFB923C); // orange
    if (val <= 500) return const Color(0xFFFF69B4); // pink
    return const Color(0xFF4ECDC4); // teal
  }

  @override
  Widget build(BuildContext context) {
    // Reset active tab to Learn Grid (0) on entry and stop any speech
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.activeTab.value = 0;
      TtsService.to.stop();
    });

    final GlobalKey<ConfettiOverlayWidgetState> confettiKey =
        GlobalKey<ConfettiOverlayWidgetState>();

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Stack(
        children: [
          Column(
            children: [
              // Custom App Bar with stars
              Obx(() => GradientAppBar(
                    title: "Count with Me! 🔢",
                    gradient: AppColors.numbersGradient,
                    trailing: ProgressChipWidget(
                      done: controller.visitedNumbers.length,
                      total: 100,
                    ),
                  )),

              Expanded(
                child: SafeArea(
                  top: false,
                  child: Column(
                    children: [
                      // Tab Select Bar
                      _buildTabBar(),

                      // Main view
                      Expanded(
                        child: Obx(() {
                          if (controller.activeTab.value == 0) {
                            return _buildLearnView();
                          } else {
                            // Trigger confetti on correct game answer
                            if (controller.gameIsCorrect.value) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                confettiKey.currentState?.startCelebration();
                              });
                            }
                            return _buildPlayGamesView();
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
            child: _buildTabButton("Learn Grid 🔢", 0),
          ),
          Expanded(
            child: _buildTabButton("Play Games 🎮", 1),
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

  // --- Learn tab contents ---
  Widget _buildLearnView() {
    return Column(
      children: [
        // Horizontal range selector chips
        SizedBox(
          height: 52.0,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            itemCount: NumbersController.ranges.length,
            itemBuilder: (ctx, index) {
              final range = NumbersController.ranges[index];
              return Obx(() {
                final isSelected = controller.currentRangeIndex.value == index;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: BouncyButton(
                    onTap: () {
                      HapticUtil.light();
                      controller.loadRange(index);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.gold : Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(
                          color: isSelected ? AppColors.gold : Colors.white.withOpacity(0.12),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        range['label'] as String,
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

        // Count Along active display banner
        Obx(() {
          if (controller.isCountAlongMode.value) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
              decoration: BoxDecoration(
                color: AppColors.gold,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: Text(
                "Counting: ${controller.countAlongCurrent.value}! 🎵",
                style: AppTextStyles.bodyMediumBold.copyWith(
                  color: AppColors.bgDark,
                  fontSize: 16.0,
                ),
                textAlign: TextAlign.center,
              ),
            );
          }
          return const SizedBox.shrink();
        }),

        // Grid numbers
        Expanded(
          child: Obx(() {
            // Adaptive columns for readability
            final range = NumbersController.ranges[controller.currentRangeIndex.value];
            final maxVal = range['max'] as int;
            int colCount = 5;
            if (maxVal <= 20) colCount = 3;
            else if (maxVal <= 100) colCount = 5;
            else colCount = 3; // larger cells for 3-digit numbers

            return GridView.builder(
              padding: const EdgeInsets.all(12.0),
              physics: const BouncingScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: colCount,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio: colCount == 3 ? 1.2 : 1.0,
              ),
              itemCount: controller.numbersList.length,
              itemBuilder: (ctx, i) {
                final numItem = controller.numbersList[i];
                final isVisited = controller.visitedNumbers.contains(numItem.number);
                final isHighlighted = (controller.countAlongCurrent.value == numItem.number);
                
                return NumberCellWidget(
                  number: numItem.number,
                  colorBand: _getColorBand(numItem.number),
                  isVisited: isVisited,
                  isHighlighted: isHighlighted,
                  onTap: () => controller.onNumberTap(numItem),
                )
                    .animate(delay: (i % 30 * 15).ms)
                    .scale(begin: const Offset(0.7, 0.7), duration: 250.ms);
              },
            );
          }),
        ),

        // Controls bar
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 20.0, top: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(() => Text(
                    "${controller.visitedNumbers.length}/100 explored",
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 14.0,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  )),
              GestureDetector(
                onTap: () {
                  HapticUtil.light();
                  if (controller.isCountAlongMode.value) {
                    controller.stopCountAlong();
                  } else {
                    controller.startCountAlong();
                  }
                },
                child: Obx(() => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.mint, Color(0xFF44A08D)],
                        ),
                        borderRadius: BorderRadius.circular(14.0),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.mint.withOpacity(0.3),
                            blurRadius: 8.0,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        controller.isCountAlongMode.value ? "⏹ Stop" : "▶ Count Along 🎵",
                        style: AppTextStyles.bodySmallBold.copyWith(
                          fontSize: 14.0,
                          color: Colors.white,
                        ),
                      ),
                    )),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Play Games tab contents ---
  Widget _buildPlayGamesView() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Question card
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: AppColors.bgMid,
              borderRadius: BorderRadius.circular(24.0),
              border: Border.all(color: Colors.white.withOpacity(0.12), width: 1.5),
            ),
            child: Column(
              children: [
                Text(
                  "Math Fun Time! 🎒",
                  style: AppTextStyles.bodyMediumBold.copyWith(color: AppColors.gold, fontSize: 16.0),
                ),
                const SizedBox(height: 12.0),
                Text(
                  controller.gameQuestion.value,
                  style: AppTextStyles.displaySmall.copyWith(fontSize: 22.0),
                  textAlign: TextAlign.center,
                ),
                
                // Extra UI for Object Counting type (render emojis dynamically)
                if (controller.currentGameType.value == 0) ...[
                  const SizedBox(height: 20.0),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    alignment: Alignment.center,
                    child: Wrap(
                      spacing: 12.0,
                      runSpacing: 12.0,
                      alignment: WrapAlignment.center,
                      children: List.generate(
                        controller.gameCount.value,
                        (index) => Text(
                          controller.gameEmoji.value,
                          style: const TextStyle(fontSize: 38.0),
                        )
                            .animate(delay: (index * 80).ms)
                            .scale(begin: const Offset(0.3, 0.3), duration: 400.ms, curve: Curves.elasticOut),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 32.0),

          // Options Choices
          Obx(() {
            return Column(
              children: [
                Wrap(
                  spacing: 16.0,
                  runSpacing: 16.0,
                  alignment: WrapAlignment.center,
                  children: controller.gameOptions.map((opt) {
                    final bool isOptSelected = controller.gameSelectedOption.value == opt;
                    final bool isCorrect = opt == controller.gameCorrectAnswer.value;

                    Color cardBg = Colors.white.withOpacity(0.08);
                    Color borderCol = Colors.white.withOpacity(0.15);

                    if (controller.gameIsAnswered.value && isOptSelected) {
                      cardBg = isCorrect
                          ? AppColors.successGreen.withOpacity(0.25)
                          : Colors.redAccent.withOpacity(0.25);
                      borderCol = isCorrect ? AppColors.successGreen : Colors.redAccent;
                    }

                    return BouncyButton(
                      onTap: () => controller.checkGameAnswer(opt),
                      child: Container(
                        constraints: const BoxConstraints(minWidth: 90.0),
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
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
                        child: Text(
                          opt,
                          style: AppTextStyles.displaySmall.copyWith(fontSize: 26.0),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }).toList(),
                )
                    .animate(target: controller.gameShakeOptions.value ? 1.0 : 0.0)
                    .shake(duration: 400.ms, hz: 6),
              ],
            );
          }),
          const SizedBox(height: 36.0),

          // Footer Feedback
          Obx(() {
            if (controller.gameIsCorrect.value) {
              return Column(
                children: [
                  Text(
                    "🎉 Brilliant! You got it right! +5 Coins 🪙",
                    style: AppTextStyles.bodyMediumBold.copyWith(color: AppColors.mint, fontSize: 16.0),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      HapticUtil.light();
                      controller.generateNewGame();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mint,
                      padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 36.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                    ),
                    child: Text(
                      "Next Game ➔",
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
                "Choose the correct option to earn gold stars!",
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
