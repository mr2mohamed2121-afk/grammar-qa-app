import 'package:flutter/material.dart';

class QuizScreen extends StatefulWidget {
  final String level;
  final int grade;

  const QuizScreen({
    super.key,
    required this.level,
    required this.grade,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestion = 0;
  int _score = 0;
  bool _answered = false;
  int? _selectedAnswer;

  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'ما هو الاسم الذي يدل على معنى في نفسه ولا يقترن بزمن؟',
      'answers': ['الفعل', 'الحرف', 'الاسم', 'الجملة'],
      'correct': 2,
      'explanation': 'الاسم: كلمة تدل على معنى في نفسها ولا تقترن بزمن',
    },
    {
      'question': 'أي من الكلمات التالية فعل ماضٍ؟',
      'answers': ['يكتب', 'اكتب', 'كتب', 'الكتابة'],
      'correct': 2,
      'explanation': 'كتب: فعل ماضٍ مبني على الفتح',
    },
    {
      'question': 'ما هو حرف الجر الذي يُجرّ الاسم بعده؟',
      'answers': ['في', 'ذهب', 'كتاب', 'الطالب'],
      'correct': 0,
      'explanation': 'في: حرف جر يُجرّ الاسم بعده',
    },
    {
      'question': 'المبتدأ في الجملة "الطالب مجتهد" هو:',
      'answers': ['مجتهد', 'الطالب', 'الجملة', 'لا يوجد'],
      'correct': 1,
      'explanation': 'الطالب: مبتدأ مرفوع وعلامة رفعه الضمة الظاهرة',
    },
    {
      'question': 'الخبر في الجملة "السماء صافية" هو:',
      'answers': ['السماء', 'صافية', 'الجملة', 'لا يوجد'],
      'correct': 1,
      'explanation': 'صافية: خبر مرفوع وعلامة رفعه الضمة الظاهرة',
    },
    {
      'question': 'أي من التالي فعل مضارع مرفوع؟',
      'answers': ['كتب', 'يكتب', 'اكتب', 'مكتوب'],
      'correct': 1,
      'explanation': 'يكتب: فعل مضارع مرفوع وعلامة رفعه الثبوت',
    },
    {
      'question': 'الفاعل في الجملة "ضرب محمد الكرة" هو:',
      'answers': ['ضرب', 'محمد', 'الكرة', 'الجملة'],
      'correct': 1,
      'explanation': 'محمد: فاعل مرفوع وعلامة رفعه الضمة الظاهرة',
    },
    {
      'question': 'المفعول به في الجملة "قرأ الطالب الدرس" هو:',
      'answers': ['قرأ', 'الطالب', 'الدرس', 'الجملة'],
      'correct': 2,
      'explanation': 'الدرس: مفعول به منصوب وعلامة نصبه الفتحة الظاهرة',
    },
    {
      'question': 'أي من التالي اسم مكان؟',
      'answers': ['مكتب', 'كتاب', 'كاتب', 'مكتوب'],
      'correct': 0,
      'explanation': 'مكتب: اسم مكان من الفعل كتب',
    },
    {
      'question': 'الاستعارة في "رأيت أسداً يقاتل" هي:',
      'answers': ['تصريحية', 'مكنية', 'تشبيه', 'مجاز'],
      'correct': 1,
      'explanation': 'مكنية: لأن المحلول (الشجاع) محذوف',
    },
    {
      'question': 'أي من التالي حرف جر؟',
      'answers': ['من', 'ذهب', 'كتاب', 'جلس'],
      'correct': 0,
      'explanation': 'من: حرف جر يُجرّ الاسم بعده',
    },
    {
      'question': 'الضمة علامة رفع للمفرد المذكر في:',
      'answers': ['الفعل الماضي', 'الاسم المفرد', 'المثنى', 'جمع المؤنث'],
      'correct': 1,
      'explanation': 'الاسم المفرد المذكر: يرفع بالضمة الظاهرة',
    },
    {
      'question': 'الفتحة علامة نصب للمفرد المذكر في:',
      'answers': ['الفاعل', 'المفعول به', 'المبتدأ', 'الخبر'],
      'correct': 1,
      'explanation': 'المفعول به: ينصب بالفتحة الظاهرة',
    },
    {
      'question': 'الكسرة علامة جر للمفرد المذكر في:',
      'answers': ['المفعول به', 'المضاف إليه', 'الفاعل', 'المبتدأ'],
      'correct': 1,
      'explanation': 'المضاف إليه: يجر بالكسرة الظاهرة',
    },
    {
      'question': 'كان وأخواتها ترفع:',
      'answers': ['المبتدأ', 'الخبر', 'الفاعل', 'المفعول به'],
      'correct': 1,
      'explanation': 'كان وأخواتها ترفع الاسم (الخبر) وتنصب الخبر (الاسم)',
    },
    {
      'question': 'إن وأخواتها تنصب:',
      'answers': ['الخبر', 'المبتدأ', 'الفاعل', 'المفعول به'],
      'correct': 1,
      'explanation': 'إن وأخواتها تنصب المبتدأ (الاسم) وترفع الخبر',
    },
    {
      'question': 'المفعول المطلق يكون من:',
      'answers': ['اسم', 'فعل', 'حرف', 'جملة'],
      'correct': 1,
      'explanation': 'المفعول المطلق: مصدر الفعل المستعمل في الجملة',
    },
    {
      'question': 'الحال يكون من:',
      'answers': ['اسم مفرد', 'جملة', 'مصدر', 'كل ما سبق'],
      'correct': 3,
      'explanation': 'الحال: يكون اسم مفرد أو جملة أو مصدر',
    },
    {
      'question': 'التمييز يكون من:',
      'answers': ['اسم مفرد', 'جملة', 'مصدر', 'كل ما سبق'],
      'correct': 0,
      'explanation': 'التمييز: يكون اسم مفرد منصوب دائماً',
    },
    {
      'question': 'أدوات الجزم هي:',
      'answers': ['لم، لما، لام الأمر، لام التعليل', 'لا، ما، لم، لن', 'إن، لو، إذا', 'هل، من، ما'],
      'correct': 0,
      'explanation': 'أدوات الجزم: لم، لما، لام الأمر، لام التعليل',
    },
    {
      'question': 'الفعل المضارع يجزم بحذف النون مع:',
      'answers': ['لم', 'لن', 'أن', 'كي'],
      'correct': 0,
      'explanation': 'لم: تجزم الفعل المضارع بحذف النون (مع التاء والألف والجماعة)',
    },
    {
      'question': 'الفعل المضارع ينصب بالنون مع:',
      'answers': ['لم', 'لن', 'أن', 'كل ما سبق'],
      'correct': 3,
      'explanation': 'أن، لن، كي: تنصب الفعل المضارع بالنون',
    },
    {
      'question': 'صيغة المبالغة على وزن فَعّال تدل على:',
      'answers': ['الكثرة', 'القلّة', 'الوسط', 'لا شيء'],
      'correct': 0,
      'explanation': 'فَعّال: تدل على كثرة الفعل (كَتّاب = يكتب كثيراً)',
    },
    {
      'question': 'التشبيه يتكون من:',
      'answers': ['ركنين', '3 أركان', '4 أركان', '5 أركان'],
      'correct': 2,
      'explanation': 'التشبيه: مشبه + مشبه به + أداة التشبيه + وجه الشبه',
    },
    {
      'question': 'الاستعارة التصريحية تكون:',
      'answers': ['محذوفة المحلول', 'مذكورة المحلول', 'لا فرق', 'كل ما سبق'],
      'correct': 1,
      'explanation': 'التصريحية: المشبه به (المحلول) مذكور صراحة',
    },
    {
      'question': 'الكناية عن صفة تكون:',
      'answers': ['بذكر الموصوف', 'بذكر ما يقارن الصفة', 'بذكر الصفة نفسها', 'لا شيء'],
      'correct': 1,
      'explanation': 'الكناية عن صفة: إطلاق لفظ على ما يقارنها (مثل: رأيتُ لهُ صُحبةً = صاحبٌ كريم)',
    },
    {
      'question': 'السجع هو:',
      'answers': ['تكرار الحرف', 'تسجيل آخر الكلام', 'تشبيه', 'استعارة'],
      'correct': 1,
      'explanation': 'السجع: تسجيل آخر الكلام (التشاكل في أواخر العبارات)',
    },
    {
      'question': 'الطباق هو:',
      'answers': ['تكرار الكلمة', 'الجمع بين ضدين', 'التشبيه', 'الاستعارة'],
      'correct': 1,
      'explanation': 'الطباق: الجمع بين ضدين في سياق واحد (الليل والنهار)',
    },
    {
      'question': 'الجناس هو:',
      'answers': ['تشابه اللفظ', 'تشابه المعنى', 'تشابه اللفظ والمعنى', 'لا شيء'],
      'correct': 0,
      'explanation': 'الجناس: تشابه اللفظ مع اختلاف المعنى (علم/عَلَم)',
    },
    {
      'question': 'المقابلة هي:',
      'answers': ['تكرار الكلمة', 'تقابل شيئين', 'التشبيه', 'الاستعارة'],
      'correct': 1,
      'explanation': 'المقابلة: تقابل شيئين لإبراز المعنى (الجنة والنار)',
    },
  ];

  void _checkAnswer(int index) {
    if (_answered) return;

    setState(() {
      _selectedAnswer = index;
      _answered = true;
      if (index == _questions[_currentQuestion]['correct']) {
        _score += 10;
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestion < _questions.length - 1) {
      setState(() {
        _currentQuestion++;
        _answered = false;
        _selectedAnswer = null;
      });
    } else {
      _showResult();
    }
  }

  void _showResult() {
    final percentage = (_score / (_questions.length * 10)) * 100;
    final passed = percentage >= 80;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(
          passed ? '🎉 مبروك!' : 'انتهى الاختبار',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFFD4AF37),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'النتيجة: $_score / ${_questions.length * 10}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'النسبة: ${percentage.toStringAsFixed(1)}%',
              style: TextStyle(
                color: percentage >= 80 ? Colors.green : Colors.orange,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 20),
            if (passed)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFD4AF37),
                    width: 2,
                  ),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.emoji_events, color: Color(0xFFD4AF37), size: 50),
                    SizedBox(height: 10),
                    Text(
                      'لقد حصلت على شهادة الإتمام!',
                      style: TextStyle(
                        color: Color(0xFFD4AF37),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text(
              'حسناً',
              style: TextStyle(color: Color(0xFFD4AF37)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentQuestion];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'اختبار النحو',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0D0D0D),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFD4AF37)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ✅ Progress bar
            LinearProgressIndicator(
              value: (_currentQuestion + 1) / _questions.length,
              backgroundColor: Colors.grey[800],
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
              minHeight: 8,
            ),
            const SizedBox(height: 10),
            Text(
              'السؤال ${_currentQuestion + 1} من ${_questions.length}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // ✅ Score
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37).withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'النقاط: $_score',
                style: const TextStyle(
                  color: Color(0xFFD4AF37),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 30),

            // ✅ Question
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFD4AF37).withOpacity(0.3),
                ),
              ),
              child: Text(
                question['question'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 30),

            // ✅ Answers
            Expanded(
              child: ListView.builder(
                itemCount: question['answers'].length,
                itemBuilder: (context, index) {
                  final isSelected = _selectedAnswer == index;
                  final isCorrect = index == question['correct'];
                  final showCorrect = _answered && isCorrect;
                  final showWrong = _answered && isSelected && !isCorrect;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () => _checkAnswer(index),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: showCorrect
                              ? Colors.green.withOpacity(0.3)
                              : showWrong
                                  ? Colors.red.withOpacity(0.3)
                                  : const Color(0xFF2A2A2A),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: showCorrect
                                ? Colors.green
                                : showWrong
                                    ? Colors.red
                                    : isSelected
                                        ? const Color(0xFFD4AF37)
                                        : Colors.grey[800]!,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: showCorrect
                                    ? Colors.green
                                    : showWrong
                                        ? Colors.red
                                        : const Color(0xFFD4AF37),
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                question['answers'][index],
                                style: TextStyle(
                                  color: showCorrect || showWrong || isSelected
                                      ? Colors.white
                                      : Colors.grey[400],
                                  fontSize: 16,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                            if (showCorrect)
                              const Icon(Icons.check_circle, color: Colors.green)
                            else if (showWrong)
                              const Icon(Icons.cancel, color: Colors.red),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // ✅ Explanation
            if (_answered)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withOpacity(0.3),
                  ),
                ),
                child: Text(
                  question['explanation'],
                  style: const TextStyle(
                    color: Color(0xFFD4AF37),
                    fontSize: 14,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            // ✅ Next button
            if (_answered)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _currentQuestion < _questions.length - 1
                        ? 'السؤال التالي'
                        : 'عرض النتيجة',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}