import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/services/voice_service.dart';

/// Comprehensive visual layout orchestrating longitudinal pregnancy workflows.
/// Syncs exactly with backend AI transition milestones rendering weekly granular actions.
class PregnancyTrackerScreen extends StatefulWidget {
  const PregnancyTrackerScreen({super.key});

  @override
  State<PregnancyTrackerScreen> createState() => _PregnancyTrackerScreenState();
}

class _PregnancyTrackerScreenState extends State<PregnancyTrackerScreen> {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:8000/api/v1'));
  
  bool _isLoading = true;
  Map<String, dynamic>? _currentWeekData;
  final int _currentWeek = 12; // Initially mocked locally representing transition state

  @override
  void initState() {
    super.initState();
    _initTracker();
  }

  Future<void> _initTracker() async {
    // 1. Fetch exact week mapping from the backend AI database
    try {
      final res = await _dio.get('/cycle/pregnancy_data/$_currentWeek');
      if (res.statusCode == 200) {
        _currentWeekData = res.data;
      }
    } catch(e) {
      // 2. Offline safe fallback mapping to ensure crucial health messages render offline
      _currentWeekData = {
         "week": _currentWeek,
         "size_comparison": "எலுமிச்சை அளவு",
         "tamil_message": "வாந்தி மற்றும் சோர்வு படிப்படியாக குறையும்",
         "warning": "திடீர் எடை குறைவு இருந்தால் VHN-ஐ பாருங்கள்",
         "action": "NT Scan (ஸ்கேன்) எடுக்க வேண்டிய நேரம்",
         "scheme_reminder": "உங்கள் VHN-ஐ சந்தித்து அட்டை பெறுங்கள்"
      };
    }
    
    setState(() => _isLoading = false);
    
    // Voice Accessibility Trigger dictating exact AI payloads without needing reading
    if (_currentWeekData != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
         final String size = _currentWeekData!['size_comparison'];
         final String msg = _currentWeekData!['tamil_message'];
         context.read<VoiceService>().speak("அக்கா, உங்கள் குழந்தை இப்போ $size இருக்கு. $msg.");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_currentWeekData == null) {
      return const Scaffold(body: Center(child: Text("Data missing")));
    }

    final data = _currentWeekData!;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("கர்ப்ப கால கையேடு", style: AppTextStyles.headingMedium), // Pregnancy Guide
        leading: const BackButton(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Core Visual Week Loop rendering exact progression
              Center(
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: AppColors.primary.withValues(alpha: 0.1), blurRadius: 20, spreadRadius: 5)
                    ]
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 140,
                        height: 140,
                        child: CircularProgressIndicator(
                          value: _currentWeek / 40.0,
                          strokeWidth: 8,
                          backgroundColor: Colors.grey.shade200,
                          color: AppColors.primary,
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("வாரம்", style: AppTextStyles.bodyLarge), // Week
                          Text("$_currentWeek", style: AppTextStyles.headingLarge.copyWith(fontSize: 48, color: AppColors.primary)),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Topline dynamic AI generated milestones
              Text("உங்கள் குழந்தை - ${data['size_comparison']}", style: AppTextStyles.headingLarge, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Text(
                data['tamil_message'],
                style: AppTextStyles.headingMedium.copyWith(color: AppColors.textPrimary),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // Tri-color actionable insight boxes mapped to AI arrays
              _buildInfoCard(
                icon: Icons.favorite_rounded,
                title: "இந்த வாரம் செய்ய வேண்டியது:", // Action
                content: data['action'],
                color: AppColors.riskGreen,
              ),
              
              const SizedBox(height: 16),
              
              _buildInfoCard(
                icon: Icons.warning_amber_rounded,
                title: "கவனிக்க வேண்டியவை:", // Warning signs
                content: data['warning'],
                color: AppColors.riskYellow,
              ),

              if (data['scheme_reminder'].toString().isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildInfoCard(
                  icon: Icons.account_balance_rounded,
                  title: "அரசு உதவித்தொகை:", // Government Scheme Reminders
                  content: data['scheme_reminder'],
                  color: AppColors.primary,
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({required IconData icon, required String title, required String content, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
           BoxShadow(color: color.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
        ]
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
             padding: const EdgeInsets.all(12),
             decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
             child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                Text(content, style: AppTextStyles.headingMedium),
              ]
            ),
          )
        ],
      )
    );
  }
}
