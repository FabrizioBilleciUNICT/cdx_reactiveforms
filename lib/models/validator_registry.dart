
/// Registry for reusable custom validators
/// 
/// This allows you to register validators by name and reuse them across multiple forms.
class ValidatorRegistry {
  static final ValidatorRegistry _instance = ValidatorRegistry._internal();
  factory ValidatorRegistry() => _instance;
  ValidatorRegistry._internal();

  final Map<String, bool Function(dynamic)> _validators = {};

  /// Register a validator with a name
  void register(String name, bool Function(dynamic) validator) {
    _validators[name] = validator;
  }

  /// Get a validator by name
  bool Function(dynamic)? get(String name) {
    return _validators[name];
  }

  /// Check if a validator is registered
  bool has(String name) {
    return _validators.containsKey(name);
  }

  /// Unregister a validator
  void unregister(String name) {
    _validators.remove(name);
  }

  /// Clear all registered validators
  void clear() {
    _validators.clear();
  }

  /// Get all registered validator names
  List<String> get registeredNames => _validators.keys.toList();
}

/// Common validators that can be registered
class CommonValidators {
  /// Validator for Italian tax code (Codice Fiscale)
  static bool italianTaxCode(dynamic value) {
    if (value is! String) return false;
    final cf = value.toUpperCase().trim();
    // Basic format check: 16 alphanumeric characters
    if (cf.length != 16) return false;
    return RegExp(r'^[A-Z0-9]{16}$').hasMatch(cf);
  }

  /// Validator for Italian VAT number (Partita IVA)
  static bool italianVAT(dynamic value) {
    if (value is! String) return false;
    final vat = value.trim();
    // Italian VAT is 11 digits
    if (vat.length != 11) return false;
    if (!RegExp(r'^\d{11}$').hasMatch(vat)) return false;
    
    // Luhn algorithm check
    int sum = 0;
    for (int i = 0; i < 10; i++) {
      int digit = int.parse(vat[i]);
      if (i % 2 == 0) {
        digit *= 2;
        if (digit > 9) digit -= 9;
      }
      sum += digit;
    }
    int checkDigit = (10 - (sum % 10)) % 10;
    return checkDigit == int.parse(vat[10]);
  }

  /// Validator for IBAN
  static bool iban(dynamic value) {
    if (value is! String) return false;
    final iban = value.replaceAll(' ', '').toUpperCase();
    // Basic format check: 15-34 alphanumeric characters, starts with 2 letters
    if (iban.length < 15 || iban.length > 34) return false;
    return RegExp(r'^[A-Z]{2}\d{2}[A-Z0-9]+$').hasMatch(iban);
  }

  /// Validator for credit card number (Luhn algorithm)
  static bool creditCard(dynamic value) {
    if (value is! String) return false;
    final card = value.replaceAll(RegExp(r'[\s-]'), '');
    if (card.length < 13 || card.length > 19) return false;
    if (!RegExp(r'^\d+$').hasMatch(card)) return false;
    
    // Luhn algorithm
    int sum = 0;
    bool alternate = false;
    for (int i = card.length - 1; i >= 0; i--) {
      int digit = int.parse(card[i]);
      if (alternate) {
        digit *= 2;
        if (digit > 9) digit -= 9;
      }
      sum += digit;
      alternate = !alternate;
    }
    return sum % 10 == 0;
  }

  /// Validator for minimum length
  static bool Function(dynamic) minLength(int min) {
    return (dynamic value) {
      if (value is String) return value.length >= min;
      if (value is List) return value.length >= min;
      return false;
    };
  }

  /// Validator for maximum length
  static bool Function(dynamic) maxLength(int max) {
    return (dynamic value) {
      if (value is String) return value.length <= max;
      if (value is List) return value.length <= max;
      return false;
    };
  }

  /// Validator for exact length
  static bool Function(dynamic) exactLength(int length) {
    return (dynamic value) {
      if (value is String) return value.length == length;
      if (value is List) return value.length == length;
      return false;
    };
  }

  /// Validator for numeric range
  static bool Function(dynamic) numericRange(num min, num max) {
    return (dynamic value) {
      if (value is num) return value >= min && value <= max;
      if (value is String) {
        final numValue = num.tryParse(value);
        if (numValue == null) return false;
        return numValue >= min && numValue <= max;
      }
      return false;
    };
  }

  /// Validator for regex pattern
  static bool Function(dynamic) pattern(RegExp regex) {
    return (dynamic value) {
      if (value is! String) return false;
      return regex.hasMatch(value);
    };
  }
}

