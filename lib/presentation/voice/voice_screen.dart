import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../shared/widgets/gradient_app_bar.dart';
import 'voice_controller.dart';
import '../shared/widgets/bouncy_button.dart';
import '../../core/utils/haptic_util.dart';

class VoiceScreen extends GetView<VoiceController> {
  const VoiceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categories = ["Animals", "Letters", "Numbers", "Colors", "Greetings"];
    final PageController pageController = PageController();

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Column(
        children: [
          // Gradient App Bar
          const GradientAppBar(
            title: "Say It! 🎤",
            gradient: AppColors.voiceGradient,
          ),

          // Horizontal Category Chip Selector
          SizedBox(
            height: 60.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                return Obx(() {
                  final isSelected = controller.selectedCategory.value == cat;
                  return _buildCategoryChip(cat, isSelected, pageController);
                });
              },
            ),
          ),

          // Words PageView Slider
          Expanded(
            child: Obx(() {
              final words = controller.currentCategoryWords;
              if (words.isEmpty) {
                return const Center(child: Text("No words found! 🎤"));
              }

              // Jump or animate page controller reset on category change
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (pageController.hasClients && pageController.page?.round() != controller.currentCardIndex.value) {
                  pageController.jumpToPage(controller.currentCardIndex.value);
                }
              });

              return PageView.builder(
                controller: pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: controller.onCardChanged,
                itemCount: words.length,
                itemBuilder: (ctx, i) {
                  return WordCard(word: words[i])
                      .animate()
                      .scale(begin: const Offset(0.9, 0.9), duration: 250.ms)
                      .fadeIn();
                },
              );
            }),
          ),

          // Mic Section (Bottom Area)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            decoration: const BoxDecoration(
              color: AppColors.bgMid,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(32.0),
                topRight: Radius.circular(32.0),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Try saying it! 🗣️",
                  style: AppTextStyles.bodyLargeBold.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 14.0),
                
                // Mic Button (Glowing scale container)
                GestureDetector(
                  onTap: controller.onMicTap,
                  child: Obx(() {
                    final listening = controller.isListening.value;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: listening ? 90.0 : 72.0,
                      height: listening ? 90.0 : 72.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: listening
                              ? const [AppColors.coral, AppColors.warningOrange]
                              : const [AppColors.mint, Color(0xFF44A08D)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: listening
                            ? [
                                BoxShadow(
                                  color: AppColors.coral.withOpacity(0.6),
                                  blurRadius: 20,
                                  spreadRadius: 4,
                                )
                              ]
                            : [
                                BoxShadow(
                                  color: AppColors.mint.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ],
                      ),
                      child: Center(
                        child: Text(
                          "🎤",
                          style: TextStyle(
                            fontSize: listening ? 40.0 : 32.0,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 12.0),
                
                // Listening Status Text
                Obx(() => Text(
                      controller.isListening.value ? "Listening... 👂" : "Tap mic to practice!",
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white70),
                    )),
                
                // spoken result match text
                Obx(() {
                  final recognized = controller.lastResult.value;
                  if (recognized.isNotEmpty) {
                    return Container(
                      margin: const EdgeInsets.only(top: 14.0),
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                      decoration: BoxDecoration(
                        color: AppColors.successGreen.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14.0),
                        border: Border.all(color: AppColors.successGreen.withOpacity(0.3)),
                      ),
                      child: Text(
                        "You said: '$recognized' 🌟",
                        style: AppTextStyles.bodyMediumBold.copyWith(color: AppColors.successGreen),
                        textAlign: TextAlign.center,
                      ),
                    )
                        .animate()
                        .shake(duration: 400.ms);
                  }
                  return const SizedBox.shrink();
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected, PageController pc) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      child: BouncyButton(
        onTap: () {
          HapticUtil.light();
          controller.changeCategory(label);
          if (pc.hasClients) {
            pc.jumpToPage(0);
          }
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
                fontSize: 14.0, // Enforce 14sp minimum
                color: isSelected ? AppColors.bgDark : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class WordCard extends StatelessWidget {
  final VoiceWordModel word;

  const WordCard({
    Key? key,
    required this.word,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VoiceController>();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(28.0),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Emoji (80sp)
          Text(
            word.emoji,
            style: const TextStyle(fontSize: 80.0),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .moveY(begin: 0, end: -6.0, duration: const Duration(seconds: 2), curve: Curves.easeInOut),
          const SizedBox(height: 16.0),
          
          // Word string text
          Text(
            word.word,
            style: AppTextStyles.displayLarge.copyWith(fontSize: 42.0),
          ),
          const SizedBox(height: 16.0),

          // Syllable breaking layout
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: word.syllables.map((syl) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 3.0),
                padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: AppColors.skyBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: AppColors.skyBlue.withOpacity(0.3)),
                ),
                child: Text(
                  syl,
                  style: AppTextStyles.bodyMediumBold.copyWith(
                    fontSize: 16.0,
                    color: AppColors.skyBlue,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24.0),

          // Hear voice speak button
          BouncyButton(
            onTap: () {
              HapticUtil.light();
              controller.speak(word.word);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: AppColors.coral,
                borderRadius: BorderRadius.circular(14.0),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.coral.withOpacity(0.3),
                    blurRadius: 8.0,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                "🔊 Listen first",
                style: AppTextStyles.bodySmallBold.copyWith(
                  fontSize: 14.0, // Enforce 14sp minimum
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
