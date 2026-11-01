import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _prefLocaleKey = 'app_selected_locale';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('en')) {
    _loadPersistedLocale();
  }

  Future<void> _loadPersistedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final langCode = prefs.getString(_prefLocaleKey);
      if (langCode != null && ['en', 'gu', 'hi'].contains(langCode)) {
        state = Locale(langCode);
      }
    } catch (_) {
      // Fallback to default
    }
  }

  Future<void> setLocale(String languageCode) async {
    if (!['en', 'gu', 'hi'].contains(languageCode)) return;
    state = Locale(languageCode);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefLocaleKey, languageCode);
    } catch (_) {}
  }
}
