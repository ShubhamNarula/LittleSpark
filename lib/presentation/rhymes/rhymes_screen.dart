import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../shared/widgets/gradient_app_bar.dart';
import '../shared/widgets/bouncy_button.dart';
import '../../core/utils/haptic_util.dart';
import 'rhymes_controller.dart';
import '../../data/models/rhyme_model.dart';
import 'widgets/rhyme_player_screen.dart';

class RhymesScreen extends GetView<RhymesController> {
  const RhymesScreen({Key? key}) : super(key: key);

  static const List<List<Color>> _cardGradients = [
    [Color(0xFFEC4899), Color(0xFFF472B6)], // pink
    [Color(0xFF8B5CF6), Color(0xFFA78BFA)], // purple
    [Color(0xFF3B82F6), Color(0xFF60A5FA)], // blue
    [Color(0xFF10B981), Color(0xFF34D399)], // green
    [Color(0xFFF59E0B), Color(0xFFFBBF24)], // amber
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Column(
        children: [
          // Gradient App Bar (No SafeArea around Column)
          const GradientAppBar(
            title: "Rhymes & Poems 🎵",
            gradient: AppColors.rhymesGradient,
            showLeading: true,
          ),

          Expanded(
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 12.0),
                    // Language Toggle Selector
                    _buildLanguageToggle(),
                    const SizedBox(height: 10.0),

                    // Featured Poem of the Day
                    Obx(() {
                      final pod = controller.poemOfTheDay.value;
                      if (pod == null) return const SizedBox.shrink();
                      return _buildPoemOfTheDayCard(pod);
                    }),

                    // Today's Playlist Heading
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                      child: Row(
                        children: [
                          const Icon(Icons.music_note_rounded, color: AppColors.gold, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            "Today's Playlist 🎶",
                            style: AppTextStyles.bodyLargeBold.copyWith(
                              fontFamily: 'FredokaOne',
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Rhymes Grid
                    Obx(() {
                      final list = controller.filteredRhymes;
                      if (list.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40.0),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("🎵", style: TextStyle(fontSize: 48)),
                                const SizedBox(height: 12),
                                Text(
                                  "No poems in this category yet!",
                                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white54),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final screenSize = MediaQuery.of(context).size;
                      final bottomInset = MediaQuery.of(context).padding.bottom;
                      final double dynamicAspectRatio = screenSize.height < 680
                          ? 1.05
                          : (screenSize.height < 780 ? 1.0 : 0.95);

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 24.0 + (bottomInset > 0 ? bottomInset : 0.0)),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12.0,
                          mainAxisSpacing: 12.0,
                          childAspectRatio: dynamicAspectRatio,
                        ),
                        itemCount: list.length,
                        itemBuilder: (ctx, i) {
                          final rhyme = list[i];
                          final gradient = _cardGradients[i % _cardGradients.length];
                          return _buildRhymeCard(rhyme, gradient, i);
                        },
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildLangButton("English 🇬🇧", "English"),
          ),
          Expanded(
            child: _buildLangButton("हिन्दी 🇮🇳", "Hindi"),
          ),
        ],
      ),
    );
  }

  Widget _buildLangButton(String label, String langVal) {
    return Obx(() {
      final isSelected = controller.activeLanguage.value == langVal;
      return GestureDetector(
        onTap: () => controller.setLanguage(langVal),
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

  Widget _buildPoemOfTheDayCard(RhymeModel poem) {
    return BouncyButton(
      onTap: () {
        controller.startRhyme(poem);
        Get.to(() => const RhymePlayerScreen(), transition: Transition.fadeIn);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28.0),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFEC4899).withOpacity(0.35),
              blurRadius: 14.0,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              bottom: -10,
              child: Opacity(
                opacity: 0.15,
                child: Text(
                  poem.emoji,
                  style: const TextStyle(fontSize: 100),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Text(
                    "⭐ POEM OF THE DAY",
                    style: AppTextStyles.bodySmallBold.copyWith(
                      color: Colors.white,
                      fontSize: 12,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Big circular Emoji badge
                    Container(
                      width: 64.0,
                      height: 64.0,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          poem.emoji,
                          style: const TextStyle(fontSize: 36.0),
                        ),
                      ),
                    ).animate(onPlay: (c) => c.repeat(reverse: true))
                     .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: const Duration(milliseconds: 1500), curve: Curves.easeInOut),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            poem.title,
                            style: AppTextStyles.bodyExtraLarge.copyWith(
                              fontFamily: 'FredokaOne',
                              color: Colors.white,
                              fontSize: 18.0,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6.0),
                          Row(
                            children: [
                              const Icon(Icons.music_note_rounded, color: AppColors.gold, size: 16.0),
                              const SizedBox(width: 4),
                              Text(
                                "Language: ${poem.language}",
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "Listen Now",
                      style: AppTextStyles.bodyMediumBold.copyWith(color: AppColors.gold),
                    ),
                    const SizedBox(width: 6.0),
                    Container(
                      padding: const EdgeInsets.all(6.0),
                      decoration: const BoxDecoration(
                        color: AppColors.gold,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: AppColors.bgDark,
                        size: 18.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRhymeCard(RhymeModel rhyme, List<Color> gradient, int index) {
    return BouncyButton(
      onTap: () {
        controller.startRhyme(rhyme);
        Get.to(() => const RhymePlayerScreen(), transition: Transition.fadeIn);
      },
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24.0),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Emoji container
            Container(
              width: 52.0,
              height: 52.0,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  rhyme.emoji,
                  style: const TextStyle(fontSize: 28.0),
                ),
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: const Duration(milliseconds: 1500), curve: Curves.easeInOut),
            const SizedBox(height: 10.0),

            // Rhyme Title
            Text(
              rhyme.title,
              style: AppTextStyles.bodyMediumBold.copyWith(
                color: Colors.white,
                fontSize: 14.0,
                shadows: [
                  const Shadow(
                    color: Colors.black26,
                    offset: Offset(0, 1),
                    blurRadius: 2.0,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6.0),

            // Play Icon Badge
            Container(
              padding: const EdgeInsets.all(4.0),
              decoration: const BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 18.0,
              ),
            ),
          ],
        ),
      ),
    )
        .animate(delay: (index * 60).ms)
        .slideY(begin: 0.2, end: 0.0, duration: 250.ms, curve: Curves.easeOutQuad)
        .fadeIn(duration: 250.ms);
  }
}
