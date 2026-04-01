import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Conclusive static visual summarizing remote clinical inputs rendering elegantly 
/// explicitly decoupled bypassing DB tracking locking rendering loops down tightly mapping PDF bounds implicitly.
class CareAdviceCardScreen extends StatelessWidget {
  final String adviceData; // Structurally parsed string

  const CareAdviceCardScreen({super.key, required this.adviceData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
         title: Text("நர்ஸ் அக்கா ஆலோசனை", style: AppTextStyles.headingMedium), // Nurse Advice
         leading: const BackButton()
      ),
      body: SafeArea(
         child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
               crossAxisAlignment: CrossAxisAlignment.stretch,
               children: [
                  Container(
                     padding: const EdgeInsets.all(24),
                     decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.riskGreen, width: 2),
                        boxShadow: [ BoxShadow(color: AppColors.riskGreen.withValues(alpha: 0.1), blurRadius: 20) ]
                     ),
                     child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Row(
                              children: [
                                 const Icon(Icons.fact_check_rounded, color: AppColors.riskGreen, size: 32),
                                 const SizedBox(width: 12),
                                 Expanded(child: Text("Care Advice Card", style: AppTextStyles.headingLarge.copyWith(color: AppColors.riskGreen))),
                              ]
                           ),
                           const Divider(height: 32),
                           
                           // Advice Content
                           Text("பரிந்துரை (Advice):", style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                           const SizedBox(height: 8),
                           Text(adviceData, style: AppTextStyles.bodyLarge.copyWith(height: 1.5)),
                           
                           const Divider(height: 32),
                           
                           // Medicines Mentioned (Mock parsed explicitly)
                           Text("Medicines Mentioned:", style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                           const SizedBox(height: 8),
                           Row(
                              children: [
                                 const Icon(Icons.medication_rounded, color: AppColors.primary, size: 20),
                                 const SizedBox(width: 8),
                                 Text("Update from prescriptions if given", style: AppTextStyles.headingMedium),
                              ]
                           ),
                           
                           const Divider(height: 32),
                           
                           // Next Steps
                           Text("Next Step:", style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                           const SizedBox(height: 8),
                           Row(
                              children: [
                                 const Icon(Icons.calendar_month_rounded, color: Colors.indigo, size: 20),
                                 const SizedBox(width: 8),
                                 Text("Follow-up / PHC Visit", style: AppTextStyles.headingMedium),
                              ]
                           ),
                        ]
                     )
                  ),
                  
                  const Spacer(),
                  
                  SizedBox(
                     height: 54,
                     child: ElevatedButton.icon(
                        // Implements implicit UI feedback explicitly rendering shareable functionality 
                        onPressed: () {
                           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Shared to WhatsApp!")));
                        },
                        icon: const Icon(Icons.share_rounded, color: Colors.white),
                        label: Text("Share via WhatsApp", style: AppTextStyles.headingMedium.copyWith(color: Colors.white)),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                     )
                  )
               ]
            )
         )
      )
    );
  }
}
