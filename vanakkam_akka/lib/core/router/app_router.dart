import 'package:go_router/go_router.dart';

import '../../features/home/home_screen.dart';
import '../../features/screening/voice_chat_ui.dart';
import '../../features/cycle_tracker/cycle_hub.dart';
import '../../features/health_notebook/notebook_home.dart';
import '../../features/teleconsult/consult_home.dart';
import '../../features/reminders/reminder_home.dart';
import '../../features/vhn_mode/vhn_login.dart';
import '../../features/vhn_mode/village_patient_list.dart';

/// Centralized app router using GoRouter for declarative navigation.
class AppRouter {
  AppRouter._();

  static const String home = '/';
  static const String screening = '/screening';
  static const String cycleTracker = '/cycle-tracker';
  static const String healthNotebook = '/health-notebook';
  static const String teleconsult = '/teleconsult';
  static const String reminders = '/reminders';
  static const String vhnMode = '/vhn-mode';
  static const String vhnDashboard = '/vhn-dashboard';

  static final router = GoRouter(
    initialLocation: home,
    routes: [
      GoRoute(
        path: home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: screening,
        builder: (context, state) => const VoiceChatUiScreen(),
      ),
      GoRoute(
        path: cycleTracker,
        builder: (context, state) => const CycleHubScreen(),
      ),
      GoRoute(
        path: healthNotebook,
        builder: (context, state) => const NotebookHomeScreen(),
      ),
      GoRoute(
        path: teleconsult,
        builder: (context, state) => const ConsultHomeScreen(),
      ),
      GoRoute(
        path: reminders,
        builder: (context, state) => const ReminderHomeScreen(),
      ),
      GoRoute(
        path: vhnMode,
        builder: (context, state) => const VhnLoginScreen(),
      ),
      GoRoute(
        path: vhnDashboard,
        builder: (context, state) => const VillagePatientListScreen(),
      ),
    ],
  );
}
