import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();

  SupabaseClient? _client;
  bool _isInitialized = false;
  bool _isMockDevMode = false;

  RealtimeChannel? _realtimeChannel;
  final StreamController<String> _realtimeEventsController =
      StreamController<String>.broadcast();

  SupabaseService._();

  bool get isInitialized => _isInitialized;
  bool get isMockDevMode => _isMockDevMode;
  Stream<String> get realtimeEvents => _realtimeEventsController.stream;

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
        debugPrint('[SupabaseService] Placeholder credentials detected. Running in Clean Initial Mode.');
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
      _setupRealtimeSubscriptions();
    } catch (e) {
      debugPrint('[SupabaseService] Connection error: $e. Fallback to Dev Clean Mode: $enableMockFallback');
      if (enableMockFallback) {
        _isMockDevMode = true;
        _isInitialized = true;
      } else {
        rethrow;
      }
    }
  }

  void _setupRealtimeSubscriptions() {
    if (_client == null || _isMockDevMode) return;
    try {
      _realtimeChannel = _client!.channel('public:ramseva_central_ledger')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'contributions',
          callback: (payload) => _realtimeEventsController.add('contributions'),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'expenses',
          callback: (payload) => _realtimeEventsController.add('expenses'),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'funds',
          callback: (payload) => _realtimeEventsController.add('funds'),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'festivals',
          callback: (payload) => _realtimeEventsController.add('festivals'),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'festival_events',
          callback: (payload) => _realtimeEventsController.add('festival_events'),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'members',
          callback: (payload) => _realtimeEventsController.add('members'),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'registration_requests',
          callback: (payload) => _realtimeEventsController.add('registration_requests'),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'registration_approvals',
          callback: (payload) => _realtimeEventsController.add('registration_approvals'),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'announcements',
          callback: (payload) => _realtimeEventsController.add('announcements'),
        );

      _realtimeChannel!.subscribe((status, [error]) {
        debugPrint('[SupabaseRealtime] Subscription status: $status (error: $error)');
      });
    } catch (e) {
      debugPrint('[SupabaseRealtime] Setup error: $e');
    }
  }

  /// Manually trigger a local state refresh event across the app
  void notifyLocalChange(String table) {
    _realtimeEventsController.add(table);
  }

  String? get currentAuthUid {
    return _client?.auth.currentUser?.id;
  }

  String? get currentUserPhone {
    return _client?.auth.currentUser?.phone;
  }
}
