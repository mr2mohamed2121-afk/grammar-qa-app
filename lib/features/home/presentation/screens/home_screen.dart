import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../quiz/presentation/screens/quiz_screen.dart';
import '../../../admin/presentation/screens/admin_dashboard.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAdmin();
  }

  void _checkAdmin() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _isAdmin = user.email == 'mr2mohamed2121@gmail.com';
      });
    }
  }

  void _startQuiz(String level, int grade) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(level: level, grade: grade),
      ),
    );
  }

  void _goToAdmin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AdminDashboard()),
    );
  }

  void _goToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
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
        backgroundColor: const Color(0xFF1E3A5F),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white70),
            onPressed: _goToSettings,
            tooltip: 'الإعدادات',
          ),
          if (_isAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings, color: Color(0xFFD4AF37)),
              onPressed: _goToAdmin,
              tooltip: 'لوحة التحكم',
            ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E3A5F), Color(0xFF0F3460)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.menu_book,
                      size: 60,
                      color: Color(0xFFD4AF37),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'أهلاً بك في تطبيق أسئلة النحو العربي',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'اختبر معلوماتك في النحو العربي',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              _buildMenuButton(
                'اختبر نفسك',
                Icons.quiz,
                const Color(0xFF1A1A2E),
                () => _showLevelDialog(),
              ),
              const SizedBox(height: 16),

              if (_isAdmin)
                _buildMenuButton(
                  'إضافة أسئلة',
                  Icons.add_circle,
                  Colors.red.shade700,
                  _goToAdmin,
                ),
              const SizedBox(height: 16),

              _buildMenuButton(
                'لوحة المتصدرين',
                Icons.emoji_events,
                Colors.orange.shade700,
                () => _showComingSoon('لوحة المتصدرين'),
              ),
              const SizedBox(height: 16),

              _buildMenuButton(
                'الدروس',
                Icons.school,
                Colors.blue.shade700,
                () => _showComingSoon('الدروس'),
              ),
              const SizedBox(height: 16),

              _buildMenuButton(
                'بث مباشر',
                Icons.live_tv,
                Colors.purple.shade700,
                () => _showComingSoon('البث المباشر'),
              ),
              const SizedBox(height: 16),

              _buildMenuButton(
                'أستاذ النحو الذكي',
                Icons.psychology,
                Colors.teal.shade700,
                () => _showComingSoon('أستاذ النحو الذكي'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.7)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 20),
          ],
        ),
      ),
    );
  }

  void _showLevelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        title: const Text(
          'اختر المرحلة',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLevelButton('ابتدائي', Colors.green, 1),
            const SizedBox(height: 12),
            _buildLevelButton('إعدادي', Colors.orange, 2),
            const SizedBox(height: 12),
            _buildLevelButton('ثانوي', Colors.red, 3),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelButton(String level, Color color, int grade) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        _startQuiz(level, grade);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color),
        ),
        child: Text(
          level,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
          ),
        ),
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$feature - قريباً!',
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
        backgroundColor: const Color(0xFF1E3A5F),
      ),
    );
  }
}