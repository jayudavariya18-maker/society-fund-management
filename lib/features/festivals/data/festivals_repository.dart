import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/supabase_service.dart';
import '../../../shared/models/festival_event_model.dart';
import '../../../shared/models/festival_model.dart';
import '../../authentication/data/auth_repository.dart';
import '../../dashboard/data/dashboard_repository.dart';
import '../../funds/data/funds_repository.dart';

final festivalsRepositoryProvider = Provider<FestivalsRepository>((ref) {
  return FestivalsRepository(SupabaseService.instance, ref);
});

final festivalsListProvider = FutureProvider<List<FestivalModel>>((ref) async {
  final repo = ref.watch(festivalsRepositoryProvider);
  return repo.fetchAllFestivals();
});

class FestivalsRepository {
  final SupabaseService _supabase;
  final Ref _ref;

  FestivalsRepository(this._supabase, this._ref);

  // Clean initial state: Zero demo festivals and events
  static final List<FestivalModel> _mockFestivals = [];
  static final List<FestivalEventModel> _mockEvents = [];

  Future<List<FestivalModel>> fetchAllFestivals() async {
    if (_supabase.isMockDevMode) {
      return _mockFestivals;
    }

    final res = await _supabase.client
        .from('festivals')
        .select('*, funds(opening_balance, total_contributions, total_expenses, current_balance)')
        .order('start_date', ascending: true);

    return (res as List).map((e) => FestivalModel.fromJson(e)).toList();
  }

  Future<List<FestivalEventModel>> fetchEventsForFestival(String festivalId) async {
    if (_supabase.isMockDevMode) {
      return _mockEvents.where((e) => e.festivalId == festivalId).toList();
    }

    final res = await _supabase.client
        .from('festival_events')
        .select()
        .eq('festival_id', festivalId)
        .order('event_date', ascending: true);

    return (res as List).map((e) => FestivalEventModel.fromJson(e)).toList();
  }

  Future<FestivalModel> createFestival({
    required String festivalName,
    String? description,
    required DateTime startDate,
    required DateTime endDate,
    String? coverImageUrl,
    double openingFundBalance = 0.0,
  }) async {
    final activeMember = _ref.read(authStateProvider).activeMember;
    final createdBy = activeMember?.memberId ?? '11111111-1111-1111-1111-111111111001';

    if (_supabase.isMockDevMode) {
      final festId = 'fest-${DateTime.now().millisecondsSinceEpoch}';
      final newFest = FestivalModel(
        festivalId: festId,
        societyId: '00000000-0000-0000-0000-000000000001',
        festivalName: festivalName,
        description: description,
        startDate: startDate,
        endDate: endDate,
        coverImageUrl: coverImageUrl,
        createdBy: createdBy,
        createdAt: DateTime.now(),
        remainingBalance: openingFundBalance,
      );
      _mockFestivals.add(newFest);

      // Create dedicated festival fund
      await _ref.read(fundsRepositoryProvider).createFestivalFund(
        fundName: '$festivalName Fund',
        festivalId: festId,
        description: 'Dedicated fund for $festivalName',
        openingBalance: openingFundBalance,
      );

      _ref.invalidate(festivalsListProvider);
      _ref.invalidate(fundsListProvider);
      _ref.invalidate(dashboardDataProvider);
      _supabase.notifyLocalChange('festivals');
      return newFest;
    }

    // 1. Insert Festival
    final festRes = await _supabase.client.from('festivals').insert({
      'society_id': '00000000-0000-0000-0000-000000000001',
      'festival_name': festivalName,
      'description': description,
      'start_date': startDate.toIso8601String().split('T').first,
      'end_date': endDate.toIso8601String().split('T').first,
      'status': 'UPCOMING',
      'cover_image_url': coverImageUrl,
      'created_by': createdBy,
    }).select().single();

    final festival = FestivalModel.fromJson(festRes);

    // 2. Automatically create the dedicated festival fund
    await _ref.read(fundsRepositoryProvider).createFestivalFund(
      fundName: '$festivalName Fund',
      festivalId: festival.festivalId,
      description: 'Dedicated fund for $festivalName',
      openingBalance: openingFundBalance,
    );

    _ref.invalidate(festivalsListProvider);
    _ref.invalidate(fundsListProvider);
    _ref.invalidate(dashboardDataProvider);
    _supabase.notifyLocalChange('festivals');
    return festival;
  }

  Future<FestivalEventModel> createEvent({
    required String festivalId,
    required String eventName,
    String? description,
    required DateTime eventDate,
    String? eventLocation,
    double estimatedBudget = 0.0,
  }) async {
    final activeMember = _ref.read(authStateProvider).activeMember;
    final createdBy = activeMember?.memberId ?? '11111111-1111-1111-1111-111111111001';

    if (_supabase.isMockDevMode) {
      final newEvent = FestivalEventModel(
        eventId: 'event-${DateTime.now().millisecondsSinceEpoch}',
        festivalId: festivalId,
        eventName: eventName,
        description: description,
        eventDate: eventDate,
        eventLocation: eventLocation,
        estimatedBudget: estimatedBudget,
        createdBy: createdBy,
        createdAt: DateTime.now(),
      );
      _mockEvents.add(newEvent);
      _ref.invalidate(festivalsListProvider);
      _supabase.notifyLocalChange('festival_events');
      return newEvent;
    }

    final res = await _supabase.client.from('festival_events').insert({
      'festival_id': festivalId,
      'event_name': eventName,
      'description': description,
      'event_date': eventDate.toIso8601String().split('T').first,
      'event_location': eventLocation,
      'estimated_budget': estimatedBudget,
      'created_by': createdBy,
    }).select().single();

    final event = FestivalEventModel.fromJson(res);
    _ref.invalidate(festivalsListProvider);
    _supabase.notifyLocalChange('festival_events');
    return event;
  }
}
