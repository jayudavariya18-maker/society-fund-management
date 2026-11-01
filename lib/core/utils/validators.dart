class Validators {
  static String? requiredField(String? value, String errorMessage) {
    if (value == null || value.trim().isEmpty) {
      return errorMessage;
    }
    return null;
  }

  static String? positiveAmount(String? value, String errorMessage) {
    if (value == null || value.trim().isEmpty) {
      return errorMessage;
    }
    final numVal = double.tryParse(value.trim());
    if (numVal == null || numVal <= 0) {
      return errorMessage;
    }
    return null;
  }

  static String? validIndianPhone(String? value, String errorMessage) {
    if (value == null || value.trim().isEmpty) {
      return errorMessage;
    }
    final clean = value.replaceAll(RegExp(r'[\s\-\+\(\)]'), '');
    // Check if 10 digits or 12 digits (with 91)
    if (clean.length == 10 && RegExp(r'^[6-9]\d{9}$').hasMatch(clean)) {
      return null;
    }
    if (clean.length == 12 && clean.startsWith('91') && RegExp(r'^91[6-9]\d{9}$').hasMatch(clean)) {
      return null;
    }
    return errorMessage;
  }

  static String formatPhoneE164(String phone) {
    final clean = phone.replaceAll(RegExp(r'[\s\-\+\(\)]'), '');
    if (clean.length == 10) {
      return '+91$clean';
    } else if (clean.length == 12 && clean.startsWith('91')) {
      return '+$clean';
    }
    return phone;
  }
}
