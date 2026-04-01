import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

import 'proxy_screening.dart';

class VillagePatientListScreen extends StatefulWidget {
  const VillagePatientListScreen({super.key});

  @override
  State<VillagePatientListScreen> createState() => _VillagePatientListScreenState();
}

class _VillagePatientListScreenState extends State<VillagePatientListScreen> {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:8000/api/v1'));
  
  bool _isLoading = true;
  List<dynamic> _patients = [];
  Map<String, dynamic>? _communityAlert;
  String _activeFilter = "ALL";

  final Map<String, String> _filters = {
     "ALL": "எல்லாரும் (All)",
     "HIGH_RISK": "அவசரம் (High Risk)",
     "PREGNANT": "கர்ப்பிணிகள் (Pregnant)",
     "UNSCREENED": "பரிசோதிக்காதவர்கள்"
  };

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
     try {
       // Typically sourced dynamically representing the logged-in VHN locally
       final pRes = await _dio.get('/vhn/patients/999'); // using mock id
       final aRes = await _dio.get('/vhn/community-alerts/Villupuram');
       
       setState(() {
          _patients = pRes.data;
          // Novel Feature tracking: Set dynamically generated disease patterns explicitly into state
          if (aRes.data['status'] == 'alert') {
              _communityAlert = aRes.data;
          }
          _isLoading = false;
       });
     } catch (e) {
       setState(() => _isLoading = false);
     }
  }

  List<dynamic> get _filteredPatients {
     if (_activeFilter == "HIGH_RISK") return _patients.where((p) => p['risk_level'] == "RED").toList();
     if (_activeFilter == "PREGNANT") return _patients.where((p) => p['is_pregnant'] == true).toList();
     if (_activeFilter == "UNSCREENED") return _patients.where((p) => p['last_screening_days'] >= 10).toList();
     return _patients;
  }

  // Visual Risk Dictionary ensuring Red triage limits pull explicit clinical priority universally
  Color _getRiskColor(String risk) {
     if (risk == "RED") return AppColors.riskRed;
     if (risk == "YELLOW") return AppColors.riskYellow;
     return AppColors.riskGreen;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
         title: Text("VHN Dashboard", style: AppTextStyles.headingMedium),
         backgroundColor: AppColors.primary,
         foregroundColor: Colors.white,
      ),
      body: SafeArea(
         child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
               if (_communityAlert != null)
                 _buildCommunityAlert(),
               
               // Interactive Filters
               SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                     children: _filters.entries.map((e) {
                        bool isSel = _activeFilter == e.key;
                        return Padding(
                           padding: const EdgeInsets.only(right: 8.0),
                           child: ChoiceChip(
                              label: Text(e.value),
                              selected: isSel,
                              selectedColor: AppColors.primary,
                              labelStyle: TextStyle(color: isSel ? Colors.white : AppColors.textPrimary),
                              onSelected: (val) { if (val) setState(() => _activeFilter = e.key); }
                           )
                        );
                     }).toList(),
                  )
               ),
               
               // Core Triage Roster mapped linearly
               Expanded(
                 child: _isLoading 
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _filteredPatients.length,
                        itemBuilder: (context, index) {
                           final p = _filteredPatients[index];
                           final rColor = _getRiskColor(p['risk_level']);
                           
                           return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 2,
                              child: InkWell(
                                 onTap: () {
                                    // Bypassing directly into proxy screening mimicking the patient profile explicitly 
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => ProxyScreeningScreen(patientId: p['id'], patientName: p['name'])));
                                 },
                                 borderRadius: BorderRadius.circular(16),
                                 child: IntrinsicHeight(
                                    child: Row(
                                       crossAxisAlignment: CrossAxisAlignment.stretch,
                                       children: [
                                          Container(
                                             width: 12,
                                             decoration: BoxDecoration(color: rColor, borderRadius: const BorderRadius.horizontal(left: Radius.circular(16))),
                                          ),
                                          Expanded(
                                             child: Padding(
                                                padding: const EdgeInsets.all(16.0),
                                                child: Column(
                                                   crossAxisAlignment: CrossAxisAlignment.start,
                                                   children: [
                                                      Row(
                                                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                         children: [
                                                            Text(p['name'], style: AppTextStyles.headingLarge),
                                                            CircleAvatar(
                                                               radius: 12,
                                                               backgroundColor: rColor,
                                                               child: const Icon(Icons.circle, color: Colors.white, size: 10),
                                                            )
                                                         ]
                                                      ),
                                                      Text("வயது: ${p['age']} | ${p['phone']}", style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                                                      const Divider(),
                                                      
                                                      // Explicit AI constructed flagged metadata
                                                      Text(
                                                         p['key_flag'], 
                                                         style: AppTextStyles.bodyLarge.copyWith(color: p['key_flag'].toString().contains("Visit") ? AppColors.riskRed : AppColors.textPrimary, fontWeight: FontWeight.bold),
                                                      )
                                                   ]
                                                )
                                             )
                                          )
                                       ]
                                    )
                                 )
                              )
                           );
                        }
                    )
               )
            ]
         )
      )
    );
  }

  // The Community Outbreak tracker
  Widget _buildCommunityAlert() {
     return Container(
        margin: const EdgeInsets.all(16.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
           color: AppColors.riskRed.withValues(alpha: 0.1),
           borderRadius: BorderRadius.circular(16),
           border: Border.all(color: AppColors.riskRed, width: 2)
        ),
        child: Column(
           children: [
              Row(
                 children: [
                    const Icon(Icons.campaign_rounded, color: AppColors.riskRed, size: 32),
                    const SizedBox(width: 8),
                     Expanded(child: Text("Community Alert!", style: AppTextStyles.headingMedium.copyWith(color: AppColors.riskRed))),
                 ]
              ),
              const SizedBox(height: 8),
              Text(
                 _communityAlert!['tamil_alert'],
                 style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
              )
           ]
        )
     );
  }
}
