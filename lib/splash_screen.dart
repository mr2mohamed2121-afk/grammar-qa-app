import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
import 'package:lottie/lottie.dart';
import 'package:just_audio/just_audio.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const SplashScreen({super.key, required this.onComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Controllers
  late AnimationController _mainController;
  late AnimationController _bookController;
  late AnimationController _pulseController;
  late AnimationController _particleController;
  late AnimationController _nameController;
  late ConfettiController _confettiController;

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _nameFadeAnimation;
  late Animation<double> _nameScaleAnimation;
  late Animation<double> _nameGlowAnimation;

  // State
  double _progress = 0.0;
  String _loadingText = 'جاري التحميل';
  int _dotCount = 0;
  bool _isExiting = false;
  bool _showCompletion = false;
  bool _lottieLoaded = false;

  // Timers
  Timer? _progressTimer;
  Timer? _textTimer;

  // Audio
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _audioAvailable = false;

  // Particles
  final List<Particle> _particles = [];
  final Random _random = Random();
  Timer? _particleTimer;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startLoadingSequence();
    _startParticleGenerator();
    _loadCompletionSound();
  }

  void _initAnimations() {
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );

    _bookController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _nameController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.2, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.3, curve: Curves.elasticOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.1, 0.4, curve: Curves.easeOutCubic),
      ),
    );

    _nameFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _nameController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _nameScaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _nameController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _nameGlowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _nameController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
      ),
    );

    _mainController.forward();

    // Start name animation after 1 second
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) _nameController.forward();
    });
  }

  void _startLoadingSequence() {
    _progressTimer = Timer.periodic(const Duration(milliseconds: 120), (timer) {
      if (!mounted) return;
      setState(() {
        _progress += 0.01;
        if (_progress >= 1.0) {
          _progress = 1.0;
          timer.cancel();
          _completeLoading();
        }
      });
    });

    _textTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!mounted) return;
      setState(() {
        _dotCount = (_dotCount + 1) % 4;
        _loadingText = 'جاري التحميل${"." * _dotCount}';
      });
    });
  }

  void _startParticleGenerator() {
    _particleTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (!mounted) return;
      if (_particles.length < 30) {
        setState(() {
          _particles.add(Particle(
            x: _random.nextDouble() * 400 - 200,
            y: _random.nextDouble() * 400 - 200,
            size: _random.nextDouble() * 6 + 2,
            speed: _random.nextDouble() * 2 + 1,
            opacity: _random.nextDouble() * 0.6 + 0.2,
            color: [
              const Color(0xFFD4AF37),
              const Color(0xFFE94560),
              const Color(0xFF0F3460),
              const Color(0xFFFFFFFF),
            ][_random.nextInt(4)],
          ));
        });
      }
    });
  }

  Future<void> _loadCompletionSound() async {
    try {
      // For Flutter Web, use root asset path (Flutter adds "assets/" prefix automatically)
      await _audioPlayer.setAsset('audio/success.mp3');
      _audioAvailable = true;
    } catch (e) {
      debugPrint('Audio not available: $e');
      _audioAvailable = false;
    }
  }

  void _completeLoading() {
    _textTimer?.cancel();
    _particleTimer?.cancel();

    setState(() {
      _showCompletion = true;
    });

    _playCompletionSound();
    _confettiController.play();

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isExiting = true;
        });

        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            widget.onComplete();
          }
        });
      }
    });
  }

  Future<void> _playCompletionSound() async {
    if (!_audioAvailable) return;
    try {
      await _audioPlayer.seek(Duration.zero);
      await _audioPlayer.play();
    } catch (e) {
      debugPrint('Could not play sound: $e');
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _bookController.dispose();
    _pulseController.dispose();
    _particleController.dispose();
    _nameController.dispose();
    _confettiController.dispose();
    _progressTimer?.cancel();
    _textTimer?.cancel();
    _particleTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF0A0A1A),
                  const Color(0xFF1A1A2E),
                  const Color(0xFF16213E),
                  const Color(0xFF0F3460),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0.0, 0.3, 0.7, 1.0],
              ),
            ),
          ),

          // Particles
          ..._particles.map((particle) => _buildParticle(particle)),

          // Confetti
          _buildConfettiLayer(),

          // Main content
          AnimatedBuilder(
            animation: _mainController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _isExiting 
                  ? Tween<double>(begin: 1.0, end: 0.0).animate(
                      CurvedAnimation(
                        parent: _mainController,
                        curve: const Interval(0.92, 1.0, curve: Curves.easeIn),
                      ),
                    )
                  : _fadeAnimation,
                child: Transform.scale(
                  scale: _isExiting
                    ? Tween<double>(begin: 1.0, end: 1.5).animate(
                        CurvedAnimation(
                          parent: _mainController,
                          curve: const Interval(0.92, 1.0, curve: Curves.easeIn),
                        ),
                      ).value
                    : _scaleAnimation.value,
                  child: Transform.translate(
                    offset: Offset(0, _slideAnimation.value),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Lottie Book Animation
                          _buildAnimatedIcon(),

                          const SizedBox(height: 30),

                          // App Title
                          _buildShimmerTitle(),

                          const SizedBox(height: 8),

                          // Subtitle
                          _buildSubtitle(),

                          const SizedBox(height: 40),

                          // Teacher Name - PROMINENTLY DISPLAYED
                          _buildTeacherName(),

                          const SizedBox(height: 50),

                          // Progress or Completion indicator
                          _showCompletion 
                            ? _buildCompletionIndicator()
                            : _buildProgressIndicator(),

                          const SizedBox(height: 20),

                          // Loading or completion text
                          _showCompletion
                            ? _buildCompletionText()
                            : _buildLoadingText(),

                          const SizedBox(height: 30),

                          // Feature badges
                          _buildFeatureBadges(),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // Version at bottom
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'الإصدار 1.0.0',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 12,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedIcon() {
    return AnimatedBuilder(
      animation: Listenable.merge([_bookController, _pulseController]),
      builder: (context, child) {
        final bounce = sin(_bookController.value * pi) * 10;
        final pulse = 1.0 + (_pulseController.value * 0.1);

        return Transform.translate(
          offset: Offset(0, -bounce),
          child: Transform.scale(
            scale: pulse,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFD4AF37).withValues(alpha: 0.3),
                    const Color(0xFFD4AF37).withValues(alpha: 0.0),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD4AF37).withValues(
                      alpha: 0.3 * _pulseController.value,
                    ),
                    blurRadius: 60,
                    spreadRadius: 20,
                  ),
                ],
              ),
              child: _buildLottieOrIcon(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLottieOrIcon() {
    // For Flutter Web, use root asset path (Flutter adds "assets/" prefix automatically)
    return Lottie.asset(
      'animations/book.json',
      width: 100,
      height: 100,
      fit: BoxFit.contain,
      repeat: true,
      animate: true,
      onLoaded: (composition) {
        setState(() => _lottieLoaded = true);
      },
      errorBuilder: (context, error, stackTrace) {
        return const Icon(
          Icons.menu_book_rounded,
          size: 70,
          color: Color(0xFFD4AF37),
        );
      },
    );
  }

  Widget _buildShimmerTitle() {
    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          colors: [
            const Color(0xFFD4AF37),
            const Color(0xFFFFFFFF),
            const Color(0xFFD4AF37),
          ],
          stops: const [0.0, 0.5, 1.0],
          begin: Alignment(-1.0 + (_progress * 2), 0),
          end: Alignment(1.0 + (_progress * 2), 0),
        ).createShader(bounds);
      },
      child: const Text(
        'أستاذ النحو العربي',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontFamily: 'Cairo',
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      'تعلم قواعد اللغة العربية بإتقان',
      style: TextStyle(
        fontSize: 14,
        color: Colors.white.withValues(alpha: 0.7),
        fontFamily: 'Cairo',
      ),
    );
  }

  // PROMINENT TEACHER NAME DISPLAY
  Widget _buildTeacherName() {
    return AnimatedBuilder(
      animation: Listenable.merge([_nameController, _pulseController]),
      builder: (context, child) {
        final glowIntensity = _nameGlowAnimation.value;

        return FadeTransition(
          opacity: _nameFadeAnimation,
          child: Transform.scale(
            scale: _nameScaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFD4AF37).withValues(alpha: 0.2 * glowIntensity),
                    const Color(0xFFE94560).withValues(alpha: 0.1 * glowIntensity),
                    const Color(0xFFD4AF37).withValues(alpha: 0.2 * glowIntensity),
                  ],
                ),
                border: Border.all(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.5 + (0.3 * _pulseController.value)),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.3 * glowIntensity),
                    blurRadius: 20 + (10 * _pulseController.value),
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Label above name
                  Text(
                    'إعداد',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.7),
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Teacher name - MAIN FOCUS
                  ShaderMask(
                    shaderCallback: (bounds) {
                      return LinearGradient(
                        colors: [
                          const Color(0xFFD4AF37),
                          const Color(0xFFFFFFFF),
                          const Color(0xFFD4AF37),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                        begin: Alignment(-1.0 + (_nameGlowAnimation.value * 2), 0),
                        end: Alignment(1.0 + (_nameGlowAnimation.value * 2), 0),
                      ).createShader(bounds);
                    },
                    child: const Text(
                      'مستر محمد أحمد الوهيدي',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Cairo',
                        letterSpacing: 1.2,
                        shadows: [
                          Shadow(
                            color: Color(0xFFD4AF37),
                            blurRadius: 10,
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Title below name
                  Text(
                    'معلم اللغة العربية',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.6),
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      width: 280,
      height: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: Colors.white.withValues(alpha: 0.1),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: 280 * _progress,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFD4AF37),
                  Color(0xFFE94560),
                  Color(0xFFD4AF37),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          Positioned(
            left: (280 * _progress) - 30,
            top: 0,
            bottom: 0,
            child: Container(
              width: 30,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.white.withValues(alpha: 0.6),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionIndicator() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      width: 280,
      height: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF00C853),
            Color(0xFFD4AF37),
            Color(0xFF00C853),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00C853).withValues(alpha: 0.6),
            blurRadius: 15,
            spreadRadius: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(
              const Color(0xFFD4AF37).withValues(alpha: 0.8),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          _loadingText,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.8),
            fontFamily: 'Cairo',
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${(_progress * 100).toInt()}%',
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFFD4AF37),
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCompletionText() {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 500),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle,
            color: Color(0xFF00C853),
            size: 24,
          ),
          const SizedBox(width: 10),
          const Text(
            'جاهز للانطلاق!',
            style: TextStyle(
              fontSize: 18,
              color: Color(0xFF00C853),
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureBadges() {
    final features = [
      {'icon': Icons.quiz, 'label': 'اختبارات'},
      {'icon': Icons.school, 'label': 'دروس'},
      {'icon': Icons.emoji_events, 'label': 'شهادات'},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: features.asMap().entries.map((entry) {
        final index = entry.key;
        final feature = entry.value;
        final delay = index * 0.15;

        return AnimatedOpacity(
          opacity: _progress > delay ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 500),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white.withValues(alpha: 0.05),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  feature['icon'] as IconData,
                  size: 16,
                  color: const Color(0xFFD4AF37),
                ),
                const SizedBox(width: 6),
                Text(
                  feature['label'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.8),
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildConfettiLayer() {
    return Stack(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: -pi / 3,
            emissionFrequency: 0.05,
            numberOfParticles: 30,
            maxBlastForce: 30,
            minBlastForce: 15,
            gravity: 0.2,
            shouldLoop: false,
            colors: const [
              Color(0xFFD4AF37),
              Color(0xFFE94560),
              Color(0xFF0F3460),
              Color(0xFFFFFFFF),
              Color(0xFF00D9FF),
              Color(0xFFFF6B9D),
            ],
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: -2 * pi / 3,
            emissionFrequency: 0.05,
            numberOfParticles: 30,
            maxBlastForce: 30,
            minBlastForce: 15,
            gravity: 0.2,
            shouldLoop: false,
            colors: const [
              Color(0xFFD4AF37),
              Color(0xFFE94560),
              Color(0xFF0F3460),
              Color(0xFFFFFFFF),
              Color(0xFF00D9FF),
              Color(0xFFFF6B9D),
            ],
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: pi / 2,
            emissionFrequency: 0.02,
            numberOfParticles: 50,
            maxBlastForce: 25,
            minBlastForce: 10,
            gravity: 0.15,
            shouldLoop: false,
            colors: const [
              Color(0xFFD4AF37),
              Color(0xFFE94560),
              Color(0xFF0F3460),
              Color(0xFFFFFFFF),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildParticle(Particle particle) {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        final time = _particleController.value;
        final x = particle.x + sin(time * pi * 2 + particle.speed) * 20;
        final y = particle.y - (time * 100 * particle.speed);
        final opacity = particle.opacity * (1 - time);

        if (y < -200) {
          Future.microtask(() {
            if (mounted) {
              setState(() {
                _particles.remove(particle);
              });
            }
          });
        }

        return Positioned(
          left: MediaQuery.of(context).size.width / 2 + x,
          top: MediaQuery.of(context).size.height / 2 + y,
          child: Opacity(
            opacity: opacity,
            child: Container(
              width: particle.size,
              height: particle.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: particle.color,
                boxShadow: [
                  BoxShadow(
                    color: particle.color.withValues(alpha: 0.5),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class Particle {
  double x;
  double y;
  final double size;
  final double speed;
  double opacity;
  final Color color;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.color,
  });
}