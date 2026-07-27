import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/rhyme_model.dart';
import '../../data/datasources/rhymes_data.dart';
import '../../services/progress_service.dart';
import '../../services/tts_service.dart';
import '../../services/audio_service.dart';
import '../../core/utils/haptic_util.dart';

class RhymesController extends GetxController {
  final ProgressService _progress = ProgressService.to;

  // Navigation / Filter State
  final RxString activeLanguage = 'English'.obs; // English / Hindi

  // Featured Poem of the Day
  final Rxn<RhymeModel> poemOfTheDay = Rxn<RhymeModel>();

  // Playback State
  final Rxn<RhymeModel> playingRhyme = Rxn<RhymeModel>();
  final RxBool isPlaying = false.obs;
  final RxBool isLooping = false.obs;
  final RxString playingVideoId = ''.obs; // The selected randomized video ID
  final RxInt currentVideoIndex = 0.obs; // Track which video ID is active
  final RxBool isVideoError = false.obs; // True when all fallbacks exhausted
  int _videosTried = 0;

  // Shuffled rhymes list based on Daily Seed
  final RxList<RhymeModel> shuffledRhymes = <RhymeModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadDailyPoems();
  }

  void _loadDailyPoems() {
    final now = DateTime.now();
    // Daily seed based on YYYYMMDD
    final seed = now.year * 10000 + now.month * 100 + now.day;
    final random = Random(seed);

    final list = List<RhymeModel>.from(RhymesData.rhymes);
    list.shuffle(random);

    if (list.isNotEmpty) {
      poemOfTheDay.value = list.first;
    }
    shuffledRhymes.assignAll(list);
  }

  // Filtered List based on language from the daily shuffled list, excluding poem of the day
  List<RhymeModel> get filteredRhymes {
    final pod = poemOfTheDay.value;
    return shuffledRhymes.where((r) {
      return r.language == activeLanguage.value && (pod == null || r.id != pod.id);
    }).toList();
  }

  void setLanguage(String lang) {
    HapticUtil.light();
    activeLanguage.value = lang;
  }

  // Playback Control
  void startRhyme(RhymeModel rhyme) {
    HapticUtil.medium();
    playingRhyme.value = rhyme;
    isPlaying.value = true;
    isVideoError.value = false;
    currentVideoIndex.value = 0;
    _videosTried = 0;

    // Pick a random starting video ID from the list
    if (rhyme.youtubeVideoIds.isNotEmpty) {
      final list = rhyme.youtubeVideoIds;
      // Use DateTime microseconds for a good random seed
      final randomIdx = DateTime.now().microsecondsSinceEpoch % list.length;
      currentVideoIndex.value = randomIdx;
      playingVideoId.value = list[randomIdx];
    } else {
      playingVideoId.value = '';
      isVideoError.value = true;
    }
    
    // Stop any other sound/speech first
    AudioService.to.stopBgMusic();
    TtsService.to.stop();
    _progress.addVisitedRhyme(rhyme.id);
  }

  /// Cycle to the next available video ID when one fails
  void tryNextVideo() {
    final rhyme = playingRhyme.value;
    if (rhyme == null) return;

    final list = rhyme.youtubeVideoIds;
    if (list.isEmpty) {
      isVideoError.value = true;
      return;
    }

    _videosTried++;
    if (_videosTried >= list.length) {
      isVideoError.value = true;
      return;
    }

    final nextIndex = (currentVideoIndex.value + 1) % list.length;
    currentVideoIndex.value = nextIndex;
    playingVideoId.value = list[nextIndex];
    isPlaying.value = true;
    isVideoError.value = false;
  }

  void pauseRhyme() {
    isPlaying.value = false;
    TtsService.to.stop();
  }

  void resumeRhyme() {
    isPlaying.value = true;
  }

  void togglePlayPause() {
    HapticUtil.light();
    if (playingRhyme.value == null) return;

    if (isPlaying.value) {
      pauseRhyme();
    } else {
      resumeRhyme();
    }
  }

  void replay() {
    HapticUtil.medium();
    if (playingRhyme.value == null) return;
    isPlaying.value = true;
  }

  void toggleLoop() {
    HapticUtil.light();
    isLooping.value = !isLooping.value;
  }

  void completeRhyme() {
    TtsService.to.stop();
    isPlaying.value = false;
    
    // Reward the child!
    _progress.addStar();
    _progress.addCoins(5);
    _progress.addXP(10);
    AudioService.to.playStar();
    
    Get.rawSnackbar(
      title: "🎉 Rhyme Complete!",
      message: "You earned 5 Coins and 10 XP! ⭐",
      backgroundColor: const Color(0xFF22C55E),
      duration: const Duration(seconds: 3),
      borderRadius: 12,
      margin: const EdgeInsets.all(12),
    );
  }

  void stopAndClosePlayer() {
    isPlaying.value = false;
    playingRhyme.value = null;
    playingVideoId.value = '';
    TtsService.to.stop();
    // Resume background music on returning to list - Disabled as per user request
    // AudioService.to.startBgMusic();
    
    // Reload daily poems
    _loadDailyPoems();
  }

  @override
  void onClose() {
    TtsService.to.stop();
    AudioService.to.stopBgMusic();
    super.onClose();
  }
}
