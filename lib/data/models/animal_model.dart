import 'package:equatable/equatable.dart';

class AnimalModel extends Equatable {
  final String name;
  final String emoji;
  final String habitat;
  final String babyName;
  final String sound;
  final String diet;
  final String funFact;

  const AnimalModel({
    required this.name,
    required this.emoji,
    required this.habitat,
    required this.babyName,
    required this.sound,
    required this.diet,
    required this.funFact,
  });

  String get habitatEmoji {
    switch (habitat.toLowerCase()) {
      case 'farm':
        return '🏡';
      case 'wild':
        return '🌿';
      case 'ocean':
        return '🌊';
      case 'sky':
        return '🦅';
      default:
        return '🌍';
    }
  }

  @override
  List<Object?> get props => [name, emoji, habitat, babyName, sound, diet, funFact];
}
