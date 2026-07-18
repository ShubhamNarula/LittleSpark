import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_routes.dart';

// Screens
import 'presentation/splash/splash_screen.dart';
import 'presentation/force_update/force_update_screen.dart';
import 'services/force_update_service.dart';
import 'presentation/home/home_screen.dart';
import 'presentation/home/home_controller.dart';
import 'presentation/alphabet/alphabet_screen.dart';
import 'presentation/alphabet/alphabet_controller.dart';
import 'presentation/numbers/numbers_screen.dart';
import 'presentation/numbers/numbers_controller.dart';
import 'presentation/colors_shapes/colors_shapes_screen.dart';
import 'presentation/colors_shapes/colors_shapes_controller.dart';
import 'presentation/animals/animals_screen.dart';
import 'presentation/animals/animals_controller.dart';
import 'presentation/fruits/fruits_screen.dart';
import 'presentation/fruits/fruits_controller.dart';
import 'presentation/voice/voice_screen.dart';
import 'presentation/voice/voice_controller.dart';
import 'presentation/rewards/rewards_screen.dart';
import 'presentation/rewards/rewards_controller.dart';
import 'presentation/alphabet_find/alphabet_find_screen.dart';
import 'presentation/alphabet_find/alphabet_find_game_screen.dart';
import 'presentation/alphabet_find/alphabet_find_controller.dart';
import 'presentation/numbers_find/numbers_find_screen.dart';
import 'presentation/numbers_find/numbers_find_game_screen.dart';
import 'presentation/numbers_find/numbers_find_controller.dart';
import 'presentation/profile/profile_screen.dart';
import 'presentation/profile/profile_controller.dart';
import 'presentation/mini_games/mini_games_screen.dart';
import 'presentation/mini_games/mini_games_controller.dart';
import 'presentation/rhymes/rhymes_screen.dart';
import 'presentation/rhymes/rhymes_controller.dart';
import 'presentation/learning_adventure/controllers/adventure_controller.dart';
import 'presentation/learning_adventure/screens/adventure_home_screen.dart';
import 'presentation/learning_adventure/screens/adventure_game_screen.dart';
import 'presentation/learning_adventure/screens/adventure_result_screen.dart';

class LittleSparkApp extends StatelessWidget {
  const LittleSparkApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'LittleSpark',
      theme: AppTheme.darkTheme,
      initialRoute: AppRoutes.splash,
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
      ],
      getPages: [
        GetPage(
          name: AppRoutes.splash,
          page: () => const SplashScreen(),
        ),
        GetPage(
          name: AppRoutes.forceUpdate,
          page: () => ForceUpdateScreen(config: Get.arguments as UpdateConfig),
        ),
        GetPage(
          name: AppRoutes.home,
          page: () => const HomeScreen(),
          binding: BindingsBuilder(() {
            if (!Get.isRegistered<HomeController>()) {
              Get.put<HomeController>(HomeController(), permanent: true);
            }
          }),
        ),
        GetPage(
          name: AppRoutes.alphabet,
          page: () => const AlphabetScreen(),
          binding: BindingsBuilder(() {
            Get.lazyPut<AlphabetController>(() => AlphabetController());
          }),
        ),
        GetPage(
          name: AppRoutes.numbers,
          page: () => const NumbersScreen(),
          binding: BindingsBuilder(() {
            Get.lazyPut<NumbersController>(() => NumbersController());
          }),
        ),
        GetPage(
          name: AppRoutes.colorsShapes,
          page: () => const ColorsShapesScreen(),
          binding: BindingsBuilder(() {
            Get.lazyPut<ColorsShapesController>(() => ColorsShapesController());
          }),
        ),
        GetPage(
          name: AppRoutes.animals,
          page: () => const AnimalsScreen(),
          binding: BindingsBuilder(() {
            Get.lazyPut<AnimalsController>(() => AnimalsController());
          }),
        ),
        GetPage(
          name: AppRoutes.fruits,
          page: () => const FruitsScreen(),
          binding: BindingsBuilder(() {
            Get.lazyPut<FruitsController>(() => FruitsController());
          }),
        ),
        GetPage(
          name: AppRoutes.voice,
          page: () => const VoiceScreen(),
          binding: BindingsBuilder(() {
            Get.lazyPut<VoiceController>(() => VoiceController());
          }),
        ),
        GetPage(
          name: AppRoutes.rewards,
          page: () => const RewardsScreen(),
          binding: BindingsBuilder(() {
            Get.lazyPut<RewardsController>(() => RewardsController());
          }),
        ),
        GetPage(
          name: AppRoutes.alphabetFind,
          page: () => const AlphabetFindScreen(),
          binding: BindingsBuilder(() {
            Get.lazyPut<AlphabetFindController>(() => AlphabetFindController());
          }),
        ),
        GetPage(
          name: AppRoutes.alphabetFindGame,
          page: () => AlphabetFindGameScreen(),
        ),
        GetPage(
          name: AppRoutes.numbersFind,
          page: () => const NumbersFindScreen(),
          binding: BindingsBuilder(() {
            Get.lazyPut<NumbersFindController>(() => NumbersFindController());
          }),
        ),
        GetPage(
          name: AppRoutes.numbersFindGame,
          page: () => NumbersFindGameScreen(),
        ),
        GetPage(
          name: AppRoutes.profile,
          page: () => const ProfileScreen(),
          binding: BindingsBuilder(() {
            Get.lazyPut<ProfileController>(() => ProfileController());
          }),
        ),
        GetPage(
          name: AppRoutes.miniGames,
          page: () => const MiniGamesScreen(),
          binding: BindingsBuilder(() {
            Get.lazyPut<MiniGamesController>(() => MiniGamesController());
          }),
        ),
        GetPage(
          name: AppRoutes.rhymes,
          page: () => const RhymesScreen(),
          binding: BindingsBuilder(() {
            Get.lazyPut<RhymesController>(() => RhymesController());
          }),
        ),
        GetPage(
          name: AppRoutes.learningAdventure,
          page: () => const AdventureHomeScreen(),
          binding: BindingsBuilder(() {
            if (!Get.isRegistered<AdventureController>()) {
              Get.put<AdventureController>(AdventureController(), permanent: true);
            }
          }),
        ),
        GetPage(
          name: AppRoutes.learningAdventureGame,
          page: () => const AdventureGameScreen(),
          binding: BindingsBuilder(() {
            // Reuse the existing controller — do NOT create a new one
            if (!Get.isRegistered<AdventureController>()) {
              Get.put<AdventureController>(AdventureController(), permanent: true);
            }
          }),
        ),
        GetPage(
          name: AppRoutes.learningAdventureResult,
          page: () => const AdventureResultScreen(),
          binding: BindingsBuilder(() {
            // Reuse the existing controller — do NOT create a new one
            if (!Get.isRegistered<AdventureController>()) {
              Get.put<AdventureController>(AdventureController(), permanent: true);
            }
          }),
        ),
      ],
    );
  }
}
