# 🔥 دليل إعداد Firebase

## الخطوة 1: إنشاء مشروع Firebase

1. اذهب إلى [Firebase Console](https://console.firebase.google.com/)
2. أنشئ مشروع جديد باسم `arabic-grammar-app`
3. فعّل Google Analytics

## الخطوة 2: إضافة التطبيق

### Android
1. في Firebase Console → Project Settings → Add App → Android
2. أدخل `com.yourcompany.arabicGrammarApp` كـ Package Name
3. حمّل `google-services.json` إلى `android/app/`

### iOS
1. في Firebase Console → Project Settings → Add App → iOS
2. أدخل Bundle ID
3. حمّل `GoogleService-Info.plist` إلى `ios/Runner/`

## الخطوة 3: تفعيل الخدمات

### Authentication
- في Firebase Console → Authentication → Sign-in method
- فعّل: Email/Password

### Firestore Database
- في Firebase Console → Firestore Database → Create Database
- ابدأ في وضع Test Mode

### Storage
- في Firebase Console → Storage → Get Started

### Cloud Functions
```bash
npm install -g firebase-tools
firebase login
firebase init functions