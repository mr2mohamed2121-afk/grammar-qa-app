import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QuestionForm extends StatefulWidget {
  final Map<String, dynamic>? questionData;
  final String? questionId;

  const QuestionForm({
    super.key,
    this.questionData,
    this.questionId,
  });

  @override
  State<QuestionForm> createState() => _QuestionFormState();
}

class _QuestionFormState extends State<QuestionForm> {
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;

  final _questionController = TextEditingController();
  final _explanationController = TextEditingController();
  final _option1Controller = TextEditingController();
  final _option2Controller = TextEditingController();
  final _option3Controller = TextEditingController();
  final _option4Controller = TextEditingController();
  final _imageUrlController = TextEditingController();

  String _selectedType = 'multipleChoice';
  String _selectedDifficulty = 'medium';
  String _selectedCategory = 'nahw';
  int _correctAnswerIndex = 0;
  bool _isActive = true;
  bool _isLoading = false;
  bool _isEdit = false;

  final List<String> _questionTypes = [
    'multipleChoice',
    'trueFalse',
    'fillInBlank',
    'matching',
  ];

  final List<String> _difficulties = ['easy', 'medium', 'hard'];

  final List<String> _categories = [
    'nahw',
    'sarf',
    'balagha',
    'arud',
    'imla',
    'history',
    'adab',
  ];

  @override
  void initState() {
    super.initState();
    _isEdit = widget.questionData != null;
    if (_isEdit) {
      _loadQuestionData();
    }
  }

  void _loadQuestionData() {
    final data = widget.questionData!;
    _questionController.text = data['question'] ?? '';
    _explanationController.text = data['explanation'] ?? '';
    _imageUrlController.text = data['imageUrl'] ?? '';
    _selectedType = data['type'] ?? 'multipleChoice';
    _selectedDifficulty = data['difficulty'] ?? 'medium';
    _selectedCategory = data['category'] ?? 'nahw';
    _correctAnswerIndex = data['correctAnswerIndex'] ?? 0;
    _isActive = data['isActive'] ?? true;

    final options = data['options'] as List<dynamic>? ?? [];
    if (options.isNotEmpty) _option1Controller.text = options[0] ?? '';
    if (options.length > 1) _option2Controller.text = options[1] ?? '';
    if (options.length > 2) _option3Controller.text = options[2] ?? '';
    if (options.length > 3) _option4Controller.text = options[3] ?? '';
  }

  @override
  void dispose() {
    _questionController.dispose();
    _explanationController.dispose();
    _option1Controller.dispose();
    _option2Controller.dispose();
    _option3Controller.dispose();
    _option4Controller.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  List<String> get _options {
    if (_selectedType == 'trueFalse') {
      return ['True', 'False'];
    }
    return [
      _option1Controller.text,
      _option2Controller.text,
      _option3Controller.text,
      _option4Controller.text,
    ].where((o) => o.isNotEmpty).toList();
  }

  Future<void> _saveQuestion() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedType != 'trueFalse' && _options.length < 2) {
      _showError('At least 2 options required');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      final questionData = {
        'question': _questionController.text.trim(),
        'type': _selectedType,
        'difficulty': _selectedDifficulty,
        'category': _selectedCategory,
        'options': _options,
        'correctAnswerIndex': _correctAnswerIndex,
        'explanation': _explanationController.text.trim(),
        'imageUrl': _imageUrlController.text.trim(),
        'isActive': _isActive,
        'updatedAt': Timestamp.now(),
        'updatedBy': user?.uid,
      };

      if (_isEdit && widget.questionId != null) {
        await _firestore
            .collection('questions')
            .doc(widget.questionId)
            .update(questionData);
      } else {
        questionData['createdAt'] = Timestamp.now();
        questionData['createdBy'] = user?.uid;
        await _firestore.collection('questions').add(questionData);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEdit ? 'Question updated successfully' : 'Question added successfully',
            ),
            backgroundColor: const Color(0xFF2E7D32),
          ),
        );
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: Text(
          _isEdit ? 'Edit Question' : 'Add New Question',
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E3A5F),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_isEdit)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _deleteQuestion,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Color(0xFFD4AF37)),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16213E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFD4AF37).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isEdit ? Icons.edit : Icons.add_circle,
                            color: const Color(0xFFD4AF37),
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _isEdit
                                  ? 'Edit existing question in database'
                                  : 'Add new question to database',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    _buildSectionTitle('Question Text *'),
                    _buildTextField(
                      controller: _questionController,
                      hint: 'Enter question text here...',
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Question text is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdown(
                            label: 'Question Type',
                            value: _selectedType,
                            items: _questionTypes.map((type) {
                              String label;
                              switch (type) {
                                case 'multipleChoice':
                                  label = 'Multiple Choice';
                                  break;
                                case 'trueFalse':
                                  label = 'True/False';
                                  break;
                                case 'fillInBlank':
                                  label = 'Fill in Blank';
                                  break;
                                case 'matching':
                                  label = 'Matching';
                                  break;
                                default:
                                  label = type;
                              }
                              return DropdownMenuItem(
                                value: type,
                                child: Text(
                                  label,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Cairo',
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedType = value!;
                                if (_selectedType == 'trueFalse') {
                                  _correctAnswerIndex = 0;
                                }
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDropdown(
                            label: 'Difficulty',
                            value: _selectedDifficulty,
                            items: _difficulties.map((diff) {
                              String label;
                              switch (diff) {
                                case 'easy':
                                  label = 'Easy';
                                  break;
                                case 'medium':
                                  label = 'Medium';
                                  break;
                                case 'hard':
                                  label = 'Hard';
                                  break;
                                default:
                                  label = diff;
                              }
                              return DropdownMenuItem(
                                value: diff,
                                child: Text(
                                  label,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Cairo',
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _selectedDifficulty = value!);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    _buildDropdown(
                      label: 'Category',
                      value: _selectedCategory,
                      items: _categories.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Text(
                            cat,
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedCategory = value!);
                      },
                    ),
                    const SizedBox(height: 20),

                    if (_selectedType == 'multipleChoice') ...[
                      _buildSectionTitle('Options *'),
                      _buildOptionField(
                        controller: _option1Controller,
                        label: 'Option 1',
                        index: 0,
                      ),
                      _buildOptionField(
                        controller: _option2Controller,
                        label: 'Option 2',
                        index: 1,
                      ),
                      _buildOptionField(
                        controller: _option3Controller,
                        label: 'Option 3',
                        index: 2,
                      ),
                      _buildOptionField(
                        controller: _option4Controller,
                        label: 'Option 4',
                        index: 3,
                      ),
                      const SizedBox(height: 20),
                    ],

                    if (_selectedType == 'trueFalse') ...[
                      _buildSectionTitle('Correct Answer'),
                      Row(
                        children: [
                          _buildTrueFalseButton('True', 0),
                          const SizedBox(width: 12),
                          _buildTrueFalseButton('False', 1),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],

                    if (_selectedType == 'multipleChoice') ...[
                      _buildSectionTitle('Correct Answer *'),
                      Wrap(
                        spacing: 8,
                        children: List.generate(4, (index) {
                          return ChoiceChip(
                            label: Text(
                              'Option ${index + 1}',
                              style: TextStyle(
                                color: _correctAnswerIndex == index
                                    ? Colors.black
                                    : Colors.white,
                                fontFamily: 'Cairo',
                              ),
                            ),
                            selected: _correctAnswerIndex == index,
                            selectedColor: const Color(0xFFD4AF37),
                            backgroundColor: const Color(0xFF16213E),
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _correctAnswerIndex = index);
                              }
                            },
                          );
                        }),
                      ),
                      const SizedBox(height: 20),
                    ],

                    _buildSectionTitle('Explanation'),
                    _buildTextField(
                      controller: _explanationController,
                      hint: 'Enter explanation for correct answer...',
                      maxLines: 4,
                    ),
                    const SizedBox(height: 20),

                    _buildSectionTitle('Image URL (Optional)'),
                    _buildTextField(
                      controller: _imageUrlController,
                      hint: 'https://example.com/image.png',
                      prefixIcon: Icons.image,
                    ),
                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16213E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isActive ? Icons.visibility : Icons.visibility_off,
                            color: _isActive ? Colors.green : Colors.grey,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Question Status',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Cairo',
                                  ),
                                ),
                                Text(
                                  _isActive
                                      ? 'Question is visible to users'
                                      : 'Question is hidden from users',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    fontFamily: 'Cairo',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _isActive,
                            onChanged: (value) {
                              setState(() => _isActive = value);
                            },
                            activeColor: const Color(0xFFD4AF37),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    _buildPreviewCard(),
                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _saveQuestion,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(Colors.black),
                                ),
                              )
                            : Icon(_isEdit ? Icons.save : Icons.add),
                        label: Text(
                          _isEdit ? 'Save Changes' : 'Add Question',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4AF37),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.cancel),
                        label: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white70,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Colors.white24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
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
          fontSize: 14,
          fontWeight: FontWeight.bold,
          fontFamily: 'Cairo',
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
    IconData? prefixIcon,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(
        color: Colors.white,
        fontFamily: 'Cairo',
      ),
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.white.withOpacity(0.4),
          fontFamily: 'Cairo',
        ),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: Colors.white54)
            : null,
        filled: true,
        fillColor: const Color(0xFF16213E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFD4AF37),
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1,
          ),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildOptionField({
    required TextEditingController controller,
    required String label,
    required int index,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _correctAnswerIndex == index
                  ? const Color(0xFFD4AF37)
                  : const Color(0xFF16213E),
              border: Border.all(
                color: _correctAnswerIndex == index
                    ? const Color(0xFFD4AF37)
                    : Colors.white24,
              ),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: _correctAnswerIndex == index
                      ? Colors.black
                      : Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: controller,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Cairo',
              ),
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(
                hintText: label,
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontFamily: 'Cairo',
                ),
                filled: true,
                fillColor: const Color(0xFF16213E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFD4AF37),
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              _correctAnswerIndex == index
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: _correctAnswerIndex == index
                  ? const Color(0xFFD4AF37)
                  : Colors.white54,
            ),
            onPressed: () {
              setState(() => _correctAnswerIndex = index);
            },
            tooltip: 'Correct Answer',
          ),
        ],
      ),
    );
  }

  Widget _buildTrueFalseButton(String label, int index) {
    final isSelected = _correctAnswerIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _correctAnswerIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFD4AF37)
                : const Color(0xFF16213E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFD4AF37)
                  : Colors.white24,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              fontFamily: 'Cairo',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFD4AF37),
            fontSize: 14,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF16213E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: const Color(0xFF16213E),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
              items: items,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.preview, color: Color(0xFFD4AF37), size: 20),
              SizedBox(width: 8),
              Text(
                'Question Preview',
                style: TextStyle(
                  color: Color(0xFFD4AF37),
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(8),
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
                        color: _getDifficultyColor().withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _getDifficultyLabel(),
                        style: TextStyle(
                          color: _getDifficultyColor(),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _selectedCategory,
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _isActive
                            ? Colors.green.withOpacity(0.2)
                            : Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _isActive ? 'Active' : 'Hidden',
                        style: TextStyle(
                          color: _isActive ? Colors.green : Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _questionController.text.isEmpty
                      ? 'Sample question...'
                      : _questionController.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 8),
                if (_selectedType == 'multipleChoice') ...[
                  ...List.generate(
                    _options.length,
                    (index) => Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: index == _correctAnswerIndex
                            ? const Color(0xFFD4AF37).withOpacity(0.2)
                            : const Color(0xFF16213E),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: index == _correctAnswerIndex
                              ? const Color(0xFFD4AF37)
                              : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            index == _correctAnswerIndex
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: index == _correctAnswerIndex
                                ? const Color(0xFFD4AF37)
                                : Colors.white54,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _options[index],
                            style: TextStyle(
                              color: index == _correctAnswerIndex
                                  ? const Color(0xFFD4AF37)
                                  : Colors.white70,
                              fontSize: 12,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor() {
    switch (_selectedDifficulty) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getDifficultyLabel() {
    switch (_selectedDifficulty) {
      case 'easy':
        return 'Easy';
      case 'medium':
        return 'Medium';
      case 'hard':
        return 'Hard';
      default:
        return _selectedDifficulty;
    }
  }

  Future<void> _deleteQuestion() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        title: const Text(
          'Confirm Delete',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Cairo',
          ),
        ),
        content: const Text(
          'Are you sure you want to delete this question?',
          style: TextStyle(
            color: Colors.white70,
            fontFamily: 'Cairo',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && widget.questionId != null) {
      setState(() => _isLoading = true);
      try {
        await _firestore.collection('questions').doc(widget.questionId).delete();
        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Question deleted successfully'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        _showError('Delete error: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }
}
