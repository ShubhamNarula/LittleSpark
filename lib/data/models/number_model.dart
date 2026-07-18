import 'package:equatable/equatable.dart';

class NumberModel extends Equatable {
  final int number;
  final String word;
  final String emoji;
  final String funFact;

  const NumberModel({
    required this.number,
    required this.word,
    required this.emoji,
    required this.funFact,
  });

  @override
  List<Object?> get props => [number, word, emoji, funFact];
}
