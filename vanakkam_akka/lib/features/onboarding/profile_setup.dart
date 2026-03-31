import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/voice_button.dart';
import '../../shared/services/auth_service.dart';
import '../../shared/services/voice_service.dart';

/// Complete voice-driven onboarding questionnaire layout
class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  int _currentStep = 0;
  bool _isSaving = false;
  
  // Accumulated Profile State
  String _name = "";
  int _age = 0;
  String _district = "";
  String _literacyMode = "voice";
  final List<String> _conditions = [];

  final List<String> _priorityDistricts = [
    "தர்மபுரி (Dharmapuri)",
    "கிருஷ்ணகிரி (Krishnagiri)",
    "விழுப்புரம் (Villupuram)",
    "இராமநாதபுரம் (Ramanathapuram)",
    "வேலூர் (Vellore)"
  ];

  @override
  void initState() {
    super.initState();
    // Start step 1 instructions on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _triggerVoiceForStep(0);
    });
  }

  void _triggerVoiceForStep(int step) {
    final voice = context.read<VoiceService>();
    switch (step) {
      case 0: voice.speak("உங்கள் பெயர் என்ன?"); break;
      case 1: voice.speak("உங்கள் வயது சொல்லுங்கள்"); break;
      case 2: voice.speak("நீங்கள் எந்த மாவட்டம்?"); break;
      case 3: voice.speak("நீங்கள் படிக்க விரும்புகிறீர்களா, அல்லது பேச விரும்புகிறீர்களா?"); break;
      case 4: voice.speak("உங்களுக்கு நீரிழிவு, அல்லது ரத்த அழுத்தம் போன்ற நோய்கள் இருக்கிறதா?"); break;
    }
  }

  void _nextStep() {
    if (_currentStep < 4) {
      setState(() => _currentStep++);
      _triggerVoiceForStep(_currentStep);
    } else {
      _saveProfile();
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    try {
      await context.read<AuthService>().updateProfile(
         name: _name,
         age: _age == 0 ? 25 : _age, // Safe default fallback
         district: _district.isEmpty ? "Unknown" : _district, 
         literacyMode: _literacyMode, 
         conditions: _conditions.isEmpty ? ["None"] : _conditions,
      );
      context.read<VoiceService>().speak("ரொம்ப நன்றி அக்கா, எல்லாம் தயார்!"); // Thank you, all set!
      
      if (mounted) context.go('/home');
    } catch (e) {
      setState(() => _isSaving = false);
      context.read<VoiceService>().speak("சேமிப்பதில் பிழை ஏற்பட்டது");
    }
  }

  int _parseAge(String spokenText) {
     // A crude digit extractor since ta-IN STT converts standard spoken numbers to strings like "25"
     final regExp = RegExp(r'\d+');
     final match = regExp.firstMatch(spokenText);
     if (match != null) {
       return int.tryParse(match.group(0) ?? '0') ?? 0;
     }
     return 0; // Return zero indicating failure to parse specific digits
  }

  @override
  Widget build(BuildContext context) {
    if (_isSaving) {
      return Scaffold(
         backgroundColor: AppColors.background,
         body: Center(
           child: Column(
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
               const CircularProgressIndicator(color: AppColors.primary),
               const SizedBox(height: 16),
               Text("சுயவிவரங்களைச் சேமிக்கிறது...", style: AppTextStyles.bodyLarge),
             ],
           ),
         ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("உங்களைப் பற்றி...", style: AppTextStyles.headingMedium),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LinearProgressIndicator(
                 value: (_currentStep + 1) / 5,
                 backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                 color: AppColors.primary,
                 minHeight: 8,
                 borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 32),
              
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: _buildCurrentStep(),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Only showing Continue button if minimum criteria for the step is met
              if (_isStepValid())
                 ElevatedButton(
                   onPressed: _nextStep,
                   child: Text("தொடரவும் (Continue)", style: AppTextStyles.headingMedium.copyWith(color: Colors.white)),
                 )
            ],
          ),
        ),
      ),
    );
  }

  bool _isStepValid() {
    if (_currentStep == 0) return _name.isNotEmpty;
    if (_currentStep == 1) return _age > 0;
    if (_currentStep == 2) return _district.isNotEmpty;
    if (_currentStep == 3) return true; // Has default
    return true; // Step 4 can be empty string list
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0: return _buildStep1Name();
      case 1: return _buildStep2Age();
      case 2: return _buildStep3District();
      case 3: return _buildStep4Literacy();
      case 4: return _buildStep5Health();
      default: return const SizedBox.shrink();
    }
  }

  // ==========================================
  // STEP BUILDERS
  // ==========================================

  Widget _buildStep1Name() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("உங்கள் பெயர் என்ன?", style: AppTextStyles.headingLarge, textAlign: TextAlign.center),
        const SizedBox(height: 48),
        if (_name.isNotEmpty) 
          Container(
             padding: const EdgeInsets.all(16),
             decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
             child: Text(_name, style: AppTextStyles.headingLarge.copyWith(color: AppColors.primary)),
          ),
        const SizedBox(height: 48),
        VoiceButton(onResult: (val) => setState(() => _name = val)),
      ],
    );
  }

  Widget _buildStep2Age() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("உங்கள் வயது சொல்லுங்கள்", style: AppTextStyles.headingLarge, textAlign: TextAlign.center),
        const SizedBox(height: 48),
        if (_age > 0)
          Text("$_age வயது", style: AppTextStyles.headingLarge.copyWith(color: AppColors.primary)),
        const SizedBox(height: 48),
        VoiceButton(onResult: (val) {
          int parsed = _parseAge(val);
          setState(() => _age = parsed);
        }),
      ],
    );
  }

  Widget _buildStep3District() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("நீங்கள் எந்த மாவட்டம்?", style: AppTextStyles.headingLarge, textAlign: TextAlign.center),
        const SizedBox(height: 32),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: _priorityDistricts.map((district) {
            final isSelected = _district == district;
            return ChoiceChip(
              label: Text(district.split(' ')[0], style: AppTextStyles.bodyLarge.copyWith(color: isSelected ? Colors.white : AppColors.textPrimary)),
              selected: isSelected,
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.surface,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              onSelected: (val) => setState(() => _district = val ? district : ""),
            );
          }).toList(),
        ),
        const SizedBox(height: 32),
        Text("அல்லது பேசுங்கள்:", style: AppTextStyles.bodyLarge),
        const SizedBox(height: 16),
        VoiceButton(onResult: (val) => setState(() => _district = val)),
        if (_district.isNotEmpty && !_priorityDistricts.contains(_district))
           Padding(
             padding: const EdgeInsets.only(top: 16),
             child: Text(_district, style: AppTextStyles.headingMedium.copyWith(color: AppColors.primary)),
           )
      ],
    );
  }

  Widget _buildStep4Literacy() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("நீங்கள் எப்படி பயன்படுத்த விரும்புகிறீர்கள்?", style: AppTextStyles.headingLarge, textAlign: TextAlign.center),
        const SizedBox(height: 48),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildLiteracyCard("voice", Icons.mic_rounded, "பேசுவேன்\n(Voice Mode)"),
            _buildLiteracyCard("text", Icons.text_fields_rounded, "படிப்பேன்\n(Read Mode)"),
          ],
        )
      ],
    );
  }
  
  Widget _buildLiteracyCard(String mode, IconData icon, String label) {
    final isSelected = _literacyMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _literacyMode = mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
           color: isSelected ? AppColors.primary : AppColors.surface,
           borderRadius: BorderRadius.circular(24),
           border: Border.all(color: AppColors.primary, width: 2),
           boxShadow: isSelected ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 10)] : [],
        ),
        child: Column(
          children: [
            Icon(icon, size: 48, color: isSelected ? Colors.white : AppColors.primary),
            const SizedBox(height: 12),
            Text(label, style: AppTextStyles.bodyLarge.copyWith(color: isSelected ? Colors.white : AppColors.primary), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildStep5Health() {
    final Map<String, String> conditionsOpt = {
      "Diabetes": "நீரிழிவு",
      "BP": "ரத்த அழுத்தம்",
      "Thyroid": "தைராய்டு",
      "None": "எதுவுமில்லை"
    };

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("உங்களுக்கு ஏதாவது நோய் இருக்கா?", style: AppTextStyles.headingLarge, textAlign: TextAlign.center),
        const SizedBox(height: 32),
        Wrap(
          spacing: 12,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: conditionsOpt.entries.map((entry) {
            final isSelected = _conditions.contains(entry.key);
            return FilterChip(
              label: Text(entry.value, style: AppTextStyles.bodyLarge.copyWith(color: isSelected ? Colors.white : AppColors.textPrimary)),
              selected: isSelected,
              selectedColor: AppColors.riskRed,
              backgroundColor: AppColors.surface,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              onSelected: (val) {
                setState(() {
                   if (entry.key == "None") {
                      _conditions.clear();
                      if (val) _conditions.add("None");
                   } else {
                      _conditions.remove("None");
                      val ? _conditions.add(entry.key) : _conditions.remove(entry.key);
                   }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 48),
        VoiceButton(onResult: (val) {
            // Optional Voice Parsing for health logic could go here.
            // Using UI buttons largely handles this reliably for rural audiences.
        }),
      ],
    );
  }
}
