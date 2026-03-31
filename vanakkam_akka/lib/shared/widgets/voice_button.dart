import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

enum VoiceState { idle, listening, processing, error }

/// A highly accessible, high-contrast pulsing voice button for Tamil rural users.
/// Integrates directly with speech_to_text using the ta_IN locale.
class VoiceButton extends StatefulWidget {
  final Function(String) onResult;

  const VoiceButton({super.key, required this.onResult});

  @override
  State<VoiceButton> createState() => _VoiceButtonState();
}

class _VoiceButtonState extends State<VoiceButton> with SingleTickerProviderStateMixin {
  late stt.SpeechToText _speech;
  bool _isAvailable = false;
  VoiceState _state = VoiceState.idle;
  String _recognizedText = '';
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initSpeech();
    
    // Setup pulsing animation for the listening state
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initSpeech() async {
    _isAvailable = await _speech.initialize(
      onError: (error) => _setErrorState(),
      onStatus: (status) {
        if (status == 'notListening' && _state == VoiceState.listening) {
           // We finished listening. Transition to processing, then emit result
           setState(() => _state = VoiceState.processing);
           _pulseController.stop();

           if (_recognizedText.isNotEmpty) {
               widget.onResult(_recognizedText);
           }
           
           // Quickly reset to idle after small delay for processing UX
           Future.delayed(const Duration(milliseconds: 500), () {
             if (mounted) setState(() => _state = VoiceState.idle);
           });
        }
      },
    );
    setState(() {});
  }

  void _setErrorState() {
    setState(() => _state = VoiceState.error);
    _pulseController.stop();
    // Return to idle after a few seconds showing the error message
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _state == VoiceState.error) {
        setState(() => _state = VoiceState.idle);
      }
    });
  }

  void _toggleListening() async {
    if (!_isAvailable) {
       _setErrorState();
       return;
    }

    if (_speech.isListening) {
      _speech.stop();
      setState(() => _state = VoiceState.processing);
    } else {
      _recognizedText = '';
      setState(() => _state = VoiceState.listening);
      _pulseController.repeat(reverse: true);
      
      await _speech.listen(
        onResult: (result) {
          _recognizedText = result.recognizedWords;
          if (result.finalResult) {
            widget.onResult(_recognizedText);
            setState(() => _state = VoiceState.idle);
            _pulseController.stop();
          }
        },
        localeId: 'ta_IN', // Enforce Tamil India locale for recognition
        cancelOnError: true,
      );
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHintText(),
        const SizedBox(height: 12),
        _buildButton(),
      ],
    );
  }

  Widget _buildHintText() {
    String hint = "";
    Color hintColor = AppColors.textSecondary;
    
    switch (_state) {
      case VoiceState.idle:
        hint = "பேசுங்கள்"; // Speak
        break;
      case VoiceState.listening:
        hint = "கவனிக்கிறது..."; // Listening...
        hintColor = AppColors.riskRed;
        break;
      case VoiceState.processing:
        hint = "செயலாக்குகிறது..."; // Processing...
        hintColor = AppColors.primary;
        break;
      case VoiceState.error:
        hint = "மீண்டும் முயற்சிக்கவும்"; // Try again
        hintColor = AppColors.riskRed;
        break;
    }

    return Text(
      hint,
      style: AppTextStyles.voiceHint.copyWith(
        color: hintColor,
        fontWeight: _state != VoiceState.idle ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildButton() {
    final bool isListening = _state == VoiceState.listening;
    final bool isProcessing = _state == VoiceState.processing;
    
    return GestureDetector(
      onTap: _toggleListening,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          // Pulse scale effect only triggers during listening state
          return Transform.scale(
            scale: isListening ? _pulseAnimation.value : 1.0,
            child: Container(
              width: 72, // Large 72px diameter touch target
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isListening ? AppColors.riskRed : AppColors.primary,
                boxShadow: [
                  BoxShadow(
                    color: (isListening ? AppColors.riskRed : AppColors.primary)
                        .withValues(alpha: 0.3),
                    spreadRadius: isListening ? 8 : 2,
                    blurRadius: isListening ? 12 : 6,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: isProcessing 
                 ? const Padding(
                     padding: EdgeInsets.all(18.0),
                     child: CircularProgressIndicator(
                       color: Colors.white,
                       strokeWidth: 3,
                     ),
                   )
                 : Icon(
                     isListening ? Icons.mic : Icons.mic_none,
                     color: Colors.white,
                     size: 36, // Explicit large icon inside button
                   ),
            ),
          );
        },
      ),
    );
  }
}
