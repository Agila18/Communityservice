import 'package:flutter/material.dart';

/// Basic app router - placeholder for navigation setup
/// Will use go_router or Navigator 2.0 in production
class AppRouter {
  AppRouter._();

  static const String home = '/';
  static const String onboarding = '/onboarding';
  static const String screening = '/screening';
  static const String cycleTracker = '/cycle-tracker';
  static const String healthNotebook = '/health-notebook';
  static const String teleconsult = '/teleconsult';
  static const String reminders = '/reminders';
  static const String nutrition = '/nutrition';
  static const String vhnMode = '/vhn-mode';

  /// Named route map for basic Navigator 1.0
  static Map<String, WidgetBuilder> get routes => {
        // Routes will be registered as features are built
      };
}
