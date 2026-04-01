import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/state/cycle_mode_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/localization/tamil_strings.dart';
import 'core/localization/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'features/screening/screening_provider.dart';
import 'shared/services/local_db_service.dart';
import 'shared/services/voice_service.dart';
import 'core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Single entry point for persistent storage initialization
  final dbService = LocalDbService();
  await dbService.init();

  final cycleMode = CycleModeProvider();
  await cycleMode.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => VoiceService()),
        ChangeNotifierProvider(create: (_) => ScreeningProvider()),
        ChangeNotifierProvider<CycleModeProvider>.value(value: cycleMode),
      ],
      child: const VanakkamAkkaApp(),
    ),
  );
}

class VanakkamAkkaApp extends StatelessWidget {
  const VanakkamAkkaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: TamilStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: const Locale('ta', 'IN'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: AppRouter.router,
    );
  }
}
