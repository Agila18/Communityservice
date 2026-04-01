import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Active 2G Voice interface aggressively mirroring established WhatsApp Voice note flows avoiding mechanical confusion.
/// Decouples literal real-time STT bindings mapping instead into discrete heavy-payload HTTP chunks ensuring delivery.
class VoiceMessageChatScreen extends StatefulWidget {
  final int sessionId;
  final String initialSummary;

  const VoiceMessageChatScreen({super.key, required this.sessionId, required this.initialSummary});

  @override
  State<VoiceMessageChatScreen> createState() => _VoiceMessageChatScreenState();
}

class _VoiceMessageChatScreenState extends State<VoiceMessageChatScreen> {
  bool _isRecording = false;
  final List<String> _messages = []; // Mock array isolating locally generated state strictly for the visual prototype

  @override
  void initState() {
    super.initState();
    // Auto-inject the generated clinical timeline payload explicitly mapping exactly what the VHN will see natively
    _messages.add("System: AI Summary sent to Nurse\n\n${widget.initialSummary}");
  }

  /// Interactive layout handler isolating explicit 'Hold-to-Record' interactions.
  void _startRecording() {
     setState(() => _isRecording = true);
     // Audio chunk recording bindings initialize natively here...
  }

  void _stopRecording() {
     setState(() {
        _isRecording = false;
        // Mocking the completion trigger simulating explicit audio packet generation logic
        _messages.add("உங்க ஆடியோ பதிவு அனுப்பப்பட்டது (Audio Message Sent 🎤)");
     });
     
     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sent securely over 2G")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
         title: Text("குரல் பதிவு (Voice Note)", style: AppTextStyles.headingMedium),
         leading: const BackButton()
      ),
      body: SafeArea(
         child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
               Expanded(
                 child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                       final msg = _messages[index];
                       final isSystem = msg.startsWith("System:");
                       
                       return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                             color: isSystem ? Colors.black87 : AppColors.primary.withValues(alpha: 0.1),
                             borderRadius: BorderRadius.circular(16),
                             border: isSystem ? null : Border.all(color: AppColors.primary)
                          ),
                          child: Text(
                             msg, 
                             style: AppTextStyles.bodyLarge.copyWith(color: isSystem ? Colors.white : AppColors.textPrimary)
                          )
                       );
                    }
                 )
               ),
               
               // Dynamic Audio Trigger Visual block adapting heavily mimicking local App norms
               Container(
                  padding: const EdgeInsets.all(32),
                  decoration: const BoxDecoration(
                     color: Colors.white,
                     border: Border(top: BorderSide(color: Colors.black12))
                  ),
                  child: Column(
                     children: [
                        Text(
                           _isRecording ? "பேசவும்... (Recording...)" : "விளக்கத்தை வாய்ஸ்-ஆக அனுப்புங்கள்", 
                           style: AppTextStyles.headingMedium.copyWith(color: _isRecording ? AppColors.riskRed : AppColors.textPrimary)
                        ),
                        const SizedBox(height: 24),
                        
                        GestureDetector(
                           onLongPress: _startRecording,
                           onLongPressUp: _stopRecording,
                           child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: _isRecording ? 100 : 80,
                              height: _isRecording ? 100 : 80,
                              decoration: BoxDecoration(
                                 color: _isRecording ? AppColors.riskRed : AppColors.riskGreen,
                                 shape: BoxShape.circle,
                                 boxShadow: _isRecording 
                                     ? [BoxShadow(color: AppColors.riskRed.withValues(alpha: 0.5), blurRadius: 20, spreadRadius: 10)]
                                     : [],
                              ),
                              child: const Icon(Icons.mic_rounded, color: Colors.white, size: 40),
                           )
                        ),
                        
                        const SizedBox(height: 16),
                        Text(
                           "பிடித்துக்கொண்டு பேசுங்கள்",  // Hold to Record
                           style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)
                        )
                     ],
                  )
               )
            ]
         )
      ),
    );
  }
}
