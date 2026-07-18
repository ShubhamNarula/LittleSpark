import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../data/models/letter_model.dart';
import '../../data/datasources/alphabet_data.dart';
import '../../services/progress_service.dart';
import '../../services/tts_service.dart';
import 'widgets/letter_detail_sheet.dart';

class AlphabetController extends GetxController {
  final ProgressService _progress = ProgressService.to;

  // Reactively track visited letters
  RxSet<String> get visitedLetters => _progress.visitedLetters;

  final List<LetterModel> letters = AlphabetData.letters;
  final RxString selectedLetter = ''.obs;

  void onLetterTap(LetterModel letter) {
    selectedLetter.value = letter.letter;
    
    // Check if letter was already visited
    final wasVisited = visitedLetters.contains(letter.letter);
    if (!wasVisited) {
      // Record visit, progress service will automatically increment star and handle saving
      _progress.addVisitedLetter(letter.letter);
    }
    
    // Display bottom sheet details
    showLetterDetail(letter);
  }

  void speak(String text) {
    TtsService.to.speak(text);
  }

  void showLetterDetail(LetterModel letter) {
    Get.bottomSheet(
      LetterDetailSheet(letter: letter),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
    );
  }

  @override
  void onClose() {
    TtsService.to.stop();
    super.onClose();
  }
}
