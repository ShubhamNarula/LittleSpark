import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class ColorItemModel extends Equatable {
  final String name;
  final int colorHex;
  final List<String> emojiExamples;
  final String roomChallenge;

  const ColorItemModel({
    required this.name,
    required this.colorHex,
    required this.emojiExamples,
    required this.roomChallenge,
  });

  Color get color => Color(colorHex);

  @override
  List<Object?> get props => [name, colorHex, emojiExamples, roomChallenge];
}
