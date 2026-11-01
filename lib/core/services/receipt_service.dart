import 'dart:math';

class ReceiptService {
  /// Generates a standardized, auditable receipt number:
  /// Pattern: REC-YYYYMM-XXXX (e.g., REC-202610-4821)
  static String generateReceiptNumber() {
    final now = DateTime.now();
    final yearMonth = '${now.year}${now.month.toString().padLeft(2, '0')}';
    final randomSuffix = (Random().nextInt(9000) + 1000).toString();
    return 'REC-$yearMonth-$randomSuffix';
  }

  /// Generates a unique transaction reference for offline/manual cash entries if none provided
  static String generateCashReference() {
    final now = DateTime.now();
    final millis = now.millisecondsSinceEpoch.toString().substring(7);
    return 'CASH-TXN-$millis';
  }
}
