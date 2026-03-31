import 'package:flutter/material.dart';
import 'tamil_strings.dart';

/// Localization delegate and helper for the app
/// Currently supports Tamil (ta) as primary language
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('ta', 'IN'), // Tamil - India
    Locale('en', 'IN'), // English - India (fallback)
  ];

  /// Get the app name in the current locale
  String get appName => TamilStrings.appName;

  /// Get the app tagline in the current locale
  String get appTagline => TamilStrings.appTagline;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['ta', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
