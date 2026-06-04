import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const int workoutReminderId = 0;
  static const int streakSaverId = 1;
  // Motivation quotes will use IDs from 100 to 130.

  static const List<String> motivationQuotes = [
    "The only bad workout is the one that didn't happen.",
    "Push yourself, because no one else is going to do it for you.",
    "Success starts with self-discipline.",
    "Don't stop when you're tired. Stop when you're done.",
    "Wake up with determination. Go to bed with satisfaction.",
    "Do something today that your future self will thank you for.",
    "Little by little, a little becomes a lot.",
    "It comes down to one simple thing: How bad do you want it?",
    "Making excuses burns zero calories per hour.",
    "Sweat is magic. Cover yourself in it daily to grant your wishes.",
    "Doubt kills more dreams than failure ever will.",
    "Your body can stand almost anything. It's your mind that you have to convince.",
    "Fall in love with taking care of your body.",
    "The hardest lift of all is lifting your butt off the couch.",
    "Sore today, strong tomorrow.",
    "Be stronger than your excuses.",
    "A one hour workout is 4% of your day. No excuses.",
    "Strive for progress, not perfection.",
    "What seems impossible today will one day become your warm-up.",
    "You don't have to be extreme, just consistent.",
    "The pain you feel today will be the strength you feel tomorrow.",
    "When you feel like quitting, think about why you started.",
    "Success isn't always about greatness. It's about consistency.",
    "Excuses don't kill the fat, exercises do.",
    "Your health is an investment, not an expense.",
    "A year from now you may wish you had started today.",
    "Believe in yourself and all that you are.",
    "Don't limit your challenges, challenge your limits.",
    "If it doesn't challenge you, it doesn't change you.",
    "You are far stronger than you think."
  ];

  static Future<void> init() async {
    try {
      tz_data.initializeTimeZones();
      String timeZoneName;
      try {
        final info = await FlutterTimezone.getLocalTimezone().timeout(const Duration(seconds: 2));
        timeZoneName = info.identifier;
      } catch (e) {
        timeZoneName = 'UTC';
      }
      tz.setLocalLocation(tz.getLocation(timeZoneName));

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/launcher_icon');

      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
      );

      await _notificationsPlugin.initialize(
        settings: initializationSettings,
      );
    } catch (e) {
      print("NotificationService error: $e");
    }
  }

  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id: id);
  }

  static Future<void> cancelAllMotivationQuotes() async {
    for (int i = 0; i < 30; i++) {
      await _notificationsPlugin.cancel(id: 100 + i);
    }
  }

  static Future<void> scheduleWorkoutReminder(int hour, int minute) async {
    await cancelNotification(workoutReminderId);
    
    // Create a time object for today at the specified time
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notificationsPlugin.zonedSchedule(
      id: workoutReminderId,
      title: 'Time for your workout! 🔥',
      body: 'Check your daily progressive overload targets.',
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder_channel',
          'Daily Reminders',
          channelDescription: 'Daily workout reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> scheduleStreakSaver() async {
    await cancelNotification(streakSaverId);
    
    final now = tz.TZDateTime.now(tz.local);
    // Schedule for 8:00 PM (20:00)
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 20, 0);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notificationsPlugin.zonedSchedule(
      id: streakSaverId,
      title: 'Streak Saver Alert! 🛡️',
      body: "You haven't logged your workout today. Don't lose your streak!",
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'streak_saver_channel',
          'Streak Savers',
          channelDescription: 'Alerts to protect your daily streak',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> scheduleMotivationQuotes() async {
    await cancelAllMotivationQuotes();
    
    final now = tz.TZDateTime.now(tz.local);
    
    for (int i = 0; i < 30; i++) {
      // Schedule at 7:00 AM every day
      var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 7, 0).add(Duration(days: i));
      
      // If it's already past 7 AM today, shift everything by 1 day
      if (i == 0 && scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await _notificationsPlugin.zonedSchedule(
        id: 100 + i,
        title: 'Morning Motivation ☀️',
        body: motivationQuotes[i % motivationQuotes.length],
        scheduledDate: scheduledDate,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'motivation_channel',
            'Daily Motivation',
            channelDescription: 'Daily inspirational fitness quotes',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }
}
