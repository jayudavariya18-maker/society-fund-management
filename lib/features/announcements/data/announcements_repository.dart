import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/local_storage_service.dart';
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

  AnnouncementsRepository(this._supabase, this._ref) {
    _initFromStorage();
  }

  // Clean initial state: Zero demo announcements
  static final List<AnnouncementModel> _mockAnnouncements = [];

  static void _initFromStorage() {
    try {
      final saved = LocalStorageService.instance.loadAnnouncements();
      if (saved.isNotEmpty && _mockAnnouncements.isEmpty) {
        _mockAnnouncements.addAll(saved);
      }
    } catch (_) {}
  }

  Future<List<AnnouncementModel>> fetchAllAnnouncements() async {
    _initFromStorage();

    if (_supabase.isMockDevMode) {
      return _mockAnnouncements;
    }

    try {
      final res = await _supabase.client
          .from('announcements')
          .select('*, creator:members(full_name)')
          .order('created_at', ascending: false);

      final list = (res as List).map((e) => AnnouncementModel.fromJson(e)).toList();
      await LocalStorageService.instance.saveAnnouncements(list);
      return list;
    } catch (_) {
      final local = LocalStorageService.instance.loadAnnouncements();
      if (local.isNotEmpty) return local;
      return _mockAnnouncements;
    }
  }

  Future<AnnouncementModel> createAnnouncement({
    required String title,
    required String message,
    String? attachmentUrl,
  }) async {
    _initFromStorage();
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
      await LocalStorageService.instance.saveAnnouncements(_mockAnnouncements);
      return newModel;
    }

    final res = await _supabase.client.from('announcements').insert({
      'society_id': '00000000-0000-0000-0000-000000000001',
      'title': title,
      'message': message,
      'attachment_url': attachmentUrl,
      'created_by': createdBy,
    }).select('*, creator:members(full_name)').single();

    final model = AnnouncementModel.fromJson(res);
    final all = LocalStorageService.instance.loadAnnouncements();
    all.insert(0, model);
    await LocalStorageService.instance.saveAnnouncements(all);
    return model;
  }
}
