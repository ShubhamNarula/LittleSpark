import 'package:flutter/material.dart';

class AdventureWorld {
  final String id;
  final String name;
  final String emoji;
  final String description;
  final List<Color> gradientColors;
  final List<Color> skyColors;
  final List<Color> groundColors;
  final int totalStages;

  const AdventureWorld({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.gradientColors,
    required this.skyColors,
    required this.groundColors,
    required this.totalStages,
  });
}
