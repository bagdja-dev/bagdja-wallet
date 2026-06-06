import 'dart:core';
import 'package:flutter/material.dart';
import 'en.dart' as en;
import 'id.dart' as id;

class Main {
  final Locale locale;
  final Map<String, String> localizedStrings;

  Main(this.locale, this.localizedStrings);

  /// Get localized string by key
  String get(String key) {
    return localizedStrings[key] ?? key;
  }

  /// Get the current instance from context
  static Main of(BuildContext context) {
    return Localizations.of<Main>(context, Main) ??
        load(Localizations.localeOf(context));
  }

  static Map<String, String> _flatten(
    Map<String, Map<String, String>> groupedStrings,
  ) {
    final Map<String, String> flattened = <String, String>{};

    for (final MapEntry<String, Map<String, String>> group
        in groupedStrings.entries) {
      for (final MapEntry<String, String> entry in group.value.entries) {
        flattened.putIfAbsent(entry.key, () => entry.value);
        flattened['${group.key}.${entry.key}'] = entry.value;
      }
    }

    return flattened;
  }

  static Map<String, Map<String, String>> _findRawStrings(
    Locale locale,
  ) {
    final String? countryCode = locale.countryCode;
    final String languageCode = locale.languageCode;

    if (countryCode != null && countryCode.isNotEmpty) {
      final String exactKey = '${languageCode}_$countryCode';
      final Map<String, Map<String, String>>? exact = _supportedLanguages[exactKey];
      if (exact != null) return exact;
    }

    // Fallback: match first locale key by language code (e.g. `id_*`).
    final String languagePrefix = '${languageCode}_';
    final List<String> matches = _supportedLanguages.keys
        .where((k) => k.startsWith(languagePrefix))
        .toList()
      ..sort();
    if (matches.isNotEmpty) {
      return _supportedLanguages[matches.first]!;
    }

    // Default fallback: English.
    return en.enStrings;
  }

  /// Load localization for specific locale
  static Main load(Locale locale) {
    final Map<String, Map<String, String>> rawStrings = _findRawStrings(locale);
    return Main(locale, _flatten(rawStrings));
  }

  /// Map of supported languages
  static final Map<String, Map<String, Map<String, String>>> _supportedLanguages = {
    'en_US': en.enStrings,
    'id_ID': id.idStrings,
  };

  /// Get list of supported locales
  static List<Locale> get supportedLocales {
    return _supportedLanguages.keys.map((key) {
      final parts = key.split('_');
      return Locale(parts[0], parts[1]);
    }).toList();
  }
}

/// Localization delegate for example app
class AppLocalizationsDelegate
    extends LocalizationsDelegate<Main> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'id'].contains(locale.languageCode);

  @override
  Future<Main> load(Locale locale) async {
    return Main.load(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

/// Extension for easy access to localization
extension LocalizationExtension on BuildContext {
  /// Get Localizations instance
  Main get l => Main.of(this);

  /// Translate a key (shorthand for Localizations.of(context).get(key))
  String tr(String key) => Main.of(this).get(key);
}
