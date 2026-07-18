import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../core/constants/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../services/progress_service.dart';

class ModuleInfo {
  final String name;
  final String route;
  final String emoji;
  final List<Color> colors;
  final double Function() getProgress;

  ModuleInfo({
    required this.name,
    required this.route,
    required this.emoji,
    required this.colors,
    required this.getProgress,
  });

  double get progress => getProgress().clamp(0.0, 1.0);
}

class HomeController extends GetxController {
  final ProgressService _progress = ProgressService.to;

  RxInt get totalStars => _progress.totalStarsRx;
  RxSet<String> get unlockedBadges => _progress.unlockedBadges;
  RxInt get xp => _progress.xpRx;
  RxInt get coins => _progress.coinsRx;
  RxInt get level => _progress.levelRx;
  RxInt get dailyStreak => _progress.dailyStreakRx;
  RxString get selectedAvatar => _progress.selectedAvatarRx;

  // Daily challenge
  RxString get dailyChallengeType => _progress.dailyChallengeTypeRx;
  RxInt get dailyChallengeTarget => _progress.dailyChallengeTargetRx;
  RxInt get dailyChallengeProgress => _progress.dailyChallengeProgressRx;
  RxBool get dailyChallengeCompleted => _progress.dailyChallengeCompletedRx;

  Map<String, dynamic>? get currentChallengeInfo => _progress.currentChallengeInfo;

  late final List<ModuleInfo> modules;

  /// Time-of-day greeting emoji and text
  String get greetingEmoji {
    final hour = DateTime.now().hour;
    if (hour < 12) return '🌅';
    if (hour < 17) return '☀️';
    return '🌙';
  }

  String get greetingText {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning!';
    if (hour < 17) return 'Good Afternoon!';
    return 'Good Evening!';
  }

  /// Rotating motivational quotes
  static const List<String> _quotes = [
    "Every expert was once a beginner! 🌟",
    "Learning is your superpower! 💪",
    "You're doing amazing! Keep going! 🚀",
    "Small steps lead to big adventures! 🏔️",
    "Today is a great day to learn! 📚",
    "You're a star learner! ⭐",
    "Practice makes perfect! 🎯",
    "Believe in yourself! You can do it! 🌈",
  ];

  String get dailyQuote {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return _quotes[dayOfYear % _quotes.length];
  }

  double get alphabetFindProgress {
    int totalFound = 0;
    try {
      final box = Hive.box('progress');
      for (int i = 1; i <= 5; i++) {
        final list = box.get('alphabetFind_stage_${i}_found');
        if (list != null && list is List) {
          totalFound += list.length;
        }
      }
    } catch (_) {}
    return totalFound / 26.0;
  }

  double get numbersFindProgress {
    int totalFound = 0;
    try {
      final box = Hive.box('progress');
      for (int i = 1; i <= 10; i++) {
        final list = box.get('numbersFind_stage_${i}_found');
        if (list != null && list is List) {
          totalFound += list.length;
        }
      }
    } catch (_) {}
    return totalFound / 100.0;
  }

  @override
  void onInit() {
    super.onInit();
    
    // Setup module metrics definitions
    modules = [
      ModuleInfo(
        name: 'A to Z 🔤',
        route: AppRoutes.alphabet,
        emoji: '🔤',
        colors: AppColors.alphabetGradient,
        getProgress: () => _progress.visitedLetters.length / 26.0,
      ),
      ModuleInfo(
        name: 'Count 1-100 🔢',
        route: AppRoutes.numbers,
        emoji: '🔢',
        colors: AppColors.numbersGradient,
        getProgress: () => _progress.visitedNumbers.length / 100.0,
      ),
      ModuleInfo(
        name: 'Colors & Shapes 🎨',
        route: AppRoutes.colorsShapes,
        emoji: '🎨',
        colors: AppColors.colorsShapesGradient,
        getProgress: () => (_progress.visitedColors.length + _progress.visitedShapes.length) / 22.0,
      ),
      ModuleInfo(
        name: 'Animal Kingdom 🐾',
        route: AppRoutes.animals,
        emoji: '🐾',
        colors: AppColors.animalsGradient,
        getProgress: () => _progress.visitedAnimals.length / 24.0,
      ),
      ModuleInfo(
        name: 'Fruits & Veggies 🍎',
        route: AppRoutes.fruits,
        emoji: '🍎',
        colors: AppColors.fruitsVeggiesGradient,
        getProgress: () => _progress.visitedFruits.length / 35.0,
      ),
      ModuleInfo(
        name: 'Say It! 🎤',
        route: AppRoutes.voice,
        emoji: '🎤',
        colors: AppColors.voiceGradient,
        getProgress: () => _progress.voicePracticeCount / 10.0,
      ),
      ModuleInfo(
        name: 'My Rewards 🏅',
        route: AppRoutes.rewards,
        emoji: '🏅',
        colors: AppColors.rewardsGradient,
        getProgress: () => _progress.unlockedBadges.length / 8.0,
      ),
      ModuleInfo(
        name: 'Mini Games 🎮',
        route: AppRoutes.miniGames,
        emoji: '🎮',
        colors: AppColors.miniGamesGradient,
        getProgress: () => _progress.miniGamesPlayed / 20.0,
      ),
      ModuleInfo(
        name: 'Find A-Z 🔤',
        route: AppRoutes.alphabetFind,
        emoji: '🔍',
        colors: const [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
        getProgress: () => alphabetFindProgress,
      ),
      ModuleInfo(
        name: 'Find 1-100 🔢',
        route: AppRoutes.numbersFind,
        emoji: '🔎',
        colors: const [Color(0xFF4ECDC4), Color(0xFF44A08D)],
        getProgress: () => numbersFindProgress,
      ),
      ModuleInfo(
        name: 'Rhymes & Poems 🎵',
        route: AppRoutes.rhymes,
        emoji: '🎵',
        colors: AppColors.rhymesGradient,
        getProgress: () => 1.0,
      ),
      ModuleInfo(
        name: 'Learning Adventure 🏃',
        route: AppRoutes.learningAdventure,
        emoji: '🏃',
        colors: AppColors.adventureGradient,
        getProgress: () => _progress.adventureProgress,
      ),
    ];
  }

  void refreshProgress() {
    // Notify GetX to rebuild reactive widgets relying on progress service
    update();
  }
}
