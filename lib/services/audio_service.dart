import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

class AudioService extends GetxService {
  static AudioService get to => Get.find();

  late AudioPlayer _tapPlayer;
  late AudioPlayer _starPlayer;
  late AudioPlayer _bgPlayer;

  Future<AudioService> init() async {
    _tapPlayer = AudioPlayer();
    _starPlayer = AudioPlayer();
    _bgPlayer = AudioPlayer();
    
    try {
      // Configure audio session category to music (playback) to bypass hardware silent switch on iOS
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
    } catch (e) {
      print("AudioService session configuration skipped: $e");
    }
    
    try {
      // Preload background music gracefully
      await _bgPlayer.setAsset('assets/audio/bgm.mp3');
      await _bgPlayer.setLoopMode(LoopMode.one);
    } catch (e) {
      // Gracefully handle missing file in development
      print("AudioService background music preloading skipped: $e");
    }
    return this;
  }

  void playTap() {
    try {
      _tapPlayer.setAsset('assets/audio/slice.wav')
          .then((_) => _tapPlayer.play())
          .catchError((_) {});
    } catch (_) {}
  }

  void playStar() {
    try {
      _starPlayer.setAsset('assets/audio/success.wav')
          .then((_) => _starPlayer.play())
          .catchError((_) {});
    } catch (_) {}
  }

  void playBadgeUnlock() {
    try {
      _tapPlayer.setAsset('assets/audio/completion.wav')
          .then((_) => _tapPlayer.play())
          .catchError((_) {});
    } catch (_) {}
  }

  void startBgMusic() {
    // Background music disabled as per user request to turn off default ambient background music
    /*
    try {
      _bgPlayer.play().catchError((_) {});
    } catch (_) {}
    */
  }

  void stopBgMusic() {
    try {
      _bgPlayer.stop();
    } catch (_) {}
  }

  @override
  void onClose() {
    _tapPlayer.dispose();
    _starPlayer.dispose();
    _bgPlayer.dispose();
    super.onClose();
  }
}
