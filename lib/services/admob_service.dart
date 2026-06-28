import 'package:flutter/material.dart';

/// خدمة الإعلانات المبسطة
class AdmobService {
  static final AdmobService _instance = AdmobService._internal();
  factory AdmobService() => _instance;
  AdmobService._internal();

  Future<void> initialize() async {
    debugPrint('📱 AdMob initialized');
  }

  void showBanner() {
    debugPrint('📱 Show banner ad');
  }

  void showInterstitial() {
    debugPrint('📱 Show interstitial ad');
  }

  void showRewarded({required Function(num amount, String type) onRewarded}) {
    debugPrint('📱 Show rewarded ad');
    onRewarded(10, 'coins');
  }
}