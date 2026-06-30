import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/bloc/theme_bloc.dart';

class QuizTimer extends StatefulWidget {
  final int seconds;
  final VoidCallback onTimeUp;

  const QuizTimer({
    super.key,
    required this.seconds,
    required this.onTimeUp,
  });

  @override
  State<QuizTimer> createState() => _QuizTimerState();
}

class _QuizTimerState extends State<QuizTimer> {
  late Timer _timer;
  late int _remaining;
  bool _isLow = false;

  @override
  void initState() {
    super.initState();
    _remaining = widget.seconds;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      
      setState(() {
        if (_remaining > 0) {
          _remaining--;
          _isLow = _remaining < 10;
        } else {
          _timer.cancel();
          widget.onTimeUp();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.read<ThemeBloc>().state.isDarkMode;
    final minutes = _remaining ~/ 60;
    final seconds = _remaining % 60;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _isLow 
            ? Colors.red.withOpacity(0.2)
            : isDark 
                ? const Color(0xFFD4AF37).withOpacity(0.2)
                : const Color(0xFF1E3A5F).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isLow 
              ? Colors.red
              : isDark 
                  ? const Color(0xFFD4AF37)
                  : const Color(0xFF1E3A5F),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            color: _isLow 
                ? Colors.red
                : isDark 
                    ? const Color(0xFFD4AF37)
                    : const Color(0xFF1E3A5F),
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
            style: TextStyle(
              color: _isLow 
                  ? Colors.red
                  : isDark 
                      ? const Color(0xFFD4AF37)
                      : const Color(0xFF1E3A5F),
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }
}