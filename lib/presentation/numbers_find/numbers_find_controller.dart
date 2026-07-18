import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import '../../core/utils/haptic_util.dart';
import '../../core/theme/app_colors.dart';
import '../../services/audio_service.dart';
import '../../services/tts_service.dart';
import '../../services/progress_service.dart';

class NumbersFindController extends GetxController {

  // Stage definitions (id, range, label, color, emoji)
  static const List<Map<String, dynamic>> stages = [
    {'id':1,  'from':1,  'to':10,  'label':'Stage 1',  'subtitle':'1 to 10',   'emoji':'1️⃣',  'color':0xFF60A5FA},
    {'id':2,  'from':11, 'to':20,  'label':'Stage 2',  'subtitle':'11 to 20',  'emoji':'🔟',  'color':0xFF4ECDC4},
    {'id':3,  'from':21, 'to':30,  'label':'Stage 3',  'subtitle':'21 to 30',  'emoji':'2️⃣',  'color':0xFFC084FC},
    {'id':4,  'from':31, 'to':40,  'label':'Stage 4',  'subtitle':'31 to 40',  'emoji':'3️⃣',  'color':0xFFFB923C},
    {'id':5,  'from':41, 'to':50,  'label':'Stage 5',  'subtitle':'41 to 50',  'emoji':'4️⃣',  'color':0xFFF472B6},
    {'id':6,  'from':51, 'to':60,  'label':'Stage 6',  'subtitle':'51 to 60',  'emoji':'5️⃣',  'color':0xFF4ECDC4},
    {'id':7,  'from':61, 'to':70,  'label':'Stage 7',  'subtitle':'61 to 70',  'emoji':'6️⃣',  'color':0xFFFF6B6B},
    {'id':8,  'from':71, 'to':80,  'label':'Stage 8',  'subtitle':'71 to 80',  'emoji':'7️⃣',  'color':0xFF84CC16},
    {'id':9,  'from':81, 'to':90,  'label':'Stage 9',  'subtitle':'81 to 90',  'emoji':'8️⃣',  'color':0xFF818CF8},
    {'id':10, 'from':91, 'to':100, 'label':'Stage 10', 'subtitle':'91 to 100', 'emoji':'💯',  'color':0xFFFFD700},
  ];

  // Fun facts for each number
  static const Map<int, Map<String, String>> numberData = {
    1:   {'word': 'One',         'emoji': '☝️',  'fact': 'You have 1 nose on your face!'},
    2:   {'word': 'Two',         'emoji': '✌️',  'fact': 'You have 2 eyes to see the world!'},
    3:   {'word': 'Three',       'emoji': '🤟',  'fact': 'A tricycle has 3 wheels!'},
    4:   {'word': 'Four',        'emoji': '🖐️',  'fact': 'A dog has 4 legs!'},
    5:   {'word': 'Five',        'emoji': '🖐️',  'fact': 'You have 5 fingers on one hand!'},
    6:   {'word': 'Six',         'emoji': '🎲',  'fact': 'A dice has 6 sides!'},
    7:   {'word': 'Seven',       'emoji': '📅',  'fact': 'There are 7 days in a week!'},
    8:   {'word': 'Eight',       'emoji': '🐙',  'fact': 'An octopus has 8 arms!'},
    9:   {'word': 'Nine',        'emoji': '🪐',  'fact': 'Scientists found 9 planets in our solar system!'},
    10:  {'word': 'Ten',         'emoji': '🤲',  'fact': 'You have 10 fingers in total!'},
    11:  {'word': 'Eleven',      'emoji': '⚽',  'fact': 'A football team has 11 players!'},
    12:  {'word': 'Twelve',      'emoji': '🗓️',  'fact': 'There are 12 months in a year!'},
    13:  {'word': 'Thirteen',    'emoji': '🍫',  'fact': 'A baker\'s dozen is 13!'},
    14:  {'word': 'Fourteen',    'emoji': '💝',  'fact': 'February 14 is Valentine\'s Day!'},
    15:  {'word': 'Fifteen',     'emoji': '🌙',  'fact': 'The moon takes 15 days to go from new to full!'},
    16:  {'word': 'Sixteen',     'emoji': '🎂',  'fact': 'In many countries kids celebrate Sweet 16!'},
    17:  {'word': 'Seventeen',   'emoji': '🦷',  'fact': 'You get your wisdom teeth around age 17!'},
    18:  {'word': 'Eighteen',    'emoji': '🗳️',  'fact': 'In India you can vote when you turn 18!'},
    19:  {'word': 'Nineteen',    'emoji': '🎸',  'fact': 'Many music bands have 19-year-old stars!'},
    20:  {'word': 'Twenty',      'emoji': '🫶',  'fact': 'You have 20 baby teeth as a small child!'},
    21:  {'word': 'Twenty One',  'emoji': '🃏',  'fact': 'The card game Blackjack is also called 21!'},
    22:  {'word': 'Twenty Two',  'emoji': '🦢',  'fact': 'Swans usually live to be about 22 years old!'},
    23:  {'word': 'Twenty Three','emoji': '🏀',  'fact': 'Michael Jordan wore jersey number 23!'},
    24:  {'word': 'Twenty Four', 'emoji': '⏰',  'fact': 'There are 24 hours in a day!'},
    25:  {'word': 'Twenty Five', 'emoji': '🎄',  'fact': 'Christmas is on December 25!'},
    26:  {'word': 'Twenty Six',  'emoji': '🔤',  'fact': 'There are 26 letters in the English alphabet!'},
    27:  {'word': 'Twenty Seven','emoji': '🍕',  'fact': 'A pizza is usually cut into 8 slices but 27 bites!'},
    28:  {'word': 'Twenty Eight','emoji': '🌙',  'fact': 'February has 28 days most years!'},
    29:  {'word': 'Twenty Nine', 'emoji': '🦁',  'fact': 'Lions can run at 29 meters per second!'},
    30:  {'word': 'Thirty',      'emoji': '🦷',  'fact': 'Adults can have up to 32 teeth, usually 30!'},
    31:  {'word': 'Thirty One',  'emoji': '📅',  'fact': 'Some months have 31 days!'},
    32:  {'word': 'Thirty Two',  'emoji': '🦷',  'fact': 'Adults have 32 teeth in total!'},
    33:  {'word': 'Thirty Three','emoji': '🌍',  'fact': 'The Eiffel Tower has 1,665 steps but the top 33 floors!'},
    34:  {'word': 'Thirty Four', 'emoji': '🐋',  'fact': 'A blue whale can hold its breath for 34 minutes!'},
    35:  {'word': 'Thirty Five', 'emoji': '🚀',  'fact': 'Astronauts float in space at 35,000 feet altitude!'},
    36:  {'word': 'Thirty Six',  'emoji': '🎯',  'fact': 'A standard dartboard has numbers up to 20, scoring up to 36!'},
    37:  {'word': 'Thirty Seven','emoji': '🌡️',  'fact': 'Normal human body temperature is 37°C!'},
    38:  {'word': 'Thirty Eight','emoji': '🦅',  'fact': 'Eagles can dive at 38 meters per second!'},
    39:  {'word': 'Thirty Nine', 'emoji': '📚',  'fact': 'The famous book series "39 Clues" has 39 adventures!'},
    40:  {'word': 'Forty',       'emoji': '🌧️',  'fact': 'The story of Noah\'s Ark says it rained 40 days!'},
    41:  {'word': 'Forty One',   'emoji': '🏔️',  'fact': 'Mount Everest was first climbed in 1953, 41 years after it was measured!'},
    42:  {'word': 'Forty Two',   'emoji': '🌌',  'fact': 'In "Hitchhiker\'s Guide to the Galaxy", 42 is the answer to everything!'},
    43:  {'word': 'Forty Three', 'emoji': '🦋',  'fact': 'A butterfly has 43 muscles in its wings!'},
    44:  {'word': 'Forty Four',  'emoji': '🎵',  'fact': 'A piano has 88 keys — that\'s 44 pairs!'},
    45:  {'word': 'Forty Five',  'emoji': '🎸',  'fact': 'A guitar usually has 45 frets total across all strings!'},
    46:  {'word': 'Forty Six',   'emoji': '🧬',  'fact': 'Human beings have 46 chromosomes!'},
    47:  {'word': 'Forty Seven', 'emoji': '🐠',  'fact': 'The Great Barrier Reef is home to 47 species of sharks!'},
    48:  {'word': 'Forty Eight', 'emoji': '⏰',  'fact': 'There are 48 hours in 2 days!'},
    49:  {'word': 'Forty Nine',  'emoji': '7️⃣',  'fact': '49 is 7 times 7 — a perfect square!'},
    50:  {'word': 'Fifty',       'emoji': '🎊',  'fact': '50 years of marriage is called a Golden Anniversary!'},
    51:  {'word': 'Fifty One',   'emoji': '🌟',  'fact': 'The Milky Way has over 51 known orbiting galaxies!'},
    52:  {'word': 'Fifty Two',   'emoji': '🃏',  'fact': 'A deck of playing cards has 52 cards!'},
    53:  {'word': 'Fifty Three', 'emoji': '🐝',  'fact': 'A bee visits 53 flowers in a single trip!'},
    54:  {'word': 'Fifty Four',  'emoji': '🎮',  'fact': 'The Rubik\'s Cube has 54 colored squares!'},
    55:  {'word': 'Fifty Five',  'emoji': '🚗',  'fact': 'Speed limit on many Indian highways is 55 km/h!'},
    56:  {'word': 'Fifty Six',   'emoji': '🌮',  'fact': 'There are 56 varieties of mangoes in India!'},
    57:  {'word': 'Fifty Seven', 'emoji': '🍅',  'fact': 'Heinz famously made 57 varieties of food products!'},
    58:  {'word': 'Fifty Eight', 'emoji': '🎸',  'fact': 'A sitar has up to 58 strings including sympathetic strings!'},
    59:  {'word': 'Fifty Nine',  'emoji': '⏱️',  'fact': 'The last second of a minute is the 59th second!'},
    60:  {'word': 'Sixty',       'emoji': '⏱️',  'fact': 'There are 60 seconds in a minute!'},
    61:  {'word': 'Sixty One',   'emoji': '🌊',  'fact': 'The Pacific Ocean covers 61% of the world!'},
    62:  {'word': 'Sixty Two',   'emoji': '🏆',  'fact': 'Sachin Tendulkar scored 62 Test centuries — wait, that\'s 51. He scored 100 international hundreds!'},
    63:  {'word': 'Sixty Three', 'emoji': '🌿',  'fact': 'India has 63 national parks to protect wildlife!'},
    64:  {'word': 'Sixty Four',  'emoji': '♟️',  'fact': 'A chessboard has 64 squares!'},
    65:  {'word': 'Sixty Five',  'emoji': '👴',  'fact': 'In many countries, people retire at age 65!'},
    66:  {'word': 'Sixty Six',   'emoji': '🛣️',  'fact': 'Route 66 is the most famous road in America!'},
    67:  {'word': 'Sixty Seven', 'emoji': '🐘',  'fact': 'Elephants can live up to 67 years in the wild!'},
    68:  {'word': 'Sixty Eight', 'emoji': '🚂',  'fact': 'The fastest Indian train runs at 68 km/h average speed!'},
    69:  {'word': 'Sixty Nine',  'emoji': '🌙',  'fact': 'Apollo 11 landed on the Moon in 1969!'},
    70:  {'word': 'Seventy',     'emoji': '🧓',  'fact': 'Ancient people called 70 years a "full life"!'},
    71:  {'word': 'Seventy One', 'emoji': '🌊',  'fact': '71% of Earth is covered in water!'},
    72:  {'word': 'Seventy Two', 'emoji': '🎸',  'fact': 'A guitar has 72 notes across all frets and strings!'},
    73:  {'word': 'Seventy Three','emoji':'🌡️',  'fact': 'Venus is 73 million km from Earth at closest point!'},
    74:  {'word': 'Seventy Four','emoji': '🦋',  'fact': 'Butterflies can fly up to 74 km/h!'},
    75:  {'word': 'Seventy Five','emoji': '💎',  'fact': '75th wedding anniversary is Diamond Anniversary!'},
    76:  {'word': 'Seventy Six', 'emoji': '🇮🇳', 'fact': 'India became independent from British rule in 1947 — 76 years ago!'},
    77:  {'word': 'Seventy Seven','emoji':'🌈',  'fact': 'Light travels at 77 million miles per second — approximately!'},
    78:  {'word': 'Seventy Eight','emoji':'🎹',  'fact': 'Old vinyl records played at 78 rotations per minute!'},
    79:  {'word': 'Seventy Nine','emoji': '🥇',  'fact': 'Gold has atomic number 79!'},
    80:  {'word': 'Eighty',      'emoji': '🐢',  'fact': 'Tortoises can live to be 80 years old!'},
    81:  {'word': 'Eighty One',  'emoji': '9️⃣',  'fact': '81 is 9 times 9 — a perfect square!'},
    82:  {'word': 'Eighty Two',  'emoji': '🌍',  'fact': 'India has 82 airports across the country!'},
    83:  {'word': 'Eighty Three','emoji': '🏏',  'fact': 'India won the Cricket World Cup in 1983!'},
    84:  {'word': 'Eighty Four', 'emoji': '📖',  'fact': 'George Orwell\'s famous book is called "1984"!'},
    85:  {'word': 'Eighty Five', 'emoji': '🦜',  'fact': 'Some parrots can live up to 85 years — longer than humans!'},
    86:  {'word': 'Eighty Six',  'emoji': '🧠',  'fact': 'Your brain has 86 billion nerve cells called neurons!'},
    87:  {'word': 'Eighty Seven','emoji': '🌺',  'fact': 'India has 87 different types of roses!'},
    88:  {'word': 'Eighty Eight','emoji': '🎹',  'fact': 'A piano has 88 keys!'},
    89:  {'word': 'Eighty Nine', 'emoji': '🏗️',  'fact': 'The Eiffel Tower was built in 1889!'},
    90:  {'word': 'Ninety',      'emoji': '🔲',  'fact': 'A right angle is exactly 90 degrees!'},
    91:  {'word': 'Ninety One',  'emoji': '📞',  'fact': '911 is the emergency number — 91 is close to it!'},
    92:  {'word': 'Ninety Two',  'emoji': '🌍',  'fact': 'Uranium has atomic number 92!'},
    93:  {'word': 'Ninety Three','emoji': '☀️',  'fact': 'The Sun is 93 million miles from Earth!'},
    94:  {'word': 'Ninety Four', 'emoji': '🏏',  'fact': 'Sachin Tendulkar scored his 100th century in 2012, playing for India since 1994!'},
    95:  {'word': 'Ninety Five', 'emoji': '📱',  'fact': 'Windows 95 brought computers to millions of homes!'},
    96:  {'word': 'Ninety Six',  'emoji': '🌊',  'fact': 'The Indian Ocean covers 96 million square kilometers!'},
    97:  {'word': 'Ninety Seven','emoji': '🥇',  'fact': '97 is a prime number — it cannot be divided by anything except 1 and itself!'},
    98:  {'word': 'Ninety Eight','emoji': '🌡️',  'fact': 'Normal American body temperature is 98.6°F (that\'s 37°C)!'},
    99:  {'word': 'Ninety Nine', 'emoji': '🎉',  'fact': '99 is one less than 100 — you are almost there!'},
    100: {'word': 'One Hundred', 'emoji': '💯',  'fact': '100 years makes one century! You are a superstar! 🎉'},
  };

  // Observables
  RxInt currentStageId = 1.obs;
  RxList<int> displayedTiles = <int>[].obs;
  RxInt targetNumber = 0.obs;
  RxBool isCorrect = false.obs;
  RxBool isWrong = false.obs;
  RxInt lastTappedNumber = (-1).obs;

  // Progress: stage_X_found → List<int>
  RxMap<int, List<int>> stageFoundNumbers = <int, List<int>>{}.obs;

  late Box _box;

  @override
  void onInit() {
    super.onInit();
    _box = Hive.box('progress');
    _loadProgress();
  }

  void _loadProgress() {
    for (int i = 1; i <= 10; i++) {
      final saved = List<int>.from(
        _box.get('numbersFind_stage_${i}_found', defaultValue: [])
      );
      stageFoundNumbers[i] = saved;
    }
  }

  bool isStageUnlocked(int stageId) {
    if (stageId == 1) return true;
    return isStageCompleted(stageId - 1);
  }

  double stageProgress(int stageId) {
    final stage = stages[stageId - 1];
    final from = stage['from'] as int;
    final to = stage['to'] as int;
    final total = to - from + 1;
    final found = stageFoundNumbers[stageId] ?? [];
    final foundCount = found.where((n) => n >= from && n <= to).length;
    return foundCount / total;
  }

  bool isStageCompleted(int stageId) => stageProgress(stageId) >= 1.0;

  void startStage(int stageId) {
    if (!isStageUnlocked(stageId)) {
      Get.snackbar(
        '🔒 Locked!',
        'Finish Stage ${stageId - 1} first to unlock this! 💪',
        backgroundColor: AppColors.coral.withOpacity(0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return;
    }
    currentStageId.value = stageId;
    _loadNextRound();
  }

  void _loadNextRound() {
    final stage = stages[currentStageId.value - 1];
    final from = stage['from'] as int;
    final to = stage['to'] as int;
    final stageNumbers = List<int>.generate(to - from + 1, (i) => from + i);
    final found = stageFoundNumbers[currentStageId.value] ?? [];
    final remaining = stageNumbers.where((n) => !found.contains(n)).toList();

    if (remaining.isEmpty) {
      _onStageComplete();
      return;
    }

    remaining.shuffle();
    targetNumber.value = remaining.first;

    // Build tile set: target + 7 distractors from OUTSIDE this stage range
    final allNumbers = List<int>.generate(100, (i) => i + 1);
    final distractors = allNumbers.where((n) => n < from || n > to).toList()..shuffle();

    final tiles = [targetNumber.value, ...distractors.take(7)];
    tiles.shuffle();
    displayedTiles.value = tiles;

    isCorrect.value = false;
    isWrong.value = false;
    lastTappedNumber.value = -1;

    final data = numberData[targetNumber.value]!;
    Future.delayed(const Duration(milliseconds: 400), () {
      Get.find<TtsService>().speak(
        'Find ${data['word']}! ${data['word']}! ${data['fact']}'
      );
    });
  }

  void onNumberTapped(int number) {
    if (isCorrect.value) return;
    HapticUtil.light();
    lastTappedNumber.value = number;

    if (number == targetNumber.value) {
      _onCorrectTap();
    } else {
      _onWrongTap();
    }
  }

  void _onCorrectTap() {
    isCorrect.value = true;
    Get.find<AudioService>().playStar();
    HapticUtil.medium();

    final found = List<int>.from(stageFoundNumbers[currentStageId.value] ?? []);
    if (!found.contains(targetNumber.value)) {
      found.add(targetNumber.value);
      stageFoundNumbers[currentStageId.value] = found;
      _box.put('numbersFind_stage_${currentStageId.value}_found', found);
      Get.find<ProgressService>().addStar();
    }

    final data = numberData[targetNumber.value]!;
    Get.find<TtsService>().speak('Wonderful! ${data['word']}! ${data['fact']}');

    Future.delayed(const Duration(milliseconds: 1800), _loadNextRound);
  }

  void _onWrongTap() {
    isWrong.value = true;
    Get.find<AudioService>().playTap();
    Get.find<TtsService>().speak('Oops! Try again!');
    Future.delayed(const Duration(milliseconds: 700), () {
      isWrong.value = false;
    });
  }

  void _onStageComplete() {
    Get.find<TtsService>().speak('Amazing! You finished Stage ${currentStageId.value}! You are a superstar!');
    Future.delayed(const Duration(milliseconds: 1500), () => Get.back());
  }
}
