import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'dart:math' show cos, sin, pi;

/// شاشة الشهادة - PDF + مشاركة
class CertificateScreen extends StatefulWidget {
  final String userName;
  final String level;
  final double percentage;
  final DateTime completionDate;

  const CertificateScreen({
    super.key,
    required this.userName,
    required this.level,
    required this.percentage,
    required this.completionDate,
  });

  @override
  State<CertificateScreen> createState() => _CertificateScreenState();
}

class _CertificateScreenState extends State<CertificateScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  bool _isGenerating = false;
  String? _pdfPath;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _grade {
    if (widget.percentage >= 95) return 'ممتاز مرتفع';
    if (widget.percentage >= 90) return 'ممتاز';
    if (widget.percentage >= 85) return 'جيد جداً مرتفع';
    if (widget.percentage >= 80) return 'جيد جداً';
    if (widget.percentage >= 75) return 'جيد مرتفع';
    if (widget.percentage >= 70) return 'جيد';
    if (widget.percentage >= 65) return 'مقبول مرتفع';
    if (widget.percentage >= 60) return 'مقبول';
    return 'ضعيف';
  }

  String get _gradeEmoji {
    if (widget.percentage >= 90) return '🏆';
    if (widget.percentage >= 80) return '🥇';
    if (widget.percentage >= 70) return '🥈';
    if (widget.percentage >= 60) return '🥉';
    return '📚';
  }

  /// إنشاء PDF الشهادة
  Future<pw.Document> _generatePdf() async {
    final pdf = pw.Document();
    final fontData = await rootBundle.load('assets/fonts/Cairo-Regular.ttf');
    final boldFontData = await rootBundle.load('assets/fonts/Cairo-Bold.ttf');
    final cairoFont = pw.Font.ttf(fontData);
    final cairoBold = pw.Font.ttf(boldFontData);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (pw.Context context) {
          return pw.Container(
            width: double.infinity,
            height: double.infinity,
            decoration: pw.BoxDecoration(
              border: pw.Border.all(
                color: PdfColor.fromHex('D4AF37'),
                width: 8,
              ),
            ),
            child: pw.Stack(
              children: [
                // Pattern إسلامي
                pw.Positioned.fill(
                  child: pw.Opacity(
                    opacity: 0.05,
                    child: pw.CustomPaint(
                      size: const PdfPoint(800, 600),
                      painter: (canvas, size) {
                        final paint = PdfPaint()
                          ..color = PdfColor.fromHex('D4AF37')
                          ..strokeWidth = 1;
                        
                        for (double x = 0; x < size.x; x += 60) {
                          for (double y = 0; y < size.y; y += 60) {
                            _drawIslamicStarPdf(canvas, x, y, 20, paint);
                          }
                        }
                      },
                    ),
                  ),
                ),
                
                // المحتوى
                pw.Center(
                  child: pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      // عنوان
                      pw.Text(
                        'شهادة إتمام',
                        style: pw.TextStyle(
                          font: cairoBold,
                          fontSize: 48,
                          color: PdfColor.fromHex('D4AF37'),
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Container(
                        width: 300,
                        height: 3,
                        color: PdfColor.fromHex('D4AF37'),
                      ),
                      pw.SizedBox(height: 30),
                      
                      // نص الشهادة
                      pw.Text(
                        'تُمنح هذه الشهادة إلى',
                        style: pw.TextStyle(
                          font: cairoFont,
                          fontSize: 20,
                          color: PdfColor.fromHex('333333'),
                        ),
                      ),
                      pw.SizedBox(height: 15),
                      
                      // اسم المستخدم
                      pw.Text(
                        widget.userName,
                        style: pw.TextStyle(
                          font: cairoBold,
                          fontSize: 36,
                          color: PdfColor.fromHex('0D0D0D'),
                        ),
                      ),
                      pw.SizedBox(height: 20),
                      
                      // التفاصيل
                      pw.Text(
                        'لإتمامه بنجاح اختبار قواعد اللغة العربية',
                        style: pw.TextStyle(
                          font: cairoFont,
                          fontSize: 18,
                          color: PdfColor.fromHex('555555'),
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        'المستوى: ${widget.level}',
                        style: pw.TextStyle(
                          font: cairoFont,
                          fontSize: 18,
                          color: PdfColor.fromHex('555555'),
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        'النسبة: ${widget.percentage.toStringAsFixed(1)}%',
                        style: pw.TextStyle(
                          font: cairoBold,
                          fontSize: 24,
                          color: PdfColor.fromHex('2E7D32'),
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        'التقدير: $_grade',
                        style: pw.TextStyle(
                          font: cairoBold,
                          fontSize: 22,
                          color: PdfColor.fromHex('D4AF37'),
                        ),
                      ),
                      pw.SizedBox(height: 40),
                      
                      // التاريخ والتوقيع
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                        children: [
                          pw.Column(
                            children: [
                              pw.Text(
                                'تاريخ الإصدار',
                                style: pw.TextStyle(
                                  font: cairoFont,
                                  fontSize: 14,
                                  color: PdfColor.fromHex('777777'),
                                ),
                              ),
                              pw.SizedBox(height: 5),
                              pw.Text(
                                '${widget.completionDate.day}/${widget.completionDate.month}/${widget.completionDate.year}',
                                style: pw.TextStyle(
                                  font: cairoBold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          pw.Column(
                            children: [
                              pw.Text(
                                'إشراف',
                                style: pw.TextStyle(
                                  font: cairoFont,
                                  fontSize: 14,
                                  color: PdfColor.fromHex('777777'),
                                ),
                              ),
                              pw.SizedBox(height: 5),
                              pw.Text(
                                'أستاذ محمد أحمد الوهيدي',
                                style: pw.TextStyle(
                                  font: cairoBold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf;
  }

  void _drawIslamicStarPdf(dynamic canvas, double x, double y, double radius, dynamic paint) {
    final path = Path();
    const points = 8;
    
    for (int i = 0; i < points * 2; i++) {
      final angle = (i * 22.5 - 90) * pi / 180;
      final r = i % 2 == 0 ? radius : radius * 0.38;
      final px = x + r * cos(angle);
      final py = y + r * sin(angle);
      
      if (i == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  /// حفظ PDF
  Future<void> _savePdf() async {
    setState(() => _isGenerating = true);
    
    try {
      final pdf = await _generatePdf();
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/certificate_${widget.userName}_${widget.level}.pdf');
      await file.writeAsBytes(await pdf.save());
      
      setState(() {
        _pdfPath = file.path;
        _isGenerating = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ تم حفظ الشهادة بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _isGenerating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ خطأ: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// مشاركة PDF
  Future<void> _sharePdf() async {
    if (_pdfPath == null) {
      await _savePdf();
    }
    
    if (_pdfPath != null) {
      await Share.shareXFiles(
        [XFile(_pdfPath!)],
        text: '🏆 شهادة إتمام - ${widget.userName} - ${widget.level}',
      );
    }
  }

  /// طباعة الشهادة
  Future<void> _printPdf() async {
    final pdf = await _generatePdf();
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final passed = widget.percentage >= 80;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text(
          'شهادة الإتمام',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF0D0D0D),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFD4AF37)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ✅ الشهادة التفاعلية
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1A1A1A), Color(0xFF2A2A2A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFD4AF37),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFD4AF37).withOpacity(0.3),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // التاج
                          Text(
                            passed ? '👑' : '📜',
                            style: const TextStyle(fontSize: 60),
                          ),
                          const SizedBox(height: 20),
                          
                          // العنوان
                          const Text(
                            'شهادة إتمام',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFD4AF37),
                              fontFamily: 'Cairo',
                            ),
                          ),
                          const SizedBox(height: 10),
                          
                          // الخط الذهبي
                          Container(
                            width: 200,
                            height: 3,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Color(0xFFD4AF37),
                                  Color(0xFFF4E4BC),
                                  Color(0xFFD4AF37),
                                  Colors.transparent,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 30),
                          
                          // اسم المستخدم
                          Text(
                            widget.userName,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Cairo',
                            ),
                          ),
                          const SizedBox(height: 15),
                          
                          // التفاصيل
                          Text(
                            'المستوى: ${widget.level}',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white70,
                              fontFamily: 'Cairo',
                            ),
                          ),
                          const SizedBox(height: 10),
                          
                          // النسبة
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: passed
                                  ? Colors.green.withOpacity(0.2)
                                  : Colors.orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: passed ? Colors.green : Colors.orange,
                                width: 2,
                              ),
                            ),
                            child: Text(
                              '${widget.percentage.toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: passed ? Colors.green : Colors.orange,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          
                          // التقدير
                          Text(
                            'التقدير: $_grade $_gradeEmoji',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFD4AF37),
                              fontFamily: 'Cairo',
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          // التاريخ
                          Text(
                            'تاريخ الإصدار: ${widget.completionDate.day}/${widget.completionDate.month}/${widget.completionDate.year}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white54,
                              fontFamily: 'Cairo',
                            ),
                          ),
                          const SizedBox(height: 10),
                          
                          // الإشراف
                          const Text(
                            'إشراف: أستاذ محمد أحمد الوهيدي',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white54,
                              fontFamily: 'Cairo',
                            ),
                          ),
                          
                          if (!passed) ...[
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.orange.withOpacity(0.3),
                                ),
                              ),
                              child: const Text(
                                '⚠️ تحتاج 80% على الأقل للحصول على شهادة',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontFamily: 'Cairo',
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 30),
            
            // ✅ أزرار التحكم
            if (passed) ...[
              _buildActionButton(
                icon: Icons.download,
                label: 'تحميل PDF',
                color: const Color(0xFFD4AF37),
                onPressed: _isGenerating ? null : _savePdf,
                isLoading: _isGenerating,
              ),
              const SizedBox(height: 12),
              
              _buildActionButton(
                icon: Icons.share,
                label: 'مشاركة الشهادة',
                color: Colors.green,
                onPressed: _sharePdf,
              ),
              const SizedBox(height: 12),
              
              _buildActionButton(
                icon: Icons.print,
                label: 'طباعة الشهادة',
                color: Colors.blue,
                onPressed: _printPdf,
              ),
            ] else ...[
              _buildActionButton(
                icon: Icons.refresh,
                label: 'إعادة الاختبار',
                color: const Color(0xFFD4AF37),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(icon, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}