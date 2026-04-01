import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

import 'voice_message_chat.dart';
import 'care_advice_card.dart';

class ConsultHomeScreen extends StatefulWidget {
  const ConsultHomeScreen({super.key});

  @override
  State<ConsultHomeScreen> createState() => _ConsultHomeScreenState();
}

class _ConsultHomeScreenState extends State<ConsultHomeScreen> {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:8000/api/v1'));
  
  bool _isLoading = true;
  List<dynamic> _sessions = [];
  
  // Natively cached states avoiding DB fetches strictly mapping Rural UI assumptions
  final String _nurseName = "Nurse Priya"; // Bound locally or fetched specifically from auth schemas
  final String _nurseStatus = "Online"; // Or '2 மணி நேரத்தில் பதில் வருவார்கள்'

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
     try {
       final res = await _dio.get('/consult/sessions/1');
       setState(() {
          _sessions = res.data;
          _isLoading = false;
       });
     } catch(e) {
       setState(() => _isLoading = false);
     }
  }

  Future<void> _startNewConsult() async {
     // Request a new session lock allocating resources structurally
     try {
       final res = await _dio.post('/consult/new', data: {"user_id": 1, "vhn_id": 999});
       final sessionId = res.data['session_id'];
       final summary = res.data['summary'];
       
       // Leap explicitly into the Chat UI mapping the specific session ID
       if (mounted) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => VoiceMessageChatScreen(sessionId: sessionId, initialSummary: summary)))
          .then((_) => _fetchHistory()); // Sync actively on return
       }
     } catch (e) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("நெட்வொர்க் பிழை (Network Error)")));
     }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
         title: Text("நர்ஸ் அக்காவிடம் பேசு", style: AppTextStyles.headingMedium), // Talk to Nurse Akka
         leading: const BackButton()
      ),
      body: SafeArea(
         child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
               // Header: Explicit Status Matrix
               Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                     color: Colors.white,
                     border: Border(bottom: BorderSide(color: Colors.black12))
                  ),
                  child: Row(
                     children: [
                        const CircleAvatar(
                           radius: 32,
                           backgroundColor: AppColors.primary,
                           child: Icon(Icons.medical_information_rounded, size: 32, color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                           child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                 Text(_nurseName, style: AppTextStyles.headingLarge),
                                 const SizedBox(height: 4),
                                 Row(
                                    children: [
                                       const Icon(Icons.check_circle_rounded, color: AppColors.riskGreen, size: 16),
                                       const SizedBox(width: 4),
                                       Expanded(child: Text(_nurseStatus, style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary))),
                                    ]
                                 )
                              ]
                           )
                        )
                     ]
                  )
               ),
               
               // High-priority Interaction Block
               Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: SizedBox(
                     height: 54,
                     child: ElevatedButton.icon(
                        onPressed: _startNewConsult,
                        icon: const Icon(Icons.mic_rounded, color: Colors.white),
                        label: Text("புதிய ஆலோசனை (New Consultation)", style: AppTextStyles.headingMedium.copyWith(color: Colors.white)),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                     )
                  )
               ),
               
               Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text("பழைய உரையாடல்கள் (History)", style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
               ),
               
               Expanded(
                  child: _isLoading 
                     ? const Center(child: CircularProgressIndicator())
                     : _sessions.isEmpty
                        ? const Center(child: Text("இன்னும் பதிவுகள் இல்லை (No records yet)", style: TextStyle(color: Colors.grey)))
                        : ListView.separated(
                            padding: const EdgeInsets.all(24),
                            itemCount: _sessions.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                               final s = _sessions[index];
                               final bool resolved = s['status'] == "RESOLVED";
                               
                               return Card(
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade300)),
                                  child: ListTile(
                                     contentPadding: const EdgeInsets.all(16),
                                     title: Text(s['date'], style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary)),
                                     subtitle: Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: Text(s['summary'], style: AppTextStyles.headingMedium),
                                     ),
                                     trailing: resolved 
                                        ? const Icon(Icons.fact_check_rounded, color: AppColors.riskGreen, size: 32)
                                        : const Icon(Icons.pending_rounded, color: AppColors.riskYellow, size: 32),
                                     onTap: () {
                                        if (resolved && s['advice'] != null) {
                                           Navigator.push(context, MaterialPageRoute(builder: (_) => CareAdviceCardScreen(adviceData: s['advice'])));
                                        } else {
                                           Navigator.push(context, MaterialPageRoute(builder: (_) => VoiceMessageChatScreen(sessionId: s['id'], initialSummary: s['summary'])));
                                        }
                                     },
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
}
