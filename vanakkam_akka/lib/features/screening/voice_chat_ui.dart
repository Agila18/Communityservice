import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'screening_provider.dart';
import '../../core/router/app_router.dart';
import '../../core/state/cycle_mode_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/services/voice_service.dart';
import '../../shared/widgets/voice_button.dart';

/// Interactive AI Health Screening Conversation Screen
class VoiceChatUiScreen extends StatefulWidget {
  const VoiceChatUiScreen({super.key});

  @override
  State<VoiceChatUiScreen> createState() => _VoiceChatUiScreenState();
}

class _VoiceChatUiScreenState extends State<VoiceChatUiScreen> {
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
       _startConversation();
    });
  }
  
  Future<void> _startConversation() async {
    final provider = context.read<ScreeningProvider>();
    final voice = context.read<VoiceService>();
    
    provider.initSession();
    
    // In actual implementation, read User Name from AuthService
    final greeting = voice.getGreeting("அக்கா");
    final initialMsg = "$greeting! உங்களின் உடல்நிலையை பரிசோதிக்க வந்திருக்கிறேன். உங்களுக்கு உடம்புல ஏதும் தொந்தரவு இருக்கா?";
    
    provider.addAiMessage(initialMsg);
    await voice.speak(initialMsg);
  }

  void _onUserSpeak(String text) async {
    if (text.isEmpty) return;
    
    final provider = context.read<ScreeningProvider>();
    final voice = context.read<VoiceService>();
    
    context.read<VoiceService>().stop(); // Stop anything currently speaking
    
    final aiReply = await provider.sendMessage(text);
    _scrollToBottom();
    
    if (aiReply != null) {
      await voice.speak(aiReply);
    }
    
    if (provider.isComplete) {
      voice.announceRiskResult(provider.currentRiskLevel, "உங்கள் உடல்நல அறிக்கை தயாராக உள்ளது.");
      _scrollToBottom();
    }
  }
  
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  String _getStatusIndicator(VoiceService voice, ScreeningProvider screening) {
     if (voice.isListening) return "கேட்கிறேன்..."; // Listening
     if (screening.isThinking) return "யோசிக்கிறேன்..."; // Thinking
     if (voice.isSpeaking) return "பதில் சொல்கிறேன்..."; // Speaking
     return "பேச மைக்கை அழுத்தவும்"; // Press Mic to Speak
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("உடல்நல பரிசோதனை", style: AppTextStyles.headingMedium), // Health Screening
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            context.read<VoiceService>().stop();
            context.pop();
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Consumer<ScreeningProvider>(
                builder: (context, screening, child) {
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                    itemCount: screening.messages.length + (screening.isComplete ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == screening.messages.length) {
                         // Final assessment trigger intercept
                         if (screening.currentRiskLevel == 'PREGNANCY_TRANSITION_PROMPT') {
                             return _buildPregnancyTransition(context);
                         }
                         return _HealthSignalCard(riskLevel: screening.currentRiskLevel);
                      }
                      final msg = screening.messages[index];
                      return _AnimatedChatBubble(message: msg);
                    },
                  );
                },
              ),
            ),
            
            // Status and Voice Activation Bar
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -4))
                ]
              ),
              child: Consumer2<VoiceService, ScreeningProvider>(
                builder: (context, voice, screening, child) {
                  final statusText = _getStatusIndicator(voice, screening);
                  final isBusy = voice.isListening || screening.isThinking || voice.isSpeaking;
                  
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: isBusy ? AppColors.primary : AppColors.textSecondary,
                          fontWeight: isBusy ? FontWeight.w600 : FontWeight.w400,
                        ),
                        child: Text(statusText),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                          onTap: () {
                             // Dismiss keyboard if testing manually
                             FocusScope.of(context).unfocus();
                          },
                          child: VoiceButton(onResult: _onUserSpeak)
                      )
                    ],
                  );
                }
              ),
            )
          ],
        ),
      ),
    );
  }

  // =============================================
  // AI Transition Block
  // =============================================
  Widget _buildPregnancyTransition(BuildContext context) {
     return Container(
       margin: const EdgeInsets.only(top: 16.0, bottom: 32.0),
       padding: const EdgeInsets.all(24.0),
       decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(24.0),
          border: Border.all(color: AppColors.accent, width: 2)
       ),
       child: Column(
          children: [
             const Icon(Icons.pregnant_woman_rounded, size: 64, color: AppColors.primary),
             const SizedBox(height: 16),
             Text(
                "கர்ப்ப பரிசோதனை (Pregnancy Test) செய்து உறுதி செய்துவிட்டீர்களா?",
                style: AppTextStyles.headingMedium.copyWith(color: AppColors.primary),
                textAlign: TextAlign.center,
             ),
             const SizedBox(height: 24),
             Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                   ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                      onPressed: () async {
                         await context.read<CycleModeProvider>().confirmPregnancyFromScreening();
                         if (context.mounted) {
                           context.go(AppRouter.cycleTracker);
                         }
                      },
                      child: Text("ஆம் (Yes)", style: AppTextStyles.headingMedium.copyWith(color: Colors.white)),
                   ),
                   OutlinedButton(
                      onPressed: () => context.pop(),
                      child: Text("இல்லை", style: AppTextStyles.headingMedium.copyWith(color: AppColors.primary)),
                   )
                ],
             )
          ]
       )
     );
  }
}

/// Slide-in implicit animation for AI and User chat bubbles
class _AnimatedChatBubble extends StatelessWidget {
  final ChatMessage message;

  const _AnimatedChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isAi = !message.isUser;
    
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutBack,
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(isAi ? -50 * (1 - value) : 50 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: Align(
              alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
              child: Container(
                margin: const EdgeInsets.only(bottom: 16.0),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                decoration: BoxDecoration(
                  color: isAi ? AppColors.primary.withValues(alpha: 0.1) : AppColors.riskGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(isAi ? 0 : 20),
                    bottomRight: Radius.circular(isAi ? 20 : 0),
                  ),
                  border: Border.all(
                    color: isAi ? AppColors.primary.withValues(alpha: 0.3) : AppColors.riskGreen.withValues(alpha: 0.3),
                    width: 1.5,
                  )
                ),
                child: Text(
                  message.text,
                  style: AppTextStyles.bodyLarge.copyWith(
                     color: AppColors.textPrimary,
                     fontWeight: isAi ? FontWeight.w500 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
        );
      }
    );
  }
}

/// Final Risk Assessment View rendering based on API signals
class _HealthSignalCard extends StatelessWidget {
  final String riskLevel;
  
  const _HealthSignalCard({required this.riskLevel});

  @override
  Widget build(BuildContext context) {
     Color riskColor = AppColors.riskGreen;
     String text = "நீங்கள் நலமாக இருக்கீங்க";
     IconData icon = Icons.check_circle_outline_rounded;
     
     if (riskLevel.toUpperCase() == 'YELLOW') {
       riskColor = AppColors.riskYellow;
       text = "கவனிக்க வேண்டும். ஆரம்ப சுகாதார நிலையத்திற்கு செல்லவும்.";
       icon = Icons.health_and_safety_outlined;
     } else if (riskLevel.toUpperCase() == 'RED') {
       riskColor = AppColors.riskRed;
       text = "அவசரம்! உடனடியாக மருத்துவமனை போங்க!";
       icon = Icons.warning_amber_rounded;
     }
     
     return TweenAnimationBuilder<double>(
       duration: const Duration(milliseconds: 600),
       curve: Curves.elasticOut,
       tween: Tween<double>(begin: 0.0, end: 1.0),
       builder: (context, value, child) {
         return Transform.scale(
           scale: value,
           child: Card(
             margin: const EdgeInsets.only(top: 16.0, bottom: 32.0),
             color: riskColor.withValues(alpha: 0.05),
             elevation: 0,
             shape: RoundedRectangleBorder(
                side: BorderSide(color: riskColor, width: 2),
                borderRadius: BorderRadius.circular(24)
             ),
             child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                   children: [
                      Icon(icon, color: riskColor, size: 64),
                      const SizedBox(height: 16),
                      Text(
                        text, 
                        style: AppTextStyles.headingMedium.copyWith(color: riskColor),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: riskColor),
                        onPressed: () => context.go(AppRouter.home),
                        child: Text("சரி (OK)", style: AppTextStyles.headingMedium.copyWith(color: Colors.white)),
                      )
                   ]
                )
             )
           ),
         );
       }
     );
  }
}
