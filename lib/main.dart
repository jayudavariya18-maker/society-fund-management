import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'core/config/app_config.dart';
import 'core/services/local_storage_service.dart';
import 'core/services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize persistent disk storage first so data & sessions survive restarts
  await LocalStorageService.instance.initialize();

  // Load configuration from compile defines, storage, or bundled assets
  await AppConfig.load();

  // Initialize Supabase connectivity with safe fallback
  await SupabaseService.instance.initialize(
    supabaseUrl: AppConfig.supabaseUrl,
    supabaseAnonKey: AppConfig.supabaseAnonKey,
    enableMockFallback: true,
  );

  runApp(
    const ProviderScope(
      child: RamSevaApp(),
    ),
  );
}
