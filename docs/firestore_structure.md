// Firestore Collection: questions
// Document Structure:
{
  "question": "السؤال هنا",
  "type": "multipleChoice", // multipleChoice, trueFalse, fillInBlank, matching
  "difficulty": "medium", // easy, medium, hard
  "category": "nahw", // nahw, sarf, balagha, arud, imla, history, adab
  "options": ["الخيار 1", "الخيار 2", "الخيار 3", "الخيار 4"],
  "correctAnswerIndex": 0,
  "explanation": "الشرح هنا",
  "imageUrl": "", // optional
  "isActive": true,
  "level": "ابتدائي", // ابتدائي, إعدادي, ثانوي
  "createdAt": Timestamp,
  "createdBy": "userId",
  "updatedAt": Timestamp,
  "updatedBy": "userId"
}

// Firestore Collection: quiz_results
// Document Structure:
{
  "userId": "uid",
  "userEmail": "email",
  "score": 120,
  "totalQuestions": 15,
  "percentage": 80.0,
  "category": "إعدادي",
  "level": "مستوى 2",
  "passed": true,
  "grade": "جيد جداً",
  "answers": [...],
  "completedAt": Timestamp
}

// Firestore Collection: leaderboard
// Document Structure:
{
  "userId": "uid",
  "userEmail": "email",
  "userName": "name",
  "totalScore": 1200,
  "totalQuizzes": 10,
  "averagePercentage": 75.5,
  "lastUpdated": Timestamp
}

// Firestore Collection: users
// Document Structure:
{
  "name": "اسم المستخدم",
  "email": "email",
  "notifications": true,
  "sound": true,
  "darkMode": true,
  "language": "ar",
  "createdAt": Timestamp,
  "updatedAt": Timestamp,
  "role": "user" // user, admin
}