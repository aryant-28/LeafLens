import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class BasicNotification {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static bool _isInitialized = false;

  // Call this function once at app startup
  static Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // For Android - use @mipmap reference format
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // For iOS
      const IOSInitializationSettings iOSSettings = IOSInitializationSettings();

      // Initialize settings for both platforms
      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iOSSettings,
      );

      // Initialize the plugin
      bool? result = await _notifications.initialize(
        initSettings,
        onSelectNotification: (String? payload) async {
          print('Notification tapped with payload: $payload');
        },
      );

      _isInitialized = true;
      print('Notification service initialized with result: $result');
      return true;
    } catch (e) {
      print('ERROR initializing notification service: $e');
      return false;
    }
  }

  // Show a basic notification immediately
  static Future<bool> showNow(String title, String body) async {
    if (!_isInitialized) {
      bool initialized = await initialize();
      if (!initialized) return false;
    }

    try {
      // Define the android notification details - note the channel description parameter position
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'basic_channel', // channel id
        'Basic Notifications', // channel name
        channelDescription:
            'Simple notification channel', // use named parameter for description
        importance: Importance.max,
        priority: Priority.high,
      );

      // Create platform-specific notification details
      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: IOSNotificationDetails(),
      );

      // Show the notification with a random ID
      final int id = DateTime.now().millisecondsSinceEpoch % 10000;
      await _notifications.show(
        id,
        title,
        body,
        platformDetails,
      );

      print('Basic notification sent successfully with ID: $id!');
      return true;
    } catch (e) {
      print('ERROR showing notification: $e');
      return false;
    }
  }
}
