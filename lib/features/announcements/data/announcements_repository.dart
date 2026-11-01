import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/supabase_service.dart';
import '../../../shared/models/announcement_model.dart';
import '../../authentication/data/auth_repository.dart';

final announcementsRepositoryProvider = Provider<AnnouncementsRepository>((ref) {
  return AnnouncementsRepository(SupabaseService.instance, ref);
});

final announcementsListProvider = FutureProvider<List<AnnouncementModel>>((ref) async {
  final repo = ref.watch(announcementsRepositoryProvider);
  return repo.fetchAllAnnouncements();
});

class AnnouncementsRepository {
  final SupabaseService _supabase;
  final Ref _ref;

  AnnouncementsRepository(this._supabase, this._ref);

  static final List<AnnouncementModel> _mockAnnouncements = [
    AnnouncementModel(
      announcementId: '77777777-7777-7777-7777-777777777001',
      societyId: '00000000-0000-0000-0000-000000000001',
      title: 'General Body Meeting on Sunday 10:00 AM',
      message: 'Dear Residents, Please gather at the Club House to discuss water storage cleaning and festival schedules.',
      createdBy: '11111111-1111-1111-1111-111111111001',
      createdByName: 'Rajeshbhai Patel',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    AnnouncementModel(
      announcementId: '77777777-7777-7777-7777-777777777002',
      societyId: '00000000-0000-0000-0000-000000000001',
      title: 'Navratri Garba Passes Distribution',
      message: 'Resident ID badges and visitor parking coupons can be collected this evening from the society office.',
      createdBy: '11111111-1111-1111-1111-111111111002',
      createdByName: 'Amitkumar Shah',
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
  ];

  Future<List<AnnouncementModel>> fetchAllAnnouncements() async {
    if (_supabase.isMockDevMode) {
      return _mockAnnouncements;
    }

    final res = await _supabase.client
        .from('announcements')
        .select('*, creator:members(full_name)')
        .order('created_at', ascending: false);

    return (res as List).map((e) => AnnouncementModel.fromJson(e)).toList();
  }

  Future<AnnouncementModel> createAnnouncement({
    required String title,
    required String message,
    String? attachmentUrl,
  }) async {
    final activeMember = _ref.read(authStateProvider).activeMember;
    final createdBy = activeMember?.memberId ?? '11111111-1111-1111-1111-111111111001';

    if (_supabase.isMockDevMode) {
      final newModel = AnnouncementModel(
        announcementId: 'ann-${DateTime.now().millisecondsSinceEpoch}',
        societyId: '00000000-0000-0000-0000-000000000001',
        title: title,
        message: message,
        attachmentUrl: attachmentUrl,
        createdBy: createdBy,
        createdByName: activeMember?.fullName ?? 'Resident',
        createdAt: DateTime.now(),
      );
      _mockAnnouncements.insert(0, newModel);
      return newModel;
    }

    final res = await _supabase.client.from('announcements').insert({
      'society_id': '00000000-0000-0000-0000-000000000001',
      'title': title,
      'message': message,
      'attachment_url': attachmentUrl,
      'created_by': createdBy,
    }).select('*, creator:members(full_name)').single();

    return AnnouncementModel.fromJson(res);
  }
}
