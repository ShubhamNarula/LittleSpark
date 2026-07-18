class AdventureCollectible {
  final String emoji;
  final String label;
  final String pronunciation;
  final String category;
  final bool isCorrect;

  const AdventureCollectible({
    required this.emoji,
    required this.label,
    required this.pronunciation,
    required this.category,
    this.isCorrect = false,
  });

  AdventureCollectible copyWith({bool? isCorrect}) {
    return AdventureCollectible(
      emoji: emoji,
      label: label,
      pronunciation: pronunciation,
      category: category,
      isCorrect: isCorrect ?? this.isCorrect,
    );
  }
}
