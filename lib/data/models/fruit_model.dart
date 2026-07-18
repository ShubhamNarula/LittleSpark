import 'package:equatable/equatable.dart';

class FruitModel extends Equatable {
  final String name;
  final String emoji;
  final String color;
  final String taste;
  final String benefit;
  final String funFact;
  final String growsOn;
  final bool isVegetable;

  const FruitModel({
    required this.name,
    required this.emoji,
    required this.color,
    required this.taste,
    required this.benefit,
    required this.funFact,
    required this.growsOn,
    this.isVegetable = false,
  });

  @override
  List<Object?> get props => [name, emoji, color, taste, benefit, funFact, growsOn, isVegetable];
}
