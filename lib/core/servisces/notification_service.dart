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

  /// تهيئة الإشعارات
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    // تهيئة المنطقة الزمنية
    tz.initializeTimeZones();
    
    // إعدادات Android
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // إعدادات iOS
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

    // إنشاء قنوات الإشعارات
    await _createNotificationChannels();

    // إعداد Firebase Messaging
    await _setupFirebaseMessaging();

    _isInitialized = true;
    debugPrint('✅ Notification service initialized');
  }

  /// إنشاء قنوات الإشعارات (Android)
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

  /// إعداد Firebase Messaging
  Future<void> _setupFirebaseMessaging() async {
    // طلب الإذن
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    // الحصول على token
    final token = await _firebaseMessaging.getToken();
    debugPrint('📱 FCM Token: $token');

    // التعامل مع الإشعارات في الخلفية
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // التعامل مع الإشعارات في المقدمة
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleForegroundMessage(message);
    });

    // عند فتح الإشعار
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('📱 Notification opened: ${message.data}');
    });
  }

  /// معالجة الإشعارات في الخلفية
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    debugPrint('📱 Background message: ${message.notification?.title}');
  }

  /// معالجة الإشعارات في المقدمة
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

  /// معالجة الضغط على الإشعار
  void _onNotificationResponse(NotificationResponse response) {
    debugPrint('📱 Notification tapped: ${response.payload}');
    // يمكن التنقل هنا بناءً على payload
  }

  // ==================== Local Notifications ====================

  /// إظهار إشعار محلي
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

  /// جدولة إشعار يومي
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

  /// جدولة إشعار بعد فترة
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
      androidScheduleMode: AndroidScheduleMode.allowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  // ==================== Specific Notifications ====================

  /// إشعار تذكير يومي بالدرس
  Future<void> showDailyLessonReminder() async {
    await scheduleDailyReminder(
      id: 1,
      title: '📚 وقت الدرس اليومي!',
      body: 'لا تنسَ درس النحو اليوم. اختبر نفسك وطوّر مهاراتك!',
      time: const TimeOfDay(hour: 9, minute: 0),
      payload: '/lessons',
    );
  }

  /// إشعار تذكير بالاختبار
  Future<void> showQuizReminder() async {
    await scheduleDelayedNotification(
      id: 2,
      title: '📝 جاهز للاختبار؟',
      body: 'اختبر معلوماتك في النحو العربي الآن!',
      delay: const Duration(hours: 2),
      payload: '/quiz',
    );
  }

  /// إشعار إنجاز (شهادة)
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

  /// إشعار بث مباشر
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

  /// إشعار ترحيب
  Future<void> showWelcomeNotification(String userName) async {
    await showLocalNotification(
      id: 4,
      title: '👋 أهلاً بيك يا $userName!',
      body: 'ابدأ رحلتك في تعلم النحو العربي مع أستاذ النحو',
      importance: Importance.high,
    );
  }

  // ==================== Management ====================

  /// إلغاء إشعار محدد
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  /// إلغاء كل الإشعارات
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  /// الحصول على الإشعارات المجدولة
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _localNotifications.pendingNotificationRequests();
  }

  /// تحديث FCM token
  Future<void> refreshFcmToken() async {
    await _firebaseMessaging.deleteToken();
    final newToken = await _firebaseMessaging.getToken();
    debugPrint('📱 New FCM Token: $newToken');
  }

  /// الاشتراك في موضوع
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    debugPrint('📱 Subscribed to topic: $topic');
  }

  /// إلغاء الاشتراك من موضوع
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    debugPrint('📱 Unsubscribed from topic: $topic');
  }
}