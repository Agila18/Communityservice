import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/services/auth_service.dart';
import '../../shared/services/voice_service.dart';

/// Full screen Tamil-focused Firebase OTP phone entry interface.
class OtpLoginScreen extends StatefulWidget {
  const OtpLoginScreen({super.key});

  @override
  State<OtpLoginScreen> createState() => _OtpLoginScreenState();
}

class _OtpLoginScreenState extends State<OtpLoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  
  bool _isOtpSent = false;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    // Voice prompt automatically speaks instructions when screen loads for accessibility
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VoiceService>().speak("உங்கள் தொலைபேசி எண்ணை உள்ளிடவும்");
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.length != 10) {
      setState(() => _errorMessage = "சரியான 10 இலக்க எண்ணை உள்ளிடவும்"); // Enter valid 10 digit number
      context.read<VoiceService>().speak(_errorMessage);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final authService = context.read<AuthService>();
    await authService.signInWithPhone(
      phone,
      onCodeSent: (String verId) {
        setState(() {
          _isOtpSent = true;
          _isLoading = false;
        });
        context.read<VoiceService>().speak("OTP அனுப்பப்பட்டுள்ளது. அதை உள்ளிடவும்"); // OTP sent, please enter
      },
      onError: (String error) {
        setState(() {
          _errorMessage = error;
          _isLoading = false;
        });
        context.read<VoiceService>().speak(_errorMessage);
      },
    );
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
       setState(() => _errorMessage = "சரியான 6 இலக்க OTP-ஐ உள்ளிடவும்"); // Enter valid 6 digit OTP
       context.read<VoiceService>().speak(_errorMessage);
       return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final authService = context.read<AuthService>();
      final result = await authService.verifyOTP(otp);
      
      setState(() => _isLoading = false);
      
      // Success, route correctly based on if they are brand new
      context.read<VoiceService>().speak("உள்நுழைவு வெற்றி"); // Login Success
      
      if (result['is_new_user'] == true) {
         // Proceed to the Name/Age/Location creation layout
         context.go('/onboarding/profile'); 
      } else {
         // Direct dashboard pass
         context.go('/home'); 
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "தவறான OTP. மீண்டும் முயற்சிக்கவும்"; // Invalid OTP. Try again.
      });
      context.read<VoiceService>().speak(_errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Beautiful Header
              Center(
                child: Text(
                  "வணக்கம் அக்கா",
                  style: AppTextStyles.headingLarge.copyWith(color: AppColors.primary, fontSize: 32),
                ),
              ),
              const SizedBox(height: 12),
              
              // Contextual Instruction Based On State Status
              Center(
                child: Text(
                  !_isOtpSent 
                      ? "உங்கள் தொலைபேசி எண்ணை உள்ளிடவும்"
                      : "உங்களுக்கு வந்த OTP-ஐ உள்ளிடவும்",
                  style: AppTextStyles.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 48),

              // UI Element Toggles
              if (!_isOtpSent) _buildPhoneEntry() else _buildOtpEntry(),

              const Spacer(),

              // Tamil Accessible Error Feedback
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Text(
                    _errorMessage,
                    style: AppTextStyles.bodyLarge.copyWith(color: AppColors.riskRed, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Dynamic Loading Feedback vs High-Contrast Submit Strategy
              if (_isLoading)
                Column(
                  children: [
                    const CircularProgressIndicator(color: AppColors.primary),
                    const SizedBox(height: 16),
                    Text(
                      "காத்திருங்கள்...", // Please wait...
                      style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                )
              else
                ElevatedButton(
                  onPressed: !_isOtpSent ? _sendOtp : _verifyOtp,
                  child: Text(
                    !_isOtpSent ? "OTP அனுப்பு" : "உள்நுழைய", // Send OTP : Login
                    style: AppTextStyles.headingMedium.copyWith(color: Colors.white, fontSize: 18),
                  ),
                ),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneEntry() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          maxLength: 10,
          style: AppTextStyles.headingLarge.copyWith(letterSpacing: 2),
          decoration: const InputDecoration(
            prefixText: "+91   ",
            prefixStyle: TextStyle(
               color: AppColors.textPrimary,
               fontSize: 24,
               fontWeight: FontWeight.w600,
            ),
            counterText: "",
          ),
        ),
      ],
    );
  }

  Widget _buildOtpEntry() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: AppTextStyles.headingLarge.copyWith(letterSpacing: 24, fontSize: 32),
          decoration: const InputDecoration(
            counterText: "",
          ),
        ),
      ],
    );
  }
}
