import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class BadgeModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final int requiredStars;
  final bool isSpecial;
  final int colorHex;
  final List<int> gradientColorsHex;

  const BadgeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.requiredStars,
    required this.isSpecial,
    required this.colorHex,
    required this.gradientColorsHex,
  });

  Color get color => Color(colorHex);

  List<Color> get gradient => gradientColorsHex.map((h) => Color(h)).toList();

  @override
  List<Object?> get props => [id, name, description, emoji, requiredStars, isSpecial, colorHex, gradientColorsHex];
}
