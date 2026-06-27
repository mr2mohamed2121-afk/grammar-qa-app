import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// بوابة المعلم - إنشاء امتحانات مخصصة
class TeacherPortalScreen extends StatefulWidget {
  const TeacherPortalScreen({super.key});

  @override
  State<TeacherPortalScreen> createState() => _TeacherPortalScreenState();
}

class _TeacherPortalScreenState extends State<TeacherPortalScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _examTitleController = TextEditingController();
  final _questionControllers = <TextEditingController>[];
  final _answerControllers = <List<TextEditingController>>[];
  final _correctAnswers = <int>[];

  int _questionCount = 5;
  String _selectedLevel = 'ابتدائي';
  int _currentStep = 0;

  final List<String> _levels = ['ابتدائي', 'إعدادي', 'ثانوي'];

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeQuestionControllers();
  }

  void _initializeQuestionControllers() {
    for (var c in _questionControllers) c.dispose();
    for (var list in _answerControllers) {
      for (var c in list) c.dispose();
    }
    
    _questionControllers.clear();
    _answerControllers.clear();
    _correctAnswers.clear();

    for (int i = 0; i < _questionCount; i++) {
      _questionControllers.add(TextEditingController());
      final answers = <TextEditingController>[];
      for (int j = 0; j < 4; j++) {
        answers.add(TextEditingController());
      }
      _answerControllers.add(answers);
      _correctAnswers.add(0);
    }
  }

  @override
  void dispose() {
    _examTitleController.dispose();
    for (var c in _questionControllers) c.dispose();
    for (var list in _answerControllers) {
      for (var c in list) c.dispose();
    }
    _tabController.dispose();
    super.dispose();
  }

  /// حفظ الامتحان
  void _saveExam() {
    if (!_formKey.currentState!.validate()) return;

    final exam = {
      'title': _examTitleController.text,
      'level': _selectedLevel,
      'question_count': _questionCount,
      'questions': <Map<String, dynamic>>[],
      'created_at': DateTime.now().toIso8601String(),
    };

    for (int i = 0; i < _questionCount; i++) {
      final answers = <String>[];
      for (int j = 0; j < 4; j++) {
        answers.add(_answerControllers[i][j].text);
      }

      (exam['questions'] as List<Map<String, dynamic>>).add({
        'question': _questionControllers[i].text,
        'answers': answers,
        'correct': _correctAnswers[i],
      });
    }

    // TODO: حفظ في Firebase
    debugPrint('Exam saved: $exam');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ تم حفظ الامتحان بنجاح'),
        backgroundColor: Colors.green,
      ),
    );

    setState(() => _currentStep = 2);
  }

  /// طباعة الامتحان
  void _printExam() {
    // TODO: توليد PDF للامتحان
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🖨️ جاري إعداد الامتحان للطباعة...'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text(
          'بوابة المعلم',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF0D0D0D),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFD4AF37),
          labelColor: const Color(0xFFD4AF37),
          unselectedLabelColor: Colors.white54,
          labelStyle: const TextStyle(fontFamily: 'Cairo'),
          tabs: const [
            Tab(icon: Icon(Icons.edit), text: 'إنشاء'),
            Tab(icon: Icon(Icons.list), text: 'الامتحانات'),
            Tab(icon: Icon(Icons.analytics), text: 'النتائج'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCreateExamTab(),
          _buildExamsListTab(),
          _buildResultsTab(),
        ],
      ),
    );
  }

  /// تبويب إنشاء الامتحان
  Widget _buildCreateExamTab() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // عنوان الامتحان
            _buildSectionTitle('عنوان الامتحان'),
            TextFormField(
              controller: _examTitleController,
              style: const TextStyle(color: Colors.white, fontFamily: 'Cairo'),
              decoration: _inputDecoration('مثال: اختبار النحو - المستوى الأول'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال عنوان الامتحان';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // المستوى
            _buildSectionTitle('المستوى'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedLevel,
                  isExpanded: true,
                  dropdownColor: const Color(0xFF2A2A2A),
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Cairo',
                    fontSize: 16,
                  ),
                  items: _levels.map((level) {
                    return DropdownMenuItem(
                      value: level,
                      child: Text(level),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedLevel = value!);
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // عدد الأسئلة
            _buildSectionTitle('عدد الأسئلة: $_questionCount'),
            Slider(
              value: _questionCount.toDouble(),
              min: 5,
              max: 30,
              divisions: 25,
              activeColor: const Color(0xFFD4AF37),
              inactiveColor: Colors.white24,
              label: _questionCount.toString(),
              onChanged: (value) {
                setState(() {
                  _questionCount = value.toInt();
                  _initializeQuestionControllers();
                });
              },
            ),
            const SizedBox(height: 20),

            // الأسئلة
            _buildSectionTitle('الأسئلة'),
            ...List.generate(_questionCount, (index) {
              return _buildQuestionCard(index);
            }),

            const SizedBox(height: 30),

            // أزرار التحكم
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _saveExam,
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: const Text(
                      'حفظ الامتحان',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
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
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _printExam,
                    icon: const Icon(Icons.print, color: Colors.white),
                    label: const Text(
                      'طباعة',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: const Color(0xFFD4AF37).withOpacity(0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD4AF37),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'السؤال',
                  style: TextStyle(
                    color: Color(0xFFD4AF37),
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _questionControllers[index],
              style: const TextStyle(color: Colors.white, fontFamily: 'Cairo'),
              decoration: _inputDecoration('نص السؤال'),
              maxLines: 2,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال السؤال';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'الإجابات',
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 8),
            ...List.generate(4, (answerIndex) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Radio<int>(
                      value: answerIndex,
                      groupValue: _correctAnswers[index],
                      activeColor: const Color(0xFFD4AF37),
                      onChanged: (value) {
                        setState(() => _correctAnswers[index] = value!);
                      },
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: _answerControllers[index][answerIndex],
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Cairo',
                        ),
                        decoration: _inputDecoration(
                          'الإجابة ${answerIndex + 1}',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'مطلوب';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildExamsListTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.folder_open,
            size: 80,
            color: Colors.white24,
          ),
          const SizedBox(height: 20),
          const Text(
            'لا توجد امتحانات محفوظة',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 18,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => _tabController.animateTo(0),
            child: const Text(
              'إنشاء امتحان جديد',
              style: TextStyle(
                color: Color(0xFFD4AF37),
                fontFamily: 'Cairo',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.bar_chart,
            size: 80,
            color: Colors.white24,
          ),
          const SizedBox(height: 20),
          const Text(
            'لا توجد نتائج بعد',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 18,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFFD4AF37),
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Cairo',
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white38),
      filled: true,
      fillColor: const Color(0xFF2A2A2A),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}