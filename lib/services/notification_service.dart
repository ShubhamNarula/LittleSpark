import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService extends GetxService {
  static NotificationService get to => Get.find();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<NotificationService> init() async {
    try {
      // 1. Request runtime notification permissions (especially for Android 13+ and iOS)
      bool permissionGranted = false;

      if (Platform.isAndroid) {
        final status = await Permission.notification.status;
        if (!status.isGranted) {
          final result = await Permission.notification.request();
          permissionGranted = result.isGranted;
          print('NotificationService: Android permission request result: $permissionGranted');
        } else {
          permissionGranted = true;
        }
      }

      // Also request via Firebase Messaging (essential for iOS/macOS)
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        permissionGranted = true;
      }

      print('NotificationService: User permission status: ${settings.authorizationStatus}, combined permission: $permissionGranted');

      // 2. Fetch and print FCM Token (highly useful for debugging or targeted tests)
      String? token = await _messaging.getToken();
      print('NotificationService: FCM Registration Token: $token');

      // 3. Subscribe to the "announcements" topic
      // This allows sending announcements to all users easily from Firebase Console.
      await _messaging.subscribeToTopic('announcements');
      print('NotificationService: Subscribed to "announcements" topic');

      // 4. Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('NotificationService: Foreground message received: ${message.notification?.title}');
        if (message.notification != null) {
          _showForegroundNotification(message.notification!);
        }
      });

      // 5. Handle message click when app is in background but running
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('NotificationService: Notification clicked: ${message.notification?.title}');
        // You can add custom routing logic here if needed.
      });

      // 6. Check if app was opened from a terminated state via a notification
      RemoteMessage? initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        print('NotificationService: App launched from terminated state via notification: ${initialMessage.notification?.title}');
      }
    } catch (e) {
      print('NotificationService: Initialization error: $e');
    }
    return this;
  }

  /// Displays a kid-friendly overlay notification when the app is in the foreground
  void _showForegroundNotification(RemoteNotification notification) {
    Get.snackbar(
      notification.title ?? "Announcement",
      notification.body ?? "",
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF6C63FF), // Sleek, modern kid-friendly indigo
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
      borderRadius: 16,
      icon: const Icon(
        Icons.campaign_rounded, // Kid-friendly megaphone icon
        color: Colors.white,
        size: 32,
      ),
      duration: const Duration(seconds: 6),
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
      shouldIconPulse: true,
      mainButton: TextButton(
        onPressed: () => Get.back(),
        child: const Text(
          "OK",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
