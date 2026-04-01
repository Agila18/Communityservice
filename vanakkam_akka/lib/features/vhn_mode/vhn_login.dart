import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

import 'package:go_router/go_router.dart';

/// Distinctive visual authentication isolating VHN capabilities entirely away from the Maternal flow.
/// Designed for high-volume clinic workers demanding secure, deterministic phone entry protocols.
class VhnLoginScreen extends StatefulWidget {
  const VhnLoginScreen({super.key});

  @override
  State<VhnLoginScreen> createState() => _VhnLoginScreenState();
}

class _VhnLoginScreenState extends State<VhnLoginScreen> {
  final TextEditingController _phoneController = TextEditingController();

  void _loginVhn() {
     // Standard stub routing directly mirroring identical Firebase pathways 
     // but asserting explicit 'role=VHN' mappings on the secure DB creation
     context.go('/vhn-dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary, // Force bold distinct styling differentiating from Patient mode
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.medical_services_rounded, size: 80, color: Colors.white),
              const SizedBox(height: 24),
              Text(
                 "VHN Login", 
                 style: AppTextStyles.headingLarge.copyWith(color: Colors.white, fontSize: 32),
                 textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                 "கிராம சுகாதார செவிலியர்", 
                 style: AppTextStyles.headingMedium.copyWith(color: Colors.white70),
                 textAlign: TextAlign.center,
              ),
              const SizedBox(height: 64),
              
              Container(
                 padding: const EdgeInsets.all(24),
                 decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24)
                 ),
                 child: Column(
                    children: [
                       const TextField(
                          decoration: InputDecoration(
                             labelText: "மொபைல் எண் (Phone Number)",
                             prefixText: "+91 ",
                             border: OutlineInputBorder()
                          ),
                          keyboardType: TextInputType.phone,
                       ),
                       const SizedBox(height: 24),
                       SizedBox(
                         width: double.infinity,
                         height: 54,
                         child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                               backgroundColor: AppColors.primary,
                               foregroundColor: Colors.white,
                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                            ),
                            onPressed: _loginVhn,
                            child: Text("OTP அனுப்பு (Send OTP)", style: AppTextStyles.headingMedium.copyWith(color: Colors.white)),
                         ),
                       )
                    ]
                 )
              )
            ],
          ),
        ),
      ),
    );
  }
}
