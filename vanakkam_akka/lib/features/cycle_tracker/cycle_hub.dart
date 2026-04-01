import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/state/cycle_mode_provider.dart';
import 'period_tracker.dart';
import 'pregnancy_tracker.dart';

/// Routes between period logging and pregnancy guide based on [CycleModeProvider] (AI + user choice).
class CycleHubScreen extends StatelessWidget {
  const CycleHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CycleModeProvider>(
      builder: (context, mode, _) {
        if (mode.pregnancyMode) {
          return const PregnancyTrackerScreen();
        }
        return const PeriodTrackerScreen();
      },
    );
  }
}
