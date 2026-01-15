import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone data
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));

    // Android initialization settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialize plugin
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _initialized = true;
  }

  void _onNotificationTap(NotificationResponse response) {
    // Handle notification tap - could navigate to specific page
    print('Notification tapped: ${response.payload}');
  }

  // Request permissions (especially for iOS)
  Future<bool> requestPermissions() async {
    if (!_initialized) await initialize();

    final androidImplementation =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    final iosImplementation =
        _notifications.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    // Request Android 13+ permission
    final androidGranted =
        await androidImplementation?.requestNotificationsPermission() ?? true;

    // Request iOS permissions
    final iosGranted = await iosImplementation?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ??
        true;

    return androidGranted && iosGranted;
  }

  // Schedule daily workout reminder
  Future<void> scheduleWorkoutReminder({
    required String time, // HH:mm format
    bool enabled = true,
  }) async {
    if (!_initialized) await initialize();

    await cancelWorkoutReminder(); // Cancel existing first

    if (!enabled) return;

    final timeParts = time.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      0, // notification ID for workout
      'Antrenman Zamanı! 💪',
      'Bugünkü antrenmanını yapmayı unutma!',
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'workout_channel',
          'Antrenman Hatırlatıcıları',
          channelDescription: 'Günlük antrenman hatırlatma bildirimleri',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
    );
  }

  Future<void> cancelWorkoutReminder() async {
    await _notifications.cancel(0);
  }

  // Schedule periodic water reminders
  Future<void> scheduleWaterReminders({
    required int intervalMinutes,
    bool enabled = true,
  }) async {
    if (!_initialized) await initialize();

    await cancelWaterReminders(); // Cancel existing first

    if (!enabled) return;

    // Schedule water reminder to repeat at interval
    await _notifications.periodicallyShow(
      1, // notification ID for water
      'Su İçmeyi Unutma! 💧',
      'Günlük su hedefine ulaşmak için şimdi bir bardak su iç!',
      RepeatInterval.values.firstWhere(
        (interval) {
          switch (interval) {
            case RepeatInterval.everyMinute:
              return intervalMinutes == 1;
            case RepeatInterval.hourly:
              return intervalMinutes == 60;
            case RepeatInterval.daily:
              return intervalMinutes == 1440;
            case RepeatInterval.weekly:
              return intervalMinutes == 10080;
            default:
              return false;
          }
        },
        orElse: () => RepeatInterval.hourly, // Default to hourly
      ),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'water_channel',
          'Su Hatırlatıcıları',
          channelDescription: 'Düzenli su içme hatırlatma bildirimleri',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancelWaterReminders() async {
    await _notifications.cancel(1);
  }

  // Schedule daily summary notification
  Future<void> scheduleDailySummary({
    required String time, // HH:mm format
    bool enabled = true,
  }) async {
    if (!_initialized) await initialize();

    await cancelDailySummary(); // Cancel existing first

    if (!enabled) return;

    final timeParts = time.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      2, // notification ID for daily summary
      'Günlük Özet 📊',
      'Bugünkü aktivitelerini kontrol et ve hedeflerini gözden geçir!',
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'summary_channel',
          'Günlük Özet',
          channelDescription: 'Günlük aktivite özeti bildirimleri',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
    );
  }

  Future<void> cancelDailySummary() async {
    await _notifications.cancel(2);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Show instant notification (for testing or immediate alerts)
  Future<void> showInstantNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_initialized) await initialize();

    await _notifications.show(
      999, // Use high ID for instant notifications
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'instant_channel',
          'Anlık Bildirimler',
          channelDescription: 'Anlık bildirimler',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: payload,
    );
  }
}
