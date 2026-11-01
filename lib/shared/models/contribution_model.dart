class ContributionModel {
  final String contributionId;
  final String fundId;
  final String? fundName;
  final String? memberId;
  final String? memberName;
  final String? flatNumber;
  final double amount;
  final String contributionType;
  final String paymentMethod;
  final String? transactionReference;
  final DateTime paymentDate;
  final String? notes;
  final String receiptNumber;
  final String? attachmentUrl;
  final String createdBy;
  final String? createdByName;
  final DateTime createdAt;
  final String status; // 'POSTED', 'REVERSED', 'ADJUSTED'

  ContributionModel({
    required this.contributionId,
    required this.fundId,
    this.fundName,
    this.memberId,
    this.memberName,
    this.flatNumber,
    required this.amount,
    required this.contributionType,
    required this.paymentMethod,
    this.transactionReference,
    required this.paymentDate,
    this.notes,
    required this.receiptNumber,
    this.attachmentUrl,
    required this.createdBy,
    this.createdByName,
    required this.createdAt,
    this.status = 'POSTED',
  });

  bool get isPosted => status == 'POSTED';
  bool get isReversed => status == 'REVERSED';
  bool get isAdjusted => status == 'ADJUSTED';

  factory ContributionModel.fromJson(Map<String, dynamic> json) {
    return ContributionModel(
      contributionId: json['contribution_id'] as String,
      fundId: json['fund_id'] as String,
      fundName: json['funds'] != null ? json['funds']['fund_name'] as String? : json['fund_name'] as String?,
      memberId: json['member_id'] as String?,
      memberName: json['members'] != null ? json['members']['full_name'] as String? : json['member_name'] as String?,
      flatNumber: json['members'] != null ? json['members']['flat_number'] as String? : json['flat_number'] as String?,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      contributionType: json['contribution_type'] as String? ?? 'OTHER',
      paymentMethod: json['payment_method'] as String? ?? 'CASH',
      transactionReference: json['transaction_reference'] as String?,
      paymentDate: json['payment_date'] != null
          ? DateTime.parse(json['payment_date'].toString())
          : DateTime.now(),
      notes: json['notes'] as String?,
      receiptNumber: json['receipt_number'] as String? ?? '',
      attachmentUrl: json['attachment_url'] as String?,
      createdBy: json['created_by'] as String? ?? '',
      createdByName: json['creator'] != null ? json['creator']['full_name'] as String? : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      status: json['status'] as String? ?? 'POSTED',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contribution_id': contributionId,
      'fund_id': fundId,
      'member_id': memberId,
      'amount': amount,
      'contribution_type': contributionType,
      'payment_method': paymentMethod,
      'transaction_reference': transactionReference,
      'payment_date': paymentDate.toIso8601String().split('T').first,
      'notes': notes,
      'receipt_number': receiptNumber,
      'attachment_url': attachmentUrl,
      'created_by': createdBy,
      'status': status,
    };
  }
}
