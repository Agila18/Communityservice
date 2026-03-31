import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Core service for handling all Voice Interactions (TTS and STT)
/// Designed exclusively for rural Tamil users with slower speech rates.
/// Uses Provider (ChangeNotifier) for global state management.
class VoiceService extends ChangeNotifier {
  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _stt = stt.SpeechToText();

  bool _isSpeaking = false;
  bool _isListening = false;
  bool _isSttInitialized = false;

  bool get isSpeaking => _isSpeaking;
  bool get isListening => _isListening;

  VoiceService() {
    _initTts();
  }

  // ==========================================
  // 1. Text-to-Speech (TTS)
  // ==========================================
  
  Future<void> _initTts() async {
    // Await completion of setting standard engine rules
    await _tts.setLanguage("ta-IN");
    await _tts.setSpeechRate(0.75); // Slower rate requested specs
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    
    // Some devices require specific engine initialization for indic languages
    await _tts.awaitSpeakCompletion(true);

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
      notifyListeners();
    });
  }

  /// Triggers the phone to read the given text aloud
  Future<void> speak(String text) async {
    if (text.isEmpty) return;
    
    // Stop anything currently speaking to avoid overlapping audio
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
  // 2. Speech-to-Text (STT)
  // ==========================================

  /// Initializes hardware plugins, requests permission, checks for mic.
  Future<bool> initialize() async {
    if (_isSttInitialized) return true;
    
    try {
      _isSttInitialized = await _stt.initialize(
        onError: (errorNotification) {
          _isListening = false;
          notifyListeners();
        },
        onStatus: (status) {
          if (status == 'notListening' || status == 'done') {
            _isListening = false;
            notifyListeners();
          }
        },
      );
      return _isSttInitialized;
    } catch (e) {
      // Catch hardware or permission exceptions
      return false; 
    }
  }

  /// Begins listening for Tamil voice input
  Future<void> startListening({
    required Function(String) onResult,
    Function(String)? onError,
  }) async {
    // 1. Check permissions and initialize
    bool available = await initialize();
    
    // 2. Handle missing mic / permission cases
    if (!available) {
      if (onError != null) {
        // Checking for different STT states
        if (!_stt.hasRecognized) {
          onError("மைக்ரோஃபோன் அனுமதி இல்லை (Microphone Permission Denied)");
        } else {
          onError("இணைய இணைப்பு பிழை (Network/Engine Error)");
        }
      }
      return;
    }

    // 3. Stop speaking if the app was mid-sentence
    if (_isSpeaking) {
      await stop();
    }
    
    _isListening = true;
    notifyListeners();

    // 4. Start recognition engine
    await _stt.listen(
      onResult: (result) {
        if (result.finalResult) {
           onResult(result.recognizedWords);
           _isListening = false;
           notifyListeners();
        }
      },
      localeId: 'ta_IN', // Enforce Tamil India locale
      cancelOnError: true,
      partialResults: false, 
      listenMode: stt.ListenMode.dictation,
    );
  }

  /// Stops actively listening for speech
  Future<void> stopListening() async {
    await _stt.stop();
    _isListening = false;
    notifyListeners();
  }

  // ==========================================
  // 3. Smart Tamil Greetings
  // ==========================================

  /// Returns a contextual Tamil greeting based on the time of day.
  String getGreeting(String name) {
    final hour = DateTime.now().hour;
    String greeting;

    if (hour >= 6 && hour < 12) {
      greeting = "காலை வணக்கம் அக்கா"; // Morning (6-12)
    } else if (hour >= 12 && hour < 17) {
      greeting = "மதிய வணக்கம் அக்கா"; // Afternoon (12-17)
    } else {
      greeting = "மாலை வணக்கம் அக்கா"; // Evening (17+)
    }

    if (name.trim().isNotEmpty) {
      return "$greeting, $name";
    }
    return greeting;
  }

  // ==========================================
  // 4. Symptom Announcement
  // ==========================================

  /// Reads aloud critical health risk feedback in a clear format.
  Future<void> announceRiskResult(String riskLevel, String message) async {
    String prefix = "";
    
    if (riskLevel.toUpperCase() == 'RED') {
      prefix = "அவசரம்! தயவுசெய்து கவனிக்கவும்."; // Urgent! Please note.
    } else if (riskLevel.toUpperCase() == 'YELLOW') {
      prefix = "கவனம் தேவை."; // Attention needed.
    } else {
      prefix = "பரிசோதனை முடிவு:"; // Screening Result:
    }
    
    await speak("$prefix $message");
  }
}
