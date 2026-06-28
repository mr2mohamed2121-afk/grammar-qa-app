import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/material.dart';

/// خدمة التخزين المؤقت - Hive + Offline Mode
class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  bool _isInitialized = false;

  // أسماء الصناديق
  static const String _userBox = 'userBox';
  static const String _questionsBox = 'questionsBox';
  static const String _progressBox = 'progressBox';
  static const String _settingsBox = 'settingsBox';
  static const String _cacheBox = 'cacheBox';

  // ==================== Initialization ====================

  /// تهيئة Hive
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      await Hive.initFlutter();
      
      // فتح الصناديق
      await Hive.openBox(_userBox);
      await Hive.openBox(_questionsBox);
      await Hive.openBox(_progressBox);
      await Hive.openBox(_settingsBox);
      await Hive.openBox(_cacheBox);
      
      _isInitialized = true;
      debugPrint('✅ Hive initialized successfully');
    } catch (e) {
      debugPrint('❌ Hive initialization failed: $e');
    }
  }

  // ==================== User Cache ====================

  /// حفظ بيانات المستخدم
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final box = Hive.box(_userBox);
    await box.put('user_data', userData);
    await box.put('user_data_timestamp', DateTime.now().toIso8601String());
  }

  /// جلب بيانات المستخدم
  Map<String, dynamic>? getUserData() {
    final box = Hive.box(_userBox);
    return box.get('user_data') as Map<String, dynamic>?;
  }

  /// حفظ حالة تسجيل الدخول
  Future<void> setLoggedIn(bool value) async {
    final box = Hive.box(_userBox);
    await box.put('is_logged_in', value);
  }

  /// التحقق من حالة تسجيل الدخول
  bool isLoggedIn() {
    final box = Hive.box(_userBox);
    return box.get('is_logged_in', defaultValue: false) as bool;
  }

  // ==================== Questions Cache ====================

  /// حفظ الأسئلة
  Future<void> saveQuestions(List<Map<String, dynamic>> questions, {String? level}) async {
    final box = Hive.box(_questionsBox);
    final key = level != null ? 'questions_$level' : 'questions_all';
    await box.put(key, questions);
    await box.put('${key}_timestamp', DateTime.now().toIso8601String());
  }

  /// جلب الأسئلة
  List<Map<String, dynamic>>? getQuestions({String? level}) {
    final box = Hive.box(_questionsBox);
    final key = level != null ? 'questions_$level' : 'questions_all';
    final data = box.get(key);
    if (data == null) return null;
    return List<Map<String, dynamic>>.from(data);
  }

  /// التحقق من صلاحية الكاش (أقل من 24 ساعة)
  bool isQuestionsCacheValid({String? level}) {
    final box = Hive.box(_questionsBox);
    final key = level != null ? 'questions_$level' : 'questions_all';
    final timestamp = box.get('${key}_timestamp') as String?;
    if (timestamp == null) return false;
    
    final cacheTime = DateTime.parse(timestamp);
    final difference = DateTime.now().difference(cacheTime);
    return difference.inHours < 24;
  }

  // ==================== Progress Cache ====================

  /// حفظ تقدم الاختبار
  Future<void> saveQuizProgress({
    required String userId,
    required String level,
    required int score,
    required int totalQuestions,
    required double percentage,
  }) async {
    final box = Hive.box(_progressBox);
    final progress = {
      'user_id': userId,
      'level': level,
      'score': score,
      'total_questions': totalQuestions,
      'percentage': percentage,
      'timestamp': DateTime.now().toIso8601String(),
      'synced': false,
    };
    
    final key = 'progress_${userId}_$level';
    await box.put(key, progress);
  }

  /// جلب تقدم المستخدم
  List<Map<String, dynamic>> getUserProgress(String userId) {
    final box = Hive.box(_progressBox);
    final progress = <Map<String, dynamic>>[];
    
    for (var key in box.keys) {
      if (key.toString().startsWith('progress_$userId')) {
        final data = box.get(key) as Map<String, dynamic>?;
        if (data != null) progress.add(data);
      }
    }
    
    return progress;
  }

  /// جلب البيانات غير المتزامنة
  List<Map<String, dynamic>> getUnsyncedProgress() {
    final box = Hive.box(_progressBox);
    final unsynced = <Map<String, dynamic>>[];
    
    for (var key in box.keys) {
      final data = box.get(key) as Map<String, dynamic>?;
      if (data != null && data['synced'] == false) {
        unsynced.add(data);
      }
    }
    
    return unsynced;
  }

  /// تحديث حالة التزامن
  Future<void> markAsSynced(String key) async {
    final box = Hive.box(_progressBox);
    final data = box.get(key) as Map<String, dynamic>?;
    if (data != null) {
      data['synced'] = true;
      await box.put(key, data);
    }
  }

  // ==================== Settings Cache ====================

  /// حفظ إعدادات المستخدم
  Future<void> saveSettings(Map<String, dynamic> settings) async {
    final box = Hive.box(_settingsBox);
    await box.put('user_settings', settings);
  }

  /// جلب إعدادات المستخدم
  Map<String, dynamic> getSettings() {
    final box = Hive.box(_settingsBox);
    return box.get('user_settings', defaultValue: {}) as Map<String, dynamic>;
  }

  /// حفظ وضع عدم الاتصال
  Future<void> setOfflineMode(bool enabled) async {
    final box = Hive.box(_settingsBox);
    await box.put('offline_mode', enabled);
  }

  /// التحقق من وضع عدم الاتصال
  bool isOfflineMode() {
    final box = Hive.box(_settingsBox);
    return box.get('offline_mode', defaultValue: false) as bool;
  }

  // ==================== General Cache ====================

  /// حفظ بيانات عامة مع TTL
  Future<void> setCache({
    required String key,
    required dynamic value,
    Duration ttl = const Duration(hours: 1),
  }) async {
    final box = Hive.box(_cacheBox);
    final cacheEntry = {
      'value': value,
      'expires_at': DateTime.now().add(ttl).toIso8601String(),
    };
    await box.put(key, cacheEntry);
  }

  /// جلب بيانات من الكاش
  dynamic getCache(String key) {
    final box = Hive.box(_cacheBox);
    final entry = box.get(key) as Map<String, dynamic>?;
    if (entry == null) return null;
    
    final expiresAt = DateTime.parse(entry['expires_at'] as String);
    if (DateTime.now().isAfter(expiresAt)) {
      box.delete(key);
      return null;
    }
    
    return entry['value'];
  }

  /// حذف كاش محدد
  Future<void> deleteCache(String key) async {
    final box = Hive.box(_cacheBox);
    await box.delete(key);
  }

  /// مسح الكاش المنتهي
  Future<void> clearExpiredCache() async {
    final box = Hive.box(_cacheBox);
    final keysToDelete = <String>[];
    
    for (var key in box.keys) {
      final entry = box.get(key) as Map<String, dynamic>?;
      if (entry != null) {
        final expiresAt = DateTime.parse(entry['expires_at'] as String);
        if (DateTime.now().isAfter(expiresAt)) {
          keysToDelete.add(key.toString());
        }
      }
    }
    
    for (var key in keysToDelete) {
      await box.delete(key);
    }
  }

  // ==================== Cache Management ====================

  /// مسح كل الكاش
  Future<void> clearAllCache() async {
    await Hive.box(_userBox).clear();
    await Hive.box(_questionsBox).clear();
    await Hive.box(_progressBox).clear();
    await Hive.box(_settingsBox).clear();
    await Hive.box(_cacheBox).clear();
    debugPrint('✅ All cache cleared');
  }

  /// الحصول على حجم الكاش
  Future<Map<String, int>> getCacheSize() async {
    return {
      'user': Hive.box(_userBox).length,
      'questions': Hive.box(_questionsBox).length,
      'progress': Hive.box(_progressBox).length,
      'settings': Hive.box(_settingsBox).length,
      'general': Hive.box(_cacheBox).length,
    };
  }

  /// إغلاق كل الصناديق
  Future<void> close() async {
    await Hive.box(_userBox).close();
    await Hive.box(_questionsBox).close();
    await Hive.box(_progressBox).close();
    await Hive.box(_settingsBox).close();
    await Hive.box(_cacheBox).close();
    _isInitialized = false;
  }
}