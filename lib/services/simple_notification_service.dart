import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class SimpleNotificationService {
  static final SimpleNotificationService _instance =
      SimpleNotificationService._internal();
  factory SimpleNotificationService() => _instance;
  SimpleNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Request notification permission
      await Permission.notification.request();

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
        onDidReceiveNotificationResponse: (NotificationResponse details) {
          // Handle notification tap
          print('Notification tapped with payload: ${details.payload}');
        },
      );

      // Make sure notifications appear in foreground too
      await _configureLocalTimeZone();

      _isInitialized = true;
      print('Notification service initialized successfully');
    } catch (e) {
      print('Error initializing notification service: $e');
      // Don't set _isInitialized to true if there was an error
    }
  }

  Future<void> _configureLocalTimeZone() async {
    // This method would normally configure timezone data but we'll leave it simple
    return;
  }

  Future<bool> showSimpleNotification({
    required String title,
    required String body,
  }) async {
    try {
      if (!_isInitialized) {
        await initialize();
        if (!_isInitialized) {
          // If initialization failed, return false
          return false;
        }
      }

      // Check notification permission
      if (!(await Permission.notification.isGranted)) {
        print('Notification permission not granted');
        return false;
      }

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'plant_reminder_channel',
        'Plant Reminders',
        channelDescription: 'Daily reminders to check your plants',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final int id = DateTime.now().millisecondsSinceEpoch % 100000;
      await _notifications.show(
        id,
        title,
        body,
        notificationDetails,
      );

      print('Notification sent successfully: $title with ID: $id');
      return true;
    } catch (e) {
      print('Error showing notification: $e');
      return false;
    }
  }
}
