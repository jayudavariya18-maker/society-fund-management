import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();

  SupabaseClient? _client;
  bool _isInitialized = false;
  bool _isMockDevMode = false;

  SupabaseService._();

  bool get isInitialized => _isInitialized;
  bool get isMockDevMode => _isMockDevMode;
  SupabaseClient get client {
    if (_client == null) {
      throw StateError('SupabaseService not initialized. Call initialize() first.');
    }
    return _client!;
  }

  Future<void> initialize({
    required String supabaseUrl,
    required String supabaseAnonKey,
    bool enableMockFallback = true,
  }) async {
    if (supabaseUrl.contains('your-project') || supabaseAnonKey.contains('your-anon-key')) {
      if (enableMockFallback) {
        debugPrint('[SupabaseService] Placeholder credentials detected. Running in Development Mock Mode.');
        _isMockDevMode = true;
        _isInitialized = true;
        return;
      }
    }

    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
      _client = Supabase.instance.client;
      _isInitialized = true;
      _isMockDevMode = false;
      debugPrint('[SupabaseService] Successfully connected to live Supabase project.');
    } catch (e) {
      debugPrint('[SupabaseService] Connection error: $e. Fallback to Dev Mock Mode: $enableMockFallback');
      if (enableMockFallback) {
        _isMockDevMode = true;
        _isInitialized = true;
      } else {
        rethrow;
      }
    }
  }

  String? get currentAuthUid {
    if (_isMockDevMode) return 'aaaaaaa1-0000-0000-0000-000000000001';
    return _client?.auth.currentUser?.id;
  }

  String? get currentUserPhone {
    if (_isMockDevMode) return '+919825000001';
    return _client?.auth.currentUser?.phone;
  }
}
