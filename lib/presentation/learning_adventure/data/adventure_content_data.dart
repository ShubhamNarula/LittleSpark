import 'package:flutter/material.dart';
import '../models/adventure_collectible_model.dart';
import '../models/adventure_stage_model.dart';
import '../models/adventure_world_model.dart';

class AdventureContentData {
  // ─────────────────────────────────────────────────────────────────
  // WORLDS
  // ─────────────────────────────────────────────────────────────────
  static const List<AdventureWorld> worlds = [
    AdventureWorld(
      id: 'alphabet_forest',
      name: 'Alphabet Forest',
      emoji: '🌲',
      description: 'Learn A to Z in the magical forest!',
      gradientColors: [Color(0xFF134E5E), Color(0xFF71B280)],
      skyColors: [Color(0xFF0D3D2A), Color(0xFF1A6B45)],
      groundColors: [Color(0xFF2D5016), Color(0xFF4A7C24)],
      totalStages: 8,
    ),
    AdventureWorld(
      id: 'number_city',
      name: 'Number City',
      emoji: '🏙️',
      description: 'Count and collect numbers in the city!',
      gradientColors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
      skyColors: [Color(0xFF0F0C29), Color(0xFF302B63)],
      groundColors: [Color(0xFF24243E), Color(0xFF302B63)],
      totalStages: 6,
    ),
    AdventureWorld(
      id: 'shape_kingdom',
      name: 'Shape Kingdom',
      emoji: '👑',
      description: 'Find circles, squares & triangles!',
      gradientColors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
      skyColors: [Color(0xFF4C1D95), Color(0xFF7C3AED)],
      groundColors: [Color(0xFF5B21B6), Color(0xFF7C3AED)],
      totalStages: 5,
    ),
    AdventureWorld(
      id: 'color_land',
      name: 'Color Land',
      emoji: '🌈',
      description: 'Collect objects of the right color!',
      gradientColors: [Color(0xFFFF6B6B), Color(0xFFFFD93D)],
      skyColors: [Color(0xFFFF6B6B), Color(0xFF6BCB77)],
      groundColors: [Color(0xFF4D9078), Color(0xFF6BCB77)],
      totalStages: 6,
    ),
    AdventureWorld(
      id: 'animal_jungle',
      name: 'Animal Jungle',
      emoji: '🦁',
      description: 'Discover amazing animals in the jungle!',
      gradientColors: [Color(0xFFf7971e), Color(0xFFffd200)],
      skyColors: [Color(0xFF5D4037), Color(0xFF795548)],
      groundColors: [Color(0xFF33691E), Color(0xFF558B2F)],
      totalStages: 5,
    ),
    AdventureWorld(
      id: 'space_adventure',
      name: 'Space Adventure',
      emoji: '🚀',
      description: 'Explore fruits & veggies in space!',
      gradientColors: [Color(0xFF0F2027), Color(0xFF203A43)],
      skyColors: [Color(0xFF0F0C29), Color(0xFF11101D)],
      groundColors: [Color(0xFF141622), Color(0xFF1C1E2E)],
      totalStages: 5,
    ),
    AdventureWorld(
      id: 'ocean_world',
      name: 'Ocean World',
      emoji: '🌊',
      description: 'Dive into sea creatures & sight words!',
      gradientColors: [Color(0xFF005C97), Color(0xFF363795)],
      skyColors: [Color(0xFF003D82), Color(0xFF005C97)],
      groundColors: [Color(0xFF01579B), Color(0xFF0288D1)],
      totalStages: 5,
    ),
    AdventureWorld(
      id: 'candy_land',
      name: 'Candy Land',
      emoji: '🍭',
      description: 'Collect yummy fruits and sweets!',
      gradientColors: [Color(0xFFf953c6), Color(0xFFb91d73)],
      skyColors: [Color(0xFFE91E8C), Color(0xFFf953c6)],
      groundColors: [Color(0xFF9C27B0), Color(0xFFAB47BC)],
      totalStages: 4,
    ),
    AdventureWorld(
      id: 'dino_valley',
      name: 'Dino Valley',
      emoji: '🦕',
      description: 'Count objects with the dinosaurs!',
      gradientColors: [Color(0xFF6A3093), Color(0xFFa044ff)],
      skyColors: [Color(0xFF4A1070), Color(0xFF6A3093)],
      groundColors: [Color(0xFF2E7D32), Color(0xFF388E3C)],
      totalStages: 4,
    ),
    AdventureWorld(
      id: 'future_city',
      name: 'Future City',
      emoji: '🤖',
      description: 'Solve math challenges in the future!',
      gradientColors: [Color(0xFF373B44), Color(0xFF4286f4)],
      skyColors: [Color(0xFF1A237E), Color(0xFF283593)],
      groundColors: [Color(0xFF212121), Color(0xFF424242)],
      totalStages: 4,
    ),
  ];

  // ─────────────────────────────────────────────────────────────────
  // COLLECTIBLE BANKS — by category
  // ─────────────────────────────────────────────────────────────────

  static const List<AdventureCollectible> alphabetItems = [
    AdventureCollectible(emoji: '🅰️', label: 'A', pronunciation: 'A for Apple', category: 'alphabets'),
    AdventureCollectible(emoji: '🅱️', label: 'B', pronunciation: 'B for Ball', category: 'alphabets'),
    AdventureCollectible(emoji: '🇨', label: 'C', pronunciation: 'C for Cat', category: 'alphabets'),
    AdventureCollectible(emoji: '🇩', label: 'D', pronunciation: 'D for Dog', category: 'alphabets'),
    AdventureCollectible(emoji: '🇪', label: 'E', pronunciation: 'E for Elephant', category: 'alphabets'),
    AdventureCollectible(emoji: '🇫', label: 'F', pronunciation: 'F for Fish', category: 'alphabets'),
    AdventureCollectible(emoji: '🇬', label: 'G', pronunciation: 'G for Goat', category: 'alphabets'),
    AdventureCollectible(emoji: '🇭', label: 'H', pronunciation: 'H for Hat', category: 'alphabets'),
    AdventureCollectible(emoji: '🇮', label: 'I', pronunciation: 'I for Ice cream', category: 'alphabets'),
    AdventureCollectible(emoji: '🇯', label: 'J', pronunciation: 'J for Jug', category: 'alphabets'),
    AdventureCollectible(emoji: '🇰', label: 'K', pronunciation: 'K for Kite', category: 'alphabets'),
    AdventureCollectible(emoji: '🇱', label: 'L', pronunciation: 'L for Lion', category: 'alphabets'),
    AdventureCollectible(emoji: '🇲', label: 'M', pronunciation: 'M for Mango', category: 'alphabets'),
    AdventureCollectible(emoji: '🇳', label: 'N', pronunciation: 'N for Nest', category: 'alphabets'),
    AdventureCollectible(emoji: '🇴', label: 'O', pronunciation: 'O for Orange', category: 'alphabets'),
    AdventureCollectible(emoji: '🇵', label: 'P', pronunciation: 'P for Parrot', category: 'alphabets'),
    AdventureCollectible(emoji: '🇶', label: 'Q', pronunciation: 'Q for Queen', category: 'alphabets'),
    AdventureCollectible(emoji: '🇷', label: 'R', pronunciation: 'R for Rabbit', category: 'alphabets'),
    AdventureCollectible(emoji: '🇸', label: 'S', pronunciation: 'S for Sun', category: 'alphabets'),
    AdventureCollectible(emoji: '🇹', label: 'T', pronunciation: 'T for Tiger', category: 'alphabets'),
    AdventureCollectible(emoji: '🇺', label: 'U', pronunciation: 'U for Umbrella', category: 'alphabets'),
    AdventureCollectible(emoji: '🇻', label: 'V', pronunciation: 'V for Van', category: 'alphabets'),
    AdventureCollectible(emoji: '🇼', label: 'W', pronunciation: 'W for Water', category: 'alphabets'),
    AdventureCollectible(emoji: '🇽', label: 'X', pronunciation: 'X for Xylophone', category: 'alphabets'),
    AdventureCollectible(emoji: '🇾', label: 'Y', pronunciation: 'Y for Yak', category: 'alphabets'),
    AdventureCollectible(emoji: '🇿', label: 'Z', pronunciation: 'Z for Zebra', category: 'alphabets'),
  ];

  // Simplified letter labels for display (using text labels instead of flag emojis)
  static List<AdventureCollectible> letterItems(String letter) {
    final labels = {
      'A': ('🍎', 'A', 'A for Apple'),
      'B': ('🎈', 'B', 'B for Ball'),
      'C': ('🐱', 'C', 'C for Cat'),
      'D': ('🐶', 'D', 'D for Dog'),
      'E': ('🐘', 'E', 'E for Elephant'),
      'F': ('🐟', 'F', 'F for Fish'),
      'G': ('🐐', 'G', 'G for Goat'),
      'H': ('🎩', 'H', 'H for Hat'),
      'I': ('🍦', 'I', 'I for Ice cream'),
      'J': ('🏺', 'J', 'J for Jug'),
      'K': ('🪁', 'K', 'K for Kite'),
      'L': ('🦁', 'L', 'L for Lion'),
      'M': ('🥭', 'M', 'M for Mango'),
      'N': ('🪺', 'N', 'N for Nest'),
      'O': ('🍊', 'O', 'O for Orange'),
      'P': ('🦜', 'P', 'P for Parrot'),
      'Q': ('👑', 'Q', 'Q for Queen'),
      'R': ('🐰', 'R', 'R for Rabbit'),
      'S': ('☀️', 'S', 'S for Sun'),
      'T': ('🐯', 'T', 'T for Tiger'),
      'U': ('☂️', 'U', 'U for Umbrella'),
      'V': ('🚐', 'V', 'V for Van'),
      'W': ('💧', 'W', 'W for Water'),
      'X': ('🎵', 'X', 'X for Xylophone'),
      'Y': ('🦬', 'Y', 'Y for Yak'),
      'Z': ('🦓', 'Z', 'Z for Zebra'),
    };
    final data = labels[letter];
    if (data == null) return [];
    return [
      AdventureCollectible(
        emoji: data.$1,
        label: data.$2,
        pronunciation: data.$3,
        category: 'alphabets',
        isCorrect: true,
      ),
    ];
  }

  static const List<AdventureCollectible> fruitItems = [
    AdventureCollectible(emoji: '🍎', label: 'Apple', pronunciation: 'Apple', category: 'fruits', isCorrect: true),
    AdventureCollectible(emoji: '🍌', label: 'Banana', pronunciation: 'Banana', category: 'fruits', isCorrect: true),
    AdventureCollectible(emoji: '🍊', label: 'Orange', pronunciation: 'Orange', category: 'fruits', isCorrect: true),
    AdventureCollectible(emoji: '🍇', label: 'Grapes', pronunciation: 'Grapes', category: 'fruits', isCorrect: true),
    AdventureCollectible(emoji: '🍓', label: 'Strawberry', pronunciation: 'Strawberry', category: 'fruits', isCorrect: true),
    AdventureCollectible(emoji: '🥭', label: 'Mango', pronunciation: 'Mango', category: 'fruits', isCorrect: true),
    AdventureCollectible(emoji: '🍍', label: 'Pineapple', pronunciation: 'Pineapple', category: 'fruits', isCorrect: true),
    AdventureCollectible(emoji: '🍑', label: 'Peach', pronunciation: 'Peach', category: 'fruits', isCorrect: true),
    AdventureCollectible(emoji: '🍒', label: 'Cherry', pronunciation: 'Cherry', category: 'fruits', isCorrect: true),
    AdventureCollectible(emoji: '🍋', label: 'Lemon', pronunciation: 'Lemon', category: 'fruits', isCorrect: true),
    AdventureCollectible(emoji: '🍐', label: 'Pear', pronunciation: 'Pear', category: 'fruits', isCorrect: true),
    AdventureCollectible(emoji: '🍉', label: 'Watermelon', pronunciation: 'Watermelon', category: 'fruits', isCorrect: true),
  ];

  static const List<AdventureCollectible> vegetableItems = [
    AdventureCollectible(emoji: '🥕', label: 'Carrot', pronunciation: 'Carrot', category: 'vegetables', isCorrect: true),
    AdventureCollectible(emoji: '🥦', label: 'Broccoli', pronunciation: 'Broccoli', category: 'vegetables', isCorrect: true),
    AdventureCollectible(emoji: '🌽', label: 'Corn', pronunciation: 'Corn', category: 'vegetables', isCorrect: true),
    AdventureCollectible(emoji: '🍅', label: 'Tomato', pronunciation: 'Tomato', category: 'vegetables', isCorrect: true),
    AdventureCollectible(emoji: '🥔', label: 'Potato', pronunciation: 'Potato', category: 'vegetables', isCorrect: true),
    AdventureCollectible(emoji: '🧅', label: 'Onion', pronunciation: 'Onion', category: 'vegetables', isCorrect: true),
    AdventureCollectible(emoji: '🫑', label: 'Pepper', pronunciation: 'Pepper', category: 'vegetables', isCorrect: true),
    AdventureCollectible(emoji: '🥑', label: 'Avocado', pronunciation: 'Avocado', category: 'vegetables', isCorrect: true),
  ];

  static const List<AdventureCollectible> animalItems = [
    AdventureCollectible(emoji: '🦁', label: 'Lion', pronunciation: 'Lion', category: 'animals', isCorrect: true),
    AdventureCollectible(emoji: '🐘', label: 'Elephant', pronunciation: 'Elephant', category: 'animals', isCorrect: true),
    AdventureCollectible(emoji: '🦒', label: 'Giraffe', pronunciation: 'Giraffe', category: 'animals', isCorrect: true),
    AdventureCollectible(emoji: '🐯', label: 'Tiger', pronunciation: 'Tiger', category: 'animals', isCorrect: true),
    AdventureCollectible(emoji: '🐒', label: 'Monkey', pronunciation: 'Monkey', category: 'animals', isCorrect: true),
    AdventureCollectible(emoji: '🦓', label: 'Zebra', pronunciation: 'Zebra', category: 'animals', isCorrect: true),
    AdventureCollectible(emoji: '🐻', label: 'Bear', pronunciation: 'Bear', category: 'animals', isCorrect: true),
    AdventureCollectible(emoji: '🦊', label: 'Fox', pronunciation: 'Fox', category: 'animals', isCorrect: true),
    AdventureCollectible(emoji: '🐺', label: 'Wolf', pronunciation: 'Wolf', category: 'animals', isCorrect: true),
    AdventureCollectible(emoji: '🐨', label: 'Koala', pronunciation: 'Koala', category: 'animals', isCorrect: true),
  ];

  static const List<AdventureCollectible> colorItems = [
    AdventureCollectible(emoji: '🔴', label: 'Red', pronunciation: 'Red', category: 'colors', isCorrect: true),
    AdventureCollectible(emoji: '🔵', label: 'Blue', pronunciation: 'Blue', category: 'colors', isCorrect: true),
    AdventureCollectible(emoji: '🟡', label: 'Yellow', pronunciation: 'Yellow', category: 'colors', isCorrect: true),
    AdventureCollectible(emoji: '🟢', label: 'Green', pronunciation: 'Green', category: 'colors', isCorrect: true),
    AdventureCollectible(emoji: '🟠', label: 'Orange', pronunciation: 'Orange', category: 'colors', isCorrect: true),
    AdventureCollectible(emoji: '🟣', label: 'Purple', pronunciation: 'Purple', category: 'colors', isCorrect: true),
    AdventureCollectible(emoji: '⚪', label: 'White', pronunciation: 'White', category: 'colors', isCorrect: true),
    AdventureCollectible(emoji: '⚫', label: 'Black', pronunciation: 'Black', category: 'colors', isCorrect: true),
  ];

  static const List<AdventureCollectible> shapeItems = [
    AdventureCollectible(emoji: '⭕', label: 'Circle', pronunciation: 'Circle', category: 'shapes', isCorrect: true),
    AdventureCollectible(emoji: '🔷', label: 'Diamond', pronunciation: 'Diamond', category: 'shapes', isCorrect: true),
    AdventureCollectible(emoji: '🔶', label: 'Diamond', pronunciation: 'Diamond', category: 'shapes', isCorrect: true),
    AdventureCollectible(emoji: '⬛', label: 'Square', pronunciation: 'Square', category: 'shapes', isCorrect: true),
    AdventureCollectible(emoji: '🔺', label: 'Triangle', pronunciation: 'Triangle', category: 'shapes', isCorrect: true),
    AdventureCollectible(emoji: '⭐', label: 'Star', pronunciation: 'Star', category: 'shapes', isCorrect: true),
    AdventureCollectible(emoji: '❤️', label: 'Heart', pronunciation: 'Heart', category: 'shapes', isCorrect: true),
  ];

  static const List<AdventureCollectible> numberItems = [
    AdventureCollectible(emoji: '1️⃣', label: '1', pronunciation: 'One', category: 'numbers', isCorrect: true),
    AdventureCollectible(emoji: '2️⃣', label: '2', pronunciation: 'Two', category: 'numbers', isCorrect: true),
    AdventureCollectible(emoji: '3️⃣', label: '3', pronunciation: 'Three', category: 'numbers', isCorrect: true),
    AdventureCollectible(emoji: '4️⃣', label: '4', pronunciation: 'Four', category: 'numbers', isCorrect: true),
    AdventureCollectible(emoji: '5️⃣', label: '5', pronunciation: 'Five', category: 'numbers', isCorrect: true),
    AdventureCollectible(emoji: '6️⃣', label: '6', pronunciation: 'Six', category: 'numbers', isCorrect: true),
    AdventureCollectible(emoji: '7️⃣', label: '7', pronunciation: 'Seven', category: 'numbers', isCorrect: true),
    AdventureCollectible(emoji: '8️⃣', label: '8', pronunciation: 'Eight', category: 'numbers', isCorrect: true),
    AdventureCollectible(emoji: '9️⃣', label: '9', pronunciation: 'Nine', category: 'numbers', isCorrect: true),
    AdventureCollectible(emoji: '🔟', label: '10', pronunciation: 'Ten', category: 'numbers', isCorrect: true),
  ];

  static const List<AdventureCollectible> vehicleItems = [
    AdventureCollectible(emoji: '🚗', label: 'Car', pronunciation: 'Car', category: 'vehicles', isCorrect: true),
    AdventureCollectible(emoji: '🚌', label: 'Bus', pronunciation: 'Bus', category: 'vehicles', isCorrect: true),
    AdventureCollectible(emoji: '🚂', label: 'Train', pronunciation: 'Train', category: 'vehicles', isCorrect: true),
    AdventureCollectible(emoji: '✈️', label: 'Airplane', pronunciation: 'Airplane', category: 'vehicles', isCorrect: true),
    AdventureCollectible(emoji: '🚢', label: 'Ship', pronunciation: 'Ship', category: 'vehicles', isCorrect: true),
    AdventureCollectible(emoji: '🚁', label: 'Helicopter', pronunciation: 'Helicopter', category: 'vehicles', isCorrect: true),
    AdventureCollectible(emoji: '🏍️', label: 'Bike', pronunciation: 'Bike', category: 'vehicles', isCorrect: true),
    AdventureCollectible(emoji: '🛸', label: 'UFO', pronunciation: 'UFO', category: 'vehicles', isCorrect: true),
  ];

  static const List<AdventureCollectible> obstacleDistractors = [
    AdventureCollectible(emoji: '💥', label: 'Boom!', pronunciation: 'Oops!', category: 'distractor'),
    AdventureCollectible(emoji: '❌', label: 'Wrong!', pronunciation: 'Try again!', category: 'distractor'),
    AdventureCollectible(emoji: '🚫', label: 'No!', pronunciation: 'Not this one!', category: 'distractor'),
  ];

  // ─────────────────────────────────────────────────────────────────
  // STAGES — Data-Driven, Easily Extensible
  // ─────────────────────────────────────────────────────────────────
  static List<AdventureStage> get stages {
    final List<AdventureStage> all = [];

    // ── Alphabet Forest Stages (1–8) — Each letter A/B/C/D/E/F/G/H ──
    final letters = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
    final letterEmojis = ['🍎','🎈','🐱','🐶','🐘','🐟','🐐','🎩'];
    for (int i = 0; i < letters.length; i++) {
      final letter = letters[i];
      final correctEmoji = letterEmojis[i];
      // Get 3 distractor letters
      final distractors = letters
          .where((l) => l != letter)
          .take(3)
          .map((l) {
            final idx = letters.indexOf(l);
            return AdventureCollectible(
              emoji: letterEmojis[idx],
              label: l,
              pronunciation: 'Not $letter',
              category: 'alphabets',
              isCorrect: false,
            );
          })
          .toList();
      all.add(AdventureStage(
        stageNumber: i + 1,
        worldId: 'alphabet_forest',
        category: 'alphabets',
        targetLabel: letter,
        instruction: 'Collect letter $letter!',
        instructionEmoji: correctEmoji,
        speedMultiplier: 1.0 + (i * 0.08),
        lives: 5,
        targetScore: 80 + (i * 10),
        targetCollectCount: 8,
        difficulty: DifficultyMode.easy,
        correctItems: [
          AdventureCollectible(
            emoji: correctEmoji,
            label: letter,
            pronunciation: '${letter} for ${_letterWords[letter]!}',
            category: 'alphabets',
            isCorrect: true,
          ),
        ],
        distractorItems: distractors,
      ));
    }

    // ── Number City Stages (9–14) — Numbers 1–6 ──
    for (int n = 1; n <= 6; n++) {
      final numEmojis = ['1️⃣','2️⃣','3️⃣','4️⃣','5️⃣','6️⃣','7️⃣','8️⃣','9️⃣','🔟'];
      final distractors = List.generate(4, (j) {
        final wrongNum = (n + j + 1) % 10;
        return AdventureCollectible(
          emoji: numEmojis[wrongNum],
          label: '${wrongNum + 1}',
          pronunciation: 'Not $n',
          category: 'numbers',
          isCorrect: false,
        );
      });
      all.add(AdventureStage(
        stageNumber: 8 + n,
        worldId: 'number_city',
        category: 'numbers',
        targetLabel: '$n',
        instruction: 'Collect number $n!',
        instructionEmoji: numEmojis[n - 1],
        speedMultiplier: 1.1 + (n * 0.07),
        lives: 5,
        targetScore: 100 + (n * 15),
        targetCollectCount: 10,
        difficulty: DifficultyMode.easy,
        correctItems: [
          AdventureCollectible(
            emoji: numEmojis[n - 1],
            label: '$n',
            pronunciation: _numberWords[n]!,
            category: 'numbers',
            isCorrect: true,
          ),
        ],
        distractorItems: distractors,
      ));
    }

    // ── Shape Kingdom Stages (15–19) — Circle, Square, Triangle, Star, Heart ──
    final shapeStages = [
      ('⭕', 'Circle', 'Circle', ['⬛','🔺','⭐','❤️'], ['Square','Triangle','Star','Heart']),
      ('⬛', 'Square', 'Square', ['⭕','🔺','⭐','❤️'], ['Circle','Triangle','Star','Heart']),
      ('🔺', 'Triangle', 'Triangle', ['⭕','⬛','⭐','❤️'], ['Circle','Square','Star','Heart']),
      ('⭐', 'Star', 'Star', ['⭕','⬛','🔺','❤️'], ['Circle','Square','Triangle','Heart']),
      ('❤️', 'Heart', 'Heart', ['⭕','⬛','🔺','⭐'], ['Circle','Square','Triangle','Star']),
    ];
    for (int s = 0; s < shapeStages.length; s++) {
      final sd = shapeStages[s];
      all.add(AdventureStage(
        stageNumber: 15 + s,
        worldId: 'shape_kingdom',
        category: 'shapes',
        targetLabel: sd.$2,
        instruction: 'Collect the ${sd.$3}!',
        instructionEmoji: sd.$1,
        speedMultiplier: 1.15 + (s * 0.06),
        lives: 5,
        targetScore: 120 + (s * 20),
        targetCollectCount: 10,
        difficulty: DifficultyMode.easy,
        correctItems: [
          AdventureCollectible(
            emoji: sd.$1,
            label: sd.$2,
            pronunciation: sd.$3,
            category: 'shapes',
            isCorrect: true,
          ),
        ],
        distractorItems: List.generate(sd.$4.length, (i) => AdventureCollectible(
          emoji: sd.$4[i],
          label: sd.$5[i],
          pronunciation: 'Not a ${sd.$3}',
          category: 'shapes',
          isCorrect: false,
        )),
      ));
    }

    // ── Color Land Stages (20–25) — Red, Blue, Yellow, Green, Orange, Purple ──
    final colorStages = [
      ('🔴', 'Red', ['🔵','🟡','🟢','🟠']),
      ('🔵', 'Blue', ['🔴','🟡','🟢','🟣']),
      ('🟡', 'Yellow', ['🔴','🔵','🟢','🟠']),
      ('🟢', 'Green', ['🔴','🔵','🟡','🟣']),
      ('🟠', 'Orange', ['🔴','🔵','🟡','🟢']),
      ('🟣', 'Purple', ['🔴','🔵','🟡','🟢']),
    ];
    for (int c = 0; c < colorStages.length; c++) {
      final cd = colorStages[c];
      all.add(AdventureStage(
        stageNumber: 20 + c,
        worldId: 'color_land',
        category: 'colors',
        targetLabel: cd.$2,
        instruction: 'Collect ${cd.$2} objects!',
        instructionEmoji: cd.$1,
        speedMultiplier: 1.2 + (c * 0.05),
        lives: 5,
        targetScore: 150 + (c * 20),
        targetCollectCount: 10,
        difficulty: DifficultyMode.medium,
        correctItems: [
          AdventureCollectible(
            emoji: cd.$1,
            label: cd.$2,
            pronunciation: cd.$2,
            category: 'colors',
            isCorrect: true,
          ),
        ],
        distractorItems: cd.$3.map((e) => AdventureCollectible(
          emoji: e,
          label: 'Wrong color',
          pronunciation: 'Not ${cd.$2}',
          category: 'colors',
          isCorrect: false,
        )).toList(),
      ));
    }

    // ── Animal Jungle Stages (26–30) — 5 animals ──
    final animalStages = [
      ('🦁', 'Lion', ['🐘','🦒','🐯','🐒']),
      ('🐘', 'Elephant', ['🦁','🦒','🐯','🐒']),
      ('🦒', 'Giraffe', ['🦁','🐘','🐯','🦓']),
      ('🐯', 'Tiger', ['🦁','🐘','🦒','🐻']),
      ('🐒', 'Monkey', ['🦁','🐘','🦒','🦊']),
    ];
    for (int a = 0; a < animalStages.length; a++) {
      final ad = animalStages[a];
      all.add(AdventureStage(
        stageNumber: 26 + a,
        worldId: 'animal_jungle',
        category: 'animals',
        targetLabel: ad.$2,
        instruction: 'Collect the ${ad.$2}!',
        instructionEmoji: ad.$1,
        speedMultiplier: 1.25 + (a * 0.07),
        lives: 5,
        targetScore: 180 + (a * 20),
        targetCollectCount: 10,
        difficulty: DifficultyMode.medium,
        correctItems: [
          AdventureCollectible(
            emoji: ad.$1,
            label: ad.$2,
            pronunciation: ad.$2,
            category: 'animals',
            isCorrect: true,
          ),
        ],
        distractorItems: ad.$3.map((e) => AdventureCollectible(
          emoji: e,
          label: 'Wrong animal',
          pronunciation: 'Not a ${ad.$2}',
          category: 'animals',
          isCorrect: false,
        )).toList(),
      ));
    }

    // ── Space Adventure: Fruits (31–35) ──
    final fruitStages = [
      ('🍎', 'Apple', ['🍌','🍊','🍇','🍓']),
      ('🍌', 'Banana', ['🍎','🍊','🍇','🥭']),
      ('🍊', 'Orange', ['🍎','🍌','🍇','🍍']),
      ('🍇', 'Grapes', ['🍎','🍌','🍊','🍓']),
      ('🍓', 'Strawberry', ['🍎','🍌','🍊','🍒']),
    ];
    for (int f = 0; f < fruitStages.length; f++) {
      final fd = fruitStages[f];
      all.add(AdventureStage(
        stageNumber: 31 + f,
        worldId: 'space_adventure',
        category: 'fruits',
        targetLabel: fd.$2,
        instruction: 'Collect ${fd.$2}!',
        instructionEmoji: fd.$1,
        speedMultiplier: 1.3 + (f * 0.06),
        lives: 5,
        targetScore: 200 + (f * 25),
        targetCollectCount: 10,
        difficulty: DifficultyMode.medium,
        correctItems: [
          AdventureCollectible(
            emoji: fd.$1,
            label: fd.$2,
            pronunciation: fd.$2,
            category: 'fruits',
            isCorrect: true,
          ),
        ],
        distractorItems: fd.$3.map((e) => AdventureCollectible(
          emoji: e,
          label: 'Wrong fruit',
          pronunciation: 'Not ${fd.$2}',
          category: 'fruits',
          isCorrect: false,
        )).toList(),
      ));
    }

    // ── Ocean World: Vegetables (36–40) ──
    final vegStages = [
      ('🥕', 'Carrot', ['🥦','🌽','🍅','🥔']),
      ('🥦', 'Broccoli', ['🥕','🌽','🍅','🧅']),
      ('🌽', 'Corn', ['🥕','🥦','🍅','🫑']),
      ('🍅', 'Tomato', ['🥕','🥦','🌽','🥑']),
      ('🥔', 'Potato', ['🥕','🥦','🌽','🧅']),
    ];
    for (int v = 0; v < vegStages.length; v++) {
      final vd = vegStages[v];
      all.add(AdventureStage(
        stageNumber: 36 + v,
        worldId: 'ocean_world',
        category: 'vegetables',
        targetLabel: vd.$2,
        instruction: 'Collect ${vd.$2}!',
        instructionEmoji: vd.$1,
        speedMultiplier: 1.35 + (v * 0.06),
        lives: 5,
        targetScore: 220 + (v * 30),
        targetCollectCount: 10,
        difficulty: DifficultyMode.medium,
        correctItems: [
          AdventureCollectible(
            emoji: vd.$1,
            label: vd.$2,
            pronunciation: vd.$2,
            category: 'vegetables',
            isCorrect: true,
          ),
        ],
        distractorItems: vd.$3.map((e) => AdventureCollectible(
          emoji: e,
          label: 'Wrong vegetable',
          pronunciation: 'Not ${vd.$2}',
          category: 'vegetables',
          isCorrect: false,
        )).toList(),
      ));
    }

    // ── Candy Land: Mixed Fruits (41–44) ──
    final candyStages = [
      ('🍍', 'Pineapple', ['🍑','🍒','🍋','🍐']),
      ('🍑', 'Peach', ['🍍','🍒','🍋','🍐']),
      ('🍒', 'Cherry', ['🍍','🍑','🍋','🍉']),
      ('🍉', 'Watermelon', ['🍍','🍑','🍒','🍋']),
    ];
    for (int c = 0; c < candyStages.length; c++) {
      final cd = candyStages[c];
      all.add(AdventureStage(
        stageNumber: 41 + c,
        worldId: 'candy_land',
        category: 'fruits',
        targetLabel: cd.$2,
        instruction: 'Collect ${cd.$2}!',
        instructionEmoji: cd.$1,
        speedMultiplier: 1.5 + (c * 0.08),
        lives: 5,
        targetScore: 250 + (c * 30),
        targetCollectCount: 12,
        difficulty: DifficultyMode.medium,
        correctItems: [
          AdventureCollectible(
            emoji: cd.$1,
            label: cd.$2,
            pronunciation: cd.$2,
            category: 'fruits',
            isCorrect: true,
          ),
        ],
        distractorItems: cd.$3.map((e) => AdventureCollectible(
          emoji: e,
          label: 'Wrong!',
          pronunciation: 'Not ${cd.$2}',
          category: 'fruits',
          isCorrect: false,
        )).toList(),
      ));
    }

    // ── Dino Valley: Counting Stars (45–48) ──
    for (int d = 0; d < 4; d++) {
      final targetCount = d + 3; // 3, 4, 5, 6
      final wrongCounts = [targetCount - 1, targetCount + 1, targetCount + 2]
          .where((n) => n > 0 && n != targetCount)
          .take(3)
          .toList();
      all.add(AdventureStage(
        stageNumber: 45 + d,
        worldId: 'dino_valley',
        category: 'counting',
        targetLabel: '$targetCount stars',
        instruction: 'Collect exactly $targetCount ⭐!',
        instructionEmoji: '⭐',
        speedMultiplier: 1.55 + (d * 0.07),
        lives: 5,
        targetScore: 280 + (d * 40),
        targetCollectCount: targetCount,
        difficulty: DifficultyMode.hard,
        correctItems: [
          const AdventureCollectible(
            emoji: '⭐',
            label: 'Star',
            pronunciation: 'Star!',
            category: 'counting',
            isCorrect: true,
          ),
        ],
        distractorItems: [
          const AdventureCollectible(
            emoji: '💀',
            label: 'Skull',
            pronunciation: 'Oops!',
            category: 'distractor',
            isCorrect: false,
          ),
          const AdventureCollectible(
            emoji: '🪨',
            label: 'Rock',
            pronunciation: 'Wrong!',
            category: 'distractor',
            isCorrect: false,
          ),
        ],
      ));
    }

    // ── Future City: Vehicles (49–52) ──
    final vehicleStages = [
      ('🚗', 'Car', ['🚌','🚂','✈️','🚢']),
      ('🚌', 'Bus', ['🚗','🚂','✈️','🚁']),
      ('✈️', 'Airplane', ['🚗','🚌','🚂','🚢']),
      ('🚂', 'Train', ['🚗','🚌','✈️','🏍️']),
    ];
    for (int t = 0; t < vehicleStages.length; t++) {
      final td = vehicleStages[t];
      all.add(AdventureStage(
        stageNumber: 49 + t,
        worldId: 'future_city',
        category: 'vehicles',
        targetLabel: td.$2,
        instruction: 'Collect the ${td.$2}!',
        instructionEmoji: td.$1,
        speedMultiplier: 1.7 + (t * 0.1),
        lives: 4,
        targetScore: 350 + (t * 50),
        targetCollectCount: 12,
        difficulty: DifficultyMode.hard,
        correctItems: [
          AdventureCollectible(
            emoji: td.$1,
            label: td.$2,
            pronunciation: td.$2,
            category: 'vehicles',
            isCorrect: true,
          ),
        ],
        distractorItems: td.$3.map((e) => AdventureCollectible(
          emoji: e,
          label: 'Wrong!',
          pronunciation: 'Not a ${td.$2}',
          category: 'vehicles',
          isCorrect: false,
        )).toList(),
      ));
    }

    return all;
  }

  static AdventureStage? getStage(int stageNumber) {
    try {
      return stages.firstWhere((s) => s.stageNumber == stageNumber);
    } catch (_) {
      return null;
    }
  }

  static AdventureWorld? getWorld(String worldId) {
    try {
      return worlds.firstWhere((w) => w.id == worldId);
    } catch (_) {
      return null;
    }
  }

  static List<AdventureStage> getWorldStages(String worldId) {
    return stages.where((s) => s.worldId == worldId).toList();
  }

  // ─────────────────────────────────────────────────────────────────
  // HELPER DATA
  // ─────────────────────────────────────────────────────────────────
  static const Map<String, String> _letterWords = {
    'A': 'Apple', 'B': 'Ball', 'C': 'Cat', 'D': 'Dog',
    'E': 'Elephant', 'F': 'Fish', 'G': 'Goat', 'H': 'Hat',
    'I': 'Ice cream', 'J': 'Jug', 'K': 'Kite', 'L': 'Lion',
    'M': 'Mango', 'N': 'Nest', 'O': 'Orange', 'P': 'Parrot',
    'Q': 'Queen', 'R': 'Rabbit', 'S': 'Sun', 'T': 'Tiger',
    'U': 'Umbrella', 'V': 'Van', 'W': 'Water', 'X': 'Xylophone',
    'Y': 'Yak', 'Z': 'Zebra',
  };

  static const Map<int, String> _numberWords = {
    1: 'One', 2: 'Two', 3: 'Three', 4: 'Four', 5: 'Five',
    6: 'Six', 7: 'Seven', 8: 'Eight', 9: 'Nine', 10: 'Ten',
  };

  // Feedback phrases (randomly selected)
  static const List<String> correctFeedback = [
    'Excellent!', 'Amazing!', 'Well Done!', 'Super Star!',
    'Brilliant!', 'Awesome!', 'Great Job!', 'Fantastic!',
  ];

  static const List<String> incorrectFeedback = [
    'Oops! Try again!', 'Not this one!', 'Keep trying!', 'Almost!',
  ];

  // Power-up definitions
  static const List<Map<String, dynamic>> powerUps = [
    {'id': 'magnet', 'emoji': '🧲', 'label': 'Magnet', 'duration': 5},
    {'id': 'shield', 'emoji': '🛡️', 'label': 'Shield', 'duration': 0},
    {'id': 'double_score', 'emoji': '✨', 'label': '2× Score', 'duration': 10},
    {'id': 'slow_motion', 'emoji': '⏱️', 'label': 'Slow-Mo', 'duration': 5},
    {'id': 'jetpack', 'emoji': '🚀', 'label': 'Jetpack', 'duration': 5},
    {'id': 'rainbow', 'emoji': '🌈', 'label': 'Rainbow', 'duration': 8},
  ];

  // Obstacle definitions
  static const List<Map<String, dynamic>> obstacles = [
    {'emoji': '🪨', 'label': 'Rock'},
    {'emoji': '🌵', 'label': 'Cactus'},
    {'emoji': '🌳', 'label': 'Tree'},
    {'emoji': '💧', 'label': 'Water pit'},
    {'emoji': '🧱', 'label': 'Wall'},
  ];
}
