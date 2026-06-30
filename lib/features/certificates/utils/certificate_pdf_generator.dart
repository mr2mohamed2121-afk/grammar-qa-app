// lib/features/certificates/utils/certificate_pdf_generator.dart
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class CertificatePdfGenerator {
  static Future<void> generateAndShare({
    required String userName,
    required String category,
    required String level,
    required int score,
    required int totalQuestions,
    required double percentage,
    required String grade,
    required DateTime completedAt,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (pw.Context context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColor.fromHex('D4AF37'), width: 5),
              borderRadius: pw.BorderRadius.circular(20),
            ),
            padding: const pw.EdgeInsets.all(40),
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  'شهادة إتمام',
                  style: pw.TextStyle(
                    fontSize: 40,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex('1E3A5F'),
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Container(
                  width: 200,
                  height: 3,
                  color: PdfColor.fromHex('D4AF37'),
                ),
                pw.SizedBox(height: 30),
                pw.Text(
                  'يشهد تطبيق أستاذ النحو العربي بأن',
                  style: pw.TextStyle(fontSize: 20),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  userName,
                  style: pw.TextStyle(
                    fontSize: 32,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex('1E3A5F'),
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'قد أتم بنجاح اختبار $category - $level',
                  style: pw.TextStyle(fontSize: 18),
                ),
                pw.SizedBox(height: 30),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    _buildStatBox('النقاط', '$score / ${totalQuestions * 10}'),
                    pw.SizedBox(width: 30),
                    _buildStatBox('النسبة', '${percentage.toStringAsFixed(1)}%'),
                    pw.SizedBox(width: 30),
                    _buildStatBox('التقدير', grade),
                  ],
                ),
                pw.SizedBox(height: 40),
                pw.Text(
                  'تاريخ الإصدار: ${completedAt.day}/${completedAt.month}/${completedAt.year}',
                  style: pw.TextStyle(
                    fontSize: 14,
                    color: PdfColor.fromHex('666666'),
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'رقم الشهادة: CERT-${completedAt.year}-${completedAt.millisecond}',
                  style: pw.TextStyle(
                    fontSize: 12,
                    color: PdfColor.fromHex('999999'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    // Save to temp directory
    final output = await getTemporaryDirectory();
    final filePath = '${output.path}/certificate_${completedAt.millisecondsSinceEpoch}.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());
    
    // Share using share_plus
    await Share.shareXFiles(
      [XFile(filePath)],
      text: 'شهادتي من تطبيق أستاذ النحو العربي! 🎓\n\n'
          'الاختبار: $category - $level\n'
          'النسبة: ${percentage.toStringAsFixed(1)}%\n'
          'التقدير: $grade',
    );
  }

  static pw.Widget _buildStatBox(String label, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColor.fromHex('D4AF37')),
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('1E3A5F'),
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            label,
            style: pw.TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}