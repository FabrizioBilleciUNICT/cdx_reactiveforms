
/// Localization support for form error messages
/// 
/// Provides a way to customize error messages for different locales.
/// If not provided, default English messages are used.
abstract class FormLocalizations {
  /// Default error message when field is invalid
  String get defaultErrorMessage;
  
  /// Error message when field is required but empty
  String get requiredFieldErrorMessage;
  
  /// Error message for email validation
  String get emailErrorMessage;
  
  /// Error message for password validation
  String get passwordErrorMessage;
  
  /// Error message for URL validation
  String get urlErrorMessage;
  
  /// Error message for phone validation
  String get phoneErrorMessage;
  
  /// Error message for file extension not allowed
  String fileExtensionErrorMessage(List<String> allowed);
  
  /// Error message for file size exceeded
  String fileSizeErrorMessage(double maxSizeMB);
  
  /// Error message for image format not allowed
  String imageFormatErrorMessage(List<String> allowed);
  
  /// Error message for image size exceeded
  String imageSizeErrorMessage(double maxSizeMB);
  
  /// Error message for array form validation
  String get arrayFormErrorMessage;
  
  /// Error message for nested form validation
  String get nestedFormErrorMessage;
  
  /// Error message for minimum items not met
  String minItemsErrorMessage(int minItems);
  
  /// Error message for maximum items exceeded
  String maxItemsErrorMessage(int maxItems);
  
  /// Error message for minimum selection not met
  String minSelectionErrorMessage(int minSize);
  
  /// Error message for maximum selection exceeded
  String maxSelectionErrorMessage(int maxSize);
}

/// Default English localizations
class DefaultFormLocalizations implements FormLocalizations {
  @override
  String get defaultErrorMessage => 'This field is not valid';
  
  @override
  String get requiredFieldErrorMessage => 'This field is required';
  
  @override
  String get emailErrorMessage => 'Please enter a valid email address';
  
  @override
  String get passwordErrorMessage => 'Password is not valid';
  
  @override
  String get urlErrorMessage => 'Please enter a valid URL';
  
  @override
  String get phoneErrorMessage => 'Please enter a valid phone number';
  
  @override
  String fileExtensionErrorMessage(List<String> allowed) {
    return 'File extension not allowed. Allowed: ${allowed.join(", ")}';
  }
  
  @override
  String fileSizeErrorMessage(double maxSizeMB) {
    return 'File size exceeds maximum allowed size of ${maxSizeMB.toStringAsFixed(2)}MB';
  }
  
  @override
  String imageFormatErrorMessage(List<String> allowed) {
    return 'Image format not allowed. Allowed: ${allowed.join(", ")}';
  }
  
  @override
  String imageSizeErrorMessage(double maxSizeMB) {
    return 'Image size exceeds maximum allowed size of ${maxSizeMB.toStringAsFixed(2)}MB';
  }
  
  @override
  String get arrayFormErrorMessage => 'This array form is not valid';
  
  @override
  String get nestedFormErrorMessage => 'This nested form is not valid';
  
  @override
  String minItemsErrorMessage(int minItems) {
    return 'At least $minItems item(s) required';
  }
  
  @override
  String maxItemsErrorMessage(int maxItems) {
    return 'Maximum $maxItems item(s) allowed';
  }
  
  @override
  String minSelectionErrorMessage(int minSize) {
    return 'At least $minSize selection(s) required';
  }
  
  @override
  String maxSelectionErrorMessage(int maxSize) {
    return 'Maximum $maxSize selection(s) allowed';
  }
}

