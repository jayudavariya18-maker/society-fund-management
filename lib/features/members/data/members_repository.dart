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

  // In-memory mock members
  static final List<MemberModel> _mockMembers = [
    MemberModel(
      memberId: '11111111-1111-1111-1111-111111111001',
      societyId: '00000000-0000-0000-0000-000000000001',
      authUid: 'aaaaaaa1-0000-0000-0000-000000000001',
      fullName: 'Rajeshbhai Patel',
      phoneNumber: '+919825000001',
      flatNumber: 'A-402',
      email: 'rajesh.patel@gmail.com',
      membershipStatus: 'ACTIVE',
      joinedAt: DateTime(2025, 1, 1),
    ),
    MemberModel(
      memberId: '11111111-1111-1111-1111-111111111002',
      societyId: '00000000-0000-0000-0000-000000000001',
      authUid: 'aaaaaaa2-0000-0000-0000-000000000002',
      fullName: 'Amitkumar Shah',
      phoneNumber: '+919825000002',
      flatNumber: 'B-201',
      email: 'amit.shah@gmail.com',
      membershipStatus: 'ACTIVE',
      joinedAt: DateTime(2025, 1, 1),
    ),
    MemberModel(
      memberId: '11111111-1111-1111-1111-111111111003',
      societyId: '00000000-0000-0000-0000-000000000001',
      authUid: 'aaaaaaa3-0000-0000-0000-000000000003',
      fullName: 'Meenaben Trivedi',
      phoneNumber: '+919825000003',
      flatNumber: 'C-104',
      email: 'meena.trivedi@gmail.com',
      membershipStatus: 'ACTIVE',
      joinedAt: DateTime(2025, 1, 15),
    ),
  ];

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
