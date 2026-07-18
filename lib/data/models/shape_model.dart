import 'package:equatable/equatable.dart';

enum ShapeType {
  circle,
  square,
  triangle,
  rectangle,
  star,
  heart,
  diamond,
  oval,
  pentagon,
  hexagon,
}

class ShapeModel extends Equatable {
  final String name;
  final int sides;
  final String description;
  final String realWorldExample;
  final String emoji;
  final ShapeType type;

  const ShapeModel({
    required this.name,
    required this.sides,
    required this.description,
    required this.realWorldExample,
    required this.emoji,
    required this.type,
  });

  @override
  List<Object?> get props => [name, sides, description, realWorldExample, emoji, type];
}
