import '../models/memory_match_level.dart';

class MemoryMatchData {
  // 16 Emoji Categories
  static const Map<String, List<String>> categories = {
    'Animals': ['🐶', '🐱', '🦊', '🐸', '🐵', '🐼', '🦁', '🐮', '🐷', '🐰', '🐻', '🦄', '🐯', '🐨', '🐘', '🦒'],
    'Birds': ['🦅', '🦆', '🦉', '🐦', '🦜', '🐧', '🦚', '🦩', '🕊️', '🦢', '🐓', '🦃', '🐤', '🦤', '🪶', '🐣'],
    'Fruits': ['🍎', '🍊', '🍋', '🍇', '🍓', '🍑', '🍒', '🥝', '🍌', '🍉', '🫐', '🥭', '🍍', '🥥', '🍐', '🫒'],
    'Vegetables': ['🥕', '🌽', '🥦', '🍅', '🧅', '🧄', '🥬', '🫑', '🥒', '🌶️', '🍆', '🥔', '🫘', '🥗', '🫛', '🍠'],
    'Vehicles': ['🚗', '🚕', '🏎️', '🚒', '🚑', '🚌', '🚂', '✈️', '🚁', '🛸', '🚀', '⛵', '🚲', '🛵', '🚜', '🚎'],
    'Colors': ['❤️', '🧡', '💛', '💚', '💙', '💜', '🖤', '🤍', '🤎', '💗', '💖', '🩵', '🩷', '🩶', '💝', '🫀'],
    'Shapes': ['⭐', '💎', '🔶', '🔷', '🔺', '🔻', '⬛', '⬜', '🟢', '🟡', '🔴', '🟣', '🟠', '🟤', '⭕', '💠'],
    'Numbers': ['1️⃣', '2️⃣', '3️⃣', '4️⃣', '5️⃣', '6️⃣', '7️⃣', '8️⃣', '9️⃣', '0️⃣', '🔟', '💯', '🎱', '🎲', '🔢', '#️⃣'],
    'Alphabet': ['🅰️', '🅱️', '🔤', '📝', '✏️', '📖', '📚', '🖊️', '🖍️', '📕', '📗', '📘', '📙', '📓', '📒', '🗒️'],
    'Space': ['🌍', '🌙', '⭐', '☀️', '🪐', '🌠', '🚀', '👽', '🛸', '🌌', '☄️', '🔭', '🌑', '🌕', '🌈', '💫'],
    'Ocean': ['🐟', '🐠', '🐡', '🦈', '🐙', '🦑', '🦐', '🦀', '🐚', '🐳', '🐬', '🦞', '🪸', '🐢', '🦭', '🪼'],
    'Dinosaurs': ['🦕', '🦖', '🐉', '🦎', '🐊', '🐍', '🦴', '🪺', '🥚', '🌿', '🌋', '🪨', '🏔️', '🦤', '🫎', '🐲'],
    'Flowers': ['🌸', '🌺', '🌻', '🌹', '🌷', '💐', '🌼', '🪻', '🪷', '🌾', '🍀', '🌵', '🎋', '🎍', '🪴', '🌿'],
    'Music': ['🎵', '🎶', '🎸', '🎹', '🥁', '🎺', '🎻', '🪗', '🎷', '🪘', '🎤', '🎧', '🪕', '📯', '🔔', '🎼'],
    'School': ['📚', '✏️', '🎒', '📐', '📏', '🖍️', '🖌️', '📝', '🔬', '🧮', '🎓', '📓', '🖊️', '📎', '📌', '🗂️'],
    'Sports': ['⚽', '🏀', '🏈', '⚾', '🎾', '🏐', '🏓', '🏸', '🥊', '⛳', '🏊', '🚴', '🤸', '🏄', '🎯', '🏆'],
  };

  // 30 Progressive Levels
  static const List<MemoryMatchLevel> levels = [
    // --- Beginner: 2×2 (2 pairs) ---
    MemoryMatchLevel(level: 1,  rows: 2, cols: 2, category: 'Animals',    categoryEmoji: '🐾', timeLimitSeconds: 60,  revealSeconds: 8, threeStarMoves: 2,  twoStarMoves: 4),
    MemoryMatchLevel(level: 2,  rows: 2, cols: 2, category: 'Fruits',     categoryEmoji: '🍎', timeLimitSeconds: 60,  revealSeconds: 8, threeStarMoves: 2,  twoStarMoves: 4),
    MemoryMatchLevel(level: 3,  rows: 2, cols: 2, category: 'Vehicles',   categoryEmoji: '🚗', timeLimitSeconds: 60,  revealSeconds: 8, threeStarMoves: 2,  twoStarMoves: 4),

    // --- Easy: 2×3 (3 pairs) ---
    MemoryMatchLevel(level: 4,  rows: 2, cols: 3, category: 'Birds',      categoryEmoji: '🐦', timeLimitSeconds: 90,  revealSeconds: 6, threeStarMoves: 4,  twoStarMoves: 7),
    MemoryMatchLevel(level: 5,  rows: 2, cols: 3, category: 'Colors',     categoryEmoji: '🎨', timeLimitSeconds: 90,  revealSeconds: 6, threeStarMoves: 4,  twoStarMoves: 7),
    MemoryMatchLevel(level: 6,  rows: 2, cols: 3, category: 'Ocean',      categoryEmoji: '🐠', timeLimitSeconds: 90,  revealSeconds: 6, threeStarMoves: 4,  twoStarMoves: 7),

    // --- Easy-Medium: 2×4 (4 pairs) ---
    MemoryMatchLevel(level: 7,  rows: 2, cols: 4, category: 'Shapes',     categoryEmoji: '🔷', timeLimitSeconds: 120, revealSeconds: 6, threeStarMoves: 5,  twoStarMoves: 9),
    MemoryMatchLevel(level: 8,  rows: 2, cols: 4, category: 'Flowers',    categoryEmoji: '🌸', timeLimitSeconds: 120, revealSeconds: 6, threeStarMoves: 5,  twoStarMoves: 9),
    MemoryMatchLevel(level: 9,  rows: 2, cols: 4, category: 'Dinosaurs',  categoryEmoji: '🦖', timeLimitSeconds: 120, revealSeconds: 6, threeStarMoves: 5,  twoStarMoves: 9),

    // --- Medium: 3×4 (6 pairs) ---
    MemoryMatchLevel(level: 10, rows: 3, cols: 4, category: 'Animals',    categoryEmoji: '🐾', timeLimitSeconds: 180, revealSeconds: 6, threeStarMoves: 8,  twoStarMoves: 14),
    MemoryMatchLevel(level: 11, rows: 3, cols: 4, category: 'Vegetables', categoryEmoji: '🥕', timeLimitSeconds: 180, revealSeconds: 6, threeStarMoves: 8,  twoStarMoves: 14),
    MemoryMatchLevel(level: 12, rows: 3, cols: 4, category: 'Music',      categoryEmoji: '🎵', timeLimitSeconds: 180, revealSeconds: 6, threeStarMoves: 8,  twoStarMoves: 14),
    MemoryMatchLevel(level: 13, rows: 3, cols: 4, category: 'Space',      categoryEmoji: '🚀', timeLimitSeconds: 170, revealSeconds: 6, threeStarMoves: 7,  twoStarMoves: 13),
    MemoryMatchLevel(level: 14, rows: 3, cols: 4, category: 'Sports',     categoryEmoji: '⚽', timeLimitSeconds: 170, revealSeconds: 6, threeStarMoves: 7,  twoStarMoves: 13),
    MemoryMatchLevel(level: 15, rows: 3, cols: 4, category: 'School',     categoryEmoji: '📚', timeLimitSeconds: 170, revealSeconds: 6, threeStarMoves: 7,  twoStarMoves: 13),

    // --- Medium-Hard: 4×4 (8 pairs) ---
    MemoryMatchLevel(level: 16, rows: 4, cols: 4, category: 'Fruits',     categoryEmoji: '🍎', timeLimitSeconds: 240, revealSeconds: 6, threeStarMoves: 10, twoStarMoves: 18),
    MemoryMatchLevel(level: 17, rows: 4, cols: 4, category: 'Birds',      categoryEmoji: '🐦', timeLimitSeconds: 240, revealSeconds: 6, threeStarMoves: 10, twoStarMoves: 18),
    MemoryMatchLevel(level: 18, rows: 4, cols: 4, category: 'Ocean',      categoryEmoji: '🐠', timeLimitSeconds: 230, revealSeconds: 6, threeStarMoves: 10, twoStarMoves: 17),
    MemoryMatchLevel(level: 19, rows: 4, cols: 4, category: 'Dinosaurs',  categoryEmoji: '🦖', timeLimitSeconds: 230, revealSeconds: 6, threeStarMoves: 10, twoStarMoves: 17),
    MemoryMatchLevel(level: 20, rows: 4, cols: 4, category: 'Vehicles',   categoryEmoji: '🚗', timeLimitSeconds: 220, revealSeconds: 6, threeStarMoves: 9,  twoStarMoves: 16),

    // --- Hard: 4×5 (10 pairs) ---
    MemoryMatchLevel(level: 21, rows: 4, cols: 5, category: 'Animals',    categoryEmoji: '🐾', timeLimitSeconds: 300, revealSeconds: 8, threeStarMoves: 13, twoStarMoves: 22),
    MemoryMatchLevel(level: 22, rows: 4, cols: 5, category: 'Flowers',    categoryEmoji: '🌸', timeLimitSeconds: 300, revealSeconds: 8, threeStarMoves: 13, twoStarMoves: 22),
    MemoryMatchLevel(level: 23, rows: 4, cols: 5, category: 'Music',      categoryEmoji: '🎵', timeLimitSeconds: 290, revealSeconds: 8, threeStarMoves: 12, twoStarMoves: 21),
    MemoryMatchLevel(level: 24, rows: 4, cols: 5, category: 'Colors',     categoryEmoji: '🎨', timeLimitSeconds: 290, revealSeconds: 8, threeStarMoves: 12, twoStarMoves: 21),
    MemoryMatchLevel(level: 25, rows: 4, cols: 5, category: 'Sports',     categoryEmoji: '⚽', timeLimitSeconds: 280, revealSeconds: 8, threeStarMoves: 12, twoStarMoves: 20),

    // --- Expert: 5×6 (15 pairs) ---
    MemoryMatchLevel(level: 26, rows: 5, cols: 6, category: 'Space',      categoryEmoji: '🚀', timeLimitSeconds: 360, revealSeconds: 8, threeStarMoves: 18, twoStarMoves: 30),
    MemoryMatchLevel(level: 27, rows: 5, cols: 6, category: 'School',     categoryEmoji: '📚', timeLimitSeconds: 360, revealSeconds: 8, threeStarMoves: 18, twoStarMoves: 30),
    MemoryMatchLevel(level: 28, rows: 5, cols: 6, category: 'Shapes',     categoryEmoji: '🔷', timeLimitSeconds: 350, revealSeconds: 8, threeStarMoves: 17, twoStarMoves: 28),
    MemoryMatchLevel(level: 29, rows: 5, cols: 6, category: 'Vegetables', categoryEmoji: '🥕', timeLimitSeconds: 350, revealSeconds: 8, threeStarMoves: 17, twoStarMoves: 28),
    MemoryMatchLevel(level: 30, rows: 5, cols: 6, category: 'Numbers',    categoryEmoji: '🔢', timeLimitSeconds: 340, revealSeconds: 8, threeStarMoves: 16, twoStarMoves: 27),
  ];

  /// Get emojis for a given category, shuffled and trimmed to the needed pair count.
  static List<String> getEmojisForCategory(String category, int pairCount) {
    final emojis = List<String>.from(categories[category] ?? categories['Animals']!);
    emojis.shuffle();
    return emojis.take(pairCount).toList();
  }
}
