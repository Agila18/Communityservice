import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../../shared/services/voice_service.dart';

/// Offline Adaptive Audio Notification orchestrator linking system-level alarm clocks 
/// dynamically mapped avoiding heavy agricultural daylight loads specifically.
class VoiceReminderService {
  static final VoiceReminderService _instance = VoiceReminderService._internal();
  factory VoiceReminderService() => _instance;
  VoiceReminderService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  
  // Decoupled instantiation to preserve safe background Audio routing
  late final VoiceService _voiceService;

  Future<void> init() async {
    tz_data.initializeTimeZones();
    _voiceService = VoiceService(); // Lazily mount to ensure UI contexts have bound
    
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    
    await _flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
         if (response.payload != null) {
            // When user taps the system notification banner -> immediately dictate audio!
            _voiceService.speak(response.payload!); 
         }
      },
    );
  }

  /// Explicit Heuristic mapping agricultural rhythms:
  /// Rural women overwhelmingly tend to household chores pre-9AM, and farm labor strictly around mid-day heat constraints.
  /// Standard clinical algorithms fail here. Akka strictly avoids these blocks.
  DateTime _optimizeRuralTiming(DateTime input) {
     final hr = input.hour;
     
     // 6 AM - 9 AM (Chores/Cooking) -> Automatically shifted securely to 9:30 AM Break
     if (hr >= 6 && hr < 9) {
        return DateTime(input.year, input.month, input.day, 9, 30);
     }
     
     // 12 PM - 2 PM (Lunch/Labor) -> Shifted securely to 3:00 PM Break
     if (hr >= 12 && hr < 14) {
        return DateTime(input.year, input.month, input.day, 15, 0);
     }
     
     return input;
  }

  /// Dynamically schedules ISO system timers injecting payload descriptors readable by VoiceEngine upon interception.
  Future<void> scheduleVoiceReminder({
     required int id,
     required String medicineName, 
     required DateTime time,
     String? customMessage
  }) async {
    final optimalTime = _optimizeRuralTiming(time);
    
    // Explicit syntax requested: 'அக்கா, [medicine name] சாப்பிட மறந்துவிடாதீர்கள்!'
    final String tamilText = customMessage ?? "அக்கா, $medicineName சாப்பிட மறந்துவிடாதீர்கள்!";
    
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id: id,
      title: 'மருந்து நேரம்! (Time for your medicine)',
      body: tamilText,
      scheduledDate: tz.TZDateTime.from(optimalTime, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'vanakkam_akka_reminders',
          'Medicines & Clinical Reminders (மாத்திரைகள்)',
          channelDescription: 'Smart maternal health notification routines avoiding chore hours.',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          styleInformation: BigTextStyleInformation(''),
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      // Removed uiLocalNotificationDateInterpretation as it appears undefined/optional in v21.0.0
      payload: tamilText, 
    );
  }
}
