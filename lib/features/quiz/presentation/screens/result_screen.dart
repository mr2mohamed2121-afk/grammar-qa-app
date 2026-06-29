import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ResultScreen extends StatefulWidget {
  final int score;
  final int totalQuestions;
  final List<Map<String, dynamic>> userAnswers;
  final String category;
  final String level;

  const ResultScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.userAnswers,
    required this.category,
    required this.level,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _saving = false;
  bool _saved = false;

  double get _percentage => (widget.score / (widget.totalQuestions * 10)) * 100;
  bool get _passed => _percentage >= 60;
  String get _grade {
    if (_percentage >= 90) return 'ممتاز';
    if (_percentage >= 80) return 'جيد جداً';
    if (_percentage >= 70) return 'جيد';
    if (_percentage >= 60) return 'مقبول';
    return 'يحتاج مراجعة';
  }

  Color get _gradeColor {
    if (_percentage >= 90) return Colors.green;
    if (_percentage >= 80) return const Color(0xFF66BB6A);
    if (_percentage >= 70) return Colors.orange;
    if (_percentage >= 60) return Colors.amber;
    return Colors.red;
  }

  @override
  void initState() {
    super.initState();
    _saveResult();
  }

  Future<void> _saveResult() async {
    setState(() => _saving = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('quiz_results').add({
          'userId': user.uid,
          'userEmail': user.email,
          'score': widget.score,
          'totalQuestions': widget.totalQuestions,
          'percentage': _percentage,
          'category': widget.category,
          'level': widget.level,
          'passed': _passed,
          'grade': _grade,
          'answers': widget.userAnswers,
          'completedAt': Timestamp.now(),
        });
      }
      setState(() => _saved = true);
    } catch (e) {
      debugPrint('Error saving result: $e');
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Header with back button
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFFD4AF37)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'نتيجة الاختبار',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 30),

              // Result Circle
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: _passed
                        ? [const Color(0xFFD4AF37), const Color(0xFF8B6914)]
                        : [Colors.red.shade400, Colors.red.shade800],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (_passed ? const Color(0xFFD4AF37) : Colors.red)
                          .withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${_percentage.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    Text(
                      _grade,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Score Details Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF16213E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    _buildScoreRow(
                      'النقاط',
                      '${widget.score} / ${widget.totalQuestions * 10}',
                      Icons.star,
                      const Color(0xFFD4AF37),
                    ),
                    const Divider(color: Colors.white24, height: 24),
                    _buildScoreRow(
                      'الإجابات الصحيحة',
                      '${widget.score ~/ 10} / ${widget.totalQuestions}',
                      Icons.check_circle,
                      Colors.green,
                    ),
                    const Divider(color: Colors.white24, height: 24),
                    _buildScoreRow(
                      'الإجابات الخاطئة',
                      '${widget.totalQuestions - (widget.score ~/ 10)}',
                      Icons.cancel,
                      Colors.red,
                    ),
                    const Divider(color: Colors.white24, height: 24),
                    _buildScoreRow(
                      'التصنيف',
                      widget.category,
                      Icons.category,
                      Colors.blue,
                    ),
                    const Divider(color: Colors.white24, height: 24),
                    _buildScoreRow(
                      'المستوى',
                      widget.level,
                      Icons.trending_up,
                      Colors.purple,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Pass/Fail Message
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _passed
                      ? Colors.green.withOpacity(0.15)
                      : Colors.red.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _passed ? Colors.green : Colors.red,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _passed ? Icons.emoji_events : Icons.school,
                      color: _passed ? Colors.green : Colors.orange,
                      size: 40,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        _passed
                            ? '🎉 مبروك! لقد اجتزت الاختبار بنجاح!'
                            : '💪 لا تيأس! راجع الدروس وحاول مرة أخرى.',
                        style: TextStyle(
                          color: _passed ? Colors.green : Colors.orange,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Saving indicator
              if (_saving)
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Color(0xFFD4AF37)),
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'جاري حفظ النتيجة...',
                      style: TextStyle(
                        color: Colors.white70,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                )
              else if (_saved)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'تم حفظ النتيجة بنجاح',
                      style: TextStyle(
                        color: Colors.green.withOpacity(0.8),
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 30),

              // Review Answers Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showReviewDialog(),
                  icon: const Icon(Icons.replay),
                  label: const Text(
                    'مراجعة الإجابات',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F3460),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Home Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  icon: const Icon(Icons.home),
                  label: const Text(
                    'العودة للرئيسية',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Date
              Text(
                'تم الإنجاز: ${DateFormat('yyyy/MM/dd - HH:mm').format(DateTime.now())}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreRow(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontFamily: 'Cairo',
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
          ),
        ),
      ],
    );
  }

  void _showReviewDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'مراجعة الإجابات',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: widget.userAnswers.length,
                    itemBuilder: (context, index) {
                      final answer = widget.userAnswers[index];
                      final isCorrect = answer['isCorrect'] as bool? ?? false;
                      final userAnswer = answer['userAnswer'] as String? ?? '';
                      final correctAnswer = answer['correctAnswer'] as String? ?? '';
                      final question = answer['question'] as String? ?? '';
                      final explanation = answer['explanation'] as String? ?? '';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF16213E),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isCorrect ? Colors.green : Colors.red,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isCorrect
                                        ? Colors.green.withOpacity(0.2)
                                        : Colors.red.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'س ${index + 1}',
                                    style: TextStyle(
                                      color: isCorrect ? Colors.green : Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  isCorrect ? Icons.check_circle : Icons.cancel,
                                  color: isCorrect ? Colors.green : Colors.red,
                                  size: 20,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              question,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Cairo',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'إجابتك: $userAnswer',
                              style: TextStyle(
                                color: isCorrect ? Colors.green : Colors.red,
                                fontFamily: 'Cairo',
                              ),
                            ),
                            if (!isCorrect) ...[
                              const SizedBox(height: 4),
                              Text(
                                'الإجابة الصحيحة: $correctAnswer',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ],
                            if (explanation.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD4AF37).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '💡 $explanation',
                                  style: const TextStyle(
                                    color: Color(0xFFD4AF37),
                                    fontSize: 12,
                                    fontFamily: 'Cairo',
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}