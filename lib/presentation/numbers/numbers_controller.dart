import 'dart:async';
import 'dart:math';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../data/models/number_model.dart';
import '../../data/datasources/numbers_data.dart';
import '../../services/progress_service.dart';
import '../../services/tts_service.dart';
import '../../services/audio_service.dart';
import 'widgets/number_detail_overlay.dart';
import '../../core/utils/haptic_util.dart';

class NumbersController extends GetxController {
  final ProgressService _progress = ProgressService.to;

  RxSet<int> get visitedNumbers => _progress.visitedNumbers;

  // Ranges definition
  static const List<Map<String, dynamic>> ranges = [
    {'label': '1-10', 'min': 1, 'max': 10},
    {'label': '11-20', 'min': 11, 'max': 20},
    {'label': '21-50', 'min': 21, 'max': 50},
    {'label': '51-100', 'min': 51, 'max': 100},
    {'label': '101-500', 'min': 101, 'max': 500},
    {'label': '501-1000', 'min': 501, 'max': 1000},
  ];

  final RxInt currentRangeIndex = 0.obs;
  final RxList<NumberModel> numbersList = <NumberModel>[].obs;

  // Tab State
  final RxInt activeTab = 0.obs; // 0: Learn, 1: Play Games

  // Count Along State
  RxBool isCountAlongMode = false.obs;
  RxInt countAlongCurrent = 0.obs;
  Timer? _countAlongTimer;

  // Interactive Games State
  final RxInt currentGameType = 0.obs; // 0: Object Counting, 1: Missing Number, 2: Before/After, 3: Odd/Even, 4: Greater/Smaller
  final RxString gameQuestion = ''.obs;
  final RxInt gameCount = 0.obs;
  final RxString gameEmoji = '🎈'.obs;
  final RxList<String> gameOptions = <String>[].obs;
  final RxString gameCorrectAnswer = ''.obs;
  final RxBool gameIsAnswered = false.obs;
  final RxBool gameIsCorrect = false.obs;
  final RxString gameSelectedOption = ''.obs;
  final RxBool gameShakeOptions = false.obs;

  final List<String> _gameEmojis = ['🎈', '🧸', '🚗', '🍎', '🐱', '🍦', '🍪', '🍩', '🦁', '🦖', '🐝', '🐸', '🦆', '🍓'];

  @override
  void onInit() {
    super.onInit();
    activeTab.value = 0; // Explicitly start at Learn Grid tab
    loadRange(0);

    // When user switches to Play Games tab, speak/generate the current question.
    // When user switches away, stop any ongoing speech.
    ever(activeTab, (int tab) {
      if (tab == 1) {
        // Switched to Play Games
        if (gameQuestion.value.isEmpty || gameIsCorrect.value) {
          generateNewGame();
        } else if (!gameIsAnswered.value) {
          Future.delayed(const Duration(milliseconds: 300), () {
            if (activeTab.value == 1) {
              TtsService.to.speak(gameQuestion.value);
            }
          });
        }
      } else {
        // Switched away from Play Games — stop speech
        TtsService.to.stop();
      }
    });
  }

  void loadRange(int index) {
    currentRangeIndex.value = index;
    final range = ranges[index];
    final minVal = range['min'] as int;
    final maxVal = range['max'] as int;

    final List<NumberModel> list = [];
    for (int i = minVal; i <= maxVal; i++) {
      if (i <= 100) {
        list.add(NumbersData.numbers[i - 1]);
      } else {
        list.add(NumberModel(
          number: i,
          word: numberToWord(i),
          emoji: '🔢',
          funFact: 'Let\'s count together and learn the number $i! 🚀',
        ));
      }
    }
    numbersList.value = list;
    stopCountAlong();
  }

  String numberToWord(int n) {
    if (n == 0) return 'Zero';
    const units = [
      '', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine', 'Ten',
      'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen'
    ];
    const tens = [
      '', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety'
    ];

    if (n < 20) return units[n];
    if (n < 100) return tens[n ~/ 10] + (n % 10 != 0 ? ' ' + units[n % 10] : '');
    if (n < 1000) return units[n ~/ 100] + ' Hundred' + (n % 100 != 0 ? ' and ' + numberToWord(n % 100) : '');
    if (n == 1000) return 'One Thousand';
    return '$n';
  }

  // --- Learn Tab Logic ---
  void startCountAlong() {
    stopCountAlong();
    isCountAlongMode.value = true;
    
    final range = ranges[currentRangeIndex.value];
    final minVal = range['min'] as int;
    final maxVal = range['max'] as int;
    
    countAlongCurrent.value = minVal;
    _visitCurrentCount();

    _countAlongTimer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      if (countAlongCurrent.value >= maxVal) {
        stopCountAlong();
      } else {
        countAlongCurrent.value++;
        _visitCurrentCount();
      }
    });
  }

  void _visitCurrentCount() {
    final currentVal = countAlongCurrent.value;
    TtsService.to.speak("$currentVal");
    _progress.addVisitedNumber(currentVal);
  }

  void stopCountAlong() {
    _countAlongTimer?.cancel();
    _countAlongTimer = null;
    isCountAlongMode.value = false;
    countAlongCurrent.value = 0;
  }

  void onNumberTap(NumberModel n) {
    if (isCountAlongMode.value) {
      stopCountAlong();
    }
    _progress.addVisitedNumber(n.number);
    showNumberDetail(n);
  }

  void showNumberDetail(NumberModel number) {
    Get.dialog(
      NumberDetailOverlay(number: number),
      barrierColor: Colors.black.withOpacity(0.7),
      useSafeArea: true,
    );
  }

  // --- Interactive Games Tab Logic ---
  void generateNewGame() {
    final rand = Random();
    final type = rand.nextInt(5); // 0 to 4
    currentGameType.value = type;
    
    gameIsAnswered.value = false;
    gameIsCorrect.value = false;
    gameSelectedOption.value = '';
    gameShakeOptions.value = false;

    // Pick a random game emoji
    gameEmoji.value = _gameEmojis[rand.nextInt(_gameEmojis.length)];

    switch (type) {
      case 0: // Object Counting
        final count = rand.nextInt(8) + 2; // 2 to 9
        gameCount.value = count;
        gameQuestion.value = "How many ${gameEmoji.value} can you count?";
        gameCorrectAnswer.value = "$count";

        final opt1 = count;
        int opt2 = rand.nextInt(8) + 2;
        while (opt2 == opt1) {
          opt2 = rand.nextInt(8) + 2;
        }
        int opt3 = rand.nextInt(8) + 2;
        while (opt3 == opt1 || opt3 == opt2) {
          opt3 = rand.nextInt(8) + 2;
        }
        final list = [opt1, opt2, opt3]..shuffle();
        gameOptions.value = list.map((e) => "$e").toList();
        break;

      case 1: // Missing Number
        final start = rand.nextInt(15) + 1; // 1 to 15
        final gap = rand.nextInt(3); // index of gap: 0, 1, or 2
        final seq = [start, start + 1, start + 2];
        final correct = seq[gap];
        gameCorrectAnswer.value = "$correct";

        final String seqStr = seq.map((e) => e == correct ? "_" : "$e").join(", ");
        gameQuestion.value = "Find the missing number:  $seqStr";

        final opt1 = correct;
        final opt2 = correct + 1;
        final opt3 = correct - 1 > 0 ? correct - 1 : correct + 2;
        final listOptions = [opt1, opt2, opt3]..shuffle();
        gameOptions.value = listOptions.map((e) => "$e").toList();
        break;

      case 2: // Before / After
        final numVal = rand.nextInt(20) + 5; // 5 to 24
        final isAfter = rand.nextBool();
        if (isAfter) {
          gameQuestion.value = "What number comes after $numVal?";
          gameCorrectAnswer.value = "${numVal + 1}";
          
          final listOptions = [numVal + 1, numVal - 1, numVal + 2]..shuffle();
          gameOptions.value = listOptions.map((e) => "$e").toList();
        } else {
          gameQuestion.value = "What number comes before $numVal?";
          gameCorrectAnswer.value = "${numVal - 1}";
          
          final listOptions = [numVal - 1, numVal + 1, numVal - 2]..shuffle();
          gameOptions.value = listOptions.map((e) => "$e").toList();
        }
        break;

      case 3: // Odd / Even
        final numVal = rand.nextInt(20) + 1; // 1 to 20
        gameQuestion.value = "Is the number $numVal Odd or Even?";
        gameCorrectAnswer.value = (numVal % 2 == 0) ? "Even" : "Odd";
        gameOptions.value = ["Odd", "Even"];
        break;

      case 4: // Greater / Smaller
        final n1 = rand.nextInt(30) + 1;
        int n2 = rand.nextInt(30) + 1;
        while (n2 == n1) {
          n2 = rand.nextInt(30) + 1;
        }
        final isGreater = rand.nextBool();
        if (isGreater) {
          gameQuestion.value = "Which number is greater: $n1 or $n2?";
          gameCorrectAnswer.value = n1 > n2 ? "$n1" : "$n2";
        } else {
          gameQuestion.value = "Which number is smaller: $n1 or $n2?";
          gameCorrectAnswer.value = n1 < n2 ? "$n1" : "$n2";
        }
        gameOptions.value = ["$n1", "$n2"];
        break;
    }

    // Only speak the question if the user is currently on the Play Games tab
    if (activeTab.value == 1) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (activeTab.value == 1) {
          TtsService.to.speak(gameQuestion.value);
        }
      });
    }
  }

  void checkGameAnswer(String option) {
    if (gameIsAnswered.value && gameIsCorrect.value) return;

    gameSelectedOption.value = option;
    gameIsAnswered.value = true;

    if (option == gameCorrectAnswer.value) {
      gameIsCorrect.value = true;
      HapticUtil.medium();
      AudioService.to.playStar(); // plays success.mp3

      // Award Rewards
      _progress.addStar();
      _progress.addCoins(5);
      _progress.addXP(10);

      TtsService.to.speak("Great job! $option is correct!");
    } else {
      gameIsCorrect.value = false;
      gameShakeOptions.value = true;
      HapticUtil.heavy();
      AudioService.to.playTap(); // slice/wrong answer tap

      TtsService.to.speak("Oops! Try again. Let's find the correct answer!");

      Future.delayed(const Duration(milliseconds: 500), () {
        gameShakeOptions.value = false;
      });
    }
  }

  @override
  void onClose() {
    _countAlongTimer?.cancel();
    TtsService.to.stop();
    super.onClose();
  }
}
