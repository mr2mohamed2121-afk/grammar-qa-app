import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io' show Platform;

/// خدمة الإشعارات - Local + Push Notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  bool _isInitialized = false;

  // ==================== Initialization ====================

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    tz.initializeTimeZones();
    
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      defaultPresentAlert: true,
      defaultPresentBadge: true,
      defaultPresentSound: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    await _createNotificationChannels();
    await _setupFirebaseMessaging();

    _isInitialized = true;
    debugPrint('✅ Notification service initialized');
  }

  Future<void> _createNotificationChannels() async {
    if (Platform.isAndroid) {
      const androidChannel = AndroidNotificationChannel(
        'daily_reminder',
        'تذكير يومي',
        description: 'تذكير يومي بدرس النحو',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );

      const androidChannel2 = AndroidNotificationChannel(
        'quiz_reminder',
        'تذكير الاختبار',
        description: 'تذكير باختبار النحو',
        importance: Importance.high,
      );

      const androidChannel3 = AndroidNotificationChannel(
        'achievement',
        'إنجازات',
        description: 'إشعارات الإنجازات والشهادات',
        importance: Importance.high,
      );

      const androidChannel4 = AndroidNotificationChannel(
        'live_stream',
        'بث مباشر',
        description: 'إشعارات البث المباشر',
        importance: Importance.max,
      );

      const androidChannel5 = AndroidNotificationChannel(
        'general',
        'عام',
        description: 'إشعارات عامة',
        importance: Importance.defaultImportance,
      );

      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      
      await androidPlugin?.createNotificationChannel(androidChannel);
      await androidPlugin?.createNotificationChannel(androidChannel2);
      await androidPlugin?.createNotificationChannel(androidChannel3);
      await androidPlugin?.createNotificationChannel(androidChannel4);
      await androidPlugin?.createNotificationChannel(androidChannel5);
    }
  }

  Future<void> _setupFirebaseMessaging() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    final token = await _firebaseMessaging.getToken();
    debugPrint('📱 FCM Token: $token');

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleForegroundMessage(message);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('📱 Notification opened: ${message.data}');
    });
  }

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    debugPrint('📱 Background message: ${message.notification?.title}');
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification != null) {
      showLocalNotification(
        id: message.hashCode,
        title: notification.title ?? 'أستاذ النحو',
        body: notification.body ?? '',
        payload: message.data['route'],
      );
    }
  }

  void _onNotificationResponse(NotificationResponse response) {
    debugPrint('📱 Notification tapped: ${response.payload}');
  }

  // ==================== Local Notifications ====================

  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String channelId = 'general',
    String channelName = 'عام',
    Importance importance = Importance.defaultImportance,
    Priority priority = Priority.defaultPriority,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      importance: importance,
      priority: priority,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFFD4AF37),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(id, title, body, details, payload: payload);
  }

  Future<void> scheduleDailyReminder({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
    String? payload,
  }) async {
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final androidDetails = const AndroidNotificationDetails(
      'daily_reminder',
      'تذكير يومي',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );
  }

  Future<void> scheduleDelayedNotification({
    required int id,
    required String title,
    required String body,
    required Duration delay,
    String? payload,
  }) async {
    final scheduledDate = DateTime.now().add(delay);

    final androidDetails = const AndroidNotificationDetails(
      'quiz_reminder',
      'تذكير الاختبار',
      importance: Importance.high,
    );

    const iosDetails = DarwinNotificationDetails();

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  // ==================== Specific Notifications ====================

  Future<void> showDailyLessonReminder() async {
    await scheduleDailyReminder(
      id: 1,
      title: '📚 وقت الدرس اليومي!',
      body: 'لا تنسَ درس النحو اليوم. اختبر نفسك وطوّر مهاراتك!',
      time: const TimeOfDay(hour: 9, minute: 0),
      payload: '/lessons',
    );
  }

  Future<void> showQuizReminder() async {
    await scheduleDelayedNotification(
      id: 2,
      title: '📝 جاهز للاختبار؟',
      body: 'اختبر معلوماتك في النحو العربي الآن!',
      delay: const Duration(hours: 2),
      payload: '/quiz',
    );
  }

  Future<void> showAchievementNotification({
    required String title,
    required String body,
  }) async {
    await showLocalNotification(
      id: DateTime.now().millisecond,
      title: '🏆 $title',
      body: body,
      channelId: 'achievement',
      channelName: 'إنجازات',
      importance: Importance.high,
      priority: Priority.high,
    );
  }

  Future<void> showLiveStreamNotification({
    required String title,
    required String body,
  }) async {
    await showLocalNotification(
      id: 3,
      title: '🔴 $title',
      body: body,
      channelId: 'live_stream',
      channelName: 'بث مباشر',
      importance: Importance.max,
      priority: Priority.max,
    );
  }

  Future<void> showWelcomeNotification(String userName) async {
    await showLocalNotification(
      id: 4,
      title: '👋 أهلاً بيك يا $userName!',
      body: 'ابدأ رحلتك في تعلم النحو العربي مع أستاذ النحو',
      importance: Importance.high,
    );
  }

  // ==================== Management ====================

  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _localNotifications.pendingNotificationRequests();
  }

  Future<void> refreshFcmToken() async {
    await _firebaseMessaging.deleteToken();
    final newToken = await _firebaseMessaging.getToken();
    debugPrint('📱 New FCM Token: $newToken');
  }

  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    debugPrint('📱 Subscribed to topic: $topic');
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    debugPrint('📱 Unsubscribed from topic: $topic');
  }
}