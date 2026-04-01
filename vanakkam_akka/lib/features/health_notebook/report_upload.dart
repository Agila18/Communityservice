import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/services/voice_service.dart';
import 'ocr_service.dart';

class ReportUploadScreen extends StatefulWidget {
  const ReportUploadScreen({super.key});

  @override
  State<ReportUploadScreen> createState() => _ReportUploadScreenState();
}

class _ReportUploadScreenState extends State<ReportUploadScreen> {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:8000/api/v1'));
  final ImagePicker _picker = ImagePicker();
  final OcrService _ocrService = OcrService();
  
  File? _selectedImage;
  String _selectedCategory = "PRESCRIPTION";
  
  // States
  bool _isProcessing = false;
  bool _isSaved = false;
  
  // Results
  String _extractedText = "";
  String _tamilExplanation = "";

  final Map<String, String> _categories = {
    "PRESCRIPTION": "மருந்து சீட்டு (Rx)",
    "LAB": "ரத்த டெஸ்ட்",
    "SCAN": "ஸ்கேன்"
  };

  /// Pick from native hardware OS boundaries
  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image == null) return;

    File file = File(image.path);
    
    // Leverage explicit bounds cropping narrowing Native MLKit focus heavily!
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: file.path,
      aspectRatioPresets: [CropAspectRatioPreset.square, CropAspectRatioPreset.ratio3x2, CropAspectRatioPreset.ratio4x3],
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'ரிப்போர்ட்டை வெட்டவும்', // Crop Report
            toolbarColor: AppColors.primary,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
      ],
    );

    if (croppedFile != null) {
      setState(() {
         _selectedImage = File(croppedFile.path);
         _extractedText = "";
         _tamilExplanation = "";
         _isSaved = false;
      });
    }
  }

  /// Engages On-Device MLKit -> FastAPI Text Analyzer -> Actionable Yield
  Future<void> _processWithAI() async {
     if (_selectedImage == null) return;
     
     setState(() => _isProcessing = true);
     context.read<VoiceService>().speak("படிக்கிறேன், ஒரு நிமிடம் காத்திருங்கள்...");
     
     try {
       // 1. Fully localized extraction avoiding massive network payload costs
       final rawText = await _ocrService.extractText(_selectedImage!);
       if (rawText.isEmpty) {
          throw Exception("No text found");
       }
       
       // 2. Offload ONLY the string to FastAPI for LLM Abstract translation
       final res = await _dio.post('/notebook/analyze', data: { "extracted_text": rawText });
       
       setState(() {
          _extractedText = rawText;
          _tamilExplanation = res.data['tamil_explanation'];
          _isProcessing = false;
       });
       
       // Auto-Dictate the payload resolving literacy bounds
       context.read<VoiceService>().speak(_tamilExplanation);
       
     } catch (e) {
       setState(() => _isProcessing = false);
       context.read<VoiceService>().speak("மன்னிக்கவும், ரிப்போர்ட்டை படிக்க முடியவில்லை.");
     }
  }

  /// Commits final structured binary arrays alongside contextual definitions securely over multipart
  Future<void> _saveRecord() async {
      if (_selectedImage == null || _tamilExplanation.isEmpty) return;
      setState(() => _isProcessing = true);
      
      try {
        FormData formData = FormData.fromMap({
          "user_id": 1,
          "record_type": _selectedCategory.toLowerCase(),
          "ocr_text": _extractedText,
          "ai_explanation": _tamilExplanation,
          "title": _categories[_selectedCategory],
          "file": await MultipartFile.fromFile(_selectedImage!.path),
        });

        await _dio.post('/notebook/upload', data: formData);
        
        setState(() {
           _isProcessing = false;
           _isSaved = true;
        });
        
        context.read<VoiceService>().speak("சேமிக்கப்பட்டது."); // Saved
        Future.delayed(const Duration(seconds: 2), () => Navigator.pop(context, true));
        
      } catch (e) {
         setState(() => _isProcessing = false);
         context.read<VoiceService>().speak("சேமிக்க முடியவில்லை");
      }
  }

  @override
  void dispose() {
    _ocrService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("புதுசா சேர்க்கவும்"), leading: const BackButton()),
      body: SafeArea(
         child: _isProcessing 
           ? _buildLoadingState()
           : _buildEditorState()
      )
    );
  }

  Widget _buildLoadingState() {
     return Center(
       child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             const CircularProgressIndicator(color: AppColors.primary),
             const SizedBox(height: 24),
             Text("படிக்கிறேன்...", style: AppTextStyles.headingLarge), // Reading...
             const SizedBox(height: 8),
             Text("கொஞ்சம் பொறுங்கள்", style: AppTextStyles.bodyLarge),
          ]
       )
     );
  }

  Widget _buildEditorState() {
     return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
           crossAxisAlignment: CrossAxisAlignment.stretch,
           children: [
              // Photo Frame Boundary
              Container(
                 height: 250,
                 decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16)
                 ),
                 child: _selectedImage != null 
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover)
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                           Icon(Icons.photo_camera_rounded, size: 64, color: Colors.grey.shade400),
                           const SizedBox(height: 16),
                           Row(
                             mainAxisAlignment: MainAxisAlignment.center,
                             children: [
                               ElevatedButton.icon(
                                  onPressed: () => _pickImage(ImageSource.camera),
                                  icon: const Icon(Icons.camera_alt),
                                  label: const Text("கேமரா"),
                               ),
                               const SizedBox(width: 16),
                               OutlinedButton.icon(
                                  onPressed: () => _pickImage(ImageSource.gallery),
                                  icon: const Icon(Icons.photo),
                                  label: const Text("கேலரி"),
                               )
                             ]
                           )
                        ],
                    )
              ),
              
              const SizedBox(height: 24),
              
              if (_selectedImage != null && _tamilExplanation.isEmpty) ...[
                 Text("இது எந்த வகையான ரிப்போர்ட்?", style: AppTextStyles.headingMedium),
                 const SizedBox(height: 12),
                 SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.entries.map((e) {
                         bool isSel = _selectedCategory == e.key;
                         return Padding(
                           padding: const EdgeInsets.only(right: 8.0),
                           child: ChoiceChip(
                             label: Text(e.value),
                             selected: isSel,
                             selectedColor: AppColors.primary.withValues(alpha: 0.2),
                             onSelected: (val) {
                                if (val) setState(() => _selectedCategory = e.key);
                             },
                           ),
                         );
                      }).toList(),
                    ),
                 ),
                 
                 const SizedBox(height: 48),
                 SizedBox(
                   height: 54,
                   child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                      icon: const Icon(Icons.auto_awesome_rounded),
                      label: Text("AI படிக்கட்டும் (Read Document)", style: AppTextStyles.headingMedium.copyWith(color: Colors.white)),
                      onPressed: _processWithAI,
                   ),
                 )
              ],
              
              if (_tamilExplanation.isNotEmpty) ...[
                 // Side-by-Side Context Rendering Panel
                 Container(
                   padding: const EdgeInsets.all(16),
                   decoration: BoxDecoration(
                      color: AppColors.riskGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.riskGreen)
                   ),
                   child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                           children: [
                              const Icon(Icons.check_circle_rounded, color: AppColors.riskGreen),
                              const SizedBox(width: 8),
                              Text("விளக்கம்", style: AppTextStyles.headingMedium),
                              const Spacer(),
                              IconButton(
                                 icon: const Icon(Icons.volume_up_rounded, color: AppColors.primary),
                                 onPressed: () => context.read<VoiceService>().speak(_tamilExplanation),
                              )
                           ]
                        ),
                        const Divider(),
                        Text(_tamilExplanation, style: AppTextStyles.bodyLarge),
                      ]
                   )
                 ),
                 
                 const SizedBox(height: 32),
                 SizedBox(
                   height: 54,
                   child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                         backgroundColor: _isSaved ? AppColors.riskGreen : AppColors.primary, 
                         foregroundColor: Colors.white
                      ),
                      icon: Icon(_isSaved ? Icons.check : Icons.save_rounded),
                      label: Text(_isSaved ? "சேமிக்கப்பட்டது" : "சேமிக்கவும் (Save)", style: AppTextStyles.headingMedium.copyWith(color: Colors.white)),
                      onPressed: _isSaved ? null : _saveRecord,
                   ),
                 )
              ]
           ]
        )
     );
  }
}
