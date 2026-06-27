import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// أستاذ النحو الذكي - AI Tutor
class AiTutorScreen extends StatefulWidget {
  const AiTutorScreen({super.key});

  @override
  State<AiTutorScreen> createState() => _AiTutorScreenState();
}

class _AiTutorScreenState extends State<AiTutorScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  
  bool _isLoading = false;

  // TODO: ضع مفتاح API الخاص بك
  static const String _apiKey = 'YOUR_OPENAI_API_KEY';
  static const String _apiUrl = 'https://api.openai.com/v1/chat/completions';

  final List<String> _quickQuestions = [
    'ما هو المبتدأ والخبر؟',
    'كيف أعرف الفاعل؟',
    'ما الفرق بين المفعول به والمفعول المطلق؟',
    'شرح كان وأخواتها',
    'ما هي علامات الإعراب؟',
    'كيف أفرق بين الماضي والمضارع؟',
    'ما هو التمييز؟',
    'شرح الاستعارة التصريحية',
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// إرسال رسالة
  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'role': 'user',
        'content': message,
        'timestamp': DateTime.now(),
      });
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      // TODO: استبدل هذا بـ API حقيقي
      // محاكاة الرد (للاختبار)
      await Future.delayed(const Duration(seconds: 2));
      
      final response = await _getAIResponse(message);
      
      setState(() {
        _messages.add({
          'role': 'assistant',
          'content': response,
          'timestamp': DateTime.now(),
        });
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add({
          'role': 'assistant',
          'content': 'عذراً، حدث خطأ. يرجى المحاولة مرة أخرى.',
          'timestamp': DateTime.now(),
          'isError': true,
        });
        _isLoading = false;
      });
    }

    _scrollToBottom();
  }

  /// الحصول على رد AI
  Future<String> _getAIResponse(String userMessage) async {
    // TODO: فعل الـ API الحقيقي
    /*
    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-4',
        'messages': [
          {
            'role': 'system',
            'content': 'أنت أستاذ نحو عربي خبير. أجب على أسئلة الطلاب بطريقة واضحة ومبسطة مع أمثلة. استخدم اللغة العربية فقط.'
          },
          ..._messages.map((m) => {
            'role': m['role'],
            'content': m['content'],
          }),
          {
            'role': 'user',
            'content': userMessage,
          },
        ],
        'temperature': 0.7,
        'max_tokens': 500,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    }
    */

    // ردود محاكاة (للاختبار)
    final mockResponses = {
      'ما هو المبتدأ والخبر؟': '''
المبتدأ والخبر هما ركنان أساسيان في الجملة الاسمية:

📌 المبتدأ: هو الاسم المرفوع الذي يُبتدأ به الكلام.
• مثال: "الطالبُ مجتهدٌ" → الطالب = مبتدأ

📌 الخبر: هو ما خبرنا به عن المبتدأ (يُبيّن صفة المبتدأ).
• مثال: "الطالبُ مجتهدٌ" → مجتهد = خبر

✅ الشروط:
1. المبتدأ مرفوع دائماً
2. الخبر مرفوع (غالباً)
3. يجوز حذف المبتدأ إذا كان معرفاً بالألف واللام
''',
      'كيف أعرف الفاعل؟': '''
الفاعل هو الاسم المرفوع الذي دلّ عليه الفعل:

📌 علامات الفاعل:
1. يكون مرفوعاً (بالضمة)
2. يأتي بعد الفعل مباشرة
3. يكون ذا عقل (إنسان أو حيوان)

✅ أمثلة:
• "كتبَ الطالبُ الدرسَ" → الطالب = فاعل
• "جلسَ المعلمُ على الكرسي" → المعلم = فاعل

⚠️ إذا كان الفعل لازماً (بدون مفعول):
• "نامَ الطفلُ" → الطفل = فاعل
''',
    };

    // البحث عن رد مطابق
    for (var entry in mockResponses.entries) {
      if (userMessage.contains(entry.key)) {
        return entry.value;
      }
    }

    // رد افتراضي
    return '''
أهلاً بيك! 🎓

سؤالك مهم جداً في النحو العربي. 

"$userMessage"

💡 باختصار:
النحو العربي علم واسع وجميل. أنصحك بمراجعة الدروس المتاحة في التطبيق لمزيد من التفاصيل والأمثلة.

📚 يمكنك أيضاً:
• مشاهدة الدروس المصورة
• حل الاختبارات التفاعلية
• مراجعة القواعد النحوية

هل عندك سؤال تاني؟
''';
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF9C27B0), Color(0xFF673AB7)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.smart_toy,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'أستاذ النحو الذكي',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'متصل',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0D0D0D),
        elevation: 0,
      ),
      body: Column(
        children: [
          // رسائل الترحيب
          if (_messages.isEmpty)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Avatar
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF9C27B0), Color(0xFF673AB7)],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF9C27B0).withOpacity(0.4),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.smart_toy,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'أهلاً بيك! أنا أستاذ النحو الذكي',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'اسألني أي سؤال في النحو والصرف والبلاغة',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontFamily: 'Cairo',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),

                    // أسئلة سريعة
                    const Text(
                      'أسئلة شائعة:',
                      style: TextStyle(
                        color: Color(0xFFD4AF37),
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _quickQuestions.map((question) {
                        return ActionChip(
                          label: Text(
                            question,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12,
                            ),
                          ),
                          backgroundColor: const Color(0xFF2A2A2A),
                          side: const BorderSide(color: Color(0xFF9C27B0)),
                          onPressed: () => _sendMessage(question),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            )
          else
            // قائمة الرسائل
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _buildMessageBubble(_messages[index]);
                },
              ),
            ),

          // مؤشر التحميل
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF9C27B0), Color(0xFF673AB7)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.smart_toy,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFFD4AF37),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'أستاذ النحو يفكر...',
                    style: TextStyle(
                      color: Colors.white54,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
            ),

          // حقل الإدخال
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              border: Border(
                top: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Cairo',
                    ),
                    decoration: InputDecoration(
                      hintText: 'اكتب سؤالك هنا...',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: const Color(0xFF2A2A2A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (value) => _sendMessage(value),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF9C27B0), Color(0xFF673AB7)],
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: IconButton(
                    onPressed: () => _sendMessage(_messageController.text),
                    icon: const Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isUser = message['role'] == 'user';
    final isError = message['isError'] == true;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          gradient: isUser
              ? const LinearGradient(
                  colors: [Color(0xFFD4AF37), Color(0xFF8B6914)],
                )
              : isError
                  ? LinearGradient(
                      colors: [
                        Colors.red.withOpacity(0.3),
                        Colors.red.withOpacity(0.1),
                      ],
                    )
                  : const LinearGradient(
                      colors: [Color(0xFF2A2A2A), Color(0xFF1A1A1A)],
                    ),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 20),
          ),
          border: !isUser
              ? Border.all(
                  color: isError ? Colors.red : const Color(0xFF9C27B0),
                  width: 1,
                )
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isUser ? Icons.person : Icons.smart_toy,
                  size: 16,
                  color: isUser ? Colors.black : const Color(0xFF9C27B0),
                ),
                const SizedBox(width: 6),
                Text(
                  isUser ? 'أنت' : 'أستاذ النحو',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isUser ? Colors.black : const Color(0xFF9C27B0),
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              message['content'],
              style: TextStyle(
                color: isUser ? Colors.black : Colors.white,
                fontFamily: 'Cairo',
                fontSize: 14,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message['timestamp']),
              style: TextStyle(
                fontSize: 10,
                color: isUser
                    ? Colors.black.withOpacity(0.5)
                    : Colors.white.withOpacity(0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}