import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../admin/presentation/screens/add_questions_screen.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../auth/presentation/screens/account_settings_dialog.dart';
import '../../../auth/presentation/screens/privacy_settings_dialog.dart';
import '../../../lessons/presentation/screens/lessons_screen.dart';
import '../../../quiz/presentation/screens/quiz_screen.dart';
import '../../../../injection.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'الصفحة الرئيسية',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0D0D0D),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFFD4AF37)),
            onPressed: () => _showSettingsMenu(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ✅ Logo ذهبي
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [
                        Color(0xFFD4AF37),
                        Color(0xFF8B6914),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD4AF37).withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.menu_book,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'تطبيق قواعد اللغة العربية',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD4AF37),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'اختبر معلوماتك في النحو والصرف والبلاغة',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 40),

                // ✅ اختبر نفسك
                _buildGradientButton(
                  context: context,
                  title: 'اختبر نفسك',
                  icon: Icons.quiz,
                  colors: [const Color(0xFF2E7D32), const Color(0xFF1B5E20)],
                  onTap: () => _showLevelSelectionDialog(context),
                ),
                const SizedBox(height: 16),

                // ✅ إضافة أسئلة
                _buildGradientButton(
                  context: context,
                  title: 'إضافة أسئلة',
                  icon: Icons.add_circle,
                  colors: [const Color(0xFFFF6B6B), const Color(0xFFEE5A24)],
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddQuestionsScreen()),
                  ),
                ),
                const SizedBox(height: 16),

                // ✅ لوحة المتصدرين
                _buildGradientButton(
                  context: context,
                  title: 'لوحة المتصدرين',
                  icon: Icons.emoji_events,
                  colors: [const Color(0xFFFFD700), const Color(0xFFFF8C00)],
                  onTap: () => _showLeaderboardDialog(context),
                ),
                const SizedBox(height: 16),

                // ✅ الدروس - بدون const
                _buildGradientButton(
                  context: context,
                  title: 'الدروس',
                  icon: Icons.school,
                  colors: [const Color(0xFF2196F3), const Color(0xFF0D47A1)],
                  onTap: () => _showLessonsDialog(context),
                ),
                const SizedBox(height: 16),

                // ✅ بث مباشر
                _buildGradientButton(
                  context: context,
                  title: 'بث مباشر',
                  icon: Icons.videocam,
                  colors: [const Color(0xFFE94560), const Color(0xFF0F3460)],
                  onTap: () => _showLiveDialog(context),
                ),
                const SizedBox(height: 16),

                // ✅ أستاذ النحو الذكي
                _buildGradientButton(
                  context: context,
                  title: 'أستاذ النحو الذكي',
                  icon: Icons.smart_toy,
                  colors: [const Color(0xFF9C27B0), const Color(0xFF673AB7)],
                  onTap: () => _showAiTutorDialog(context),
                ),
                const SizedBox(height: 16),

                // ✅ بوابة المعلم
                _buildGradientButton(
                  context: context,
                  title: 'بوابة المعلم',
                  icon: Icons.person_outline,
                  colors: [const Color(0xFF795548), const Color(0xFF3E2723)],
                  onTap: () => _showTeacherDialog(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ✅ اختبر نفسك - يفتح QuizScreen
  void _showLevelSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'اختر المستوى',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFFD4AF37)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLevelCard(
              context,
              'المرحلة الابتدائية',
              'الصف الأول - الصف السادس',
              Colors.green,
              Icons.child_care,
              () {
                Navigator.pop(context);
                _startQuiz(context, 'ابتدائي');
              },
            ),
            const SizedBox(height: 10),
            _buildLevelCard(
              context,
              'المرحلة الإعدادية',
              'الصف الأول - الصف الثالث',
              Colors.orange,
              Icons.school,
              () {
                Navigator.pop(context);
                _startQuiz(context, 'إعدادي');
              },
            ),
            const SizedBox(height: 10),
            _buildLevelCard(
              context,
              'المرحلة الثانوية',
              'الصف الأول - الصف الثالث + البلاغة',
              Colors.red,
              Icons.cast_for_education,
              () {
                Navigator.pop(context);
                _startQuiz(context, 'ثانوي');
              },
            ),
          ],
        ),
      ),
    );
  }

  // ✅ يفتح QuizScreen
  void _startQuiz(BuildContext context, String level) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(
          level: level,
          grade: 1,
        ),
      ),
    );
  }

  Widget _buildLevelCard(BuildContext context, String title, String subtitle,
      Color color, IconData icon, VoidCallback onTap) {
    return Card(
      color: const Color(0xFF2A2A2A),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: color.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  // ✅ الدروس - بدون const
  void _showLessonsDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LessonsScreen()),
    );
  }

  void _showLeaderboardDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'لوحة المتصدرين',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFFD4AF37)),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.emoji_events, size: 60, color: Colors.amber),
            SizedBox(height: 20),
            Text(
              'قريباً: سيتم إضافة نظام النقاط والمتصدرين',
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'حسناً',
              style: TextStyle(color: Color(0xFFD4AF37)),
            ),
          ),
        ],
      ),
    );
  }

  void _showLiveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'بث مباشر',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFFD4AF37)),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.videocam, size: 60, color: Colors.red),
            SizedBox(height: 20),
            Text(
              'قريباً: سيتم إضافة بث مباشر للدروس',
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'حسناً',
              style: TextStyle(color: Color(0xFFD4AF37)),
            ),
          ),
        ],
      ),
    );
  }

  void _showAiTutorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'أستاذ النحو الذكي',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFFD4AF37)),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.smart_toy, size: 60, color: Colors.purple),
            SizedBox(height: 20),
            Text(
              'قريباً: سيتم إضافة مساعد ذكي للإجابة على أسئلتك النحوية',
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'حسناً',
              style: TextStyle(color: Color(0xFFD4AF37)),
            ),
          ),
        ],
      ),
    );
  }

  void _showTeacherDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'بوابة المعلم',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFFD4AF37)),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_outline, size: 60, color: Colors.brown),
            SizedBox(height: 20),
            Text(
              'قريباً: سيتم إضافة خاصية إنشاء امتحانات للمعلمين',
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              '• إنشاء امتحان مخصص\n• اختيار عدد الأسئلة\n• تعديل الأسئلة\n• طباعة الامتحان',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'حسناً',
              style: TextStyle(color: Color(0xFFD4AF37)),
            ),
          ),
        ],
      ),
    );
  }

  void _showSettingsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0D0D0D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'الإعدادات',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD4AF37),
              ),
            ),
            const SizedBox(height: 20),

            ListTile(
              leading: const Icon(Icons.person, color: Colors.white),
              title: const Text(
                'إعدادات الحساب',
                style: TextStyle(fontFamily: 'Cairo', color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => const AccountSettingsDialog(),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.privacy_tip, color: Colors.white),
              title: const Text(
                'الخصوصية',
                style: TextStyle(fontFamily: 'Cairo', color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => const PrivacySettingsDialog(),
                );
              },
            ),

            const Divider(color: Colors.white24),

            // ✅ تسجيل الخروج
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'تسجيل الخروج',
                style: TextStyle(fontFamily: 'Cairo', color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                getIt<AuthBloc>().add(SignOutRequested());
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientButton({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      color: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: colors[0].withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: Colors.white),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}