import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

/// Enhanced Voice Service using Whisper API for Tamil Speech Recognition
/// Integrates with backend Whisper API for accurate Tamil transcription
class WhisperVoiceService extends ChangeNotifier {
  final FlutterTts _tts = FlutterTts();
  final AudioRecorder _recorder = AudioRecorder();
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://localhost:8000/api/v1',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  bool _isSpeaking = false;
  bool _isListening = false;
  bool _isRecording = false;
  String _lastError = "";

  bool get isSpeaking => _isSpeaking;
  bool get isListening => _isListening;
  bool get isRecording => _isRecording;
  String get lastError => _lastError;

  WhisperVoiceService() {
    _initTts();
  }

  // ==========================================
  // 1. Text-to-Speech (TTS)
  // ==========================================

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage("ta-IN");
    } catch (_) {
      try {
        await _tts.setLanguage("en-IN");
      } catch (_) {}
    }
    try {
      await _tts.setSpeechRate(0.75);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      await _tts.awaitSpeakCompletion(true);
    } catch (_) {}

    _tts.setStartHandler(() {
      _isSpeaking = true;
      notifyListeners();
    });

    _tts.setCompletionHandler(() {
      _isSpeaking = false;
      notifyListeners();
    });

    _tts.setCancelHandler(() {
      _isSpeaking = false;
      notifyListeners();
    });

    _tts.setErrorHandler((msg) {
      _isSpeaking = false;
      _lastError = "TTS Error: $msg";
      notifyListeners();
    });
  }

  /// Triggers the phone to read the given text aloud
  Future<void> speak(String text) async {
    if (text.isEmpty) return;

    if (_isSpeaking) {
      await stop();
    }

    await _tts.speak(text);
  }

  /// Manually stops the TTS engine
  Future<void> stop() async {
    await _tts.stop();
    _isSpeaking = false;
    notifyListeners();
  }

  // ==========================================
  // 2. Whisper-based Speech-to-Text (STT)
  // ==========================================

  /// Request microphone permission
  Future<bool> _requestPermission() async {
    try {
      final status = await Permission.microphone.request();
      return status == PermissionStatus.granted;
    } catch (e) {
      _lastError = "Permission error: $e";
      notifyListeners();
      return false;
    }
  }

  /// Start recording audio for Whisper transcription
  Future<void> startListening({
    required Function(String) onResult,
    Function(String)? onError,
  }) async {
    _lastError = "";

    // 1. Request microphone permission
    bool hasPermission = await _requestPermission();
    if (!hasPermission) {
      if (onError != null) {
        onError("மைக்ரோஃபோன் அனுமதி இல்லை (Microphone Permission Denied)");
      }
      return;
    }

    // 2. Stop any ongoing TTS
    if (_isSpeaking) {
      await stop();
    }

    try {
      _isRecording = true;
      _isListening = true;
      notifyListeners();

      // 3. Start recording
      await _recorder.start();

      // Record for maximum 10 seconds
      await Future.delayed(const Duration(seconds: 10));

      // 4. Stop recording and get the file
      final String? recordedPath = await _recorder.stop();

      if (recordedPath != null && recordedPath.isNotEmpty) {
        // 5. Send to Whisper API
        await _transcribeWithWhisper(recordedPath, onResult, onError);
      } else {
        if (onError != null) {
          onError("பதிவு செய்யப்படவில்லை (Recording failed)");
        }
      }
    } catch (e) {
      _lastError = "Recording error: $e";
      if (onError != null) {
        onError("பதிவு பிழை: $e");
      }
    } finally {
      _isRecording = false;
      _isListening = false;
      notifyListeners();
    }
  }

  /// Transcribe audio file using Whisper API
  Future<void> _transcribeWithWhisper(
    String audioPath,
    Function(String) onResult,
    Function(String)? onError,
  ) async {
    try {
      final File audioFile = File(audioPath);
      if (!await audioFile.exists()) {
        if (onError != null)
          onError("ஆடியோ கோப்பு இல்லை (Audio file not found)");
        return;
      }

      // Create multipart request
      final formData = FormData.fromMap({
        'audio_file': await MultipartFile.fromFile(
          audioPath,
          filename: 'audio.wav',
        ),
        'language': 'ta', // Tamil language
      });

      // Send to Whisper API
      final response = await _dio.post('/voice/transcribe', data: formData);

      if (response.statusCode == 200 && response.data['success'] == true) {
        final String transcribedText = response.data['data']['text'] ?? '';

        if (transcribedText.isNotEmpty) {
          onResult(transcribedText);
        } else {
          if (onError != null)
            onError("உரை மாற்றம் கிடைக்கவில்லை (No transcription received)");
        }
      } else {
        if (onError != null)
          onError("API பிழை: ${response.data['message'] ?? 'Unknown error'}");
      }
    } on DioException catch (e) {
      String errorMessage =
          "பிணையப் இணைப்பில் சிக்கல் உள்ளது. மீண்டும் முயற்சிக்கவும்.";

      if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = "இணைப்பு நேரம் முடிந்தது (Connection timeout)";
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = "பதில் நேரம் முடிந்தது (Response timeout)";
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = "பிணைய இணைப்பு பிழை (Network connection error)";
      }

      _lastError = errorMessage;
      if (onError != null) onError(errorMessage);
    } catch (e) {
      _lastError = "Transcription error: $e";
      if (onError != null) onError("பரிசோதனை பிழை: $e");
    }
  }

  /// Stop recording
  Future<void> stopListening() async {
    try {
      if (_isRecording) {
        await _recorder.stop();
      }
    } catch (e) {
      _lastError = "Stop recording error: $e";
    } finally {
      _isRecording = false;
      _isListening = false;
      notifyListeners();
    }
  }

  // ==========================================
  // 3. Smart Tamil Greetings
  // ==========================================

  String getGreeting(String name) {
    final hour = DateTime.now().hour;
    String greeting;

    if (hour >= 6 && hour < 12) {
      greeting = "காலை வணக்கம் அக்கா";
    } else if (hour >= 12 && hour < 17) {
      greeting = "மதிய வணக்கம் அக்கா";
    } else {
      greeting = "மாலை வணக்கம் அக்கா";
    }

    if (name.trim().isNotEmpty) {
      return "$greeting, $name";
    }
    return greeting;
  }

  // ==========================================
  // 4. Symptom Announcement
  // ==========================================

  Future<void> announceRiskResult(String riskLevel, String message) async {
    String prefix = "";

    if (riskLevel.toUpperCase() == 'RED') {
      prefix = "அவசரம்! தயவுசெய்து கவனிக்கவும்.";
    } else if (riskLevel.toUpperCase() == 'YELLOW') {
      prefix = "கவனம் தேவை.";
    } else {
      prefix = "பரிசோதனை முடிவு:";
    }

    await speak("$prefix $message");
  }

  // ==========================================
  // 5. Health Check
  // ==========================================

  /// Check if Whisper API is available
  Future<bool> checkWhisperHealth() async {
    try {
      final response = await _dio.post('/voice/health');
      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      _lastError = "Whisper health check failed: $e";
      return false;
    }
  }
}
