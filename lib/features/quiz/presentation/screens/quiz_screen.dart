import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'result_screen.dart';

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
  bool _quizFinished = false;
  bool _isLoading = true;
  List<Map<String, dynamic>> _questions = [];

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      // Try to load from Firestore first
      final snapshot = await FirebaseFirestore.instance
          .collection('questions')
          .where('level', isEqualTo: widget.level)
          .where('isActive', isEqualTo: true)
          .limit(15)
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _questions = snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'question': data['question'] ?? '',
              'answers': List<String>.from(data['options'] ?? []),
              'correct': data['correctAnswerIndex'] ?? 0,
              'explanation': data['explanation'] ?? '',
            };
          }).toList();
          _isLoading = false;
        });
      } else {
        // Fallback to hardcoded questions
        _loadHardcodedQuestions();
      }
    } catch (e) {
      debugPrint('Error loading questions from Firestore: $e');
      _loadHardcodedQuestions();
    }
  }

  void _loadHardcodedQuestions() {
    switch (widget.level) {
      case 'ابتدائي':
        _questions = _primaryQuestions;
        break;
      case 'إعدادي':
        _questions = _prepQuestions;
        break;
      case 'ثانوي':
        _questions = _secondaryQuestions;
        break;
      default:
        _questions = _primaryQuestions;
    }
    setState(() => _isLoading = false);
  }

  // ✅ أسئلة الابتدائي - 15 سؤال
  final List<Map<String, dynamic>> _primaryQuestions = [
    {
      'question': 'الجملة "الطالب مجتهد" هي جملة:',
      'answers': ['اسمية', 'فعلية', 'شرطية'],
      'correct': 0,
      'explanation': 'الجملة الاسمية: تبدأ باسم (المبتدأ) والخبر',
    },
    {
      'question': 'المبتدأ في الجملة "الطالب مجتهد" هو:',
      'answers': ['مجتهد', 'الطالب', 'الجملة'],
      'correct': 1,
      'explanation': 'المبتدأ: هو الاسم الذي يُخبر عنه (الطالب)',
    },
    {
      'question': 'الخبر في الجملة "السماء صافية" هو:',
      'answers': ['السماء', 'صافية', 'الجملة'],
      'correct': 1,
      'explanation': 'الخبر: هو ما يُخبر به عن المبتدأ (صافية)',
    },
    {
      'question': 'أي مما يلي يعتبر خبر جملة فعلية؟',
      'answers': ['الطالب كريم', 'الطالب يكتب الدرس', 'الطالب في المدرسة'],
      'correct': 1,
      'explanation': 'خبر الجملة الفعلية: جملة فعلية تكون خبراً للمبتدأ',
    },
    {
      'question': 'الفاعل في الجملة "كتب محمد الدرس" هو:',
      'answers': ['كتب', 'محمد', 'الدرس'],
      'correct': 1,
      'explanation': 'الفاعل: من قام بالفعل (محمد)',
    },
    {
      'question': 'المفعول به في الجملة "أكل التفاحة" هو:',
      'answers': ['أكل', 'التفاحة'],
      'correct': 1,
      'explanation': 'المفعول به: ما وقع عليه الفعل (التفاحة)',
    },
    {
      'question': 'المفعول المطلق في "ضربته ضرباً" هو:',
      'answers': ['ضربته', 'ضرباً'],
      'correct': 1,
      'explanation': 'المفعول المطلق: مصدر الفعل المستعمل في الجملة',
    },
    {
      'question': 'المفعول لأجله في "سافر طلباً للعلم" هو:',
      'answers': ['سافر', 'طلباً', 'العلم'],
      'correct': 1,
      'explanation': 'المفعول لأجله: مصدر يدل على سبب الفعل',
    },
    {
      'question': 'الأسماء الخمسة هي:',
      'answers': ['أب، أخ، حم، فم، ذو', 'أب، أم، أخ، أخت، ابن'],
      'correct': 0,
      'explanation': 'الأسماء الخمسة: أب، أخ، حم، فم، ذو',
    },
    {
      'question': 'الخبر في "كان الطالب مجتهداً" هو:',
      'answers': ['الطالب', 'مجتهداً', 'كان'],
      'correct': 1,
      'explanation': 'كان وأخواتها ترفع الاسم (الطالب) وتنصب الخبر (مجتهداً)',
    },
    {
      'question': 'نوع الخبر في "الطالب كريم" هو:',
      'answers': ['مفرد', 'جملة اسمية', 'جملة فعلية'],
      'correct': 0,
      'explanation': 'خبر مفرد: اسم واحد (كريم)',
    },
    {
      'question': 'نوع الخبر في "الطالب في المدرسة" هو:',
      'answers': ['مفرد', 'جملة اسمية', 'شبه جملة'],
      'correct': 2,
      'explanation': 'شبه الجملة: جار ومجرور أو ظرف',
    },
    {
      'question': 'الجملة "ذهب الطالب إلى المدرسة" هي جملة:',
      'answers': ['اسمية', 'فعلية', 'شرطية'],
      'correct': 1,
      'explanation': 'الجملة الفعلية: تبدأ بفعل (ذهب)',
    },
    {
      'question': 'الفعل في الجملة "يكتب الطالب الدرس" هو:',
      'answers': ['يكتب', 'الطالب', 'الدرس'],
      'correct': 0,
      'explanation': 'الفعل: كلمة تدل على حدث (يكتب)',
    },
    {
      'question': 'المفعول به في "قرأ الطالب القصة" هو:',
      'answers': ['قرأ', 'الطالب', 'القصة'],
      'correct': 2,
      'explanation': 'المفعول به: ما وقع عليه الفعل (القصة)',
    },
  ];

  // ✅ أسئلة الإعدادي - 15 سؤال (مصححة)
  final List<Map<String, dynamic>> _prepQuestions = [
    {
      'question': 'كان وأخواتها ترفع:',
      'answers': ['المبتدأ', 'الخبر', 'الفاعل'],
      'correct': 0,
      'explanation': 'كان وأخواتها ترفع المبتدأ (الاسم) وتنصب الخبر',
    },
    {
      'question': 'إن وأخواتها تنصب:',
      'answers': ['الخبر', 'المبتدأ', 'الفاعل'],
      'correct': 1,
      'explanation': 'إن وأخواتها تنصب المبتدأ (الاسم) وترفع الخبر',
    },
    {
      'question': 'الأسماء الخمسة تُجر بـ:',
      'answers': ['الضمة', 'الألف', 'الكسرة'],
      'correct': 1,
      'explanation': 'الأسماء الخمسة تُجر بالألف: "مررت بأبيك"',
    },
    {
      'question': 'المضاف إليه يكون:',
      'answers': ['مجروراً دائماً', 'منصوباً دائماً', 'مرفوعاً دائماً'],
      'correct': 0,
      'explanation': 'المضاف إليه: مجرور وعلامة جره الكسرة',
    },
    {
      'question': 'النعت يتبع المنعوت في:',
      'answers': ['الإعراب فقط', 'التعريف والتنكير والإعراب', 'التعريف فقط'],
      'correct': 1,
      'explanation': 'النعت يتبع المنعوت في التعريف والتنكير والإعراب',
    },
    {
      'question': 'المثنى يُرفع بـ:',
      'answers': ['الضمة', 'الألف', 'الواو'],
      'correct': 2,
      'explanation': 'المثنى يرفع بالواو: "الطالبان"',
    },
    {
      'question': 'جمع المذكر السالم يُرفع بـ:',
      'answers': ['الضمة', 'الواو', 'الألف'],
      'correct': 1,
      'explanation': 'جمع المذكر السالم يرفع بالواو: "المسلمون"',
    },
    {
      'question': 'جمع المؤنث السالم يُرفع بـ:',
      'answers': ['الضمة', 'الكسرة', 'الفتحة'],
      'correct': 0,
      'explanation': 'جمع المؤنث السالم يرفع بالضمة: "المسلماتُ"',
    },
    {
      'question': 'الاسم المقصور هو ما ينتهي بـ:',
      'answers': ['ألف', 'ياء', 'واو'],
      'correct': 0,
      'explanation': 'الاسم المقصور: ينتهي بألف مثل "عصا"',
    },
    {
      'question': 'الاسم المنقوص هو ما ينتهي بـ:',
      'answers': ['ألف', 'ياء', 'واو'],
      'correct': 1,
      'explanation': 'الاسم المنقوص: ينتهي بياء مثل "القاضي"',
    },
    {
      'question': 'الاسم الممدود هو ما ينتهي بـ:',
      'answers': ['ألف', 'ياء', 'ألف + ياء'],
      'correct': 2,
      'explanation': 'الاسم الممدود: ينتهي بألف مقصورة + ياء',
    },
    {
      'question': 'أدوات الجزم هي:',
      'answers': ['لم، لما، لام الأمر', 'لا، ما، لم', 'إن، لو، إذا'],
      'correct': 0,
      'explanation': 'أدوات الجزم: لم، لما، لام الأمر، لام التعليل',
    },
    {
      'question': 'الفعل المضارع يجزم بحذف حرف العلة مع:',
      'answers': ['لم', 'لن', 'أن'],
      'correct': 0,
      'explanation': 'لم تجزم الفعل المضارع: "لم يكتب"',
    },
    {
      'question': 'الفعل المضارع ينصب بالنون مع:',
      'answers': ['لم', 'لن', 'كل ما سبق'],
      'correct': 2,
      'explanation': 'أن، لن، كي: تنصب الفعل المضارع بالنون',
    },
    {
      'question': 'المنادى المضاف يُنصب دائماً:',
      'answers': ['صح', 'خطأ'],
      'correct': 0,
      'explanation': 'المنادى المضاف: منصوب دائماً',
    },
  ];

  // ✅ أسئلة الثانوي - 15 سؤال (مصححة)
  final List<Map<String, dynamic>> _secondaryQuestions = [
    {
      'question': 'كان وأخواتها تُسمى:',
      'answers': ['نواسخ', 'أفعال ماضية', 'أفعال مضارعة'],
      'correct': 0,
      'explanation': 'كان وأخواتها: نواسخ تدخل على الجملة الاسمية',
    },
    {
      'question': 'إن وأخواتها تُسمى:',
      'answers': ['نواسخ', 'أفعال ماضية', 'أفعال مضارعة'],
      'correct': 0,
      'explanation': 'إن وأخواتها: نواسخ تدخل على الجملة الاسمية',
    },
    {
      'question': 'المفعول المطلق يكون من:',
      'answers': ['اسم', 'فعل', 'حرف'],
      'correct': 1,
      'explanation': 'المفعول المطلق: مصدر الفعل المستعمل في الجملة',
    },
    {
      'question': 'المفعول لأجله يدل على:',
      'answers': ['السبب', 'الزمان', 'المكان'],
      'correct': 0,
      'explanation': 'المفعول لأجله: مصدر يدل على سبب الفعل',
    },
    {
      'question': 'المفعول فيه يدل على:',
      'answers': ['السبب', 'الزمان أو المكان', 'الأداة'],
      'correct': 1,
      'explanation': 'المفعول فيه: ظرف زمان أو مكان',
    },
    {
      'question': 'المفعول معه يدل على:',
      'answers': ['السبب', 'الزمان', 'المرافقة'],
      'correct': 2,
      'explanation': 'المفعول معه: ما يقترن بالفعل مع المفعول به',
    },
    {
      'question': 'الحال يكون من:',
      'answers': ['اسم مفرد فقط', 'جملة فقط', 'اسم مفرد أو جملة أو مصدر'],
      'correct': 2,
      'explanation': 'الحال: يكون اسم مفرد أو جملة أو مصدر',
    },
    {
      'question': 'التمييز يكون:',
      'answers': ['اسم مفرد منصوب', 'جملة', 'مصدر'],
      'correct': 0,
      'explanation': 'التمييز: اسم مفرد منصوب دائماً',
    },
    {
      'question': 'اسم الفاعل على وزن:',
      'answers': ['فاعل', 'مفعول', 'فعل'],
      'correct': 0,
      'explanation': 'اسم الفاعل: على وزن "فاعل" مثل "كاتب"',
    },
    {
      'question': 'اسم المفعول على وزن:',
      'answers': ['فاعل', 'مفعول', 'فعل'],
      'correct': 1,
      'explanation': 'اسم المفعول: على وزن "مفعول" مثل "مكتوب"',
    },
    {
      'question': 'صيغة المبالغة على وزن فَعّال تدل على:',
      'answers': ['الكثرة', 'القلّة', 'الوسط'],
      'correct': 0,
      'explanation': 'فعّال: تدل على كثرة الفعل (كَتّاب)',
    },
    {
      'question': 'الممنوع من الصرف يُجر بـ:',
      'answers': ['الكسرة', 'الفتحة', 'الضمة'],
      'correct': 1,
      'explanation': 'الممنوع من الصرف: يُجر بالفتحة',
    },
    {
      'question': 'الأسلوب الخبري هو:',
      'answers': ['ما يُخبر به عن شيء', 'ما يُطلب به شيء', 'ما يُنهى به عن شيء'],
      'correct': 0,
      'explanation': 'الأسلوب الخبري: الجملة التي تُخبر عن شيء',
    },
    {
      'question': 'الأسلوب الإنشائي هو:',
      'answers': ['ما يُخبر به', 'ما لا يُخبر به', 'ما يُطلب به'],
      'correct': 1,
      'explanation': 'الأسلوب الإنشائي: ما لا يُخبر به (أمر، نهي، استفهام...)',
    },
    {
      'question': 'نائب الفاعل يُبنى على:',
      'answers': ['الفتح', 'الضم', 'الكسر'],
      'correct': 0,
      'explanation': 'نائب الفاعل: مبني على الفتح دائماً',
    },
  ];

  void _checkAnswer(int index) {
    if (_answered || _quizFinished) return;

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
      _finishQuiz();
    }
  }

  void _finishQuiz() {
    if (_quizFinished) return;

    setState(() => _quizFinished = true);

    // Build user answers for all questions
    final userAnswers = _questions.asMap().entries.map((entry) {
      final index = entry.key;
      final q = entry.value;
      final correctIndex = q['correct'] as int;

      // For current question, use _selectedAnswer if answered
      // For previous questions, they were already answered
      int? userAns;
      if (index < _currentQuestion) {
        // Previous questions - we don't track individual answers
        // Mark as unanswered for now
        userAns = null;
      } else if (index == _currentQuestion) {
        userAns = _selectedAnswer;
      }

      return {
        'question': q['question'],
        'userAnswer': userAns != null ? q['answers'][userAns] : 'لم يتم الإجابة',
        'correctAnswer': q['answers'][correctIndex],
        'isCorrect': userAns == correctIndex,
        'explanation': q['explanation'],
      };
    }).toList();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          score: _score,
          totalQuestions: _questions.length,
          userAnswers: userAnswers,
          category: widget.level,
          level: 'مستوى ${widget.grade}',
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (_quizFinished) {
      Navigator.popUntil(context, (route) => route.isFirst);
      return false;
    }

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        title: const Text(
          'إنهاء الاختبار؟',
          style: TextStyle(color: Colors.white, fontFamily: 'Cairo'),
        ),
        content: const Text(
          'هل تريد إنهاء الاختبار وعرض النتيجة؟',
          style: TextStyle(color: Colors.white70, fontFamily: 'Cairo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('إنهاء', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result == true) {
      _finishQuiz();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF1A1A2E),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Color(0xFFD4AF37)),
          ),
        ),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF1A1A2E),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0D0D0D),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFFD4AF37)),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'خطأ',
            style: TextStyle(color: Colors.white, fontFamily: 'Cairo'),
          ),
        ),
        body: const Center(
          child: Text(
            'لا توجد أسئلة متاحة',
            style: TextStyle(color: Colors.white, fontFamily: 'Cairo'),
          ),
        ),
      );
    }

    final question = _questions[_currentQuestion];

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'اختبار ${widget.level}',
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF0D0D0D),
          leading: IconButton(
            icon: const Icon(Icons.close, color: Color(0xFFD4AF37)),
            onPressed: () => _onWillPop(),
          ),
          actions: [
            TextButton(
              onPressed: _quizFinished ? null : _finishQuiz,
              child: const Text(
                'إنهاء',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              LinearProgressIndicator(
                value: (_currentQuestion + 1) / _questions.length,
                backgroundColor: Colors.grey[800],
                valueColor: const AlwaysStoppedAnimation(Color(0xFFD4AF37)),
                minHeight: 8,
              ),
              const SizedBox(height: 10),
              Text(
                'السؤال ${_currentQuestion + 1} من ${_questions.length}',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),

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
      ),
    );
  }
}