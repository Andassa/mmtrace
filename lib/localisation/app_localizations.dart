import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  // List of supported locales
  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('fr'), // French
  ];

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  // Load localized values from a JSON file or similar source
  static Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  // A map for all the translations
  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'hello': 'Hello',
      'permit_details': 'Permit Details',
      'substance_found': 'Substance Found',
      'fokotany': 'Fokotany',
      'region': 'Region',
    },
    'fr': {
      'hello': 'Bonjour',
      'permit_details': 'Détails du Permis',
      'substance_found': 'Substance Trouvée',
      'fokotany': 'Fokotany',
      'region': 'Région',
    },
  };

  // Retrieve localized strings based on the locale
  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'fr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations.load(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

// Add these to main.dart to provide support for localization
final localizationsDelegates = [
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];
