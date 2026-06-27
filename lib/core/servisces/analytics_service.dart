import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

/// خدمة التحليلات - 20+ Event
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // ==================== User Properties ====================

  /// تعيين خصائص المستخدم
  Future<void> setUserProperties({
    required String userId,
    String? userType,
    String? subscriptionPlan,
    String? level,
  }) async {
    await _analytics.setUserId(id: userId);
    
    if (userType != null) {
      await _analytics.setUserProperty(name: 'user_type', value: userType);
    }
    if (subscriptionPlan != null) {
      await _analytics.setUserProperty(name: 'subscription', value: subscriptionPlan);
    }
    if (level != null) {
      await _analytics.setUserProperty(name: 'current_level', value: level);
    }
  }

  // ==================== Authentication Events ====================

  /// تسجيل دخول
  Future<void> logLogin(String method) async {
    await _analytics.logLogin(loginMethod: method);
    debugPrint('📊 Analytics: login - $method');
  }

  /// تسجيل حساب جديد
  Future<void> logSignUp(String method) async {
    await _analytics.logSignUp(signUpMethod: method);
    debugPrint('📊 Analytics: sign_up - $method');
  }

  /// تسجيل خروج
  Future<void> logLogout() async {
    await _analytics.logEvent(name: 'logout');
    debugPrint('📊 Analytics: logout');
  }

  // ==================== Quiz Events ====================

  /// بدء اختبار
  Future<void> logQuizStart({
    required String level,
    required int questionCount,
  }) async {
    await _analytics.logEvent(
      name: 'quiz_start',
      parameters: {
        'level': level,
        'question_count': questionCount,
      },
    );
  }

  /// إجابة على سؤال
  Future<void> logQuizAnswer({
    required String level,
    required int questionIndex,
    required bool isCorrect,
    required int timeSpentSeconds,
  }) async {
    await _analytics.logEvent(
      name: 'quiz_answer',
      parameters: {
        'level': level,
        'question_index': questionIndex,
        'is_correct': isCorrect,
        'time_spent': timeSpentSeconds,
      },
    );
  }

  /// إكمال اختبار
  Future<void> logQuizComplete({
    required String level,
    required int score,
    required int totalQuestions,
    required double percentage,
    required bool passed,
    required int durationSeconds,
  }) async {
    await _analytics.logEvent(
      name: 'quiz_complete',
      parameters: {
        'level': level,
        'score': score,
        'total_questions': totalQuestions,
        'percentage': percentage,
        'passed': passed,
        'duration_seconds': durationSeconds,
      },
    );
  }

  // ==================== Lesson Events ====================

  /// فتح درس
  Future<void> logLessonView({
    required String lessonId,
    required String lessonTitle,
    required String level,
  }) async {
    await _analytics.logEvent(
      name: 'lesson_view',
      parameters: {
        'lesson_id': lessonId,
        'lesson_title': lessonTitle,
        'level': level,
      },
    );
  }

  /// إكمال درس
  Future<void> logLessonComplete({
    required String lessonId,
    required String lessonTitle,
    required int durationSeconds,
  }) async {
    await _analytics.logEvent(
      name: 'lesson_complete',
      parameters: {
        'lesson_id': lessonId,
        'lesson_title': lessonTitle,
        'duration_seconds': durationSeconds,
      },
    );
  }

  // ==================== Certificate Events ====================

  /// إصدار شهادة
  Future<void> logCertificateEarned({
    required String level,
    required double percentage,
  }) async {
    await _analytics.logEvent(
      name: 'certificate_earned',
      parameters: {
        'level': level,
        'percentage': percentage,
      },
    );
  }

  /// مشاركة شهادة
  Future<void> logCertificateShare({
    required String level,
    required String shareMethod,
  }) async {
    await _analytics.logEvent(
      name: 'certificate_share',
      parameters: {
        'level': level,
        'share_method': shareMethod,
      },
    );
  }

  // ==================== AI Tutor Events ====================

  /// استخدام المساعد الذكي
  Future<void> logAiTutorUsed({
    required String questionType,
    required int responseLength,
  }) async {
    await _analytics.logEvent(
      name: 'ai_tutor_used',
      parameters: {
        'question_type': questionType,
        'response_length': responseLength,
      },
    );
  }

  // ==================== Live Stream Events ====================

  /// مشاهدة بث مباشر
  Future<void> logLiveStreamView({
    required String streamId,
    required String teacherName,
    required int durationSeconds,
  }) async {
    await _analytics.logEvent(
      name: 'live_stream_view',
      parameters: {
        'stream_id': streamId,
        'teacher_name': teacherName,
        'duration_seconds': durationSeconds,
      },
    );
  }

  // ==================== Teacher Portal Events ====================

  /// إنشاء امتحان
  Future<void> logExamCreated({
    required String teacherId,
    required int questionCount,
    required String level,
  }) async {
    await _analytics.logEvent(
      name: 'exam_created',
      parameters: {
        'teacher_id': teacherId,
        'question_count': questionCount,
        'level': level,
      },
    );
  }

  // ==================== Payment Events ====================

  /// بدء عملية شراء
  Future<void> logPurchaseStart({
    required String productId,
    required double value,
    required String currency,
  }) async {
    await _analytics.logEvent(
      name: 'purchase_start',
      parameters: {
        'product_id': productId,
        'value': value,
        'currency': currency,
      },
    );
  }

  /// إكمال عملية شراء
  Future<void> logPurchaseComplete({
    required String productId,
    required double value,
    required String currency,
    required String transactionId,
  }) async {
    await _analytics.logPurchase(
      value: value,
      currency: currency,
      transactionId: transactionId,
    );
  }

  // ==================== Engagement Events ====================

  /// وقت استخدام التطبيق
  Future<void> logAppOpen() async {
    await _analytics.logAppOpen();
  }

  /// وقت استخدام التطبيق
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass ?? 'Flutter',
    );
  }

  /// مشاركة محتوى
  Future<void> logShare({
    required String contentType,
    required String itemId,
    required String method,
  }) async {
    await _analytics.logShare(
      contentType: contentType,
      itemId: itemId,
      method: method,
    );
  }

  /// البحث
  Future<void> logSearch({required String searchTerm}) async {
    await _analytics.logSearch(searchTerm: searchTerm);
  }

  /// خطأ
  Future<void> logError({
    required String errorType,
    required String errorMessage,
    String? screenName,
  }) async {
    await _analytics.logEvent(
      name: 'app_error',
      parameters: {
        'error_type': errorType,
        'error_message': errorMessage,
        'screen_name': screenName ?? 'unknown',
      },
    );
  }

  // ==================== Custom Events ====================

  /// حدث مخصص عام
  Future<void> logCustomEvent({
    required String eventName,
    Map<String, dynamic>? parameters,
  }) async {
    await _analytics.logEvent(
      name: eventName,
      parameters: parameters?.map(
        (key, value) => MapEntry(key, value as Object),
      ),
    );
  }
}