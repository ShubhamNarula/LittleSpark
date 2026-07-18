class MemoryMatchLevel {
  final int level;
  final int rows;
  final int cols;
  final String category;
  final String categoryEmoji;
  final int timeLimitSeconds;
  final int revealSeconds; // How long cards stay face-up at start
  // Star thresholds: moves <= threshold1 => 3 stars, <= threshold2 => 2 stars, else 1 star
  final int threeStarMoves;
  final int twoStarMoves;

  const MemoryMatchLevel({
    required this.level,
    required this.rows,
    required this.cols,
    required this.category,
    required this.categoryEmoji,
    required this.timeLimitSeconds,
    this.revealSeconds = 3,
    required this.threeStarMoves,
    required this.twoStarMoves,
  });

  int get totalCards => rows * cols;
  int get totalPairs => totalCards ~/ 2;
}
