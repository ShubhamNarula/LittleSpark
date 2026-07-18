import 'package:get/get.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService extends GetxService {
  static TtsService get to => Get.find();

  final FlutterTts _tts = FlutterTts();
  String _currentLang = "en-US";

  Future<TtsService> init() async {
    try {
      await _tts.setLanguage("en-US");
      _currentLang = "en-US";
      await _tts.setSpeechRate(0.45); // Slower for kids
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.2); // Friendly high pitch
      _tts.setErrorHandler((msg) {
        print("TtsService runtime error caught: $msg");
      });
    } catch (e) {
      print("TtsService initialization error: $e");
    }
    return this;
  }

  Future<void> speak(
    String text, {
    String? languageCode,
    double? pitch,
    double? speechRate,
    String? fallbackText,
    String? fallbackLanguageCode,
  }) async {
    try {
      await _tts.stop();
      String targetLang = languageCode ?? "en-US";
      String targetText = text;

      if (languageCode != null) {
        bool isAvailable = false;
        try {
          isAvailable = await _tts.isLanguageAvailable(languageCode);
        } catch (_) {}

        if (!isAvailable) {
          if (languageCode == 'hi-IN') {
            try {
              bool isHiAvailable = await _tts.isLanguageAvailable('hi');
              if (isHiAvailable) {
                targetLang = 'hi';
                isAvailable = true;
              }
            } catch (_) {}
          }
        }

        if (!isAvailable && fallbackText != null) {
          targetText = fallbackText;
          targetLang = fallbackLanguageCode ?? "en-US";
        }
      }

      if (_currentLang != targetLang) {
        await _tts.setLanguage(targetLang);
        _currentLang = targetLang;
      }

      if (pitch != null) {
        await _tts.setPitch(pitch);
      } else {
        await _tts.setPitch(1.2);
      }

      if (speechRate != null) {
        await _tts.setSpeechRate(speechRate);
      } else {
        await _tts.setSpeechRate(0.45);
      }

      await _tts.speak(targetText);
    } catch (e) {
      print("TtsService speak error: $e");
    }
  }

  Future<void> stop() async {
    try {
      await _tts.speak("");
      await _tts.stop();
    } catch (_) {}
  }

  @override
  void onClose() {
    _tts.stop();
    super.onClose();
  }
}
