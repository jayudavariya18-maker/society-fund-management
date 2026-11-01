import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/supabase_service.dart';
import '../../../shared/models/audit_log_model.dart';

final auditRepositoryProvider = Provider<AuditRepository>((ref) {
  return AuditRepository(SupabaseService.instance);
});

final auditLogsListProvider = FutureProvider<List<AuditLogModel>>((ref) async {
  final repo = ref.watch(auditRepositoryProvider);
  return repo.fetchAuditLogs();
});

class AuditRepository {
  final SupabaseService _supabase;

  AuditRepository(this._supabase);

  static final List<AuditLogModel> _mockAuditLogs = [
    AuditLogModel(
      logId: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1',
      societyId: '00000000-0000-0000-0000-000000000001',
      memberId: '11111111-1111-1111-1111-111111111001',
      memberName: 'Rajeshbhai Patel',
      action: 'SOCIETY_CREATED',
      recordType: 'society',
      recordId: '00000000-0000-0000-0000-000000000001',
      newValues: {'society_name': 'Bajrang Heights Co-Operative Housing Society'},
      timestamp: DateTime(2025, 1, 1, 9, 0),
    ),
    AuditLogModel(
      logId: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2',
      societyId: '00000000-0000-0000-0000-000000000001',
      memberId: '11111111-1111-1111-1111-111111111001',
      memberName: 'Rajeshbhai Patel',
      action: 'FESTIVAL_CREATED',
      recordType: 'festivals',
      recordId: '33333333-3333-3333-3333-333333333001',
      newValues: {'festival_name': 'Navratri Mahotsav 2026'},
      timestamp: DateTime(2026, 9, 1, 10, 0),
    ),
    AuditLogModel(
      logId: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa3',
      societyId: '00000000-0000-0000-0000-000000000001',
      memberId: '11111111-1111-1111-1111-111111111001',
      memberName: 'Rajeshbhai Patel',
      action: 'CONTRIBUTION_ADDED',
      recordType: 'contributions',
      recordId: '55555555-5555-5555-5555-555555555001',
      newValues: {'amount': 3000.00, 'receipt_number': 'REC-202610-0001', 'member': 'Rajeshbhai Patel'},
      timestamp: DateTime(2026, 10, 1, 11, 15),
    ),
    AuditLogModel(
      logId: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa4',
      societyId: '00000000-0000-0000-0000-000000000001',
      memberId: '11111111-1111-1111-1111-111111111001',
      memberName: 'Rajeshbhai Patel',
      action: 'EXPENSE_ADDED',
      recordType: 'expenses',
      recordId: '66666666-6666-6666-6666-666666666001',
      newValues: {'amount': 8500.00, 'category': 'ELECTRICITY', 'vendor': 'Torrent Power Ltd'},
      timestamp: DateTime(2026, 10, 4, 15, 30),
    ),
  ];

  Future<List<AuditLogModel>> fetchAuditLogs() async {
    if (_supabase.isMockDevMode) {
      final list = List<AuditLogModel>.from(_mockAuditLogs);
      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return list;
    }

    final res = await _supabase.client
        .from('audit_logs')
        .select('*, members(full_name)')
        .order('timestamp', ascending: false)
        .limit(100);

    return (res as List).map((e) => AuditLogModel.fromJson(e)).toList();
  }
}
