import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../core/services/supabase_service.dart';
import '../../../shared/models/member_model.dart';

final membersRepositoryProvider = Provider<MembersRepository>((ref) {
  return MembersRepository(SupabaseService.instance);
});

final membersListProvider = FutureProvider<List<MemberModel>>((ref) async {
  final repo = ref.watch(membersRepositoryProvider);
  return repo.fetchAllMembers();
});

class MembersRepository {
  final SupabaseService _supabase;

  MembersRepository(this._supabase) {
    _initFromStorage();
  }

  // Clean initial store: Zero demo members
  static final List<MemberModel> _mockMembers = [];

  static void _initFromStorage() {
    try {
      final saved = LocalStorageService.instance.loadMembers();
      if (saved.isNotEmpty && _mockMembers.isEmpty) {
        _mockMembers.addAll(saved);
      }
    } catch (_) {}
  }

  static List<MemberModel> get mockMembers {
    _initFromStorage();
    return _mockMembers;
  }

  static void addMockMember(MemberModel member) {
    _initFromStorage();
    if (!_mockMembers.any((m) => m.memberId == member.memberId || m.phoneNumber == member.phoneNumber)) {
      _mockMembers.add(member);
      LocalStorageService.instance.saveMembers(_mockMembers);
    }
  }

  Future<List<MemberModel>> fetchAllMembers() async {
    _initFromStorage();

    if (_supabase.isMockDevMode) {
      return _mockMembers;
    }

    try {
      final res = await _supabase.client
          .from('members')
          .select()
          .eq('membership_status', 'ACTIVE')
          .order('flat_number', ascending: true);

      final members = (res as List).map((e) => MemberModel.fromJson(e)).toList();
      await LocalStorageService.instance.saveMembers(members);
      return members;
    } catch (_) {
      final local = LocalStorageService.instance.loadMembers();
      if (local.isNotEmpty) return local;
      return _mockMembers;
    }
  }

  Future<List<MemberModel>> searchMembers(String query) async {
    final all = await fetchAllMembers();
    if (query.trim().isEmpty) return all;
    final q = query.toLowerCase();
    return all.where((m) =>
      m.fullName.toLowerCase().contains(q) ||
      m.flatNumber.toLowerCase().contains(q) ||
      m.phoneNumber.contains(q)
    ).toList();
  }
}
