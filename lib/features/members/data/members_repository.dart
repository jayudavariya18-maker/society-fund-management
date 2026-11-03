import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  MembersRepository(this._supabase);

  // Clean initial store: Zero demo members
  static final List<MemberModel> _mockMembers = [];

  static List<MemberModel> get mockMembers => _mockMembers;

  static void addMockMember(MemberModel member) {
    if (!_mockMembers.any((m) => m.memberId == member.memberId || m.phoneNumber == member.phoneNumber)) {
      _mockMembers.add(member);
    }
  }

  Future<List<MemberModel>> fetchAllMembers() async {
    if (_supabase.isMockDevMode) {
      return _mockMembers;
    }

    final res = await _supabase.client
        .from('members')
        .select()
        .eq('membership_status', 'ACTIVE')
        .order('flat_number', ascending: true);

    return (res as List).map((e) => MemberModel.fromJson(e)).toList();
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
