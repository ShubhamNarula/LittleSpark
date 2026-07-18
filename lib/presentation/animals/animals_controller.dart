import 'dart:math';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../data/models/animal_model.dart';
import '../../data/datasources/animals_data.dart';
import '../../services/progress_service.dart';
import '../../services/tts_service.dart';
import '../../services/audio_service.dart';
import 'widgets/animal_detail_sheet.dart';
import '../../core/utils/haptic_util.dart';

class AnimalsController extends GetxController {
  final ProgressService _progress = ProgressService.to;

  RxSet<String> get visitedAnimals => _progress.visitedAnimals;

  // View state
  final RxInt activeTab = 0.obs; // 0: Explore, 1: Animal Quiz
  final RxString selectedFilter = 'All 🌍'.obs;

  // Quiz state
  final RxInt quizType = 0.obs; // 0: Sound-based quiz, 1: Fun-fact-based quiz
  final RxString quizQuestion = ''.obs;
  final RxList<AnimalModel> quizOptions = <AnimalModel>[].obs;
  late Rx<AnimalModel> quizCorrectAnimal;
  final RxBool quizIsAnswered = false.obs;
  final RxBool quizIsCorrect = false.obs;
  final RxString quizSelectedName = ''.obs;
  final RxBool quizShakeOptions = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (AnimalsData.animals.isNotEmpty) {
      quizCorrectAnimal = AnimalsData.animals[0].obs;
    }
    generateQuizQuestion();

    // When user switches to Animal Quiz tab, speak the current question.
    // When user switches away, stop any ongoing speech.
    ever(activeTab, (int tab) {
      if (tab == 1) {
        // Switched to Animal Quiz — speak question if not yet answered
        if (!quizIsAnswered.value) {
          Future.delayed(const Duration(milliseconds: 300), () {
            if (activeTab.value == 1) {
              _speakQuizQuestion();
            }
          });
        }
      } else {
        // Switched away from Animal Quiz — stop speech
        TtsService.to.stop();
      }
    });
  }

  List<AnimalModel> get filteredAnimals {
    final filter = selectedFilter.value;
    if (filter.contains('All')) {
      return AnimalsData.animals;
    }
    final cleanFilter = filter.split(' ')[0].toLowerCase();
    return AnimalsData.animals.where((a) {
      return a.habitat.toLowerCase() == cleanFilter;
    }).toList();
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  void onAnimalTap(AnimalModel animal) {
    if (!visitedAnimals.contains(animal.name)) {
      _progress.addVisitedAnimal(animal.name);
    }
    showAnimalDetail(animal);
  }

  void speak(String text) {
    TtsService.to.speak(text);
  }

  void showAnimalDetail(AnimalModel animal) {
    Get.bottomSheet(
      AnimalDetailSheet(animal: animal),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
    );
  }

  // --- Animal Quiz Logic ---
  void generateQuizQuestion() {
    if (AnimalsData.animals.isEmpty) return;

    final Random rand = Random();
    quizIsAnswered.value = false;
    quizIsCorrect.value = false;
    quizSelectedName.value = '';
    quizShakeOptions.value = false;

    // Pick target animal
    final target = AnimalsData.animals[rand.nextInt(AnimalsData.animals.length)];
    quizCorrectAnimal.value = target;

    // Pick quiz type
    final type = rand.nextInt(2); // 0 or 1
    quizType.value = type;

    if (type == 0) {
      // Sound quiz: clean the text a bit (e.g. "WOOF! 🔊" -> "WOOF!")
      final soundStr = target.sound.split(' ')[0];
      quizQuestion.value = "Who goes '$soundStr'? 🔊";
    } else {
      // Fact quiz: clean text if needed
      quizQuestion.value = "Guess who: ${target.funFact}";
    }

    // Build 3 unique choices
    final list = [target];
    final all = List<AnimalModel>.from(AnimalsData.animals)..remove(target);
    all.shuffle();

    list.add(all[0]);
    list.add(all[1]);
    list.shuffle();

    quizOptions.value = list;

    // Only speak the question if the user is currently on the Animal Quiz tab
    if (activeTab.value == 1) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (activeTab.value == 1) {
          _speakQuizQuestion();
        }
      });
    }
  }

  /// Helper to speak the current quiz question based on quiz type.
  void _speakQuizQuestion() {
    final target = quizCorrectAnimal.value;
    if (quizType.value == 0) {
      final soundStr = target.sound.split(' ')[0];
      TtsService.to.speak("Which animal goes $soundStr?");
    } else {
      TtsService.to.speak("Listen carefully. Who is this? ${target.funFact}");
    }
  }

  void checkQuizAnswer(String selectedName) {
    if (quizIsAnswered.value && quizIsCorrect.value) return;

    quizSelectedName.value = selectedName;
    quizIsAnswered.value = true;

    final targetName = quizCorrectAnimal.value.name;

    if (selectedName == targetName) {
      quizIsCorrect.value = true;
      HapticUtil.medium();
      AudioService.to.playStar(); // success sound

      // Reward progress
      _progress.addStar(); // star + 15 XP + 5 Coins
      _progress.addCoins(5); // bonus coins
      _progress.addXP(10); // bonus XP

      TtsService.to.speak("Hooray! That is correct! It's a $targetName!");
    } else {
      quizIsCorrect.value = false;
      quizShakeOptions.value = true;
      HapticUtil.heavy();
      AudioService.to.playTap(); // slice/wrong answer click

      TtsService.to.speak("Oops! That's not correct. Let's try again!");

      Future.delayed(const Duration(milliseconds: 500), () {
        quizShakeOptions.value = false;
      });
    }
  }

  @override
  void onClose() {
    TtsService.to.stop();
    super.onClose();
  }
}
