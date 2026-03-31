import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Centralized Auth Service integrating Firebase Phone Auth + FastAPI JWT Backend
class AuthService extends ChangeNotifier {
  final fb.FirebaseAuth _firebaseAuth = fb.FirebaseAuth.instance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  // Setup Dio pointing to your localhost/FastAPI running instance
  // Note: 10.0.2.2 is the localhost alias for Android Emulators
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:8000/api/v1'));
  
  String? _verificationId;
  String? _jwtToken;
  
  bool get isAuthenticated => _jwtToken != null;

  AuthService() {
    _loadStoredToken();
  }

  /// Attempts to load an existing JWT token to skip login
  Future<void> _loadStoredToken() async {
    _jwtToken = await _secureStorage.read(key: 'jwt_token');
    if (_jwtToken != null) {
      notifyListeners();
    }
  }

  /// Triggers Firebase OTP sending specifically forced into Indian (+91) format
  Future<void> signInWithPhone(
    String phoneNumber, {
    required Function(String code) onCodeSent,
    required Function(String error) onError,
  }) async {
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: '+91$phoneNumber',
      
      // Auto-resolution (often works seamlessly on Android skipping the code)
      verificationCompleted: (fb.PhoneAuthCredential credential) async {
        await _signInWithCredential(credential, onError);
      },
      
      // Failed verification
      verificationFailed: (fb.FirebaseAuthException e) {
        onError("பிழை: ${e.message}");
      },
      
      // OTP physically sent to SMS
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        onCodeSent(verificationId);
      },
      
      // Auto-retrieval timeout
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  /// Captures the manual 6-digit OTP and authenticates with Firebase explicitly
  Future<Map<String, dynamic>> verifyOTP(String otp) async {
    if (_verificationId == null) {
      throw Exception("சரிபார்ப்பு குறியீடு கிடைக்கவில்லை (Verification ID missing)");
    }
    
    try {
       // 1. Authenticate with Firebase using manually entered OTP code
       fb.PhoneAuthCredential credential = fb.PhoneAuthProvider.credential(
         verificationId: _verificationId!,
         smsCode: otp,
       );
       return await _signInWithCredential(credential, (err) { throw Exception(err); });
    } catch(e) {
       throw Exception("தவறான OTP. மீண்டும் முயற்சிக்கவும்");
    }
  }

  /// Takes Firebase credential, secures ID token, and pushes it to FastAPI DB checks
  Future<Map<String, dynamic>> _signInWithCredential(fb.PhoneAuthCredential credential, Function(String err) onError) async {
    try {
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final idToken = await userCredential.user?.getIdToken();
      
      if (idToken == null) {
        throw Exception("Firebase அங்கீகாரம் தோல்வியடைந்தது"); // Token Failed
      }

      // 2. Transmit the Firebase ID Token to the custom FastAPI backend
      final response = await _dio.post('/auth/verify-otp', data: {
        'id_token': idToken,
      });
      
      final data = response.data;
      
      // 3. Store the fully generated user JWT securely on the OS encrypted level
      _jwtToken = data['token'];
      await _secureStorage.write(key: 'jwt_token', value: _jwtToken);
      
      notifyListeners();
      return data; // returns { "token", "user_id", "is_new_user" }
      
    } catch (e) {
      onError("சர்வர் பிழை (Backend Login Error): $e");
      rethrow;
    }
  }

  /// Pushes comprehensive onboarding payload to backend profile setup routes
  Future<void> updateProfile({
    required String name,
    required int age,
    required String district,
    required String literacyMode,
    required List<String> conditions,
  }) async {
    if (_jwtToken == null) throw Exception("No auth token available");
    try {
      await _dio.post('/auth/profile', data: {
        'name': name,
        'age': age,
        'district': district,
        'literacy_mode': literacyMode,
        'health_conditions': conditions,
      }, options: Options(headers: {'Authorization': 'Bearer $_jwtToken'}));
    } catch (e) {
      throw Exception("சுயவிவரப் பிழை (Profile Update Error): $e");
    }
  }

  /// Fetch user profile ensuring standard Bearer inclusion (JWT secured)
  Future<dynamic> getCurrentUser() async {
    if (_jwtToken == null) return null;
    
    try {
      final response = await _dio.get(
        '/auth/me', 
        options: Options(headers: {'Authorization': 'Bearer $_jwtToken'})
      );
      return response.data;
    } catch (e) {
      return null;
    }
  }

  /// Wipe application data to perform safe logouts
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _secureStorage.delete(key: 'jwt_token');
    _jwtToken = null;
    notifyListeners();
  }
}
