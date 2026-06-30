const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

// Trigger when a new quiz result is added
exports.updateLeaderboard = functions.firestore
  .document('quiz_results/{resultId}')
  .onCreate(async (snap, context) => {
    const data = snap.data();
    const userId = data.userId;

    if (!userId) return;

    const leaderboardRef = admin.firestore().collection('leaderboard').doc(userId);

    try {
      const doc = await leaderboardRef.get();

      if (doc.exists) {
        const currentData = doc.data();
        const totalQuizzes = (currentData.totalQuizzes || 0) + 1;
        const totalScore = (currentData.totalScore || 0) + (data.score || 0);
        const averagePercentage = totalScore / (totalQuizzes * data.totalQuestions * 10) * 100;

        await leaderboardRef.update({
          totalScore: totalScore,
          totalQuizzes: totalQuizzes,
          averagePercentage: Math.round(averagePercentage * 100) / 100,
          lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
        });
      } else {
        // Create new leaderboard entry
        await leaderboardRef.set({
          userId: userId,
          userEmail: data.userEmail || '',
          userName: data.userEmail?.split('@')[0] || 'مستخدم',
          totalScore: data.score || 0,
          totalQuizzes: 1,
          averagePercentage: (data.percentage || 0),
          lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
        });
      }

      console.log(`Leaderboard updated for user: ${userId}`);
    } catch (error) {
      console.error('Error updating leaderboard:', error);
    }
  });

// HTTP function to seed questions (admin only)
exports.seedQuestions = functions.https.onCall(async (data, context) => {
  // Check if user is admin
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const userDoc = await admin.firestore().collection('users').doc(context.auth.uid).get();
  if (!userDoc.exists || userDoc.data().role !== 'admin') {
    throw new functions.https.HttpsError('permission-denied', 'Admin access required');
  }

  const questions = data.questions || [];
  const batch = admin.firestore().batch();

  questions.forEach((question) => {
    const ref = admin.firestore().collection('questions').doc();
    batch.set(ref, {
      ...question,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      createdBy: context.auth.uid,
      isActive: true,
    });
  });

  await batch.commit();
  return { success: true, count: questions.length };
});