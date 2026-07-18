import 'package:equatable/equatable.dart';

class LetterModel extends Equatable {
  final String letter;
  final String word;
  final String emoji;
  final String funFact;
  final int colorHex;

  const LetterModel({
    required this.letter,
    required this.word,
    required this.emoji,
    required this.funFact,
    required this.colorHex,
  });

  @override
  List<Object?> get props => [letter, word, emoji, funFact, colorHex];
}
