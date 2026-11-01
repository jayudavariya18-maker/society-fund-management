class AuditLogModel {
  final String logId;
  final String societyId;
  final String? memberId;
  final String? memberName;
  final String action;
  final String recordType;
  final String recordId;
  final Map<String, dynamic>? oldValues;
  final Map<String, dynamic>? newValues;
  final DateTime timestamp;
  final String? deviceInformation;

  AuditLogModel({
    required this.logId,
    required this.societyId,
    this.memberId,
    this.memberName,
    required this.action,
    required this.recordType,
    required this.recordId,
    this.oldValues,
    this.newValues,
    required this.timestamp,
    this.deviceInformation,
  });

  factory AuditLogModel.fromJson(Map<String, dynamic> json) {
    return AuditLogModel(
      logId: json['log_id'] as String,
      societyId: json['society_id'] as String,
      memberId: json['member_id'] as String?,
      memberName: json['members'] != null ? json['members']['full_name'] as String? : null,
      action: json['action'] as String? ?? 'UNKNOWN',
      recordType: json['record_type'] as String? ?? '',
      recordId: json['record_id'] as String? ?? '',
      oldValues: json['old_values'] is Map<String, dynamic> ? json['old_values'] as Map<String, dynamic> : null,
      newValues: json['new_values'] is Map<String, dynamic> ? json['new_values'] as Map<String, dynamic> : null,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'].toString())
          : DateTime.now(),
      deviceInformation: json['device_information'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'log_id': logId,
      'society_id': societyId,
      'member_id': memberId,
      'action': action,
      'record_type': recordType,
      'record_id': recordId,
      'old_values': oldValues,
      'new_values': newValues,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
