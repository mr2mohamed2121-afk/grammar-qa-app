import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math' show cos, sin, pi;

import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/auth/presentation/screens/forgot_password_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/admin/presentation/screens/admin_dashboard.dart';
import 'injection.dart';

// ==================== PATTERN ISLAMI ====================
class ArabicPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4AF37).withOpacity(0.06)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = const Color(0xFFD4AF37).withOpacity(0.02)
      ..style = PaintingStyle.fill;

    const spacing = 55.0;
    
    for (double x = -spacing; x < size.width + spacing; x += spacing) {
      for (double y = -spacing; y < size.height + spacing; y += spacing) {
        _drawIslamicStar(canvas, Offset(x, y), 22, paint, fillPaint);
      }
    }
  }

  void _drawIslamicStar(
    Canvas canvas, 
    Offset center, 
    double radius, 
    Paint paint,
    Paint fillPaint,
  ) {
    final path = Path();
    const points = 8;
    
    for (int i = 0; i < points * 2; i++) {
      final angle = (i * 22.5 - 90) * pi / 180;
      final r = i % 2 == 0 ? radius : radius * 0.38;
      final x = center.dx + r * cos(angle);
      final y = center.dy + r * sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, paint);
    
    // دائرة داخلية صغيرة
    canvas.drawCircle(center, radius * 0.12, paint);
    
    // خطوط متصالبة
    final crossPaint = Paint()
      ..color = const Color(0xFFD4AF37).withOpacity(0.04)
      ..strokeWidth = 0.8;
    
    canvas.drawLine(
      Offset(center.dx - radius * 0.6, center.dy),
      Offset(center.dx + radius * 0.6, center.dy),
      crossPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - radius * 0.6),
      Offset(center.dx, center.dy + radius * 0.6),
      crossPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ==================== APP ====================
class GrammarQAApp extends StatelessWidget {
  const GrammarQAApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value: getIt<AuthBloc>()..add(AppStarted()),
        ),
      ],
      child: MaterialApp(
        title: 'أستاذ النحو العربي',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.amber,
          fontFamily: 'Cairo',
          useMaterial3: true,
        ),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ar', 'EG'),
          Locale('en', 'US'),
        ],
        locale: const Locale('ar', 'EG'),
        home: const SplashScreenWrapper(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/forgot-password': (context) => const ForgotPasswordScreen(),
          '/home': (context) => const HomeScreen(),
        },
      ),
    );
  }
}

// ==================== SPLASH SCREEN ====================
class SplashScreenWrapper extends StatefulWidget {
  const SplashScreenWrapper({super.key});

  @override
  State<SplashScreenWrapper> createState() => _SplashScreenWrapperState();
}

class _SplashScreenWrapperState extends State<SplashScreenWrapper>
    with SingleTickerProviderStateMixin {
  bool _showSplash = true;
  bool? _isAdmin;
  bool _isLoading = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _animationController.forward();

    Future.delayed(const Duration(seconds: 12), () {
      if (mounted) {
        setState(() {
          _showSplash = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkAdminStatus() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        setState(() {
          _isAdmin = userDoc.data()?['isAdmin'] ?? false;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isAdmin = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isAdmin = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0A0A0A),
                Color(0xFF12121E),
                Color(0xFF0A0A0A),
              ],
            ),
          ),
          child: Stack(
            children: [
              // ✅ Pattern إسلامي هندسي
              CustomPaint(
                size: Size.infinite,
                painter: ArabicPatternPainter(),
              ),
              
              // ✅ Gradient overlay ذهبي خفيف من النص
              Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.3),
                    radius: 0.7,
                    colors: [
                      const Color(0xFFD4AF37).withOpacity(0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              
              // المحتوى
              Center(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ✅ Logo ذهبي مع glow
                        Transform.scale(
                          scale: _scaleAnimation.value,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const RadialGradient(
                                  colors: [
                                    Color(0xFFD4AF37),
                                    Color(0xFF8B6914),
                                    Colors.transparent,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFD4AF37).withOpacity(0.4),
                                    blurRadius: 60,
                                    spreadRadius: 20,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.menu_book,
                                size: 80,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),

                        // ✅ Title ذهبي
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: const Text(
                            'أستاذ النحو العربي',
                            style: TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFD4AF37),
                              letterSpacing: 2,
                              shadows: [
                                Shadow(
                                  color: Color(0xFFD4AF37),
                                  blurRadius: 30,
                                  offset: Offset(0, 0),
                                ),
                                Shadow(
                                  color: Colors.black,
                                  blurRadius: 10,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),

                        // ✅ Decorative line ذهبية
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Container(
                            width: 200,
                            height: 3,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Color(0xFFD4AF37),
                                  Color(0xFFF4E4BC),
                                  Color(0xFFD4AF37),
                                  Colors.transparent,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(2),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFD4AF37).withOpacity(0.6),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ✅ Subtitle
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: const Text(
                            'تعلم النحو والصرف والبلاغة',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white70,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 50),

                        // ✅ Supervisor name
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 20,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: const Color(0xFFD4AF37).withOpacity(0.6),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFD4AF37).withOpacity(0.2),
                                  blurRadius: 40,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const Column(
                              children: [
                                Text(
                                  'إشراف',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFFD4AF37),
                                    letterSpacing: 3,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'أستاذ محمد أحمد الوهيدي',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 60),

                        // ✅ Loading
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Column(
                            children: [
                              SizedBox(
                                width: 220,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    backgroundColor: Colors.white.withOpacity(0.1),
                                    valueColor: const AlwaysStoppedAnimation<Color>(
                                      Color(0xFFD4AF37),
                                    ),
                                    minHeight: 6,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 25),
                              const Text(
                                'جاري التحميل...',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white54,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (state is AuthAuthenticated) {
            if (_isAdmin == true || state.isAdmin) {
              return const AdminDashboard();
            }
            return const HomeScreen();
          }
          if (state is AuthUnauthenticated) {
            return const LoginScreen();
          }
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }
}