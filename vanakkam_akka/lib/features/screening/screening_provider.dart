import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}

/// Manages the state and backend API integration for the AI Health Screening flow.
class ScreeningProvider extends ChangeNotifier {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:8000/api/v1'));
  
  List<ChatMessage> messages = [];
  bool isThinking = false;
  String currentRiskLevel = '';
  bool isComplete = false;
  
  int userId = 1; // Expected to be injected securely from AuthService in production
  
  /// Re-initializes state for a new screening session
  void initSession() {
    messages.clear();
    isComplete = false;
    currentRiskLevel = '';
    isThinking = false;
    notifyListeners();
  }
  
  /// Pushes an initial or system message without triggering the AI
  void addAiMessage(String msg) {
    messages.add(ChatMessage(text: msg, isUser: false));
    notifyListeners();
  }

  /// Sends the user's spoken text to the backend and returns the AI response
  Future<String?> sendMessage(String userText) async {
    // Immediate UI update for user message
    messages.add(ChatMessage(text: userText, isUser: true));
    isThinking = true;
    notifyListeners();
    
    try {
      // Filter out only textual history (excluding risk cards)
      final history = messages.map((m) => {
        "role": m.isUser ? "user" : "assistant",
        "content": m.text
      }).toList();

      final response = await _dio.post('/screening/message', data: {
        'user_id': userId,
        'message': userText,
        'conversation_history': history,
      });
      
      final data = response.data;
      final aiResponse = data['ai_response'] as String;
      
      isComplete = data['is_complete'] ?? false;
      currentRiskLevel = data['risk_level'] ?? '';
      
      // Update UI with AI response
      messages.add(ChatMessage(text: aiResponse, isUser: false));
      isThinking = false;
      notifyListeners();
      
      return aiResponse;
    } catch (e) {
      isThinking = false;
      final errorMsg = "மன்னிக்கவும், பிணையப் இணைப்பில் சிக்கல் உள்ளது. மீண்டும் கூறுங்கள்."; // Sorry, network issue. Please repeat.
      messages.add(ChatMessage(text: errorMsg, isUser: false));
      notifyListeners();
      return errorMsg;
    }
  }
}
