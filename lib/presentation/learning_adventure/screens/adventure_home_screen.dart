import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/haptic_util.dart';
import '../../../services/progress_service.dart';
import '../controllers/adventure_controller.dart';
import '../data/adventure_content_data.dart';
import '../models/adventure_world_model.dart';
import '../models/adventure_stage_model.dart';

class AdventureHomeScreen extends StatelessWidget {
  const AdventureHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdventureController>();
    final progress = ProgressService.to;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Stack(
        children: [
          // ── Animated background particles ───────────────────
          Positioned.fill(
            child: _BackgroundParticles(),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                _buildHeader(controller, progress),

                const SizedBox(height: 12),

                // Section title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '🌍 Choose Your World',
                    style: AppTextStyles.displaySmall.copyWith(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideX(begin: -0.2, end: 0),
                ),

                const SizedBox(height: 8),

                // World cards
                Expanded(
                  child: _buildWorldList(controller, progress),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AdventureController ctrl, ProgressService progress) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.adventureGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              HapticUtil.light();
              Get.back();
            },
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🏃 Learning Adventure',
                  style: AppTextStyles.displaySmall.copyWith(
                    fontSize: 20,
                    color: Colors.white,
                    fontFamily: 'FredokaOne',
                  ),
                ),
                const SizedBox(height: 4),
                Obx(() => Text(
                      'Stage ${progress.adventureUnlockedStage} Unlocked • High Score: ${progress.adventureHighScore}',
                      style: AppTextStyles.bodySmall.copyWith(color: Colors.white70, fontSize: 12),
                    )),
              ],
            ),
          ),
          // Stats column
          Obx(() => Column(
                children: [
                  _buildStatChip('⭐', '${progress.adventureTotalStars}', AppColors.gold),
                  const SizedBox(height: 4),
                  _buildStatChip('🪙', '${progress.coins}', AppColors.warningOrange),
                ],
              )),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildStatChip(String icon, String val, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(val, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Nunito')),
        ],
      ),
    );
  }

  Widget _buildWorldList(AdventureController ctrl, ProgressService progress) {
    final worlds = AdventureContentData.worlds;
    return Builder(builder: (ctx) {
      final bottomInset = MediaQuery.of(ctx).padding.bottom;
      return ListView.builder(
        padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 16 + (bottomInset > 0 ? bottomInset : 0.0)),
        physics: const BouncingScrollPhysics(),
        itemCount: worlds.length,
      itemBuilder: (ctx, i) {
        final world = worlds[i];
        final worldStages = AdventureContentData.getWorldStages(world.id);
        final firstStageNum = worldStages.isNotEmpty ? worldStages.first.stageNumber : 1;
        final isUnlocked = progress.adventureUnlockedStage >= firstStageNum;

        return _WorldCard(
          world: world,
          controller: ctrl,
          progress: progress,
          stages: worldStages,
          isUnlocked: isUnlocked,
          delay: i * 80,
        ).animate(delay: (i * 80).ms).slideX(begin: 0.3, end: 0, duration: 400.ms).fadeIn(duration: 400.ms);
      },
    );
    });
  }
}

// ─────────────────────────────────────────────────────────────────
// World Card
// ─────────────────────────────────────────────────────────────────
class _WorldCard extends StatelessWidget {
  final AdventureWorld world;
  final AdventureController controller;
  final ProgressService progress;
  final List<AdventureStage> stages;
  final bool isUnlocked;
  final int delay;

  const _WorldCard({
    required this.world,
    required this.controller,
    required this.progress,
    required this.stages,
    required this.isUnlocked,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isUnlocked
          ? () {
              HapticUtil.medium();
              _launchWorld();
            }
          : () {
              HapticUtil.light();
              Get.rawSnackbar(
                title: '🔒 Locked',
                message: 'Complete earlier stages to unlock ${world.name}!',
                duration: const Duration(seconds: 2),
                backgroundColor: Colors.white10,
                borderRadius: 12,
                margin: const EdgeInsets.all(12),
              );
            },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isUnlocked
                ? world.gradientColors
                : [Colors.grey.shade800, Colors.grey.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: (isUnlocked ? world.gradientColors[0] : Colors.grey).withOpacity(0.35),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // World emoji with pulsing animation
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(world.emoji, style: const TextStyle(fontSize: 38)),
                ),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(
                    begin: const Offset(0.92, 0.92),
                    end: const Offset(1.08, 1.08),
                    duration: const Duration(milliseconds: 1800),
                    curve: Curves.easeInOut,
                  ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            world.name,
                            style: AppTextStyles.bodyLargeBold.copyWith(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        if (!isUnlocked)
                          const Icon(Icons.lock_rounded, color: Colors.white54, size: 20),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      world.description,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Stage progress bar
                    _buildStageProgress(),
                  ],
                ),
              ),

              if (isUnlocked) ...[
                const SizedBox(width: 12),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(
                      begin: const Offset(0.9, 0.9),
                      end: const Offset(1.1, 1.1),
                      duration: const Duration(milliseconds: 1000),
                    ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStageProgress() {
    final completedStages = stages
        .where((s) => progress.adventureUnlockedStage > s.stageNumber)
        .length;
    final total = stages.length;
    final ratio = total > 0 ? completedStages / total : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio.clamp(0.0, 1.0),
            backgroundColor: Colors.white.withOpacity(0.15),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$completedStages / $total stages',
          style: AppTextStyles.bodySmall.copyWith(color: Colors.white60, fontSize: 11),
        ),
      ],
    );
  }

  void _launchWorld() {
    if (stages.isEmpty) return;

    // Find the next unlocked (or first) stage for this world
    AdventureStage nextStage = stages.first;
    for (final s in stages) {
      if (s.stageNumber >= progress.adventureUnlockedStage) {
        nextStage = s;
        break;
      }
    }
    controller.startStage(nextStage);
  }
}

// ─────────────────────────────────────────────────────────────────
// Background animated particles
// ─────────────────────────────────────────────────────────────────
class _BackgroundParticles extends StatelessWidget {
  const _BackgroundParticles();

  @override
  Widget build(BuildContext context) {
    const particles = ['⭐', '🌟', '✨', '💫', '🎯', '🎮'];
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    if (width <= 0 || height <= 0) return const SizedBox.shrink();

    return Stack(
      children: List.generate(12, (i) {
        final x = (i * 73.0) % width;
        final y = (i * 131.0) % height;
        return Positioned(
          left: x,
          top: y,
          child: Text(
            particles[i % particles.length],
            style: TextStyle(fontSize: 16 + (i % 3) * 6.0, color: Colors.white.withOpacity(0.07)),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .moveY(
                begin: 0,
                end: -20,
                duration: Duration(seconds: 3 + (i % 3)),
                curve: Curves.easeInOut,
              )
              .fadeIn(duration: const Duration(seconds: 1)),
        );
      }),
    );
  }
}
