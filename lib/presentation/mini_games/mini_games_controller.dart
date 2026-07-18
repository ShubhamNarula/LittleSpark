import 'package:get/get.dart';
import '../../services/progress_service.dart';

class MiniGameInfo {
  final String name;
  final String emoji;
  final String description;
  final int difficultyStars;
  final String gameId;

  MiniGameInfo({
    required this.name,
    required this.emoji,
    required this.description,
    required this.difficultyStars,
    required this.gameId,
  });
}

class MiniGamesController extends GetxController {
  final ProgressService _progress = ProgressService.to;

  RxInt get coins => _progress.coinsRx;
  RxInt get miniGamesPlayed => _progress.miniGamesPlayedRx;

  final List<MiniGameInfo> games = [
    MiniGameInfo(
      name: 'Bubble Pop ABCs',
      emoji: '🫧',
      description: 'Pop the right letter bubbles!',
      difficultyStars: 1,
      gameId: 'bubble_pop',
    ),
    MiniGameInfo(
      name: 'Memory Match',
      emoji: '🧠',
      description: 'Find matching emoji pairs!',
      difficultyStars: 2,
      gameId: 'memory_match',
    ),
    MiniGameInfo(
      name: 'Color Catcher',
      emoji: '🎨',
      description: 'Catch the right colored objects!',
      difficultyStars: 2,
      gameId: 'color_catcher',
    ),
    MiniGameInfo(
      name: 'Shape Builder',
      emoji: '🔷',
      description: 'Build shapes from pieces!',
      difficultyStars: 3,
      gameId: 'shape_builder',
    ),
    MiniGameInfo(
      name: 'Treasure Hunt',
      emoji: '💰',
      description: 'Count the treasure items!',
      difficultyStars: 1,
      gameId: 'treasure_hunt',
    ),
    MiniGameInfo(
      name: 'Word Scramble',
      emoji: '🔤',
      description: 'Unscramble the letters to spell!',
      difficultyStars: 3,
      gameId: 'word_scramble',
    ),
    MiniGameInfo(
      name: 'Math Wizard',
      emoji: '🪄',
      description: 'Solve magical math problems!',
      difficultyStars: 3,
      gameId: 'math_wizard',
    ),
    MiniGameInfo(
      name: 'Pattern Match',
      emoji: '🧩',
      description: 'Find what comes next!',
      difficultyStars: 2,
      gameId: 'pattern_match',
    ),
    MiniGameInfo(
      name: 'Daily Spin',
      emoji: '🎡',
      description: 'Spin for daily rewards!',
      difficultyStars: 1,
      gameId: 'spin_wheel',
    ),
  ];

  int getHighScore(String gameId) {
    return _progress.gameHighScores[gameId] ?? 0;
  }
}
