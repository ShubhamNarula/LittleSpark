import 'package:get/get.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService extends GetxService {
  static AnalyticsService get to => Get.find();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  Future<AnalyticsService> init() async {
    try {
      // Enable data collection
      await _analytics.setAnalyticsCollectionEnabled(true);
      print("AnalyticsService: Initialized successfully");
    } catch (e) {
      print("AnalyticsService: Initialization error: $e");
    }
    return this;
  }

  /// Logs a custom event
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    try {
      await _analytics.logEvent(
        name: name,
        parameters: parameters,
      );
      print("AnalyticsService: Logged event '$name' with parameters: $parameters");
    } catch (e) {
      print("AnalyticsService: Error logging event '$name': $e");
    }
  }

  /// Logs activity related to learning games/adventures
  Future<void> logGameActivity({
    required String gameName,
    required String action,
    String? detail,
  }) async {
    await logEvent(
      name: 'game_activity',
      parameters: {
        'game_name': gameName,
        'action': action,
        if (detail != null) 'detail': detail,
      },
    );
  }
}
