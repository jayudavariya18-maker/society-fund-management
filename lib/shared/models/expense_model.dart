class ExpenseModel {
  final String expenseId;
  final String fundId;
  final String? fundName;
  final String? eventId;
  final String? eventName;
  final double amount;
  final String expenseCategory;
  final String description;
  final String? vendorName;
  final String paymentMethod;
  final DateTime expenseDate;
  final String? billImageUrl;
  final String? receiptReference;
  final String createdBy;
  final String? createdByName;
  final DateTime createdAt;
  final String status; // 'POSTED', 'REVERSED', 'ADJUSTED'
  final String? correctionReference;

  ExpenseModel({
    required this.expenseId,
    required this.fundId,
    this.fundName,
    this.eventId,
    this.eventName,
    required this.amount,
    required this.expenseCategory,
    required this.description,
    this.vendorName,
    required this.paymentMethod,
    required this.expenseDate,
    this.billImageUrl,
    this.receiptReference,
    required this.createdBy,
    this.createdByName,
    required this.createdAt,
    this.status = 'POSTED',
    this.correctionReference,
  });

  bool get isPosted => status == 'POSTED';
  bool get isReversed => status == 'REVERSED';
  bool get isAdjusted => status == 'ADJUSTED';

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      expenseId: json['expense_id'] as String,
      fundId: json['fund_id'] as String,
      fundName: json['funds'] != null ? json['funds']['fund_name'] as String? : json['fund_name'] as String?,
      eventId: json['event_id'] as String?,
      eventName: json['festival_events'] != null ? json['festival_events']['event_name'] as String? : json['event_name'] as String?,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      expenseCategory: json['expense_category'] as String? ?? 'OTHER',
      description: json['description'] as String? ?? '',
      vendorName: json['vendor_name'] as String?,
      paymentMethod: json['payment_method'] as String? ?? 'CASH',
      expenseDate: json['expense_date'] != null
          ? DateTime.parse(json['expense_date'].toString())
          : DateTime.now(),
      billImageUrl: json['bill_image_url'] as String?,
      receiptReference: json['receipt_reference'] as String?,
      createdBy: json['created_by'] as String? ?? '',
      createdByName: json['creator'] != null ? json['creator']['full_name'] as String? : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      status: json['status'] as String? ?? 'POSTED',
      correctionReference: json['correction_reference'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'expense_id': expenseId,
      'fund_id': fundId,
      'event_id': eventId,
      'amount': amount,
      'expense_category': expenseCategory,
      'description': description,
      'vendor_name': vendorName,
      'payment_method': paymentMethod,
      'expense_date': expenseDate.toIso8601String().split('T').first,
      'bill_image_url': billImageUrl,
      'receipt_reference': receiptReference,
      'created_by': createdBy,
      'status': status,
      'correction_reference': correctionReference,
    };
  }
}
