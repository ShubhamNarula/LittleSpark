import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../../services/progress_service.dart';
import '../../services/audio_service.dart';
import '../../services/tts_service.dart';
import '../../core/utils/haptic_util.dart';
import '../../core/theme/app_colors.dart';

class VoiceWordModel {
  final String word;
  final String emoji;
  final List<String> syllables;

  const VoiceWordModel({
    required this.word,
    required this.emoji,
    required this.syllables,
  });
}

class VoiceController extends GetxController {
  final ProgressService _progress = ProgressService.to;
  final stt.SpeechToText _speech = stt.SpeechToText();

  RxBool isListening = false.obs;
  RxString lastResult = ''.obs;
  RxString selectedCategory = 'Animals'.obs;
  RxInt currentCardIndex = 0.obs;

  late final Map<String, List<VoiceWordModel>> categoriesData;

  @override
  void onInit() {
    super.onInit();
    
    // Categorized kid words
    categoriesData = {
      'Animals': const [
        VoiceWordModel(word: 'Lion', emoji: '🦁', syllables: ['Li', 'on']),
        VoiceWordModel(word: 'Monkey', emoji: '🐒', syllables: ['Mon', 'key']),
        VoiceWordModel(word: 'Penguin', emoji: '🐧', syllables: ['Pen', 'guin']),
        VoiceWordModel(word: 'Bear', emoji: '🐻', syllables: ['Bear']),
        VoiceWordModel(word: 'Frog', emoji: '🐸', syllables: ['Frog']),
      ],
      'Letters': const [
        VoiceWordModel(word: 'Apple', emoji: '🍎', syllables: ['Ap', 'ple']),
        VoiceWordModel(word: 'Zebra', emoji: '🦓', syllables: ['Ze', 'bra']),
        VoiceWordModel(word: 'House', emoji: '🏠', syllables: ['House']),
        VoiceWordModel(word: 'Nest', emoji: '🪹', syllables: ['Nest']),
        VoiceWordModel(word: 'Queen', emoji: '👸', syllables: ['Queen']),
      ],
      'Numbers': const [
        VoiceWordModel(word: 'Seven', emoji: '🌈', syllables: ['Sev', 'en']),
        VoiceWordModel(word: 'Twenty', emoji: '🥑', syllables: ['Twen', 'ty']),
        VoiceWordModel(word: 'Hundred', emoji: '🎉', syllables: ['Hun', 'dred']),
        VoiceWordModel(word: 'Twelve', emoji: '🍰', syllables: ['Twelve']),
        VoiceWordModel(word: 'Fifty', emoji: '🏁', syllables: ['Fif', 'ty']),
      ],
      'Colors': const [
        VoiceWordModel(word: 'Purple', emoji: '🍇', syllables: ['Pur', 'ple']),
        VoiceWordModel(word: 'Yellow', emoji: '🍌', syllables: ['Yel', 'low']),
        VoiceWordModel(word: 'Orange', emoji: '🍊', syllables: ['Or', 'ange']),
        VoiceWordModel(word: 'Green', emoji: '🐸', syllables: ['Green']),
        VoiceWordModel(word: 'Blue', emoji: '👖', syllables: ['Blue']),
      ],
      'Greetings': const [
        VoiceWordModel(word: 'Hello', emoji: '👋', syllables: ['Hel', 'lo']),
        VoiceWordModel(word: 'Superstar', emoji: '🌟', syllables: ['Su', 'per', 'star']),
        VoiceWordModel(word: 'Welcome', emoji: '🏡', syllables: ['Wel', 'come']),
        VoiceWordModel(word: 'Morning', emoji: '☀️', syllables: ['Morn', 'ing']),
        VoiceWordModel(word: 'Grow', emoji: '🌱', syllables: ['Grow']),
      ],
    };
  }

  List<VoiceWordModel> get currentCategoryWords {
    return categoriesData[selectedCategory.value] ?? [];
  }

  void changeCategory(String category) {
    selectedCategory.value = category;
    currentCardIndex.value = 0;
    lastResult.value = '';
    if (isListening.value) {
      stopListening();
    }
  }

  void onCardChanged(int index) {
    currentCardIndex.value = index;
    lastResult.value = '';
    if (isListening.value) {
      stopListening();
    }
  }

  Future<void> onMicTap() async {
    HapticUtil.light();
    if (isListening.value) {
      stopListening();
    } else {
      await startListening();
    }
  }

  Future<void> startListening() async {
    // Request microphone permission
    final permissionStatus = await Permission.microphone.request();
    if (!permissionStatus.isGranted) {
      Get.snackbar(
        "Microphone Required",
        "Please enable microphone permission in Settings to practice speaking! 🎤",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      bool available = await _speech.initialize(
        onStatus: (status) {
          if (status == 'notListening' || status == 'done') {
            isListening.value = false;
          }
        },
        onError: (errorNotification) {
          isListening.value = false;
          print("Speech recognition error: $errorNotification");
        },
      );

      if (available) {
        isListening.value = true;
        lastResult.value = '';
        
        await _speech.listen(
          onResult: (result) {
            lastResult.value = result.recognizedWords;
            _checkPronunciation(result.recognizedWords);
          },
          listenFor: const Duration(seconds: 4),
          pauseFor: const Duration(seconds: 2),
        );
      } else {
        // Fallback for simulators or unsupported platforms
        isListening.value = false;
        _simulateRecognition();
      }
    } catch (e) {
      isListening.value = false;
      _simulateRecognition();
    }
  }

  void stopListening() {
    _speech.stop();
    isListening.value = false;
  }

  void _checkPronunciation(String recognized) {
    final currentWord = currentCategoryWords[currentCardIndex.value].word.toLowerCase();
    if (recognized.toLowerCase().contains(currentWord)) {
      // Correct Match!
      HapticUtil.heavy();
      AudioService.to.playStar();
      _progress.incrementVoicePractice();
      
      // Stop listening once matched
      stopListening();

      // Show temporary overlay success notification
      Get.rawSnackbar(
        title: "Spectacular! 🌟",
        message: "You said it perfectly! +1 Star",
        backgroundColor: AppColors.successGreen,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(12),
        borderRadius: 16,
      );
    }
  }

  // Graceful simulation of match for testing/simulators if speech engine fails
  void _simulateRecognition() {
    Get.snackbar(
      "Simulator Fallback 🎤",
      "Tap the mic again to simulate pronunciation on simulator!",
      duration: const Duration(seconds: 2),
    );
    
    // Auto-check correct pronunciation after delay for demo
    Future.delayed(const Duration(seconds: 2), () {
      final target = currentCategoryWords[currentCardIndex.value].word;
      lastResult.value = target;
      _checkPronunciation(target);
    });
  }

  void speak(String text) {
    TtsService.to.speak(text);
  }

  @override
  void onClose() {
    _speech.stop();
    TtsService.to.stop();
    super.onClose();
  }
}
