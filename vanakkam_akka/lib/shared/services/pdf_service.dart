import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Highly specialized static compiler converting dynamic Flutter structural 
/// bounds down into rigid printable and sharable ISO A5 documents.
/// Ensures Google Unicode rendering engines cleanly handle complex Tamil glyph loops.
class PdfService {
  Future<File> generateVisitCard(Map<String, dynamic> data) async {
    final pdf = pw.Document();
    
    // Asynchronously bridge natively compiled TTF curves specifically targeting indic-script accuracy
    final font = await PdfGoogleFonts.notoSansTamilRegular();
    final fontBold = await PdfGoogleFonts.notoSansTamilBold();
    
    // Construct A5 rigid mapping for standard PHC/Clinician binders
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        theme: pw.ThemeData.withFont(base: font, bold: fontBold),
        build: (pw.Context context) {
           return pw.Column(
             crossAxisAlignment: pw.CrossAxisAlignment.start,
             children: [
                pw.Center(
                  child: pw.Text("Vanakkam Akka - Medical summary Card", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.deepOrange800))
                ),
                pw.SizedBox(height: 12),
                pw.Divider(),
                pw.SizedBox(height: 12),
                
                // Section 1: Core Triage Demographics mapping English structure for Physician scan
                _buildSection("Patient details", "நோயாளி விவரம்: ${data['user_name']}, Age: ${data['user_age']}, District: ${data['district']}", font, fontBold),
                
                // Section 2: Clinical Risk Evaluation
                if (data['pregnancy_week'] != null)
                   _buildSection("Maternal Age", "கர்ப்ப வாரம்: ${data['pregnancy_week']} weeks", font, fontBold),
                   
                _buildSection("Latest Assessment Risk", "தற்போதைய ஆபத்து நிலை: ${data['risk_level']}", font, fontBold),
                
                pw.SizedBox(height: 8),
                
                // Section 3: Subjective AI Paragraph matching Tamil descriptions
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(color: PdfColors.grey100, border: pw.Border.all(color: PdfColors.grey300)),
                  child: pw.Column(
                     crossAxisAlignment: pw.CrossAxisAlignment.start,
                     children: [
                        pw.Text("AI Summary (Tamil)", style: const pw.TextStyle(fontSize: 10, color: PdfColors.blueGrey800)),
                        pw.SizedBox(height: 4),
                        pw.Text(data['ai_summary_tamil'] ?? "", style: pw.TextStyle(font: font, fontSize: 13, lineSpacing: 1.5)),
                     ]
                  )
                ),
                
                pw.SizedBox(height: 16),
                
                // Section 4 & 5: OCR Extractions securely surfaced
                _buildSection("Current Medications (OCR Extracted)", data['latest_prescription'] != null ? data['latest_prescription']['explanation'] : "No medicines on file / தரவுகள் இல்லை", font, fontBold),
                pw.SizedBox(height: 8),
                _buildSection("Recent Lab Observations", data['latest_lab'] != null ? data['latest_lab']['explanation'] : "No labs on file / பரிசோதனைகள் இல்லை", font, fontBold),
             ]
           );
        }
      )
    );
    
    // Save locally buffering entirely into OS storage bindings bypassing explicit SD card perm locks
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/visit_summary_${DateTime.now().millisecondsSinceEpoch}.pdf");
    await file.writeAsBytes(await pdf.save());
    
    return file;
  }
  
  // Cleanly structured reusable hierarchy drawing the explicit Side-by-Side English mapping requested
  pw.Widget _buildSection(String engTitle, String content, pw.Font font, pw.Font fontBold) {
     return pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 12),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
             pw.Text(engTitle, style: pw.TextStyle(font: fontBold, fontSize: 11, color: PdfColors.blueGrey600)),
             pw.SizedBox(height: 4),
             pw.Text(content, style: pw.TextStyle(font: font, fontSize: 13)),
          ]
        )
     );
  }
}
