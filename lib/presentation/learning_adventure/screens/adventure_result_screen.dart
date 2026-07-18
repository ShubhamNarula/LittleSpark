import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/haptic_util.dart';
import '../controllers/adventure_controller.dart';
import '../data/adventure_content_data.dart';

class AdventureResultScreen extends StatefulWidget {
  const AdventureResultScreen({Key? key}) : super(key: key);

  @override
  State<AdventureResultScreen> createState() => _AdventureResultScreenState();
}

class _AdventureResultScreenState extends State<AdventureResultScreen> {
  late ConfettiController _confettiController;
  late AdventureController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<AdventureController>();
    if (_ctrl.currentStage.value == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAllNamed('/home');
        Get.toNamed('/learning-adventure');
      });
      return;
    }
    _confettiController = ConfettiController(duration: const Duration(seconds: 4));

    if (_ctrl.gameState.value == GameState.stageComplete) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _confettiController.play();
      });
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  bool get _isWin => _ctrl.gameState.value == GameState.stageComplete;

  @override
  Widget build(BuildContext context) {
    final stage = _ctrl.currentStage.value;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Stack(
        children: [
          // ── Background gradient ────────────────────────────────
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isWin
                      ? [const Color(0xFF0D3D2A), const Color(0xFF1A6B45)]
                      : [const Color(0xFF3D0D0D), const Color(0xFF6B1A1A)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // ── Confetti ──────────────────────────────────────────
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 30,
              gravity: 0.2,
              colors: const [
                AppColors.gold,
                AppColors.coral,
                AppColors.mint,
                AppColors.lavender,
                AppColors.successGreen,
              ],
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Result emoji + title
                  _buildResultHeader()
                      .animate()
                      .scaleXY(begin: 0.5, end: 1.0, duration: 500.ms, curve: Curves.elasticOut)
                      .fadeIn(duration: 400.ms),

                  const SizedBox(height: 28),

                  // Stars earned
                  _buildStarsRow()
                      .animate(delay: 300.ms)
                      .slideY(begin: 0.3, end: 0, duration: 400.ms)
                      .fadeIn(duration: 400.ms),

                  const SizedBox(height: 28),

                  // Score breakdown
                  _buildScoreCard()
                      .animate(delay: 500.ms)
                      .slideY(begin: 0.3, end: 0, duration: 400.ms)
                      .fadeIn(duration: 400.ms),

                  const SizedBox(height: 28),

                  // Reward breakdown
                  _buildRewardCard()
                      .animate(delay: 700.ms)
                      .slideY(begin: 0.3, end: 0, duration: 400.ms)
                      .fadeIn(duration: 400.ms),

                  const SizedBox(height: 32),

                  // Action buttons
                  _buildActionButtons()
                      .animate(delay: 900.ms)
                      .slideY(begin: 0.3, end: 0, duration: 400.ms)
                      .fadeIn(duration: 400.ms),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultHeader() {
    return Column(
      children: [
        Text(
          _isWin ? '🏆' : '💔',
          style: const TextStyle(fontSize: 80),
        ),
        const SizedBox(height: 12),
        Text(
          _isWin ? 'Stage Complete!' : 'Game Over',
          style: AppTextStyles.displaySmall.copyWith(
            fontSize: 32,
            color: Colors.white,
            fontFamily: 'FredokaOne',
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          _isWin
              ? 'Amazing job, champion! 🌟'
              : 'Keep trying! You\'re getting better! 💪',
          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStarsRow() {
    final stars = _ctrl.starsEarned.value;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            i < stars ? '⭐' : '☆',
            style: TextStyle(
              fontSize: i < stars ? 52 : 40,
              color: i < stars ? AppColors.gold : Colors.white24,
            ),
          )
              .animate(delay: (300 + i * 200).ms)
              .scaleXY(begin: 0.3, end: 1.0, duration: 400.ms, curve: Curves.elasticOut),
        );
      }),
    );
  }

  Widget _buildScoreCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Column(
        children: [
          Text(
            'Your Score',
            style: AppTextStyles.bodyMediumBold.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            '${_ctrl.score.value}',
            style: AppTextStyles.displaySmall.copyWith(
              fontSize: 44,
              color: AppColors.gold,
              fontFamily: 'FredokaOne',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statCell('✅', '${_ctrl.correctCollected.value}', 'Correct'),
              _statCell('🔥', '${_ctrl.combo.value > 0 ? _ctrl.combo.value : 0}', 'Best Combo'),
              _statCell('📊', '×${_ctrl.multiplier}', 'Multiplier'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCell(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
        Text(
          value,
          style: AppTextStyles.bodyMediumBold.copyWith(color: Colors.white, fontSize: 18),
        ),
        Text(label, style: AppTextStyles.bodySmall.copyWith(color: Colors.white54, fontSize: 11)),
      ],
    );
  }

  Widget _buildRewardCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isWin
              ? [AppColors.gold.withOpacity(0.15), AppColors.warningOrange.withOpacity(0.08)]
              : [Colors.white.withOpacity(0.05), Colors.transparent],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _isWin ? AppColors.gold.withOpacity(0.3) : Colors.white12,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _rewardCell('🪙', '+${_ctrl.coinsEarned.value}', 'Coins'),
          _rewardCell('✨', '+${_ctrl.xpEarned.value}', 'XP'),
          _rewardCell('⭐', '+${_ctrl.starsEarned.value}', 'Stars'),
        ],
      ),
    );
  }

  Widget _rewardCell(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.bodyLargeBold.copyWith(
            color: AppColors.gold,
            fontSize: 20,
            fontFamily: 'FredokaOne',
          ),
        ),
        Text(label, style: AppTextStyles.bodySmall.copyWith(color: Colors.white54, fontSize: 12)),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        if (_isWin) ...[
          _actionButton(
            '▶️  Next Stage',
            AppColors.successGreen,
            () {
              HapticUtil.medium();
              _goNextStage();
            },
          ),
          const SizedBox(height: 12),
        ],
        _actionButton(
          '🔄  Retry Stage',
          AppColors.skyBlue,
          () {
            HapticUtil.medium();
            _retryStage();
          },
        ),
        const SizedBox(height: 12),
        _actionButton(
          '🏠  Back to Worlds',
          AppColors.lavender,
          () {
            HapticUtil.light();
            _ctrl.quitToLobby();
          },
        ),
      ],
    );
  }

  Widget _actionButton(String text, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.5), width: 1.5),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.15), blurRadius: 12),
          ],
        ),
        child: Text(
          text,
          style: AppTextStyles.bodyMediumBold.copyWith(color: color, fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scaleXY(begin: 0.98, end: 1.02, duration: const Duration(seconds: 2));
  }

  void _goNextStage() {
    final stage = _ctrl.currentStage.value;
    if (stage == null) {
      _ctrl.quitToLobby();
      return;
    }
    final nextStage = AdventureContentData.getStage(stage.stageNumber + 1);
    if (nextStage != null) {
      _ctrl.startStage(nextStage);
    } else {
      _ctrl.quitToLobby();
    }
  }

  void _retryStage() {
    final stage = _ctrl.currentStage.value;
    if (stage != null) {
      _ctrl.startStage(stage);
    }
  }
}
