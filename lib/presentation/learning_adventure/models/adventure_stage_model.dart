import 'adventure_collectible_model.dart';

enum DifficultyMode { easy, medium, hard }

class AdventureStage {
  final int stageNumber;
  final String worldId;
  final String category;
  final String targetLabel;
  final String instruction;
  final String instructionEmoji;
  final double speedMultiplier;
  final int lives;
  final int targetScore;
  final int targetCollectCount;
  final DifficultyMode difficulty;
  final List<AdventureCollectible> correctItems;
  final List<AdventureCollectible> distractorItems;

  const AdventureStage({
    required this.stageNumber,
    required this.worldId,
    required this.category,
    required this.targetLabel,
    required this.instruction,
    required this.instructionEmoji,
    required this.speedMultiplier,
    required this.lives,
    required this.targetScore,
    required this.targetCollectCount,
    required this.difficulty,
    required this.correctItems,
    required this.distractorItems,
  });
}
