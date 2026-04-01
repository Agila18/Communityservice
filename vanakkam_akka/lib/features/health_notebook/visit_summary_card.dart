import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/services/voice_service.dart';
import '../../shared/services/pdf_service.dart';

class VisitSummaryCardScreen extends StatefulWidget {
  const VisitSummaryCardScreen({super.key});

  @override
  State<VisitSummaryCardScreen> createState() => _VisitSummaryCardScreenState();
}

class _VisitSummaryCardScreenState extends State<VisitSummaryCardScreen> {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:8000/api/v1'));
  
  bool _isLoading = true;
  bool _isGeneratingPdf = false;
  Map<String, dynamic>? _summaryData;

  @override
  void initState() {
    super.initState();
    _fetchUnifiedSummary();
  }

  /// Triggers massive backend cross-module aggregation yielding the isolated Clinical Object payload
  Future<void> _fetchUnifiedSummary() async {
    try {
      final res = await _dio.post('/notebook/generate-summary/1'); // In practice map globally configured IDs
      setState(() {
         _summaryData = res.data;
         _isLoading = false;
      });
      
      // Prompt safety and utility immediately upon mounting
      WidgetsBinding.instance.addPostFrameCallback((_) {
         context.read<VoiceService>().speak("உங்களின் மருத்துவ அறிக்கை தயாராகிறது. இதை டாக்டரிடம் அப்படியே காட்டலாம்.");
      });
      
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  /// Explicit binding activating PdfService rendering local UI trees cleanly down to bytes and sharing natively
  Future<void> _generateAndSharePdf() async {
     if (_summaryData == null) return;
     
     setState(() => _isGeneratingPdf = true);
     context.read<VoiceService>().speak("PDF ரிப்போர்ட் தயாராகிறது...");
     
     try {
       final pdfService = PdfService();
       final File pdfFile = await pdfService.generateVisitCard(_summaryData!);
       
       setState(() => _isGeneratingPdf = false);
       
       // Engaging native OS share dialog securely bypassing local storage scoped boundaries
       await Share.shareXFiles([XFile(pdfFile.path)], text: "Vanakkam Akka - Medical Visit Summary (Confidential)");
       
     } catch (e) {
       setState(() => _isGeneratingPdf = false);
       context.read<VoiceService>().speak("மன்னிக்கவும், PDF தயாராகவில்லை.");
     }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("மருத்துவமனை Summary", style: AppTextStyles.headingMedium), // Hospital Summary
        leading: const BackButton(),
        actions: [
           if (!_isLoading && _summaryData != null)
             IconButton(
               icon: const Icon(Icons.share_rounded, color: AppColors.primary),
               color: AppColors.primary,
               onPressed: _isGeneratingPdf ? null : _generateAndSharePdf,
             )
        ],
      ),
      body: SafeArea(
        child: _isLoading 
           ? _buildLoadingState()
           : _summaryData == null 
              ? const Center(child: Text("தகவல் இல்லை (No data)", style: TextStyle(color: Colors.grey)))
              : _buildCard(),
      ),
      // Persistent Share target accessible easily for rural interactions
      floatingActionButton: _isLoading || _summaryData == null ? null : FloatingActionButton.extended(
         onPressed: _isGeneratingPdf ? null : _generateAndSharePdf,
         backgroundColor: AppColors.primary,
         icon: _isGeneratingPdf ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.picture_as_pdf_rounded, color: Colors.white),
         label: Text("பகிர்ந்து கொள் (Share)", style: AppTextStyles.headingMedium.copyWith(color: Colors.white)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildLoadingState() {
     return Center(
       child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             const CircularProgressIndicator(color: AppColors.primary),
             const SizedBox(height: 24),
             Text("உள்ளடக்கம் தயார் ஆகிறது...", style: AppTextStyles.headingMedium),
          ]
       )
     );
  }

  /// Renders visually exactly resolving the strict dual-lingual parameters expected
  Widget _buildCard() {
     final data = _summaryData!;
     
     // Color mapping for dynamic clinical flag visualization
     Color flagColor = AppColors.riskGreen;
     if (data['risk_level'] == "YELLOW") flagColor = AppColors.riskYellow;
     if (data['risk_level'] == "RED") flagColor = AppColors.riskRed;
     
     return SingleChildScrollView(
       padding: const EdgeInsets.all(16.0).copyWith(bottom: 100),
       child: Container(
          decoration: BoxDecoration(
             color: Colors.white,
             borderRadius: BorderRadius.circular(24),
             border: Border.all(color: Colors.grey.shade300),
             boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
             ]
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
               // Header Branding
               Container(
                 padding: const EdgeInsets.all(20),
                 decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24))
                 ),
                 child: Row(
                    children: [
                       const Icon(Icons.badge_rounded, size: 40, color: AppColors.primary),
                       const SizedBox(width: 16),
                       Expanded(
                         child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                               Text("நோயாளி விவரம் (Patient ID)", style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary)),
                               const SizedBox(height: 4),
                               Text("${data['user_name']}", style: AppTextStyles.headingLarge.copyWith(color: AppColors.primary)),
                            ]
                         ),
                       )
                    ],
                 ),
               ),
               
               Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                        // Demographics Map (Eng/Tamil)
                        _buildRow("வயது (Age)", "${data['user_age']} years"),
                        _buildRow("மாவட்டம் (District)", "${data['district']}"),
                        
                        if (data['pregnancy_week'] != null) ...[
                           const Divider(height: 32),
                           _buildRow("கர்ப்ப வாரம் (Maternal Week)", "${data['pregnancy_week']} weeks", color: AppColors.riskGreen),
                        ],
                        
                        const Divider(height: 32),
                        
                        // Current AI Synthesized Paragraph
                        Row(
                           children: [
                              Text("AI சுருக்கம் (Condition Summary)", style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                              const Spacer(),
                              Container(
                                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                 decoration: BoxDecoration(color: flagColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(16)),
                                 child: Text(data['risk_level'], style: TextStyle(color: flagColor, fontWeight: FontWeight.bold, fontSize: 12)),
                              )
                           ]
                        ),
                        const SizedBox(height: 12),
                        Text(
                           data['ai_summary_tamil'] ?? "",
                           style: AppTextStyles.bodyLarge.copyWith(height: 1.5),
                        ),
                        
                        const Divider(height: 32),
                        
                        // Latest Medicines
                        _buildSectionHeader("Medicine (மாத்திரை)", Icons.medication_rounded),
                        const SizedBox(height: 8),
                        Text(
                           data['latest_prescription'] != null ? data['latest_prescription']['explanation'] : "தரவுகள் இல்லை (None recorded)", 
                           style: AppTextStyles.bodyLarge
                        ),
                        
                        const Divider(height: 32),
                        
                        // Latest Labs
                        _buildSectionHeader("Labs (ரத்த பரிசோதனை)", Icons.science_rounded),
                        const SizedBox(height: 8),
                        Text(
                           data['latest_lab'] != null ? data['latest_lab']['explanation'] : "தரவுகள் இல்லை (None recorded)", 
                           style: AppTextStyles.bodyLarge
                        ),
                     ]
                  )
               )
            ]
          )
       )
     );
  }

  Widget _buildRow(String title, String value, {Color? color}) {
     return Padding(
       padding: const EdgeInsets.only(bottom: 12.0),
       child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Expanded(flex: 2, child: Text(title, style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary))),
             Expanded(flex: 3, child: Text(value, style: AppTextStyles.headingMedium.copyWith(color: color ?? AppColors.textPrimary), textAlign: TextAlign.right)),
          ]
       ),
     );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
     return Row(
        children: [
           Icon(icon, size: 20, color: Colors.blueGrey),
           const SizedBox(width: 8),
           Text(title, style: AppTextStyles.headingMedium.copyWith(color: Colors.blueGrey)),
        ]
     );
  }
}
