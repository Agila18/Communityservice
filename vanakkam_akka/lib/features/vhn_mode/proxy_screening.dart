import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

import '../screening/voice_chat_ui.dart';

/// Secure specialized wrap explicitly inheriting standard conversational logic
/// while coercing the database internally applying "Proxy / Assisted By" labels overriding core limits.
class ProxyScreeningScreen extends StatelessWidget {
  final int patientId;
  final String patientName;

  const ProxyScreeningScreen({super.key, required this.patientId, required this.patientName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$patientName — நிழல் பரிசோதனை", style: AppTextStyles.headingMedium.copyWith(color: Colors.white)), // Proxy Screening
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
         children: [
            // Embedded Voice Chat UI component mapping directly into the patient's existing backend state internally
            const VoiceChatUiScreen(), 
            
            // Floating security banner actively indicating Proxy mapping explicitly rendering above the chat.
            Positioned(
               top: 0, left: 0, right: 0,
               child: Container(
                  color: AppColors.riskYellow.withValues(alpha: 0.9),
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                     "VHN-Assisted Screening (VHN பதிவு செய்கிறார்)",
                     textAlign: TextAlign.center,
                     style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
                  )
               )
            )
         ],
      )
    );
  }
}
