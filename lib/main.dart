import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'core/services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase connectivity with safe dev fallback
  // In production, credentials come from environment or .env
  await SupabaseService.instance.initialize(
    supabaseUrl: const String.fromEnvironment('SUPABASE_URL', defaultValue: 'https://your-project.supabase.co'),
    supabaseAnonKey: const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: 'your-anon-key-here'),
    enableMockFallback: true,
  );

  runApp(
    const ProviderScope(
      child: BajrangSocietyApp(),
    ),
  );
}
