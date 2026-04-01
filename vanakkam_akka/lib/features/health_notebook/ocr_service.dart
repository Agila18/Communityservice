import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// On-device OCR for prescription/lab printouts (Latin script). Lines are merged in reading order.
/// Tamil script is not supported by on-device ML Kit; backend LLM still simplifies English OCR to Tamil.
class OcrService {
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<String> extractText(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    try {
      final recognizedText = await _textRecognizer.processImage(inputImage);
      final buffer = StringBuffer();
      for (final block in recognizedText.blocks) {
        for (final line in block.lines) {
          buffer.writeln(line.text);
        }
      }
      return buffer.toString().trim();
    } catch (e) {
      return '';
    }
  }

  void dispose() {
    _textRecognizer.close();
  }
}
