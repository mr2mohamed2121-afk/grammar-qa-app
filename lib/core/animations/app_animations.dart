import 'package:flutter/material.dart';

/// 8 أنواع Animations
class AppAnimations {
  
  // ==================== 1. Fade In ====================
  
  static Widget fadeIn({
    required Widget child,
    required Duration duration,
    Duration delay = Duration.zero,
    Curve curve = Curves.easeIn,
  }) {
    return _AnimatedWrapper(
      duration: duration,
      delay: delay,
      builder: (context, animation) {
        return FadeTransition(
          opacity: Tween<double>(begin: 0, end: 1).animate(
            CurvedAnimation(parent: animation, curve: curve),
          ),
          child: child,
        );
      },
    );
  }

  // ==================== 2. Slide Up ====================
  
  static Widget slideUp({
    required Widget child,
    required Duration duration,
    Duration delay = Duration.zero,
    double offset = 50,
    Curve curve = Curves.easeOut,
  }) {
    return _AnimatedWrapper(
      duration: duration,
      delay: delay,
      builder: (context, animation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: Offset(0, offset / 100),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: animation, curve: curve),
          ),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0, end: 1).animate(
              CurvedAnimation(parent: animation, curve: curve),
            ),
            child: child,
          ),
        );
      },
    );
  }

  // ==================== 3. Scale In ====================
  
  static Widget scaleIn({
    required Widget child,
    required Duration duration,
    Duration delay = Duration.zero,
    double beginScale = 0.5,
    Curve curve = Curves.elasticOut,
  }) {
    return _AnimatedWrapper(
      duration: duration,
      delay: delay,
      builder: (context, animation) {
        return ScaleTransition(
          scale: Tween<double>(begin: beginScale, end: 1).animate(
            CurvedAnimation(parent: animation, curve: curve),
          ),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0, end: 1).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeIn),
            ),
            child: child,
          ),
        );
      },
    );
  }

  // ==================== 4. Slide In From Right ====================
  
  static Widget slideInRight({
    required Widget child,
    required Duration duration,
    Duration delay = Duration.zero,
    Curve curve = Curves.easeOut,
  }) {
    return _AnimatedWrapper(
      duration: duration,
      delay: delay,
      builder: (context, animation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: animation, curve: curve),
          ),
          child: child,
        );
      },
    );
  }

  // ==================== 5. Slide In From Left ====================
  
  static Widget slideInLeft({
    required Widget child,
    required Duration duration,
    Duration delay = Duration.zero,
    Curve curve = Curves.easeOut,
  }) {
    return _AnimatedWrapper(
      duration: duration,
      delay: delay,
      builder: (context, animation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1, 0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: animation, curve: curve),
          ),
          child: child,
        );
      },
    );
  }

  // ==================== 6. Bounce In ====================
  
  static Widget bounceIn({
    required Widget child,
    required Duration duration,
    Duration delay = Duration.zero,
  }) {
    return _AnimatedWrapper(
      duration: duration,
      delay: delay,
      builder: (context, animation) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0, end: 1).animate(
            CurvedAnimation(parent: animation, curve: Curves.bounceOut),
          ),
          child: child,
        );
      },
    );
  }

  // ==================== 7. Flip Card ====================
  
  static Widget flipCard({
    required Widget front,
    required Widget back,
    required bool isFront,
    required Duration duration,
  }) {
    return AnimatedSwitcher(
      duration: duration,
      transitionBuilder: (child, animation) {
        final rotateAnim = Tween<double>(begin: 0, end: 1).animate(animation);
        return AnimatedBuilder(
          animation: rotateAnim,
          builder: (context, child) {
            final angle = rotateAnim.value * 3.14159;
            final isFrontVisible = rotateAnim.value < 0.5;
            return Transform(
              transform: Matrix4.rotationY(angle),
              alignment: Alignment.center,
              child: isFrontVisible ? front : back,
            );
          },
        );
      },
      child: isFront ? front : back,
    );
  }

  // ==================== 8. Staggered List ====================
  
  static Widget staggeredList({
    required List<Widget> children,
    required Duration itemDuration,
    Duration staggerDelay = const Duration(milliseconds: 100),
    Axis direction = Axis.vertical,
  }) {
    return _StaggeredList(
      children: children,
      itemDuration: itemDuration,
      staggerDelay: staggerDelay,
      direction: direction,
    );
  }

  // ==================== Pulse Animation ====================
  
  static Widget pulse({
    required Widget child,
    required Duration duration,
  }) {
    return _PulseAnimation(
      duration: duration,
      child: child,
    );
  }

  // ==================== Shimmer Loading ====================
  
  static Widget shimmer({
    required Widget child,
    required Color baseColor,
    required Color highlightColor,
  }) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          colors: [baseColor, highlightColor, baseColor],
          stops: const [0.0, 0.5, 1.0],
          begin: const Alignment(-1.0, -0.5),
          end: const Alignment(1.0, 0.5),
          tileMode: TileMode.clamp,
        ).createShader(bounds);
      },
      child: child,
    );
  }
}

// ==================== Internal Widgets ====================

class _AnimatedWrapper extends StatefulWidget {
  final Duration duration;
  final Duration delay;
  final Widget Function(BuildContext, AnimationController) builder;

  const _AnimatedWrapper({
    required this.duration,
    required this.delay,
    required this.builder,
  });

  @override
  State<_AnimatedWrapper> createState() => _AnimatedWrapperState();
}

class _AnimatedWrapperState extends State<_AnimatedWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => widget.builder(context, _controller),
    );
  }
}

class _StaggeredList extends StatefulWidget {
  final List<Widget> children;
  final Duration itemDuration;
  final Duration staggerDelay;
  final Axis direction;

  const _StaggeredList({
    required this.children,
    required this.itemDuration,
    required this.staggerDelay,
    required this.direction,
  });

  @override
  State<_StaggeredList> createState() => _StaggeredListState();
}

class _StaggeredListState extends State<_StaggeredList>
    with TickerProviderStateMixin {
  final List<AnimationController> _controllers = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.children.length; i++) {
      final controller = AnimationController(
        vsync: this,
        duration: widget.itemDuration,
      );
      _controllers.add(controller);
      
      Future.delayed(widget.staggerDelay * i, () {
        if (mounted) controller.forward();
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (int i = 0; i < widget.children.length; i++) {
      children.add(
        AnimatedBuilder(
          animation: _controllers[i],
          builder: (context, child) {
            return Opacity(
              opacity: _controllers[i].value,
              child: Transform.translate(
                offset: Offset(
                  0,
                  (1 - _controllers[i].value) * 30,
                ),
                child: widget.children[i],
              ),
            );
          },
        ),
      );
    }

    if (widget.direction == Axis.horizontal) {
      return Row(children: children);
    }
    return Column(children: children);
  }
}

class _PulseAnimation extends StatefulWidget {
  final Duration duration;
  final Widget child;

  const _PulseAnimation({
    required this.duration,
    required this.child,
  });

  @override
  State<_PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<_PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: 1 + (_controller.value * 0.1),
          child: widget.child,
        );
      },
    );
  }
}