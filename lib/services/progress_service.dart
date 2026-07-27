import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'audio_service.dart';
import '../presentation/rewards/widgets/badge_unlock_dialog.dart';

class ProgressService extends GetxService {
  static ProgressService get to => Get.find();

  late Box _box;

  // Reactively track stats in-memory
  final RxInt _totalStars = 0.obs;
  final RxSet<String> _visitedLetters = <String>{}.obs;
  final RxSet<int> _visitedNumbers = <int>{}.obs;
  final RxSet<String> _visitedAnimals = <String>{}.obs;
  final RxSet<String> _visitedFruits = <String>{}.obs;
  final RxSet<String> _visitedColors = <String>{}.obs;
  final RxSet<String> _visitedShapes = <String>{}.obs;
  final RxSet<String> _visitedRhymes = <String>{}.obs;
  final RxInt _voicePracticeCount = 0.obs;
  final RxSet<String> _unlockedBadges = <String>{}.obs;

  // New stats for gamification
  final RxInt _xp = 0.obs;
  final RxInt _coins = 0.obs;
  final RxInt _level = 1.obs;
  final RxInt _dailyStreak = 1.obs;
  final RxString _selectedAvatar = '🧑‍🚀'.obs;

  // Mini-games tracking
  final RxInt _miniGamesPlayed = 0.obs;
  final RxMap<String, int> _gameHighScores = <String, int>{}.obs;

  // Memory Match game tracking
  final RxInt _memoryMatchMaxLevel = 1.obs;
  final RxMap<String, int> _memoryMatchLevelStars = <String, int>{}.obs;
  final RxMap<String, int> _memoryMatchBestTimes = <String, int>{}.obs;
  final RxInt _memoryMatchTotalWins = 0.obs;

  // Daily challenge
  final RxString _dailyChallengeType = ''.obs;
  final RxInt _dailyChallengeTarget = 0.obs;
  final RxInt _dailyChallengeProgress = 0.obs;
  final RxBool _dailyChallengeCompleted = false.obs;

  // Learning Adventure progress
  final RxInt _adventureHighScore = 0.obs;
  final RxInt _adventureTotalStars = 0.obs;
  final RxInt _adventureUnlockedStage = 1.obs;
  final RxInt _adventureTotalCollected = 0.obs;

  Future<ProgressService> init() async {
    _box = Hive.box('progress');
    
    // Load initial values
    _totalStars.value = _box.get('totalStars', defaultValue: 0);
    
    final List letters = _box.get('visitedLetters', defaultValue: []);
    _visitedLetters.addAll(letters.cast<String>());
    
    final List numbers = _box.get('visitedNumbers', defaultValue: []);
    _visitedNumbers.addAll(numbers.cast<int>());
    
    final List animals = _box.get('visitedAnimals', defaultValue: []);
    _visitedAnimals.addAll(animals.cast<String>());
    
    final List fruits = _box.get('visitedFruits', defaultValue: []);
    _visitedFruits.addAll(fruits.cast<String>());
    
    final List colors = _box.get('visitedColors', defaultValue: []);
    _visitedColors.addAll(colors.cast<String>());
    
    final List shapes = _box.get('visitedShapes', defaultValue: []);
    _visitedShapes.addAll(shapes.cast<String>());

    final List rhymes = _box.get('visitedRhymes', defaultValue: []);
    _visitedRhymes.addAll(rhymes.cast<String>());
    
    _voicePracticeCount.value = _box.get('voicePracticeCount', defaultValue: 0);
    
    final List badges = _box.get('unlockedBadges', defaultValue: []);
    _unlockedBadges.addAll(badges.cast<String>());

    // Load new stats
    _xp.value = _box.get('xp', defaultValue: 0);
    _coins.value = _box.get('coins', defaultValue: 0);
    _level.value = _box.get('level', defaultValue: 1);
    _dailyStreak.value = _box.get('dailyStreak', defaultValue: 1);
    _selectedAvatar.value = _box.get('selectedAvatar', defaultValue: '🧑‍🚀');
    _miniGamesPlayed.value = _box.get('miniGamesPlayed', defaultValue: 0);

    // Load game high scores
    final Map scoresRaw = _box.get('gameHighScores', defaultValue: {});
    _gameHighScores.assignAll(Map<String, int>.from(scoresRaw));

    // Load memory match progress
    _memoryMatchMaxLevel.value = _box.get('memoryMatchMaxLevel', defaultValue: 1);
    _memoryMatchTotalWins.value = _box.get('memoryMatchTotalWins', defaultValue: 0);
    final Map starsRaw = _box.get('memoryMatchLevelStars', defaultValue: {});
    _memoryMatchLevelStars.assignAll(Map<String, int>.from(starsRaw));
    final Map timesRaw = _box.get('memoryMatchBestTimes', defaultValue: {});
    _memoryMatchBestTimes.assignAll(Map<String, int>.from(timesRaw));

    // Load adventure progress
    _adventureHighScore.value = _box.get('adventureHighScore', defaultValue: 0);
    _adventureTotalStars.value = _box.get('adventureTotalStars', defaultValue: 0);
    _adventureUnlockedStage.value = _box.get('adventureUnlockedStage', defaultValue: 1);
    _adventureTotalCollected.value = _box.get('adventureTotalCollected', defaultValue: 0);

    _checkDailyStreak();
    _setupDailyChallenge();
    
    return this;
  }

  void _checkDailyStreak() {
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    final lastOpen = _box.get('lastOpenDate', defaultValue: '') as String;
    if (lastOpen.isEmpty) {
      _box.put('lastOpenDate', todayStr);
      return;
    }
    if (lastOpen != todayStr) {
      final lastDate = DateTime.parse(lastOpen);
      final diff = DateTime.now().difference(lastDate).inDays;
      if (diff == 1) {
        _dailyStreak.value++;
        _box.put('dailyStreak', _dailyStreak.value);
        // Reward daily streak coins
        addCoins(10);
      } else if (diff > 1) {
        _dailyStreak.value = 1;
        _box.put('dailyStreak', _dailyStreak.value);
      }
      _box.put('lastOpenDate', todayStr);
    }
  }

  // Getters that return RxSet/RxInt for direct observation
  int get totalStars => _totalStars.value;
  RxInt get totalStarsRx => _totalStars;

  RxSet<String> get visitedLetters => _visitedLetters;
  RxSet<int> get visitedNumbers => _visitedNumbers;
  RxSet<String> get visitedAnimals => _visitedAnimals;
  RxSet<String> get visitedFruits => _visitedFruits;
  RxSet<String> get visitedColors => _visitedColors;
  RxSet<String> get visitedShapes => _visitedShapes;
  RxSet<String> get visitedRhymes => _visitedRhymes;

  int get voicePracticeCount => _voicePracticeCount.value;
  RxInt get voicePracticeCountRx => _voicePracticeCount;

  RxSet<String> get unlockedBadges => _unlockedBadges;

  int get xp => _xp.value;
  RxInt get xpRx => _xp;

  int get coins => _coins.value;
  RxInt get coinsRx => _coins;

  int get level => _level.value;
  RxInt get levelRx => _level;

  int get dailyStreak => _dailyStreak.value;
  RxInt get dailyStreakRx => _dailyStreak;

  String get selectedAvatar => _selectedAvatar.value;
  RxString get selectedAvatarRx => _selectedAvatar;

  int get miniGamesPlayed => _miniGamesPlayed.value;
  RxInt get miniGamesPlayedRx => _miniGamesPlayed;
  RxMap<String, int> get gameHighScores => _gameHighScores;

  // Memory Match getters
  int get memoryMatchMaxLevel => _memoryMatchMaxLevel.value;
  RxInt get memoryMatchMaxLevelRx => _memoryMatchMaxLevel;
  int get memoryMatchTotalWins => _memoryMatchTotalWins.value;
  RxInt get memoryMatchTotalWinsRx => _memoryMatchTotalWins;
  RxMap<String, int> get memoryMatchLevelStars => _memoryMatchLevelStars;
  RxMap<String, int> get memoryMatchBestTimes => _memoryMatchBestTimes;

  // Adventure getters
  int get adventureHighScore => _adventureHighScore.value;
  RxInt get adventureHighScoreRx => _adventureHighScore;
  int get adventureTotalStars => _adventureTotalStars.value;
  RxInt get adventureTotalStarsRx => _adventureTotalStars;
  int get adventureUnlockedStage => _adventureUnlockedStage.value;
  RxInt get adventureUnlockedStageRx => _adventureUnlockedStage;
  int get adventureTotalCollected => _adventureTotalCollected.value;
  double get adventureProgress => ((_adventureUnlockedStage.value - 1) / 48.0).clamp(0.0, 1.0);

  int getMemoryMatchLevelStars(int level) => _memoryMatchLevelStars['$level'] ?? 0;
  int getMemoryMatchBestTime(int level) => _memoryMatchBestTimes['$level'] ?? 0;

  void completeMemoryMatchLevel(int level, int stars, int timeSeconds) {
    // Update stars if better
    final currentStars = _memoryMatchLevelStars['$level'] ?? 0;
    if (stars > currentStars) {
      _memoryMatchLevelStars['$level'] = stars;
      _box.put('memoryMatchLevelStars', Map<String, int>.from(_memoryMatchLevelStars));
    }
    // Update best time if better (lower is better)
    final currentBest = _memoryMatchBestTimes['$level'] ?? 999;
    if (timeSeconds < currentBest) {
      _memoryMatchBestTimes['$level'] = timeSeconds;
      _box.put('memoryMatchBestTimes', Map<String, int>.from(_memoryMatchBestTimes));
    }
    // Unlock next level
    if (level >= _memoryMatchMaxLevel.value) {
      _memoryMatchMaxLevel.value = level + 1;
      _box.put('memoryMatchMaxLevel', _memoryMatchMaxLevel.value);
    }
    // Increment total wins
    _memoryMatchTotalWins.value++;
    _box.put('memoryMatchTotalWins', _memoryMatchTotalWins.value);
  }

  // Adventure progress methods
  void addVisitedRhyme(String rhymeId) {
    if (!_visitedRhymes.contains(rhymeId)) {
      _visitedRhymes.add(rhymeId);
      _box.put('visitedRhymes', _visitedRhymes.toList());
    }
  }

  void updateAdventureHighScore(int score) {
    if (score > _adventureHighScore.value) {
      _adventureHighScore.value = score;
      _box.put('adventureHighScore', score);
    }
  }

  void addAdventureStar() {
    _adventureTotalStars.value++;
    _box.put('adventureTotalStars', _adventureTotalStars.value);
  }

  void unlockAdventureStage(int stage) {
    if (stage > _adventureUnlockedStage.value) {
      _adventureUnlockedStage.value = stage;
      _box.put('adventureUnlockedStage', stage);
    }
  }

  void incrementAdventureCollected() {
    _adventureTotalCollected.value++;
    _box.put('adventureTotalCollected', _adventureTotalCollected.value);
    _advanceDailyChallenge('play_games');
  }

  String get dailyChallengeType => _dailyChallengeType.value;
  RxString get dailyChallengeTypeRx => _dailyChallengeType;
  int get dailyChallengeTarget => _dailyChallengeTarget.value;
  RxInt get dailyChallengeTargetRx => _dailyChallengeTarget;
  int get dailyChallengeProgress => _dailyChallengeProgress.value;
  RxInt get dailyChallengeProgressRx => _dailyChallengeProgress;
  bool get dailyChallengeCompleted => _dailyChallengeCompleted.value;
  RxBool get dailyChallengeCompletedRx => _dailyChallengeCompleted;

  void addStar() {
    _totalStars.value++;
    _box.put('totalStars', _totalStars.value);
    
    // Play star earn sound
    AudioService.to.playStar();
    
    addXP(15);
    addCoins(5);
    
    _advanceDailyChallenge('earn_stars');
    _checkBadges();
  }

  void addXP(int amount) {
    _xp.value += amount;
    final xpNeeded = _level.value * 100;
    if (_xp.value >= xpNeeded) {
      _xp.value -= xpNeeded;
      _level.value++;
      _box.put('level', _level.value);
      addCoins(50);
      
      // Play level up sound
      AudioService.to.playBadgeUnlock(); // plays completion.mp3
      
      // Show non-blocking popup notification
      Get.rawSnackbar(
        titleText: const Text(
          "🎉 Level Up! 🎉",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
            fontFamily: 'FredokaOne',
          ),
        ),
        messageText: Text(
          "You reached Level ${_level.value}! +50 Coins 🪙",
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16.0,
            fontFamily: 'Nunito',
          ),
        ),
        backgroundColor: const Color(0xFFC084FC),
        borderRadius: 20,
        margin: const EdgeInsets.all(16.0),
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
    }
    _box.put('xp', _xp.value);
  }

  void addCoins(int amount) {
    _coins.value += amount;
    _box.put('coins', _coins.value);
    _advanceDailyChallenge('earn_coins');
  }

  void updateAvatar(String emoji) {
    _selectedAvatar.value = emoji;
    _box.put('selectedAvatar', emoji);
  }

  void incrementMiniGamesPlayed() {
    _miniGamesPlayed.value++;
    _box.put('miniGamesPlayed', _miniGamesPlayed.value);
    _advanceDailyChallenge('play_games');
  }

  void updateGameHighScore(String gameId, int score) {
    final current = _gameHighScores[gameId] ?? 0;
    if (score > current) {
      _gameHighScores[gameId] = score;
      _box.put('gameHighScores', Map<String, int>.from(_gameHighScores));
    }
  }

  // Daily challenge system
  static const List<Map<String, dynamic>> _challengePool = [
    {'type': 'learn_letters', 'text': 'Learn 3 new letters today! 🔤', 'target': 3, 'emoji': '🔤'},
    {'type': 'learn_numbers', 'text': 'Explore 5 new numbers! 🔢', 'target': 5, 'emoji': '🔢'},
    {'type': 'play_games', 'text': 'Play 2 mini-games! 🎮', 'target': 2, 'emoji': '🎮'},
    {'type': 'earn_stars', 'text': 'Earn 5 stars today! ⭐', 'target': 5, 'emoji': '⭐'},
    {'type': 'visit_animals', 'text': 'Discover 3 animals! 🐾', 'target': 3, 'emoji': '🐾'},
    {'type': 'earn_coins', 'text': 'Collect 20 coins! 🪙', 'target': 20, 'emoji': '🪙'},
  ];

  void _setupDailyChallenge() {
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    final savedDate = _box.get('dailyChallengeDate', defaultValue: '') as String;

    if (savedDate == todayStr) {
      // Load existing challenge
      _dailyChallengeType.value = _box.get('dailyChallengeType', defaultValue: '') as String;
      _dailyChallengeTarget.value = _box.get('dailyChallengeTarget', defaultValue: 0) as int;
      _dailyChallengeProgress.value = _box.get('dailyChallengeProgressVal', defaultValue: 0) as int;
      _dailyChallengeCompleted.value = _box.get('dailyChallengeCompleted', defaultValue: false) as bool;
    } else {
      // Generate new daily challenge based on day of year for consistency
      final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
      final challenge = _challengePool[dayOfYear % _challengePool.length];

      _dailyChallengeType.value = challenge['type'] as String;
      _dailyChallengeTarget.value = challenge['target'] as int;
      _dailyChallengeProgress.value = 0;
      _dailyChallengeCompleted.value = false;

      _box.put('dailyChallengeDate', todayStr);
      _box.put('dailyChallengeType', _dailyChallengeType.value);
      _box.put('dailyChallengeTarget', _dailyChallengeTarget.value);
      _box.put('dailyChallengeProgressVal', 0);
      _box.put('dailyChallengeCompleted', false);
    }
  }

  Map<String, dynamic>? get currentChallengeInfo {
    if (_dailyChallengeType.value.isEmpty) return null;
    try {
      return _challengePool.firstWhere((c) => c['type'] == _dailyChallengeType.value);
    } catch (_) {
      return null;
    }
  }

  void _advanceDailyChallenge(String type) {
    if (_dailyChallengeCompleted.value) return;
    if (_dailyChallengeType.value != type) return;

    _dailyChallengeProgress.value++;
    _box.put('dailyChallengeProgressVal', _dailyChallengeProgress.value);

    if (_dailyChallengeProgress.value >= _dailyChallengeTarget.value) {
      _dailyChallengeCompleted.value = true;
      _box.put('dailyChallengeCompleted', true);
      addCoins(25);
      addXP(30);
    }
  }

  void resetProgress() {
    _totalStars.value = 0;
    _visitedLetters.clear();
    _visitedNumbers.clear();
    _visitedAnimals.clear();
    _visitedFruits.clear();
    _visitedColors.clear();
    _visitedShapes.clear();
    _voicePracticeCount.value = 0;
    _unlockedBadges.clear();
    _xp.value = 0;
    _coins.value = 0;
    _level.value = 1;
    _dailyStreak.value = 1;
    _selectedAvatar.value = '🧑‍🚀';
    _miniGamesPlayed.value = 0;
    _gameHighScores.clear();
    _memoryMatchMaxLevel.value = 1;
    _memoryMatchLevelStars.clear();
    _memoryMatchBestTimes.clear();
    _memoryMatchTotalWins.value = 0;
    _dailyChallengeProgress.value = 0;
    _dailyChallengeCompleted.value = false;
    
    _box.clear();
    
    // Re-save defaults
    _box.put('totalStars', 0);
    _box.put('visitedLetters', <String>[]);
    _box.put('visitedNumbers', <int>[]);
    _box.put('visitedAnimals', <String>[]);
    _box.put('visitedFruits', <String>[]);
    _box.put('visitedColors', <String>[]);
    _box.put('visitedShapes', <String>[]);
    _box.put('voicePracticeCount', 0);
    _box.put('unlockedBadges', <String>[]);
    _box.put('xp', 0);
    _box.put('coins', 0);
    _box.put('level', 1);
    _box.put('dailyStreak', 1);
    _box.put('selectedAvatar', '🧑‍🚀');
  }

  void addVisitedLetter(String letter) {
    if (!_visitedLetters.contains(letter)) {
      _visitedLetters.add(letter);
      _box.put('visitedLetters', _visitedLetters.toList());
      _advanceDailyChallenge('learn_letters');
      addStar();
    }
  }

  void addVisitedNumber(int n) {
    if (!_visitedNumbers.contains(n)) {
      _visitedNumbers.add(n);
      _box.put('visitedNumbers', _visitedNumbers.toList());
      _advanceDailyChallenge('learn_numbers');
      addStar();
    }
  }

  void addVisitedAnimal(String animal) {
    if (!_visitedAnimals.contains(animal)) {
      _visitedAnimals.add(animal);
      _box.put('visitedAnimals', _visitedAnimals.toList());
      _advanceDailyChallenge('visit_animals');
      addStar();
    }
  }

  void addVisitedFruit(String fruit) {
    if (!_visitedFruits.contains(fruit)) {
      _visitedFruits.add(fruit);
      _box.put('visitedFruits', _visitedFruits.toList());
      addStar();
    }
  }

  void addVisitedColor(String color) {
    if (!_visitedColors.contains(color)) {
      _visitedColors.add(color);
      _box.put('visitedColors', _visitedColors.toList());
      addStar();
    }
  }

  void addVisitedShape(String shape) {
    if (!_visitedShapes.contains(shape)) {
      _visitedShapes.add(shape);
      _box.put('visitedShapes', _visitedShapes.toList());
      addStar();
    }
  }

  void incrementVoicePractice() {
    _voicePracticeCount.value++;
    _box.put('voicePracticeCount', _voicePracticeCount.value);
    addStar();
  }

  void _checkBadges() {
    final badges = <String>[];
    
    // 🌟 First Steps - Open any module or earn 1 star
    if (totalStars >= 1) badges.add('first_steps');
    
    // 🔤 Alphabet Hero - Explore all 26 letters
    if (_visitedLetters.length >= 26) badges.add('alphabet_hero');
    
    // 🔢 Count Master - Click all 100 numbers
    if (_visitedNumbers.length >= 100) badges.add('count_master');
    
    // 🎨 Color Wizard - Explore all 12 colors
    if (_visitedColors.length >= 12) badges.add('color_wizard');
    
    // 🐾 Animal Expert - Discover all 24 animals
    if (_visitedAnimals.length >= 24) badges.add('animal_expert');
    
    // 🍎 Healthy Champ - Explore all fruits & veggies (35 items)
    if (_visitedFruits.length >= 35) badges.add('healthy_champ');
    
    // 🎤 Speakeasy - Use voice module 10 times
    if (_voicePracticeCount.value >= 10) badges.add('speakeasy');
    
    // 💎 LittleSpark Legend - Earn 100 total stars
    if (totalStars >= 100) badges.add('littlespark_legend');

    bool newUnlock = false;
    
    for (final b in badges) {
      if (!_unlockedBadges.contains(b)) {
        _unlockedBadges.add(b);
        newUnlock = true;
        AudioService.to.playBadgeUnlock();
        _showBadgeUnlockOverlay(b);
      }
    }
    
    if (newUnlock) {
      _box.put('unlockedBadges', _unlockedBadges.toList());
    }
  }

  void _showBadgeUnlockOverlay(String badgeId) {
    Get.dialog(
      BadgeUnlockDialog(badgeId: badgeId),
      barrierDismissible: true,
    );
  }
}
