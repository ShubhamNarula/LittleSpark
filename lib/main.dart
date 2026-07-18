import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/audio_service.dart';
import 'services/tts_service.dart';
import 'services/progress_service.dart';
import 'services/analytics_service.dart';
import 'services/notification_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  try {
    await Firebase.initializeApp();
    
    // Initialize Analytics and Notifications
    final analytics = Get.put(AnalyticsService(), permanent: true);
    await analytics.init();

    final notifications = Get.put(NotificationService(), permanent: true);
    await notifications.init();
  } catch (e) {
    print("Firebase initialization failed: $e");
  }

  // Initialize Hive
  await Hive.initFlutter();
  await Hive.openBox('progress');
  await Hive.openBox('settings');
  
  // Initialize global services so they are available on direct routing / web refresh
  final audio = Get.put(AudioService(), permanent: true);
  await audio.init();

  final tts = Get.put(TtsService(), permanent: true);
  await tts.init();

  final progress = Get.put(ProgressService(), permanent: true);
  await progress.init();
  
  // Enforce portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status Bar Styling
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(const LittleSparkApp());
}
