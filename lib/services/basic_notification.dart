import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class BasicNotification {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse response) async {
          print('Notification tapped with payload: ${response.payload}');
        },
      );

      _isInitialized = true;
      print('Basic notification service initialized successfully');
    } catch (e) {
      print('Error initializing basic notification service: $e');
      rethrow;
    }
  }

  static Future<bool> showNow(String title, String body) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'basic_channel',
        'Basic Notifications',
        channelDescription: 'For basic test notifications',
        importance: Importance.max,
        priority: Priority.high,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final int id = DateTime.now().millisecondsSinceEpoch % 100000;
      await _notifications.show(id, title, body, notificationDetails);
      return true;
    } catch (e) {
      print('Error showing basic notification: $e');
      return false;
    }
  }
}
