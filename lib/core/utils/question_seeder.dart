import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QuestionSeeder {
  static Future<void> seedQuestions() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Check if admin
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!userDoc.exists || userDoc.data()?['role'] != 'admin') {
      throw Exception('Admin access required');
    }

    final batch = FirebaseFirestore.instance.batch();

    // Primary questions (15)
    final primaryQuestions = [
      {
        'question': 'الجملة "الطالب مجتهد" هي جملة:',
        'type': 'multipleChoice',
        'difficulty': 'easy',
        'category': 'nahw',
        'options': ['اسمية', 'فعلية', 'شرطية'],
        'correctAnswerIndex': 0,
        'explanation': 'الجملة الاسمية: تبدأ باسم (المبتدأ) والخبر',
        'level': 'ابتدائي',
        'isActive': true,
      },
      // ... add all 15 primary questions
    ];

    // Prep questions (15)
    final prepQuestions = [
      {
        'question': 'كان وأخواتها ترفع:',
        'type': 'multipleChoice',
        'difficulty': 'medium',
        'category': 'nahw',
        'options': ['المبتدأ', 'الخبر', 'الفاعل'],
        'correctAnswerIndex': 0,
        'explanation': 'كان وأخواتها ترفع المبتدأ (الاسم) وتنصب الخبر',
        'level': 'إعدادي',
        'isActive': true,
      },
      // ... add all 15 prep questions
    ];

    // Secondary questions (15)
    final secondaryQuestions = [
      {
        'question': 'كان وأخواتها تُسمى:',
        'type': 'multipleChoice',
        'difficulty': 'hard',
        'category': 'nahw',
        'options': ['نواسخ', 'أفعال ماضية', 'أفعال مضارعة'],
        'correctAnswerIndex': 0,
        'explanation': 'كان وأخواتها: نواسخ تدخل على الجملة الاسمية',
        'level': 'ثانوي',
        'isActive': true,
      },
      // ... add all 15 secondary questions
    ];

    // Add all questions to batch
    for (var question in [...primaryQuestions, ...prepQuestions, ...secondaryQuestions]) {
      final ref = FirebaseFirestore.instance.collection('questions').doc();
      batch.set(ref, {
        ...question,
        'createdAt': Timestamp.now(),
        'createdBy': user.uid,
        'updatedAt': Timestamp.now(),
        'updatedBy': user.uid,
      });
    }

    await batch.commit();
    print('✅ Questions seeded successfully!');
  }
}