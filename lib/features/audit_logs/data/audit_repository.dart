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

  static final List<AuditLogModel> _mockAuditLogs = [];

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
