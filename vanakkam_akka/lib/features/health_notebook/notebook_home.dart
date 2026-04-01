import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/services/voice_service.dart';
import 'report_upload.dart';

/// Digital Health Notebook orchestrating dynamic local storage sorting 
/// heavily emphasizing visual categorization mapping complex clinical files over grids.
class NotebookHomeScreen extends StatefulWidget {
  const NotebookHomeScreen({super.key});

  @override
  State<NotebookHomeScreen> createState() => _NotebookHomeScreenState();
}

class _NotebookHomeScreenState extends State<NotebookHomeScreen> {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:8000/api/v1'));
  
  bool _isLoading = true;
  List<dynamic> _allRecords = [];
  String _activeFilter = "ALL";
  
  final Map<String, String> _filters = {
     "ALL": "எல்லாம்",
     "PRESCRIPTION": "மருந்து",
     "LAB": "ரத்த டெஸ்ட்",
     "SCAN": "ஸ்கேன்"
  };

  @override
  void initState() {
    super.initState();
    _fetchRecords();
  }

  Future<void> _fetchRecords() async {
    setState(() => _isLoading = true);
    try {
      final res = await _dio.get('/records/1'); // Fetching explicitly mapped subset via user route
      setState(() {
         _allRecords = res.data;
         _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<dynamic> get _filteredRecords {
     if (_activeFilter == "ALL") return _allRecords;
     return _allRecords.where((r) => r['type'].toString().toUpperCase() == _activeFilter).toList();
  }
  
  IconData _getIconForType(String type) {
     switch(type.toUpperCase()) {
        case 'PRESCRIPTION': return Icons.medication_rounded;
        case 'LAB': return Icons.science_rounded;
        case 'SCAN': return Icons.aspect_ratio_rounded;
        default: return Icons.description_rounded;
     }
  }

  Future<void> _openUploader() async {
    final didUpload = await Navigator.push(
      context, 
      MaterialPageRoute(builder: (_) => const ReportUploadScreen())
    );
    if (didUpload == true) {
       _fetchRecords();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("டிஜிட்டல் குறிப்பேடு", style: AppTextStyles.headingMedium), // Digital Notebook
        leading: const BackButton(),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Filter Tabs
            SingleChildScrollView(
               scrollDirection: Axis.horizontal,
               padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
               child: Row(
                  children: _filters.entries.map((e) {
                     bool isSelected = _activeFilter == e.key;
                     return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                           label: Text(e.value),
                           selected: isSelected,
                           selectedColor: AppColors.primary,
                           labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textPrimary),
                           onSelected: (val) {
                              if (val) setState(() => _activeFilter = e.key);
                           },
                        )
                     );
                  }).toList(),
               ),
            ),
            
            // Grid Renderer
            Expanded(
               child: _isLoading 
                 ? const Center(child: CircularProgressIndicator())
                 : _filteredRecords.isEmpty 
                     ? _buildEmptyState()
                     : _buildRecordsGrid()
            )
          ],
        )
      ),
      floatingActionButton: FloatingActionButton.extended(
         onPressed: _openUploader,
         backgroundColor: AppColors.primary,
         icon: const Icon(Icons.add_a_photo_rounded, color: Colors.white),
         label: Text("புதுசா சேர்க்கவும் (Add New)", style: AppTextStyles.headingMedium.copyWith(color: Colors.white)),
      ),
    );
  }

  Widget _buildEmptyState() {
     return Center(
        child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
              Icon(Icons.folder_open_rounded, size: 80, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                "இன்னும் records இல்லை.\nAdd பண்ணுங்கள்!", 
                style: AppTextStyles.headingMedium.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              )
           ]
        )
     );
  }

  Widget _buildRecordsGrid() {
     return GridView.builder(
        padding: const EdgeInsets.all(16.0).copyWith(bottom: 100), // FAB clearance
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
           crossAxisCount: 2,
           crossAxisSpacing: 16,
           mainAxisSpacing: 16,
           childAspectRatio: 0.8
        ),
        itemCount: _filteredRecords.length,
        itemBuilder: (context, index) {
            final record = _filteredRecords[index];
            final typeStr = record['type'].toString();
            
            return GestureDetector(
               onTap: () {
                  context.read<VoiceService>().speak(record['ai_explanation']);
               },
               child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                     color: Colors.white,
                     borderRadius: BorderRadius.circular(20),
                     border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
                     boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
                     ]
                  ),
                  child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                        Row(
                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                           children: [
                              Container(
                                 padding: const EdgeInsets.all(8),
                                 decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                                 child: Icon(_getIconForType(typeStr), color: AppColors.primary, size: 24),
                              ),
                              const Icon(Icons.volume_up_rounded, color: AppColors.riskGreen, size: 20)
                           ]
                        ),
                        const SizedBox(height: 12),
                        Text(record['title'] ?? "", style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text(record['date'] ?? "", style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                        const Spacer(),
                        Container(
                           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                           decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                           child: Text(
                              record['ai_explanation'] ?? "", 
                              style: AppTextStyles.bodySmall, 
                              maxLines: 3, 
                              overflow: TextOverflow.ellipsis
                           ),
                        )
                     ],
                  )
               ),
            );
        }
     );
  }
}
