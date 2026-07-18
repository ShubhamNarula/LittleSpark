import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/haptic_util.dart';
import '../controllers/adventure_controller.dart';
import '../data/adventure_content_data.dart';
import '../models/adventure_stage_model.dart';
import '../models/adventure_world_model.dart';
import '../game/adventure_game_widget.dart';

class AdventureGameScreen extends StatefulWidget {
  const AdventureGameScreen({Key? key}) : super(key: key);

  @override
  State<AdventureGameScreen> createState() => _AdventureGameScreenState();
}

class _AdventureGameScreenState extends State<AdventureGameScreen> {
  late AdventureController _ctrl;
  AdventureStage? _stage;
  AdventureWorld? _world;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<AdventureController>();

    // Safely retrieve the stage from arguments or controller
    final argStage = Get.arguments as AdventureStage?;
    final stageVal = argStage ?? _ctrl.currentStage.value;

    if (stageVal == null) {
       debugPrint('⚠️ [GameScreen] Stage data is null (likely Hot Restart). Redirecting to lobby...');
       WidgetsBinding.instance.addPostFrameCallback((_) {
         Get.offAllNamed('/home');
         Get.toNamed('/learning-adventure');
       });
       return;
     }

    _stage = stageVal;
    if (_ctrl.currentStage.value == null) {
      _ctrl.currentStage.value = _stage;
    }

    final worldId = _stage!.worldId;
    _world = AdventureContentData.getWorld(worldId) ??
        AdventureContentData.worlds.first;

    _initialized = true;
    debugPrint('🐼 [GameScreen] Panda avatar ready. Stage: ${_stage!.worldId}, World: ${_world!.name}');

    // Start spawning after the first frame is painted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _ctrl.beginSpawning();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If not initialized (e.g. during redirect after hot restart), show a safe loading indicator
    if (!_initialized || _stage == null || _world == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF1A1040),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🐼', style: TextStyle(fontSize: 48)),
              SizedBox(height: 16),
              CircularProgressIndicator(color: Colors.white70),
            ],
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        if (_ctrl.gameState.value == GameState.playing) {
          _ctrl.pauseGame();
          return false;
        } else {
          _ctrl.quitToLobby();
          return false;
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // ── Game Canvas (Panda 3D perspective runner) ───────
            Positioned.fill(
              child: AdventureGameWidget(world: _world!),
            ),

            // ── Top HUD (Hearts & Score Cards) ──────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildTopHud(),
            ),

            // ── Bottom instruction banner ────────────────────────
            Positioned(
              bottom: 24,
              left: 12,
              right: 12,
              child: _buildInstructionBanner(),
            ),

            // ── Feedback message overlay ─────────────────────────
            // MUST wrap Obx INSIDE Positioned to prevent ParentDataWidget errors in Stack
            Positioned(
              top: MediaQuery.of(context).size.height * 0.35,
              left: 0,
              right: 0,
              child: Obx(() {
                if (!_ctrl.showFeedback.value) return const SizedBox.shrink();
                return Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.successGreen.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(color: AppColors.successGreen.withOpacity(0.5), blurRadius: 16),
                      ],
                    ),
                    child: Text(
                      _ctrl.feedbackMessage.value,
                      style: AppTextStyles.bodyLargeBold.copyWith(
                        color: Colors.white,
                        fontSize: 22,
                        fontFamily: 'FredokaOne',
                      ),
                    ),
                  )
                      .animate()
                      .scaleXY(begin: 0.5, end: 1.0, duration: 200.ms, curve: Curves.elasticOut)
                      .fadeIn(duration: 200.ms),
                );
              }),
            ),

            // ── Pause overlay ────────────────────────────────────
            // MUST wrap Obx INSIDE Positioned.fill to prevent ParentDataWidget errors in Stack
            Positioned.fill(
              child: Obx(() {
                if (_ctrl.gameState.value != GameState.paused) return const SizedBox.shrink();
                return Container(
                  color: Colors.black54,
                  child: Center(
                    child: _buildPauseOverlay(),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHud() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Obx(() {
          final currentLives = _ctrl.lives.value;
          final currentScore = _ctrl.score.value;
          final currentCombo = _ctrl.combo.value;
          final pu = _ctrl.activePowerUp.value;

          return Row(
            children: [
              // ⏸️ Pause button (Styled like a circular wooden/amber game button)
              GestureDetector(
                onTap: () {
                  HapticUtil.light();
                  _ctrl.pauseGame();
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade600,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.5),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: const Icon(Icons.pause_rounded, color: Colors.white, size: 24),
                ),
              ),
              const SizedBox(width: 12),

              // ❤️ Hearts Card (Bright white kid card with red border)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.redAccent, width: 2.5),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 4, offset: const Offset(0, 2)),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (i) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Text(
                        i < currentLives ? '❤️' : '🖤',
                        style: const TextStyle(fontSize: 20),
                      ),
                    );
                  }),
                ),
              ),
              const Spacer(),

              // 🔥 Combo Badge
              if (currentCombo >= 3) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Text(
                    '🔥 ×${_ctrl.multiplier}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      fontFamily: 'FredokaOne',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],

              // 🛡️ active power up badge
              if (pu != PowerUpType.none) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purpleAccent,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Text(
                    pu == PowerUpType.shield ? '🛡️' : pu == PowerUpType.jetpack ? '🚀' : '✨',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(width: 8),
              ],

              // ⭐ Score Card (Bright white card with gold border)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.amber, width: 2.5),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 4, offset: const Offset(0, 2)),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('⭐', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 6),
                    Text(
                      '$currentScore',
                      style: AppTextStyles.bodyMediumBold.copyWith(
                        color: Colors.amber.shade800,
                        fontSize: 16,
                        fontFamily: 'FredokaOne',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildInstructionBanner() {
    return Obx(() {
      final collected = _ctrl.correctCollected.value;
      final target = _stage!.targetCollectCount;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.skyBlue, width: 3),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            // Instruction Emoji Card
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.skyBlue.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Text(_stage!.instructionEmoji, style: const TextStyle(fontSize: 32)),
            ),
            const SizedBox(width: 14),

            // Instruction Text and Progress
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _stage!.instruction,
                    style: AppTextStyles.bodyMediumBold.copyWith(
                      color: Colors.blue.shade900,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: (collected / target).clamp(0.0, 1.0),
                      backgroundColor: Colors.blue.shade50.withOpacity(0.8),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.successGreen),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Count Indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.successGreen.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.successGreen, width: 1.5),
              ),
              child: Text(
                '$collected/$target',
                style: AppTextStyles.bodySmallBold.copyWith(
                  color: AppColors.successGreen,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildPauseOverlay() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.bgMid,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(color: Colors.black45, blurRadius: 24),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '⏸️ Paused',
            style: AppTextStyles.displaySmall.copyWith(
              color: Colors.white,
              fontFamily: 'FredokaOne',
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Take a deep breath! 😊',
            style: AppTextStyles.bodySmall.copyWith(color: Colors.white60),
          ),
          const SizedBox(height: 28),
          _pauseButton('▶️  Resume', AppColors.successGreen, () {
            _ctrl.resumeGame();
          }),
          const SizedBox(height: 12),
          _pauseButton('🏠  Go to Lobby', AppColors.coral, () {
            _ctrl.quitToLobby();
          }),
        ],
      ),
    ).animate().scaleXY(begin: 0.8, end: 1.0, duration: 300.ms, curve: Curves.elasticOut);
  }

  Widget _pauseButton(String text, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticUtil.medium();
        onTap();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Text(
          text,
          style: AppTextStyles.bodyMediumBold.copyWith(color: color, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
