import 'package:flutter/material.dart';

class LessonsScreen extends StatefulWidget {
  const LessonsScreen({super.key});

  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  String _selectedLevel = 'ابتدائي';
  int _selectedGrade = 1;

  final Map<String, Map<int, List<Map<String, String>>>> _lessons = {
    'ابتدائي': {
      1: [
        {'title': 'المعرفة والنكرة', 'content': 'الاسم إما معرفة (بأل) أو نكرة (من غير أل). المعرفة: الكتاب، النكرة: كتاب.'},
        {'title': 'المفرد والمثنى والجمع', 'content': 'المفرد: كتاب واحد، المثنى: كتابان، الجمع: كتب.'},
        {'title': 'المذكر والمؤنث', 'content': 'المذكر: ولد، المؤنث: بنت. المؤنث يُعرف بالتاء المربوطة أو الألف المقصورة.'},
      ],
      2: [
        {'title': 'الفعل الماضي', 'content': 'الفعل الماضي: فعل وقع في الزمن الماضي. مثال: كتب، ضرب، فتح.'},
        {'title': 'الفعل المضارع', 'content': 'الفعل المضارع: فعل يدل على الحاضر والمستقبل. يُعرف بحروف المضارعة: أ، ن، ي، ت.'},
        {'title': 'الفعل الأمر', 'content': 'الفعل الأمر: فعل يطلب فعلاً في المستقبل. يُشتق من المضارع بحذف حرف المضارعة.'},
      ],
      3: [
        {'title': 'المرفوعات', 'content': 'الأسماء المرفوعة: الفاعل، نائب الفاعل، المبتدأ، الخبر، اسم كان وأخواتها، خبر إن وأخواتها.'},
        {'title': 'المنصوبات', 'content': 'الأسماء المنصوبة: المفعول به، المفعول المطلق، المفعول لأجله، المفعول معه، المستثنى، الحال، التمييز.'},
        {'title': 'المجرورات', 'content': 'الأسماء المجرورة: اسم مجرور بحرف الجر، المضاف إليه، المتوكل، المقترن بما يجره.'},
      ],
      4: [
        {'title': 'الإضافة', 'content': 'الإضافة: هي إضافة اسم لاسم آخر للتخصيص. المضاف: محذوف الألف واللام، المضاف إليه: مجرور.'},
        {'title': 'التوابع', 'content': 'التوابع: النعت، العطف، التوكيد، البدل. كل تابع يتبع متبوعه في الإعراب.'},
        {'title': 'النداء', 'content': 'النداء: يا + المنادى. أنواع المنادى: علم، نكرة مقصودة، نكرة غير مقصودة، مضاف، الشبيه بالمضاف.'},
      ],
      5: [
        {'title': 'الاستفهام', 'content': 'أدوات الاستفهام: هل، من، ما، متى، أين، كيف، لماذا، كم، أي.'},
        {'title': 'النفي', 'content': 'أدوات النفي: لا، ما، لم، لن، ليس. كل أداة لها استخدام خاص حسب الزمن والمعنى.'},
        {'title': 'الشرط', 'content': 'أدوات الشرط: إن، لو، إذا، لولا، لوما. الجملة الشرطية: فعل شرط + جواب شرط.'},
      ],
      6: [
        {'title': 'الإعراب', 'content': 'الإعراب: تغيير أواخر الكلمات حسب موقعها في الجملة. الرفع: الضمة، النصب: الفتحة، الجر: الكسرة.'},
        {'title': 'الإمالة', 'content': 'الإمالة: ميل الصوت نحو الفتحة عند النطق بحرف الياء. تظهر في بعض الكلمات مثل: صلاة، زكاة.'},
        {'title': 'التقليب', 'content': 'التقليب: تقليب اللسان عند النطق بحرف الراء. الراء مفخمة في بعض المواضع ومكسورة في البعض الآخر.'},
      ],
    },
    'إعدادي': {
      1: [
        {'title': 'المبني والمعرب', 'content': 'المبني: ما لا يتغير في أواخره مهما تغير موقعه. المعرب: ما يتغير في أواخره حسب موقعه.'},
        {'title': 'النواسخ', 'content': 'نواسخ الفعل: كان وأخواتها (تنصب المبتدأ وترفع الخبر). نواسخ الاسم: إن وأخواتها (تنصب المبتدأ وترفع الخبر).'},
        {'title': 'العوامل الداخلة على الجملة', 'content': 'ظننت، علمت، ألفيت، وجدت، رأيت، سمعت: هذه الأفعال تدخل على الجملة الاسمية فتنصب المبتدأ.'},
      ],
      2: [
        {'title': 'إعراب الفعل المضارع', 'content': 'يرفع بالثبوت (لم يسبق بأداة نصب أو جزم)، ينصب بالنون (أن، لن، كي)، يجزم بحذف النون (لم، لما، لام الأمر).'},
        {'title': 'إعراب المثنى والجمع', 'content': 'المثنى: يرفع بالألف، ينصب ويجزم بالياء، يجر بالياء. جمع المذكر السالم: يرفع بالواو، ينصب ويجزم بالياء، يجر بالياء.'},
        {'title': 'إعراب الممنوع من الصرف', 'content': 'يُرفع بالضمة، ويُنصب ويُجر بالفتحة. أنواعه: علم الأعجمي، جمع مؤنث سالم، مصدر صريح، صفة على وزن أفعل.'},
      ],
      3: [
        {'title': 'الإعراب التقديري', 'content': 'ما لا يظهر إعرابه لمانع لغوي (الثقل) أو عرفي (الاستعمال). مثال: فاطمةُ، قاضٍ.'},
        {'title': 'الإعراب بالحروف', 'content': 'إعراب الأسماء بحروف: حروف الجر تجر الاسم بعدها. حروف النصب تنصب الفعل المضارع.'},
        {'title': 'التقديم والتأخير', 'content': 'تقديم الخبر على المبتدأ: للتخصيص أو للتنكير. تقديم المفعول به: للتخصيص أو للاهتمام.'},
      ],
    },
    'ثانوي': {
      1: [
        {'title': 'المصادر', 'content': 'أنواع المصادر: صريحة (مثل: كتابة)، مؤولة (ما أُول من الفعل مثل: إكراماً)، ميمية (مثل: مكتابة).'},
        {'title': 'أسماء الزمان والمكان', 'content': 'اسم زمان: مدرسة (زمن الدراسة)، اسم مكان: مسجد (مكان السجود). يُشتقان من الفعل الثلاثي.'},
        {'title': 'صيغ المبالغة', 'content': 'صيغ المبالغة: فَعّال (كَتّاب)، فَعول (صَبور)، فَعِل (كَرِيم)، مِفعال (مِقتال).'},
      ],
      2: [
        {'title': 'الاستعارة', 'content': 'الاستعارة: إبراز المعنى المجازي بلفظ حقيقي. أنواعها: تصريحية (الأسدُ يقاتل)، مكنية (رأيتُ أسداً يقاتل).'},
        {'title': 'الكناية', 'content': 'الكناية: إطلاق لفظ على ما يقارنه لدلالة على معنى مجازي. أنواعها: عن صفة، عن موصوف، عن مصاحب.'},
        {'title': 'المجاز المرسل', 'content': 'المجاز المرسل: نسبة الشيء إلى غيره لعلاقة ليست مشابهة. مثال: شربتُ كأساً (المجاز: ما في الكأس).'},
      ],
      3: [
        {'title': 'البلاغة في القرآن', 'content': 'إعجاز القرآن البلاغي: تفرد القرآن في الأساليب البلاغية التي عجز البشر عن الإتيان بمثلها.'},
        {'title': 'البديع', 'content': 'البديع: حسن التأليف بين الكلمات. أنواعه: الجناس، الطباق، السجع، المقابلة، التوازي، الاقتباس.'},
        {'title': 'الأساليب البلاغية', 'content': 'التشبيه، الاستعارة، الكناية، المجاز، التعجيز، التهويل، التفخيم، التصغير. كل أسلوب له غرض بلاغي.'},
      ],
    },
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'الدروس',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0D0D0D),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFD4AF37)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // ✅ اختيار المرحلة
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF1A1A1A),
            child: Row(
              children: [
                Expanded(
                  child: _buildLevelButton('ابتدائي', Colors.green),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildLevelButton('إعدادي', Colors.orange),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildLevelButton('ثانوي', Colors.red),
                ),
              ],
            ),
          ),

          // ✅ اختيار الصف
          if (_selectedLevel == 'ابتدائي')
            _buildGradeSelector([1, 2, 3, 4, 5, 6])
          else if (_selectedLevel == 'إعدادي')
            _buildGradeSelector([1, 2, 3])
          else
            _buildGradeSelector([1, 2, 3]),

          // ✅ قائمة الدروس
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _lessons[_selectedLevel]?[_selectedGrade]?.length ?? 0,
              itemBuilder: (context, index) {
                final lesson = _lessons[_selectedLevel]![_selectedGrade]![index];
                return _buildLessonCard(lesson);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelButton(String level, Color color) {
    final isSelected = _selectedLevel == level;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedLevel = level;
          _selectedGrade = 1;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? color : Colors.grey[800],
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        level,
        style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildGradeSelector(List<int> grades) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFF1A1A1A),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: grades.map((grade) {
            final isSelected = _selectedGrade == grade;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text('الصف $grade'),
                selected: isSelected,
                onSelected: (_) {
                  setState(() {
                    _selectedGrade = grade;
                  });
                },
                selectedColor: const Color(0xFFD4AF37),
                backgroundColor: Colors.grey[800],
                labelStyle: TextStyle(
                  color: isSelected ? Colors.black : Colors.white,
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildLessonCard(Map<String, String> lesson) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: const Color(0xFFD4AF37).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ExpansionTile(
        title: Text(
          lesson['title']!,
          style: const TextStyle(
            color: Color(0xFFD4AF37),
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        iconColor: const Color(0xFFD4AF37),
        collapsedIconColor: Colors.grey,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              lesson['content']!,
              style: const TextStyle(
                color: Colors.white70,
                fontFamily: 'Cairo',
                fontSize: 14,
                height: 1.8,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}