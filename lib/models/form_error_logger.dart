
import 'package:flutter/foundation.dart';

/// Optional error logger interface for form error handling
/// 
/// Implement this interface to log form errors for debugging or monitoring purposes.
abstract class FormErrorLogger {
  /// Log an error that occurred during form operations
  void logError(String formType, String fieldName, dynamic error, [StackTrace? stackTrace]);
  
  /// Log a validation error
  void logValidationError(String formType, String fieldName, String errorMessage);
}

/// Default no-op logger that does nothing
class NoOpFormErrorLogger implements FormErrorLogger {
  @override
  void logError(String formType, String fieldName, dynamic error, [StackTrace? stackTrace]) {
    // No-op
  }
  
  @override
  void logValidationError(String formType, String fieldName, String errorMessage) {
    // No-op
  }
}

/// Console logger that prints to debug console
class ConsoleFormErrorLogger implements FormErrorLogger {
  @override
  void logError(String formType, String fieldName, dynamic error, [StackTrace? stackTrace]) {
    debugPrint('[$formType] Error in field "$fieldName": $error');
    if (stackTrace != null) {
      debugPrint('StackTrace: $stackTrace');
    }
  }
  
  @override
  void logValidationError(String formType, String fieldName, String errorMessage) {
    debugPrint('[$formType] Validation error in field "$fieldName": $errorMessage');
  }
}

