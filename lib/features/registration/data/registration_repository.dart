import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/supabase_service.dart';
import '../../../shared/models/member_model.dart';
import '../../../shared/models/registration_request_model.dart';
import '../../authentication/data/auth_repository.dart';
import '../../dashboard/data/dashboard_repository.dart';
import '../../members/data/members_repository.dart';

final registrationRepositoryProvider = Provider<RegistrationRepository>((ref) {
  return RegistrationRepository(SupabaseService.instance, ref);
});

final pendingRegistrationsProvider = FutureProvider<List<RegistrationRequestModel>>((ref) async {
  final repo = ref.watch(registrationRepositoryProvider);
  return repo.fetchPendingRequests();
});

class RegistrationRepository {
  final SupabaseService _supabase;
  final Ref _ref;

  RegistrationRepository(this._supabase, this._ref);

  // Clean initial state: Zero demo registration requests
  static final List<RegistrationRequestModel> _mockRequests = [];

  static List<RegistrationRequestModel> get mockRequests => _mockRequests;

  /// Submit new resident registration request
  Future<RegistrationRequestModel> submitRequest({
    required String fullName,
    required String flatNumber,
    String? additionalInfo,
  }) async {
    final currentPhone = _ref.read(authStateProvider).phoneNumber ?? '+919825000004';
    final authUid = _supabase.currentAuthUid ?? 'aaaaaaa4-0000-0000-0000-000000000004';

    if (_supabase.isMockDevMode) {
      final newReq = RegistrationRequestModel(
        requestId: 'req-${DateTime.now().millisecondsSinceEpoch}',
        societyId: '00000000-0000-0000-0000-000000000001',
        authUid: authUid,
        fullName: fullName,
        phoneNumber: currentPhone,
        flatNumber: flatNumber,
        additionalInformation: additionalInfo,
        requestStatus: 'PENDING',
        submittedAt: DateTime.now(),
      );
      _mockRequests.add(newReq);
      _ref.invalidate(pendingRegistrationsProvider);
      _supabase.notifyLocalChange('registration_requests');
      return newReq;
    }

    final res = await _supabase.client.from('registration_requests').insert({
      'society_id': '00000000-0000-0000-0000-000000000001',
      'auth_uid': authUid,
      'full_name': fullName,
      'phone_number': currentPhone,
      'flat_number': flatNumber,
      'additional_information': additionalInfo,
      'request_status': 'PENDING',
    }).select().single();

    final model = RegistrationRequestModel.fromJson(res);
    _ref.invalidate(pendingRegistrationsProvider);
    _supabase.notifyLocalChange('registration_requests');
    return model;
  }

  /// Fetch all PENDING registration requests for active members to review
  Future<List<RegistrationRequestModel>> fetchPendingRequests() async {
    if (_supabase.isMockDevMode) {
      return _mockRequests.where((r) => r.isPending).toList();
    }

    final res = await _supabase.client
        .from('registration_requests')
        .select()
        .eq('request_status', 'PENDING')
        .order('submitted_at', ascending: false);

    return (res as List).map((e) => RegistrationRequestModel.fromJson(e)).toList();
  }

  /// Approve or Reject a Registration Request (Executed by ANY active member)
  Future<void> reviewRequest({
    required String requestId,
    required String decision, // 'APPROVED' or 'REJECTED'
    String? comments,
  }) async {
    final activeMember = _ref.read(authStateProvider).activeMember;
    if (activeMember == null) {
      throw StateError('Only active members can approve or reject registration requests.');
    }

    if (_supabase.isMockDevMode) {
      final index = _mockRequests.indexWhere((r) => r.requestId == requestId);
      if (index != -1) {
        final req = _mockRequests[index];
        // Self-approval security check
        if (req.authUid == activeMember.authUid) {
          throw StateError('Self-approval is forbidden. Another active member must approve your request.');
        }

        _mockRequests[index] = RegistrationRequestModel(
          requestId: req.requestId,
          societyId: req.societyId,
          authUid: req.authUid,
          fullName: req.fullName,
          phoneNumber: req.phoneNumber,
          flatNumber: req.flatNumber,
          additionalInformation: req.additionalInformation,
          requestStatus: decision,
          submittedAt: req.submittedAt,
          reviewedBy: activeMember.memberId,
          reviewerName: activeMember.fullName,
          reviewedAt: DateTime.now(),
          rejectionReason: decision == 'REJECTED' ? comments : null,
        );

        if (decision == 'APPROVED') {
          MembersRepository.addMockMember(
            MemberModel(
              memberId: 'mem-${DateTime.now().millisecondsSinceEpoch}',
              societyId: req.societyId,
              authUid: req.authUid,
              fullName: req.fullName,
              phoneNumber: req.phoneNumber,
              flatNumber: req.flatNumber,
              membershipStatus: 'ACTIVE',
              joinedAt: DateTime.now(),
            ),
          );
        }
        _ref.invalidate(pendingRegistrationsProvider);
        _ref.invalidate(membersListProvider);
        _ref.invalidate(dashboardDataProvider);
        _supabase.notifyLocalChange('registration_requests');
      }
      return;
    }

    // Insert into public.registration_approvals
    // The database trigger fn_validate_registration_approval strictly prevents self-approval
    // and fn_process_registration_decision creates the active member profile upon approval.
    await _supabase.client.from('registration_approvals').insert({
      'request_id': requestId,
      'approved_by': activeMember.memberId,
      'decision': decision,
      'comments': comments,
      'decided_at': DateTime.now().toIso8601String(),
    });
    _ref.invalidate(pendingRegistrationsProvider);
    _ref.invalidate(membersListProvider);
    _ref.invalidate(dashboardDataProvider);
    _supabase.notifyLocalChange('registration_approvals');
  }
}
