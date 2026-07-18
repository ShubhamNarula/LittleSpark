import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/haptic_util.dart';
import '../../../services/progress_service.dart';
import '../../../services/audio_service.dart';
import '../../shared/widgets/celebration_overlay.dart';

class ShapeBuilderGame extends StatefulWidget {
  const ShapeBuilderGame({Key? key}) : super(key: key);

  @override
  State<ShapeBuilderGame> createState() => _ShapeBuilderGameState();
}

class _ShapeBuilderGameState extends State<ShapeBuilderGame> {
  final _progress = ProgressService.to;
  final _rand = Random();

  int _currentLevel = 0;
  int _score = 0;
  bool _gameStarted = false;
  bool _levelComplete = false;

  List<_ShapePiece> _slots = [];
  List<_ShapePiece> _availablePieces = [];
  int _placedCount = 0;

  static const List<Map<String, dynamic>> _levels = [
    {
      'name': 'House',
      'emoji': '🏠',
      'pieces': [
        {'shape': 'square', 'label': '⬛ Square', 'emoji': '🟫'},
        {'shape': 'triangle', 'label': '🔺 Triangle', 'emoji': '🔺'},
      ],
    },
    {
      'name': 'Rocket',
      'emoji': '🚀',
      'pieces': [
        {'shape': 'rectangle', 'label': '▬ Rectangle', 'emoji': '🟦'},
        {'shape': 'triangle', 'label': '🔺 Triangle', 'emoji': '🔺'},
        {'shape': 'circle', 'label': '⚪ Circle', 'emoji': '⚪'},
      ],
    },
    {
      'name': 'Tree',
      'emoji': '🌲',
      'pieces': [
        {'shape': 'triangle', 'label': '🔺 Big Triangle', 'emoji': '🔺'},
        {'shape': 'triangle_sm', 'label': '🔻 Small Triangle', 'emoji': '🔻'},
        {'shape': 'rectangle', 'label': '▬ Trunk', 'emoji': '🟫'},
      ],
    },
    {
      'name': 'Star',
      'emoji': '⭐',
      'pieces': [
        {'shape': 'triangle', 'label': '🔺 Top', 'emoji': '🔺'},
        {'shape': 'triangle_down', 'label': '🔻 Bottom', 'emoji': '🔻'},
        {'shape': 'diamond', 'label': '◆ Center', 'emoji': '🔶'},
      ],
    },
    {
      'name': 'Car',
      'emoji': '🚗',
      'pieces': [
        {'shape': 'rectangle', 'label': '▬ Body', 'emoji': '🟥'},
        {'shape': 'circle', 'label': '⚪ Wheel 1', 'emoji': '⚫'},
        {'shape': 'circle', 'label': '⚪ Wheel 2', 'emoji': '⚫'},
        {'shape': 'trapezoid', 'label': '⬜ Window', 'emoji': '🟦'},
      ],
    },
  ];

  void _startGame() {
    setState(() {
      _gameStarted = true;
      _currentLevel = 0;
      _score = 0;
    });
    _loadLevel(_currentLevel);
  }

  void _loadLevel(int level) {
    if (level >= _levels.length) {
      // All levels complete
      _finishGame();
      return;
    }

    final levelData = _levels[level];
    final pieces = levelData['pieces'] as List<Map<String, dynamic>>;
    
    _slots = pieces.map((p) => _ShapePiece(
      shape: p['shape'] as String,
      label: p['label'] as String,
      emoji: p['emoji'] as String,
      isPlaced: false,
    )).toList();

    _availablePieces = List.from(_slots)..shuffle(_rand);
    // Add some distractors
    final distractors = [
      _ShapePiece(shape: 'hexagon', label: '⬡ Hexagon', emoji: '🔷', isPlaced: false),
      _ShapePiece(shape: 'oval', label: '⬭ Oval', emoji: '🥚', isPlaced: false),
    ];
    if (pieces.length < 4) {
      _availablePieces.add(distractors[_rand.nextInt(distractors.length)]);
    }
    _availablePieces.shuffle(_rand);
    
    _placedCount = 0;
    _levelComplete = false;

    setState(() {
      _currentLevel = level;
    });
  }

  void _onPieceDrop(_ShapePiece piece, int slotIndex) {
    if (slotIndex >= _slots.length) return;
    final slot = _slots[slotIndex];
    
    if (slot.isPlaced) return;

    if (piece.shape == slot.shape) {
      // Correct placement!
      setState(() {
        slot.isPlaced = true;
        _availablePieces.remove(piece);
        _placedCount++;
        _score += 15;
      });
      HapticUtil.medium();
      AudioService.to.playStar();

      if (_placedCount == _slots.length) {
        _onLevelComplete();
      }
    } else {
      HapticUtil.heavy();
      AudioService.to.playTap();
    }
  }

  void _onLevelComplete() {
    setState(() {
      _levelComplete = true;
    });
    _progress.addStar();
    _progress.addCoins(5);

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _loadLevel(_currentLevel + 1);
      }
    });
  }

  void _finishGame() {
    _progress.incrementMiniGamesPlayed();
    _progress.updateGameHighScore('shape_builder', _score);
    _progress.addXP(25);

    showCelebration(context);
    
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) Get.back();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: _gameStarted ? _buildGameView() : _buildStartView(),
      ),
    );
  }

  Widget _buildStartView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("🔷", style: TextStyle(fontSize: 80))
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .rotate(begin: -0.05, end: 0.05, duration: const Duration(seconds: 2)),
          const SizedBox(height: 16),
          Text("Shape Builder",
              style: AppTextStyles.displaySmall.copyWith(color: AppColors.gold, fontSize: 32)),
          const SizedBox(height: 8),
          Text("Drag the right shapes to\ncomplete the picture!",
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
              textAlign: TextAlign.center),
          const SizedBox(height: 40),
          GestureDetector(
            onTap: _startGame,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF60A5FA), Color(0xFF3B82F6)]),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF60A5FA).withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6)),
                ],
              ),
              child: Text("BUILD! 🔷",
                  style: AppTextStyles.bodyLargeBold.copyWith(color: Colors.white, fontSize: 20)),
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.05, 1.05), duration: const Duration(milliseconds: 1200)),
          const SizedBox(height: 20),
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white54, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildGameView() {
    final levelData = _levels[_currentLevel];

    return Column(
      children: [
        // HUD
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.close_rounded, color: Colors.white54),
              ),
              Text("Level ${_currentLevel + 1}/${_levels.length}",
                  style: AppTextStyles.bodyMediumBold.copyWith(color: Colors.white70)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.gold.withOpacity(0.3)),
                ),
                child: Text("⭐ $_score",
                    style: AppTextStyles.bodyMediumBold.copyWith(color: AppColors.gold)),
              ),
            ],
          ),
        ),

        // Target shape display
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.bgMid,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
          ),
          child: Column(
            children: [
              Text("Build: ${levelData['name']}",
                  style: AppTextStyles.bodyLargeBold.copyWith(color: AppColors.gold, fontSize: 20)),
              const SizedBox(height: 12),
              Text(
                levelData['emoji'] as String,
                style: const TextStyle(fontSize: 72),
              )
                  .animate(key: ValueKey(_currentLevel))
                  .scale(begin: const Offset(0.5, 0.5), duration: const Duration(milliseconds: 500), curve: Curves.elasticOut),
            ],
          ),
        ),

        // Slots (drop targets)
        const SizedBox(height: 16),
        Text("Drop pieces here:", style: AppTextStyles.bodyMediumBold.copyWith(color: Colors.white54)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: List.generate(_slots.length, (i) {
            final slot = _slots[i];
            return DragTarget<_ShapePiece>(
              onAcceptWithDetails: (details) => _onPieceDrop(details.data, i),
              onWillAcceptWithDetails: (_) => !slot.isPlaced,
              builder: (ctx, candidateData, rejectedData) {
                final isHovering = candidateData.isNotEmpty;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: slot.isPlaced
                        ? AppColors.successGreen.withOpacity(0.2)
                        : isHovering
                            ? AppColors.lavender.withOpacity(0.2)
                            : Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: slot.isPlaced
                          ? AppColors.successGreen
                          : isHovering
                              ? AppColors.lavender
                              : Colors.white24,
                      width: 2,
                      strokeAlign: BorderSide.strokeAlignInside,
                    ),
                  ),
                  child: Center(
                    child: slot.isPlaced
                        ? Text(slot.emoji, style: const TextStyle(fontSize: 36))
                            .animate()
                            .scale(begin: const Offset(0.3, 0.3), duration: const Duration(milliseconds: 400), curve: Curves.elasticOut)
                        : Text(slot.label.substring(0, 2), style: TextStyle(fontSize: 24, color: Colors.white.withOpacity(0.3))),
                  ),
                );
              },
            );
          }),
        ),

        const Spacer(),

        // Level complete banner
        if (_levelComplete)
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.mint, Color(0xFF44A08D)]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text("🎉 ${levelData['name']} Complete! Next level...",
                style: AppTextStyles.bodyLargeBold.copyWith(color: Colors.white)),
          )
              .animate()
              .slideY(begin: 0.5, duration: const Duration(milliseconds: 400), curve: Curves.easeOutCubic)
              .fadeIn(),

        // Available pieces (draggable)
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              Text("Your Pieces:", style: AppTextStyles.bodySmallBold.copyWith(color: Colors.white54)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: _availablePieces.map((piece) {
                  return Draggable<_ShapePiece>(
                    data: piece,
                    feedback: Material(
                      color: Colors.transparent,
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: AppColors.lavender.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.lavender, width: 2),
                        ),
                        child: Center(
                          child: Text(piece.emoji, style: const TextStyle(fontSize: 32)),
                        ),
                      ),
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.3,
                      child: _buildPieceChip(piece),
                    ),
                    child: _buildPieceChip(piece),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildPieceChip(_ShapePiece piece) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(piece.emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 6),
          Text(piece.label, style: AppTextStyles.bodySmallBold.copyWith(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}

class _ShapePiece {
  final String shape;
  final String label;
  final String emoji;
  bool isPlaced;

  _ShapePiece({
    required this.shape,
    required this.label,
    required this.emoji,
    this.isPlaced = false,
  });
}
