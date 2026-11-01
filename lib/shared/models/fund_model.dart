import '../../core/utils/currency_formatter.dart';

class FundModel {
  final String fundId;
  final String societyId;
  final String fundName;
  final String fundType; // 'GENERAL' or 'FESTIVAL'
  final String? festivalId;
  final String? festivalName;
  final String? description;
  final double openingBalance;
  final double totalContributions;
  final double totalExpenses;
  final double currentBalance;
  final int contributionCount;
  final int expenseCount;
  final bool isActive;
  final DateTime createdAt;

  FundModel({
    required this.fundId,
    required this.societyId,
    required this.fundName,
    required this.fundType,
    this.festivalId,
    this.festivalName,
    this.description,
    this.openingBalance = 0.0,
    this.totalContributions = 0.0,
    this.totalExpenses = 0.0,
    required this.currentBalance,
    this.contributionCount = 0,
    this.expenseCount = 0,
    this.isActive = true,
    required this.createdAt,
  });

  bool get isGeneral => fundType == 'GENERAL';
  bool get isFestival => fundType == 'FESTIVAL';

  factory FundModel.fromJson(Map<String, dynamic> json) {
    final opening = (json['opening_balance'] as num?)?.toDouble() ?? 0.0;
    final contrib = (json['total_contributions'] as num?)?.toDouble() ?? 0.0;
    final exp = (json['total_expenses'] as num?)?.toDouble() ?? 0.0;
    final computedBalance = json['current_balance'] != null
        ? (json['current_balance'] as num).toDouble()
        : CurrencyFormatter.subtract(CurrencyFormatter.add(opening, contrib), exp);

    return FundModel(
      fundId: json['fund_id'] as String,
      societyId: json['society_id'] as String,
      fundName: json['fund_name'] as String? ?? 'Society Fund',
      fundType: json['fund_type'] as String? ?? 'GENERAL',
      festivalId: json['festival_id'] as String?,
      festivalName: json['festival_name'] as String?,
      description: json['description'] as String?,
      openingBalance: opening,
      totalContributions: contrib,
      totalExpenses: exp,
      currentBalance: computedBalance,
      contributionCount: (json['contribution_count'] as num?)?.toInt() ?? 0,
      expenseCount: (json['expense_count'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fund_id': fundId,
      'society_id': societyId,
      'fund_name': fundName,
      'fund_type': fundType,
      'festival_id': festivalId,
      'description': description,
      'opening_balance': openingBalance,
      'is_active': isActive,
    };
  }
}
