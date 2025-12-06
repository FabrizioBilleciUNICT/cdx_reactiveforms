
/// Defines a condition for showing/hiding or enabling/disabling a form field
/// based on the value of another field.
abstract class FieldCondition {
  /// The key of the field this condition depends on
  String get dependsOnField;
  
  /// Check if the condition is met given the current value of the dependent field
  bool isMet(dynamic dependentFieldValue);
}

/// Condition that checks if a field value equals a specific value
class EqualsCondition implements FieldCondition {
  @override
  final String dependsOnField;
  final dynamic expectedValue;
  
  EqualsCondition({
    required this.dependsOnField,
    required this.expectedValue,
  });
  
  @override
  bool isMet(dynamic dependentFieldValue) {
    return dependentFieldValue == expectedValue;
  }
}

/// Condition that checks if a field value is in a list of values
class InCondition implements FieldCondition {
  @override
  final String dependsOnField;
  final List<dynamic> allowedValues;
  
  InCondition({
    required this.dependsOnField,
    required this.allowedValues,
  });
  
  @override
  bool isMet(dynamic dependentFieldValue) {
    return allowedValues.contains(dependentFieldValue);
  }
}

/// Condition that checks if a field value is not null/empty
class NotEmptyCondition implements FieldCondition {
  @override
  final String dependsOnField;
  
  NotEmptyCondition({
    required this.dependsOnField,
  });
  
  @override
  bool isMet(dynamic dependentFieldValue) {
    if (dependentFieldValue == null) return false;
    if (dependentFieldValue is String) return dependentFieldValue.isNotEmpty;
    if (dependentFieldValue is List) return dependentFieldValue.isNotEmpty;
    if (dependentFieldValue is Map) return dependentFieldValue.isNotEmpty;
    return true;
  }
}

/// Condition that checks if a field value is null/empty
class EmptyCondition implements FieldCondition {
  @override
  final String dependsOnField;
  
  EmptyCondition({
    required this.dependsOnField,
  });
  
  @override
  bool isMet(dynamic dependentFieldValue) {
    if (dependentFieldValue == null) return true;
    if (dependentFieldValue is String) return dependentFieldValue.isEmpty;
    if (dependentFieldValue is List) return dependentFieldValue.isEmpty;
    if (dependentFieldValue is Map) return dependentFieldValue.isEmpty;
    return false;
  }
}

/// Condition that uses a custom function to evaluate
class CustomCondition implements FieldCondition {
  @override
  final String dependsOnField;
  final bool Function(dynamic) evaluator;
  
  CustomCondition({
    required this.dependsOnField,
    required this.evaluator,
  });
  
  @override
  bool isMet(dynamic dependentFieldValue) {
    return evaluator(dependentFieldValue);
  }
}

