import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/services/voice_service.dart';

/// Health Notebook rendering historical records while dynamically providing massive
/// central camera interactions resolving complex physician scripts via OCR Audio loops
class HealthNotebookScreen extends StatefulWidget {
  const HealthNotebookScreen({super.key});

  @override
  State<HealthNotebookScreen> createState() => _HealthNotebookScreenState();
}

class _HealthNotebookScreenState extends State<HealthNotebookScreen> {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://localhost:8000/api/v1'));
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = true;
  bool _isUploading = false;
  List<dynamic> _records = [];

  @override
  void initState() {
    super.initState();
    _fetchRecords();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VoiceService>().speak(
        "உங்கள் மருத்துவ குறிப்பேடு. புதிய ரிப்போர்ட்டை சேர்க்க கேமராவை அழுத்தவும்.",
      );
    });
  }

  Future<void> _fetchRecords() async {
    try {
      final res = await _dio.get('/records/1'); // Fetch user 1
      setState(() {
        _records = res.data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  /// Engages Native OS Camera bindings, grabs bytes, shapes Multipart configurations, and posts to FastAPI
  Future<void> _captureAndUploadRecord() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (photo == null) return; // User cancelled

    setState(() => _isUploading = true);
    context.read<VoiceService>().speak(
      "படிக்கிறேன், ஒரு நிமிடம் காத்திருங்கள்...",
    ); // Reading, please wait

    try {
      FormData formData = FormData.fromMap({
        "user_id": 1,
        "record_type": "prescription",
        "file": await MultipartFile.fromFile(photo.path, filename: photo.name),
      });

      final res = await _dio.post('/records/upload', data: formData);
      final explanation = res.data['ai_explanation'];

      setState(() => _isUploading = false);

      // Auto Voice dictates exact Tamil context skipping Jargon!
      context.read<VoiceService>().speak(explanation);

      _fetchRecords(); // Refresh UI dynamically
    } catch (e) {
      setState(() => _isUploading = false);
      context.read<VoiceService>().speak(
        "மன்னிக்கவும், ரிப்போர்ட்டை சேமிக்க முடியவில்லை.",
      );
    }
  }

  /// Allows explicit User interaction to repeat spoken OCR AI abstractions
  void _playRecordAudio(String explanation) {
    context.read<VoiceService>().speak(explanation);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "மருத்துவ குறிப்பேடு",
          style: AppTextStyles.headingMedium,
        ), // Health Notebook
        leading: const BackButton(),
      ),
      body: SafeArea(
        child: _isUploading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: AppColors.primary),
                    const SizedBox(height: 24),
                    Text(
                      "ரிப்போர்ட்டை படிக்கிறேன்...",
                      style: AppTextStyles.headingMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "தயவுசெய்து காத்திருக்கவும்",
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              )
            : _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _records.isEmpty
            ? _buildEmptyState()
            : _buildGalleryList(),
      ),

      // Massive accessible FAB enforcing rural ease-of-use directly to the central interaction pattern
      floatingActionButton: SizedBox(
        height: 72,
        width: 180,
        child: FloatingActionButton.extended(
          onPressed: _captureAndUploadRecord,
          backgroundColor: AppColors.primary,
          icon: const Icon(
            Icons.camera_alt_rounded,
            size: 32,
            color: Colors.white,
          ),
          label: Text(
            "புகைப்படம் எடு",
            style: AppTextStyles.headingMedium.copyWith(color: Colors.white),
          ), // Take Photo
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.library_books_rounded,
              size: 96,
              color: AppColors.primary.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 24),
            Text(
              "எந்த தகவலும் இல்லை",
              style: AppTextStyles.headingLarge,
            ), // No data
            const SizedBox(height: 16),
            Text(
              "மருந்து சீட்டு அல்லது ரிப்போர்ட்டை படிக்க கேமராவை அழுத்தவும்", // Press camera to read prescription
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Parses historical AI inferences translating metadata representations into clean cards
  Widget _buildGalleryList() {
    return ListView.builder(
      padding: const EdgeInsets.all(
        16.0,
      ).copyWith(bottom: 100), // Clearance for giant FAB
      itemCount: _records.length,
      itemBuilder: (context, index) {
        final record = _records[index];
        final isPrescription = record['type'] == 'prescription';

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isPrescription
                            ? Icons.medical_information_rounded
                            : Icons.science_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            record['title'] ?? "மருத்துவ அறிக்கை",
                            style: AppTextStyles.headingMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            record['date'] ?? "",
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.volume_up_rounded,
                        color: AppColors.riskGreen,
                        size: 32,
                      ),
                      onPressed: () =>
                          _playRecordAudio(record['ai_explanation']),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),

                // Display the primary simple Tamil extraction heavily parsed by GPT
                Text(
                  record['ai_explanation'] ?? "விளக்கம் இல்லை",
                  style: AppTextStyles.bodyLarge,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
