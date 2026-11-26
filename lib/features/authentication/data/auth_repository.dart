import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/models/member_model.dart';
import '../../../shared/models/registration_request_model.dart';
import '../../members/data/members_repository.dart';
import '../../registration/data/registration_repository.dart';

enum AuthStatus {
  unauthenticated,
  otpSent,
  activeMember,
  pendingApproval,
  rejected,
  unregistered,
}

class AuthUserState {
  final AuthStatus status;
  final String? phoneNumber;
  final MemberModel? activeMember;
  final RegistrationRequestModel? pendingRequest;
  final String? errorMessage;

  const AuthUserState({
    this.status = AuthStatus.unauthenticated,
    this.phoneNumber,
    this.activeMember,
    this.pendingRequest,
    this.errorMessage,
  });

  AuthUserState copyWith({
    AuthStatus? status,
    String? phoneNumber,
    MemberModel? activeMember,
    RegistrationRequestModel? pendingRequest,
    String? errorMessage,
  }) {
    return AuthUserState(
      status: status ?? this.status,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      activeMember: activeMember ?? this.activeMember,
      pendingRequest: pendingRequest ?? this.pendingRequest,
      errorMessage: errorMessage,
    );
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(SupabaseService.instance);
});

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthUserState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthNotifier(repo);
});

class AuthRepository {
  final SupabaseService _supabaseService;

  AuthRepository(this._supabaseService);

  /// Verify entered society password against stored or default hash
  bool verifySocietyPassword(String password) {
    return LocalStorageService.instance.verifySocietyPassword(password);
  }

  /// Check whether any active members exist
  Future<bool> hasActiveMembers() async {
    if (_supabaseService.isMockDevMode) {
      return MembersRepository.mockMembers.isNotEmpty;
    }
    try {
      final res = await _supabaseService.client
          .from('members')
          .select('member_id')
          .eq('membership_status', 'ACTIVE')
          .limit(1);
      return (res as List).isNotEmpty;
    } catch (_) {
      return MembersRepository.mockMembers.isNotEmpty;
    }
  }

  /// Register new resident using Common Society Password
  Future<MemberModel> registerWithSocietyPassword({
    required String fullName,
    required String flatNumber,
    required String phoneNumber,
    String? email,
    required String password,
  }) async {
    final cleanPhone = Validators.formatPhoneE164(phoneNumber);

    // 1. Password verification
    final isPasswordValid = verifySocietyPassword(password);
    if (!isPasswordValid) {
      throw const AuthException(
        'Incorrect society password. Please enter the common society password or contact the society committee.',
      );
    }

    if (_supabaseService.isMockDevMode) {
      // Create new active member
      final newMember = MemberModel(
        memberId: 'mem-${DateTime.now().millisecondsSinceEpoch}',
        societyId: '00000000-0000-0000-0000-000000000001',
        authUid: 'mock-${DateTime.now().millisecondsSinceEpoch}',
        fullName: fullName.trim(),
        phoneNumber: cleanPhone,
        flatNumber: flatNumber.trim(),
        email: email != null && email.trim().isNotEmpty ? email.trim() : null,
        membershipStatus: 'ACTIVE',
        joinedAt: DateTime.now(),
      );

      MembersRepository.addMockMember(newMember);
      await LocalStorageService.instance.saveActiveMember(newMember);
      return newMember;
    }

    try {
      final res = await _supabaseService.client.rpc(
        'register_member_with_society_password',
        params: {
          'p_full_name': fullName.trim(),
          'p_flat_number': flatNumber.trim(),
          'p_phone': cleanPhone,
          'p_email': email != null && email.trim().isNotEmpty ? email.trim() : null,
          'p_password': password.trim(),
        },
      );
      final member = MemberModel.fromJson(res as Map<String, dynamic>);
      await LocalStorageService.instance.saveActiveMember(member);
      MembersRepository.addMockMember(member);
      return member;
    } on PostgrestException catch (e) {
      // If stored procedure doesn't exist yet, insert directly
      if (e.message.contains('function') || e.code == '42883') {
        final insertRes = await _supabaseService.client.from('members').insert({
          'society_id': '00000000-0000-0000-0000-000000000001',
          'auth_uid': 'gen-${DateTime.now().millisecondsSinceEpoch}',
          'full_name': fullName.trim(),
          'phone_number': cleanPhone,
          'flat_number': flatNumber.trim(),
          'email': email,
          'membership_status': 'ACTIVE',
        }).select().single();

        final member = MemberModel.fromJson(insertRes);
        await LocalStorageService.instance.saveActiveMember(member);
        MembersRepository.addMockMember(member);
        return member;
      }
      throw AuthException(e.message);
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  /// Login returning resident using Mobile Number and Common Society Password
  Future<MemberModel> loginWithSocietyPassword({
    required String phoneNumber,
    required String password,
  }) async {
    final cleanPhone = Validators.formatPhoneE164(phoneNumber);

    // 1. Password verification
    final isPasswordValid = verifySocietyPassword(password);
    if (!isPasswordValid) {
      throw const AuthException(
        'Incorrect society password. Please enter the common society password or contact the society committee.',
      );
    }

    if (_supabaseService.isMockDevMode) {
      // Find matching member in memory or storage
      final allMembers = MembersRepository.mockMembers;
      final match = allMembers.where((m) {
        final p = m.phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
        final target = cleanPhone.replaceAll(RegExp(r'[^0-9]'), '');
        return p == target || p.endsWith(target) || target.endsWith(p);
      }).firstOrNull;

      if (match != null) {
        if (match.isActive) {
          await LocalStorageService.instance.saveActiveMember(match);
          return match;
        } else {
          throw AuthException('Membership status is ${match.membershipStatus}. Please contact society committee.');
        }
      }

      // If no members registered yet in evaluation mode, auto-provision
      if (allMembers.isEmpty) {
        final autoMember = MemberModel(
          memberId: 'mem-${DateTime.now().millisecondsSinceEpoch}',
          societyId: '00000000-0000-0000-0000-000000000001',
          authUid: 'mock-first',
          fullName: 'Society Resident',
          phoneNumber: cleanPhone,
          flatNumber: 'A-101',
          membershipStatus: 'ACTIVE',
          joinedAt: DateTime.now(),
        );
        MembersRepository.addMockMember(autoMember);
        await LocalStorageService.instance.saveActiveMember(autoMember);
        return autoMember;
      }

      throw const AuthException(
        'Mobile number not registered in society records. Please tap "Register as New Resident" to set up your account.',
      );
    }

    try {
      final res = await _supabaseService.client.rpc(
        'login_member_with_society_password',
        params: {
          'p_phone': cleanPhone,
          'p_password': password.trim(),
        },
      );
      final member = MemberModel.fromJson(res as Map<String, dynamic>);
      await LocalStorageService.instance.saveActiveMember(member);
      MembersRepository.addMockMember(member);
      return member;
    } on PostgrestException catch (e) {
      if (e.message.contains('function') || e.code == '42883') {
        // Fallback direct query
        final memberRes = await _supabaseService.client
            .from('members')
            .select()
            .eq('phone_number', cleanPhone)
            .maybeSingle();

        if (memberRes != null) {
          final member = MemberModel.fromJson(memberRes);
          if (member.isActive) {
            await LocalStorageService.instance.saveActiveMember(member);
            MembersRepository.addMockMember(member);
            return member;
          } else {
            throw AuthException('Membership status is ${member.membershipStatus}.');
          }
        }
        throw const AuthException(
          'Mobile number not registered in society records. Please tap "Register as New Resident".',
        );
      }
      throw AuthException(e.message);
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  /// Bootstrap the founding first member of Ramdevra Society
  Future<MemberModel> bootstrapFirstMember({
    required String fullName,
    required String flatNumber,
    String? email,
  }) async {
    final member = MemberModel(
      memberId: 'mem-${DateTime.now().millisecondsSinceEpoch}',
      societyId: '00000000-0000-0000-0000-000000000001',
      authUid: 'bootstrap-${DateTime.now().millisecondsSinceEpoch}',
      fullName: fullName,
      phoneNumber: '+919876543210',
      flatNumber: flatNumber,
      email: email,
      membershipStatus: 'ACTIVE',
      joinedAt: DateTime.now(),
    );
    MembersRepository.addMockMember(member);
    await LocalStorageService.instance.saveActiveMember(member);
    return member;
  }

  /// Check Membership Status for authenticated user
  Future<AuthUserState> checkMembershipStatus(String phoneNumber) async {
    final active = LocalStorageService.instance.getActiveMember();
    if (active != null && active.isActive) {
      return AuthUserState(
        status: AuthStatus.activeMember,
        phoneNumber: active.phoneNumber,
        activeMember: active,
      );
    }

    return const AuthUserState(status: AuthStatus.unauthenticated);
  }

  Future<void> signOut() async {
    await LocalStorageService.instance.clearSession();
    try {
      if (!_supabaseService.isMockDevMode) {
        await _supabaseService.client.auth.signOut();
      }
    } catch (_) {}
  }
}

class AuthNotifier extends StateNotifier<AuthUserState> {
  final AuthRepository _repo;

  AuthNotifier(this._repo) : super(const AuthUserState()) {
    _initCheck();
  }

  /// Restore saved session instantly on app launch
  Future<void> _initCheck() async {
    try {
      final savedMember = LocalStorageService.instance.getActiveMember();
      if (savedMember != null && savedMember.isActive) {
        state = AuthUserState(
          status: AuthStatus.activeMember,
          phoneNumber: savedMember.phoneNumber,
          activeMember: savedMember,
        );
        debugPrint('[AuthNotifier] Restored persistent active member session: ${savedMember.fullName} (${savedMember.flatNumber})');
        return;
      }
      state = const AuthUserState(status: AuthStatus.unauthenticated);
    } catch (e) {
      debugPrint('[AuthNotifier] Error during session restoration: $e');
      state = const AuthUserState(status: AuthStatus.unauthenticated);
    }
  }

  /// Register with society password
  Future<void> registerWithSocietyPassword({
    required String fullName,
    required String flatNumber,
    required String phoneNumber,
    String? email,
    required String password,
  }) async {
    state = state.copyWith(errorMessage: null);
    try {
      final member = await _repo.registerWithSocietyPassword(
        fullName: fullName,
        flatNumber: flatNumber,
        phoneNumber: phoneNumber,
        email: email,
        password: password,
      );
      state = AuthUserState(
        status: AuthStatus.activeMember,
        phoneNumber: member.phoneNumber,
        activeMember: member,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      rethrow;
    }
  }

  /// Login with society password
  Future<void> loginWithSocietyPassword({
    required String phoneNumber,
    required String password,
  }) async {
    state = state.copyWith(errorMessage: null);
    try {
      final member = await _repo.loginWithSocietyPassword(
        phoneNumber: phoneNumber,
        password: password,
      );
      state = AuthUserState(
        status: AuthStatus.activeMember,
        phoneNumber: member.phoneNumber,
        activeMember: member,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      rethrow;
    }
  }

  Future<void> completeFirstMemberBootstrap({
    required String fullName,
    required String flatNumber,
    String? email,
  }) async {
    state = state.copyWith(errorMessage: null);
    try {
      final member = await _repo.bootstrapFirstMember(
        fullName: fullName,
        flatNumber: flatNumber,
        email: email,
      );
      state = AuthUserState(
        status: AuthStatus.activeMember,
        phoneNumber: member.phoneNumber,
        activeMember: member,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      rethrow;
    }
  }

  Future<void> refreshStatus() async {
    if (state.phoneNumber == null) return;
    try {
      final checkRes = await _repo.checkMembershipStatus(state.phoneNumber!);
      state = checkRes;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> signOut() async {
    await _repo.signOut();
    state = const AuthUserState(status: AuthStatus.unauthenticated);
  }
}
