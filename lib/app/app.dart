import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/realtime_sync_provider.dart';
import '../features/dashboard/data/dashboard_repository.dart';
import '../features/funds/data/funds_repository.dart';
import 'localization/app_localizations.dart';
import 'localization/locale_provider.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class RamSevaApp extends ConsumerStatefulWidget {
  const RamSevaApp({super.key});

  @override
  ConsumerState<RamSevaApp> createState() => _RamSevaAppState();
}

class _RamSevaAppState extends ConsumerState<RamSevaApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh central balances whenever user returns to the application
      ref.invalidate(dashboardDataProvider);
      ref.invalidate(fundsListProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Automatically listen to realtime PostgreSQL database changes across all devices
    ref.listen(realtimeSyncProvider, (_, __) {});

    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'RamSeva',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: router,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}

/// Backwards-compatible alias
typedef BajrangSocietyApp = RamSevaApp;
