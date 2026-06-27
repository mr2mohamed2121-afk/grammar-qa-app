import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_ios/local_auth_ios.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// خدمة الأمان - App Check + Biometric Authentication
class SecurityService {
  static final SecurityService _instance = SecurityService._internal();
  factory SecurityService() => _instance;
  SecurityService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isAppCheckInitialized = false;

  // ==================== Firebase App Check ====================
  
  /// تفعيل Firebase App Check
  Future<void> initializeAppCheck() async {
    if (_isAppCheckInitialized) return;
    
    try {
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.playIntegrity,
        appleProvider: AppleProvider.deviceCheck,
      );
      _isAppCheckInitialized = true;
      debugPrint('✅ App Check activated successfully');
    } catch (e) {
      debugPrint('❌ App Check activation failed: $e');
    }
  }

  /// الحصول على App Check token
  Future<String?> getAppCheckToken() async {
    try {
      return await FirebaseAppCheck.instance.getToken();
    } catch (e) {
      debugPrint('❌ Failed to get App Check token: $e');
      return null;
    }
  }

  // ==================== Biometric Authentication ====================

  /// التحقق من دعم الجهاز للبصمة/الوجه
  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } catch (e) {
      return false;
    }
  }

  /// التحقق من وجود بصمات مسجلة
  Future<bool> canCheckBiometrics() async {
    try {
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      return availableBiometrics.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// الحصول على أنواع البصمات المتاحة
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  /// مصادقة البصمة/الوجه
  Future<bool> authenticateWithBiometrics({
    required String localizedReason,
    bool useErrorDialogs = true,
    bool stickyAuth = false,
    bool sensitiveTransaction = true,
  }) async {
    try {
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: localizedReason,
        authMessages: const [
          AndroidAuthMessages(
            signInTitle: 'المصادقة البيومترية',
            cancelButton: 'إلغاء',
            biometricHint: 'تحقق من هويتك',
            biometricNotRecognized: 'لم يتم التعرف، حاول مرة أخرى',
            biometricRequiredTitle: 'الرجاء المصادقة البيومترية',
            deviceCredentialsRequiredTitle: 'يرجى إدخال بيانات الاعتماد',
            deviceCredentialsSetupDescription: 'يرجى إعداد بيانات الاعتماد',
            goToSettingsButton: 'الإعدادات',
            goToSettingsDescription: 'يرجى إعداد البصمة في الإعدادات',
          ),
          IOSAuthMessages(
            cancelButton: 'إلغاء',
            goToSettingsButton: 'الإعدادات',
            goToSettingsDescription: 'يرجى إعداد Face ID في الإعدادات',
            lockOut: 'الرجاء إعادة تمكين Face ID',
          ),
        ],
        options: AuthenticationOptions(
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyAuth,
          sensitiveTransaction: sensitiveTransaction,
          biometricOnly: false,
        ),
      );
      return didAuthenticate;
    } catch (e) {
      debugPrint('❌ Biometric authentication failed: $e');
      return false;
    }
  }

  /// مصادقة قوية (بصمة فقط بدون PIN)
  Future<bool> authenticateWithBiometricsOnly({
    required String localizedReason,
  }) async {
    try {
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      return didAuthenticate;
    } catch (e) {
      debugPrint('❌ Biometric-only authentication failed: $e');
      return false;
    }
  }

  /// إلغاء المصادقة
  Future<bool> stopAuthentication() async {
    try {
      return await _localAuth.stopAuthentication();
    } catch (e) {
      return false;
    }
  }

  // ==================== Security Helpers ====================

  /// التحقق من صلاحية الجلسة
  bool isSessionValid() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    
    // التحقق من آخر تسجيل دخول (أقل من 24 ساعة)
    final metadata = user.metadata;
    final lastSignIn = metadata.lastSignInTime;
    if (lastSignIn == null) return false;
    
    final difference = DateTime.now().difference(lastSignIn);
    return difference.inHours < 24;
  }

  /// التحقق من إيميل مؤكد
  bool isEmailVerified() {
    final user = FirebaseAuth.instance.currentUser;
    return user?.emailVerified ?? false;
  }

  /// إرسال إيميل التأكيد
  Future<void> sendEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  /// تسجيل الخروج من جميع الأجهزة
  Future<void> revokeAllSessions() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      debugPrint('❌ Failed to revoke sessions: $e');
    }
  }
}