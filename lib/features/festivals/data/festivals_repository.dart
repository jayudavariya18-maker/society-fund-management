import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/supabase_service.dart';
import '../../../shared/models/festival_event_model.dart';
import '../../../shared/models/festival_model.dart';
import '../../authentication/data/auth_repository.dart';
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

  // In-memory mock festivals
  static final List<FestivalModel> _mockFestivals = [
    FestivalModel(
      festivalId: '33333333-3333-3333-3333-333333333001',
      societyId: '00000000-0000-0000-0000-000000000001',
      festivalName: 'Navratri Mahotsav 2026',
      description: '9 Days of Dandiya Raas, Garba & Aarti celebration with resident community',
      startDate: DateTime(2026, 10, 10),
      endDate: DateTime(2026, 10, 19),
      status: 'UPCOMING',
      createdBy: '11111111-1111-1111-1111-111111111001',
      createdAt: DateTime(2026, 9, 1),
      totalContributions: 10000.00,
      totalExpenses: 4000.00,
      remainingBalance: 6000.00,
    ),
    FestivalModel(
      festivalId: '33333333-3333-3333-3333-333333333002',
      societyId: '00000000-0000-0000-0000-000000000001',
      festivalName: 'Diwali Snehamilan 2026',
      description: 'New Year Annakut, Deepotsav & Society Annual Community Dinner',
      startDate: DateTime(2026, 11, 8),
      endDate: DateTime(2026, 11, 10),
      status: 'UPCOMING',
      createdBy: '11111111-1111-1111-1111-111111111002',
      createdAt: DateTime(2026, 9, 15),
      totalContributions: 0.00,
      totalExpenses: 0.00,
      remainingBalance: 0.00,
    ),
  ];

  static final List<FestivalEventModel> _mockEvents = [
    FestivalEventModel(
      eventId: '44444444-4444-4444-4444-444444444001',
      festivalId: '33333333-3333-3333-3333-333333333001',
      eventName: 'Grand Garba Night & Orchestra',
      description: 'Live Gujarati folk band and traditional sound arrangement',
      eventDate: DateTime(2026, 10, 15),
      eventLocation: 'Central Society Lawn',
      estimatedBudget: 35000.00,
      createdBy: '11111111-1111-1111-1111-111111111001',
      createdAt: DateTime(2026, 9, 5),
    ),
    FestivalEventModel(
      eventId: '44444444-4444-4444-4444-444444444002',
      festivalId: '33333333-3333-3333-3333-333333333001',
      eventName: 'Maha Aarti, Hawan & Mahaprasad',
      description: 'Ashtami sacred fire and community feast',
      eventDate: DateTime(2026, 10, 18),
      eventLocation: 'Community Hall',
      estimatedBudget: 25000.00,
      createdBy: '11111111-1111-1111-1111-111111111003',
      createdAt: DateTime(2026, 9, 6),
    ),
  ];

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

    return FestivalEventModel.fromJson(res);
  }
}
