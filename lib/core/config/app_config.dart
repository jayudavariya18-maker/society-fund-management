import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  static const String defaultSocietyId = '00000000-0000-0000-0000-000000000001';
  static const String defaultSocietyName = 'Ramdevra Society';
  static const String appName = 'RamSeva';
  static const String tagline = 'Ram Na Aashirwad, Hanumanji Ni Shakti, Ramdevra Ni Pragati.';

  static String supabaseUrl = const String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  static String supabaseAnonKey = const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
  static String societyId = const String.fromEnvironment('SOCIETY_ID', defaultValue: defaultSocietyId);

  /// Load credentials from environment, SharedPreferences, or assets/config.json
  static Future<void> load() async {
    // 1. Check SharedPreferences first (allows user or admin to update credentials in-app)
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUrl = prefs.getString('custom_supabase_url');
      final savedKey = prefs.getString('custom_supabase_anon_key');
      if (savedUrl != null && savedUrl.isNotEmpty && savedKey != null && savedKey.isNotEmpty) {
        supabaseUrl = savedUrl;
        supabaseAnonKey = savedKey;
        return;
      }
    } catch (_) {}

    // 2. If compile-time define was provided, use it
    if (supabaseUrl.isNotEmpty && !supabaseUrl.contains('your-project') &&
        supabaseAnonKey.isNotEmpty && !supabaseAnonKey.contains('your-anon-key')) {
      return;
    }

    // 3. Attempt to load from assets/config.json if packaged
    try {
      final jsonStr = await rootBundle.loadString('assets/config.json');
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      if (map['SUPABASE_URL'] != null && map['SUPABASE_ANON_KEY'] != null) {
        final u = map['SUPABASE_URL'].toString();
        final k = map['SUPABASE_ANON_KEY'].toString();
        if (!u.contains('your-project') && !k.contains('your-anon-key')) {
          supabaseUrl = u;
          supabaseAnonKey = k;
          if (map['SOCIETY_ID'] != null) {
            societyId = map['SOCIETY_ID'].toString();
          }
          return;
        }
      }
    } catch (_) {}

    // 4. Default fallback if not yet configured
    if (supabaseUrl.isEmpty) {
      supabaseUrl = 'https://your-project.supabase.co';
    }
    if (supabaseAnonKey.isEmpty) {
      supabaseAnonKey = 'your-anon-key-here';
    }
  }

  static bool get isLiveBackendConfigured =>
      supabaseUrl.isNotEmpty &&
      !supabaseUrl.contains('your-project') &&
      supabaseAnonKey.isNotEmpty &&
      !supabaseAnonKey.contains('your-anon-key');

  static Future<void> saveCustomBackend({required String url, required String anonKey}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('custom_supabase_url', url.trim());
    await prefs.setString('custom_supabase_anon_key', anonKey.trim());
    supabaseUrl = url.trim();
    supabaseAnonKey = anonKey.trim();
  }
}
