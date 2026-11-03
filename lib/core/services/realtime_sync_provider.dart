import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'supabase_service.dart';
import '../../features/announcements/data/announcements_repository.dart';
import '../../features/contributions/data/contributions_repository.dart';
import '../../features/dashboard/data/dashboard_repository.dart';
import '../../features/expenses/data/expenses_repository.dart';
import '../../features/festivals/data/festivals_repository.dart';
import '../../features/funds/data/funds_repository.dart';
import '../../features/members/data/members_repository.dart';
import '../../features/registration/data/registration_repository.dart';

final realtimeSyncProvider = StreamProvider<String>((ref) {
  final stream = SupabaseService.instance.realtimeEvents;

  final subscription = stream.listen((table) {
    debugPrint('[RealtimeSync] Remote update detected on table: $table. Invalidating caches...');
    // Invalidate dashboard and financial summaries
    ref.invalidate(dashboardDataProvider);
    ref.invalidate(fundsListProvider);

    if (table == 'contributions') {
      ref.invalidate(contributionsListProvider(null));
    } else if (table == 'expenses') {
      ref.invalidate(expensesListProvider(null));
    } else if (table == 'festivals' || table == 'festival_events') {
      ref.invalidate(festivalsListProvider);
    } else if (table == 'members') {
      ref.invalidate(membersListProvider);
    } else if (table == 'registration_requests' || table == 'registration_approvals') {
      ref.invalidate(pendingRegistrationsProvider);
      ref.invalidate(membersListProvider);
    } else if (table == 'announcements') {
      ref.invalidate(announcementsListProvider);
    }
  });

  ref.onDispose(() {
    subscription.cancel();
  });

  return stream;
});
