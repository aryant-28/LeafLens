import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:convert';
import '../models/plant_reminder.dart';

class ScheduledNotificationService {
  static final ScheduledNotificationService _instance =
      ScheduledNotificationService._internal();
  factory ScheduledNotificationService() => _instance;
  ScheduledNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final String _remindersKey = 'plant_reminders';
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize timezone
      tz.initializeTimeZones();
      final String timeZoneName = tz.local.name;
      tz.setLocalLocation(tz.getLocation(timeZoneName));

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
      print('Scheduled notification service initialized successfully');

      // Schedule all reminders
      await scheduleAllReminders();
    } catch (e) {
      print('Error initializing scheduled notification service: $e');
    }
  }

  Future<void> scheduleAllReminders() async {
    try {
      final List<PlantReminder> reminders = await _loadReminders();
      if (reminders.isEmpty) {
        print('No reminders to schedule');
        return;
      }

      // Cancel all existing notifications first
      await _notifications.cancelAll();

      // Schedule each enabled reminder
      for (final reminder in reminders) {
        if (reminder.isEnabled) {
          await scheduleDailyReminder(reminder);
        }
      }

      print(
          'Scheduled ${reminders.where((r) => r.isEnabled).length} reminders');
    } catch (e) {
      print('Error scheduling reminders: $e');
    }
  }

  Future<List<PlantReminder>> _loadReminders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedReminders = prefs.getStringList(_remindersKey) ?? [];

      return savedReminders
          .map((str) => PlantReminder.fromJson(jsonDecode(str)))
          .toList();
    } catch (e) {
      print('Error loading reminders: $e');
      return [];
    }
  }

  Future<void> scheduleDailyReminder(PlantReminder reminder) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'plant_reminder_channel',
        'Plant Reminders',
        channelDescription: 'Daily reminders to check your plants',
        importance: Importance.high,
        priority: Priority.high,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Create a time object for now
      final now = DateTime.now();

      // Create a time for today with the specified hour/minute
      var scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        reminder.time.hour,
        reminder.time.minute,
      );

      // If the time is in the past, schedule for tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      // Generate a unique ID using the plant name
      final int id = reminder.id.hashCode;

      // The notification body
      final String body = reminder.notes.isEmpty
          ? "Time to check on your ${reminder.plantName}!"
          : reminder.notes;

      // Schedule a notification
      await _notifications.zonedSchedule(
        id,
        "Reminder: ${reminder.plantName}",
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        notificationDetails,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: reminder.id,
      );

      print(
          'Scheduled reminder for ${reminder.plantName} at ${scheduledDate.toString()}');
    } catch (e) {
      print('Error scheduling reminder: $e');
    }
  }
}
