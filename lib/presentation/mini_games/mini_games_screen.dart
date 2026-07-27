import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../shared/widgets/gradient_app_bar.dart';
import '../shared/widgets/bouncy_button.dart';
import '../../core/utils/haptic_util.dart';
import 'mini_games_controller.dart';
import 'games/bubble_pop_game.dart';
import 'games/memory_match_game.dart';
import 'games/color_catcher_game.dart';
import 'games/shape_builder_game.dart';
import 'games/treasure_hunt_game.dart';
import 'games/word_scramble_game.dart';
import 'games/math_wizard_game.dart';
import 'games/pattern_match_game.dart';
import 'games/spin_wheel_game.dart';

class MiniGamesScreen extends GetView<MiniGamesController> {
  const MiniGamesScreen({Key? key}) : super(key: key);

  static const List<List<Color>> _cardGradients = [
    [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
    [Color(0xFF4ECDC4), Color(0xFF44A08D)],
    [Color(0xFFC084FC), Color(0xFF818CF8)],
    [Color(0xFF60A5FA), Color(0xFF3B82F6)],
    [Color(0xFFFFD700), Color(0xFFF59E0B)],
    [Color(0xFFF472B6), Color(0xFFEC4899)],
  ];

  void _launchGame(int index) {
    HapticUtil.medium();
    Widget gameScreen;
    switch (index) {
      case 0:
        gameScreen = const BubblePopGame();
        break;
      case 1:
        gameScreen = const MemoryMatchGame();
        break;
      case 2:
        gameScreen = const ColorCatcherGame();
        break;
      case 3:
        gameScreen = const ShapeBuilderGame();
        break;
      case 4:
        gameScreen = const TreasureHuntGame();
        break;
      case 5:
        gameScreen = const WordScrambleGame();
        break;
      case 6:
        gameScreen = const MathWizardGame();
        break;
      case 7:
        gameScreen = const PatternMatchGame();
        break;
      case 8:
        gameScreen = const SpinWheelGame();
        break;
      default:
        return;
    }
    Get.to(() => gameScreen, transition: Transition.zoom);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Column(
        children: [
          // App Bar
          const GradientAppBar(
            title: "Mini Games 🎮",
            gradient: AppColors.miniGamesGradient,
          ),

          // Stats bar
          Obx(() => Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatBadge("🎮", "${controller.miniGamesPlayed.value}", "Played"),
                    _buildStatBadge("🪙", "${controller.coins.value}", "Coins"),
                  ],
                ),
              )),

          // Game Cards List
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                top: 8.0,
                bottom: 24.0 + (MediaQuery.of(context).padding.bottom > 0 ? MediaQuery.of(context).padding.bottom : 0.0),
              ),
              physics: const BouncingScrollPhysics(),
              itemCount: controller.games.length,
              itemBuilder: (ctx, i) {
                final game = controller.games[i];
                final gradient = _cardGradients[i % _cardGradients.length];
                final highScore = controller.getHighScore(game.gameId);

                return _buildGameCard(game, gradient, highScore, i)
                    .animate(delay: Duration(milliseconds: i * 100))
                    .slideX(begin: 0.3, end: 0.0, duration: const Duration(milliseconds: 400), curve: Curves.easeOutCubic)
                    .fadeIn(duration: const Duration(milliseconds: 400));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge(String icon, String value, String label) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 18.0)),
            const SizedBox(width: 6.0),
            Text(
              value,
              style: AppTextStyles.bodyMediumBold.copyWith(
                color: AppColors.gold,
                fontSize: 16.0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2.0),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: Colors.white38,
            fontSize: 12.0,
          ),
        ),
      ],
    );
  }

  Widget _buildGameCard(MiniGameInfo game, List<Color> gradient, int highScore, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14.0),
      child: BouncyButton(
        onTap: () => _launchGame(index),
        child: Container(
          padding: const EdgeInsets.all(18.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24.0),
            boxShadow: [
              BoxShadow(
                color: gradient[0].withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              // Game emoji with pulsing glow
              Container(
                width: 70.0,
                height: 70.0,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Center(
                  child: Text(
                    game.emoji,
                    style: const TextStyle(fontSize: 38.0),
                  )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scale(
                        begin: const Offset(0.9, 0.9),
                        end: const Offset(1.1, 1.1),
                        duration: const Duration(seconds: 2),
                        curve: Curves.easeInOut,
                      ),
                ),
              ),
              const SizedBox(width: 16.0),

              // Game info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game.name,
                      style: AppTextStyles.bodyLargeBold.copyWith(
                        color: Colors.white,
                        fontSize: 18.0,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      game.description,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 13.0,
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    Row(
                      children: [
                        // Difficulty stars
                        ...List.generate(3, (si) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 2.0),
                            child: Icon(
                              si < game.difficultyStars ? Icons.star_rounded : Icons.star_outline_rounded,
                              size: 16.0,
                              color: si < game.difficultyStars ? AppColors.gold : Colors.white38,
                            ),
                          );
                        }),
                        const Spacer(),
                        if (highScore > 0)
                          Text(
                            "Best: $highScore",
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white70,
                              fontSize: 12.0,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Play arrow
              Container(
                width: 42.0,
                height: 42.0,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 28.0,
                ),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(
                    begin: const Offset(0.95, 0.95),
                    end: const Offset(1.1, 1.1),
                    duration: const Duration(seconds: 1),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
