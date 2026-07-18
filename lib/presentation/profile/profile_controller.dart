import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/progress_service.dart';
import '../../core/utils/haptic_util.dart';

class ProfileController extends GetxController {
  final ProgressService progress = ProgressService.to;

  // Expose reactive getters for Obx widgets
  RxSet<String> get unlockedBadges => progress.unlockedBadges;

  // Predefined kid-friendly avatars list
  final List<String> avatars = [
    '🧑‍🚀', '🦁', '🐼', '🦊', '🐨', '🐵',
    '🐱', '🐶', '🦄', '🦖', '🐝', '🦉',
    '🐸', '🐰', '🐯', '🐷', '🐧', '🐳'
  ];

  // Parental Gate math equation variables
  final RxInt parentGateNum1 = 0.obs;
  final RxInt parentGateNum2 = 0.obs;
  final TextEditingController mathAnswerController = TextEditingController();
  final RxString validationError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    generateParentEquation();
  }

  void generateParentEquation() {
    final Random random = Random();
    parentGateNum1.value = random.nextInt(9) + 2; // 2 - 10
    parentGateNum2.value = random.nextInt(8) + 2; // 2 - 9
    mathAnswerController.clear();
    validationError.value = '';
  }

  void updateAvatar(String emoji) {
    HapticUtil.medium();
    progress.updateAvatar(emoji);
    Get.rawSnackbar(
      message: "Avatar changed to $emoji! ✨",
      backgroundColor: const Color(0xFF22C55E),
      duration: const Duration(seconds: 2),
      borderRadius: 12,
      margin: const EdgeInsets.all(12),
    );
  }

  bool verifyParentGate(String answerStr) {
    final int? answeredVal = int.tryParse(answerStr.trim());
    final int correctVal = parentGateNum1.value + parentGateNum2.value;
    if (answeredVal == correctVal) {
      validationError.value = '';
      return true;
    } else {
      HapticUtil.heavy();
      validationError.value = "Oops! That's not correct. Try again!";
      return false;
    }
  }

  void executeWipe() {
    HapticUtil.heavy();
    progress.resetProgress();
    Get.back(); // close verification dialog
    Get.back(); // return to home
    Get.rawSnackbar(
      message: "Progress reset successfully! 🔄 Ready for new adventures!",
      backgroundColor: const Color(0xFFEF4444),
      duration: const Duration(seconds: 3),
      borderRadius: 12,
      margin: const EdgeInsets.all(12),
    );
  }
}
