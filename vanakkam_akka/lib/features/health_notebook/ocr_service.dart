import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Offline On-Device OCR Engine.
/// Securely pulls raw text representations bounding boxes directly matching script geometries
/// entirely locally bypassing initial server uploads until strictly needed for Translation.
class OcrService {
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  
  Future<String> extractText(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    try {
       // Processes entirely matching bounding rect groupings for Latin characters (English Prescriptions/Machines)
       final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
       return recognizedText.text;
    } catch (e) {
       print("MLKit Local Fault: $e");
       return ""; // Ensures we degrade safely
    }
  }
  
  void dispose() {
    _textRecognizer.close();
  }
}
