import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../../core/utils/haptic_util.dart';
import '../../services/audio_service.dart';
import '../../services/tts_service.dart';
import '../../services/progress_service.dart';

class AlphabetFindController extends GetxController {

  // Stage definitions
  static const List<Map<String, dynamic>> stages = [
    {'id': 1, 'letters': ['A','B','C','D','E'], 'label': 'Stage 1', 'subtitle': 'A to E', 'emoji': '🍎'},
    {'id': 2, 'letters': ['F','G','H','I','J'], 'label': 'Stage 2', 'subtitle': 'F to J', 'emoji': '🐱'},
    {'id': 3, 'letters': ['K','L','M','N','O'], 'label': 'Stage 3', 'subtitle': 'K to O', 'emoji': '🦁'},
    {'id': 4, 'letters': ['P','Q','R','S','T'], 'label': 'Stage 4', 'subtitle': 'P to T', 'emoji': '🦜'},
    {'id': 5, 'letters': ['U','V','W','X','Y','Z'], 'label': 'Stage 5', 'subtitle': 'U to Z', 'emoji': '🦓'},
  ];

  // Emoji + word for each letter (for TTS and reveal)
  static const Map<String, Map<String, String>> letterData = {
    'A': {'word': 'Apple',    'emoji': '🍎'},
    'B': {'word': 'Ball',     'emoji': '⚽'},
    'C': {'word': 'Cat',      'emoji': '🐱'},
    'D': {'word': 'Dog',      'emoji': '🐶'},
    'E': {'word': 'Elephant', 'emoji': '🐘'},
    'F': {'word': 'Fish',     'emoji': '🐟'},
    'G': {'word': 'Grapes',   'emoji': '🍇'},
    'H': {'word': 'Hat',      'emoji': '🎩'},
    'I': {'word': 'Igloo',    'emoji': '🏔️'},
    'J': {'word': 'Jug',      'emoji': '🫙'},
    'K': {'word': 'Kite',     'emoji': '🪁'},
    'L': {'word': 'Lion',     'emoji': '🦁'},
    'M': {'word': 'Mango',    'emoji': '🥭'},
    'N': {'word': 'Nest',     'emoji': '🪹'},
    'O': {'word': 'Orange',   'emoji': '🍊'},
    'P': {'word': 'Parrot',   'emoji': '🦜'},
    'Q': {'word': 'Queen',    'emoji': '👸'},
    'R': {'word': 'Rainbow',  'emoji': '🌈'},
    'S': {'word': 'Sun',      'emoji': '☀️'},
    'T': {'word': 'Tiger',    'emoji': '🐯'},
    'U': {'word': 'Umbrella', 'emoji': '☂️'},
    'V': {'word': 'Van',      'emoji': '🚐'},
    'W': {'word': 'Whale',    'emoji': '🐳'},
    'X': {'word': 'Xylophone','emoji': '🎸'},
    'Y': {'word': 'Yak',      'emoji': '🐂'},
    'Z': {'word': 'Zebra',    'emoji': '🦓'},
  };

  // Observables
  RxInt currentStageId = 1.obs;
  RxList<String> displayedTiles = <String>[].obs;   // 7 random letters shown
  RxString targetLetter = ''.obs;                    // the letter to find
  RxBool isCorrect = false.obs;
  RxBool isWrong = false.obs;
  RxString lastTappedLetter = ''.obs;

  // Per-stage progress (Hive persisted)
  // Key: 'alphabetFind_stage_X_found' → List<String>
  RxMap<int, List<String>> stageFoundLetters = <int, List<String>>{}.obs;

  late Box _box;

  @override
  void onInit() {
    super.onInit();
    _box = Hive.box('progress');
    _loadProgress();
  }

  void _loadProgress() {
    for (int i = 1; i <= 5; i++) {
      final saved = List<String>.from(
        _box.get('alphabetFind_stage_${i}_found', defaultValue: [])
      );
      stageFoundLetters[i] = saved;
    }
  }

  // Returns true if stage is unlocked
  bool isStageUnlocked(int stageId) {
    if (stageId == 1) return true;
    final prevStage = stages[stageId - 2];
    final prevLetters = List<String>.from(prevStage['letters']);
    final found = stageFoundLetters[stageId - 1] ?? [];
    return prevLetters.every((l) => found.contains(l));
  }

  // Returns completion % for a stage (0.0 to 1.0)
  double stageProgress(int stageId) {
    final stageLetters = List<String>.from(stages[stageId - 1]['letters']);
    final found = stageFoundLetters[stageId] ?? [];
    final foundCount = stageLetters.where((l) => found.contains(l)).length;
    return foundCount / stageLetters.length;
  }

  bool isStageCompleted(int stageId) => stageProgress(stageId) >= 1.0;

  // START GAME for a stage — load first round
  void startStage(int stageId) {
    currentStageId.value = stageId;
    _loadNextRound();
  }

  void _loadNextRound() {
    final stageLetters = List<String>.from(stages[currentStageId.value - 1]['letters']);
    final found = stageFoundLetters[currentStageId.value] ?? [];
    final remaining = stageLetters.where((l) => !found.contains(l)).toList();

    if (remaining.isEmpty) {
      // Stage complete — back to stage select
      _onStageComplete();
      return;
    }

    // Pick target: always one from remaining (not yet found)
    remaining.shuffle();
    targetLetter.value = remaining.first;

    // Build tile set: target + random distractor letters (not in current stage)
    final allLetters = letterData.keys.toList();
    final distractors = allLetters
        .where((l) => !stageLetters.contains(l))
        .toList()
      ..shuffle();

    // 7 tiles total: 1 target + 6 distractors
    final tiles = [targetLetter.value, ...distractors.take(6)];
    tiles.shuffle();
    displayedTiles.value = tiles;

    isCorrect.value = false;
    isWrong.value = false;
    lastTappedLetter.value = '';

    // TTS: "Find A! A for Apple!"
    final data = letterData[targetLetter.value]!;
    Future.delayed(const Duration(milliseconds: 400), () {
      Get.find<TtsService>().speak(
        'Find ${targetLetter.value}! ${targetLetter.value} for ${data['word']}!'
      );
    });
  }

  void onLetterTapped(String letter) {
    if (isCorrect.value) return; // prevent double tap

    HapticUtil.light();
    lastTappedLetter.value = letter;

    if (letter == targetLetter.value) {
      _onCorrectTap();
    } else {
      _onWrongTap();
    }
  }

  void _onCorrectTap() {
    isCorrect.value = true;
    Get.find<AudioService>().playStar();
    HapticUtil.medium();

    // Save to Hive
    final found = List<String>.from(stageFoundLetters[currentStageId.value] ?? []);
    if (!found.contains(targetLetter.value)) {
      found.add(targetLetter.value);
      stageFoundLetters[currentStageId.value] = found;
      _box.put('alphabetFind_stage_${currentStageId.value}_found', found);
      Get.find<ProgressService>().addStar();
    }

    // TTS: "Well done! A for Apple! 🎉"
    final data = letterData[targetLetter.value]!;
    Get.find<TtsService>().speak('Well done! ${targetLetter.value} for ${data['word']}!');

    // Check if stage just became newly unlocked
    _checkNextStageUnlock();

    // Wait 1.8s then load next round
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
    Get.find<TtsService>().speak('Amazing! You finished Stage ${currentStageId.value}!');
    // Navigate back to stage select after 1.5s
    Future.delayed(const Duration(milliseconds: 1500), () => Get.back());
  }

  void _checkNextStageUnlock() {
    final nextStageId = currentStageId.value + 1;
    if (nextStageId > 5) return;
    if (isStageCompleted(currentStageId.value) && !isStageUnlocked(nextStageId)) {
      Future.delayed(const Duration(milliseconds: 2000), () {
        Get.find<TtsService>().speak('Great job! New letters unlocked!');
      });
    }
  }
}
