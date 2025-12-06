
import 'package:cdx_reactiveforms/forms/text.dart';
import 'package:cdx_reactiveforms/models/form_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/types.dart';

class PhoneForm extends TextForm<String> {
  final String? messageError;
  final String? countryCode;

  PhoneForm({
    required super.hint,
    required super.label,
    super.type = FormsType.custom,
    super.labelInfo,
    super.isRequired,
    super.editable,
    super.visible,
    required super.initialValue,
    super.minValue = '',
    super.maxValue = '',
    this.messageError,
    this.countryCode,
    super.onChange,
    super.localizations,
    super.semanticsLabel,
    super.tooltip,
    super.hintText,
  }) : super(
    errorNotifier: ValueNotifier(''),
    formatters: [
      FilteringTextInputFormatter.allow(RegExp(r'[\d\s\+\-\(\)]')),
    ],
    inputType: TextInputType.phone,
  );

  bool _isValidPhone(String? phone) {
    if (phone == null || phone.isEmpty) return false;
    
    // Remove common phone formatting characters
    final cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    // International format: + followed by 7-15 digits
    if (cleaned.startsWith('+')) {
      final digits = cleaned.substring(1);
      return RegExp(r'^\d{7,15}$').hasMatch(digits);
    }
    
    // National format: 7-15 digits (without country code)
    if (RegExp(r'^\d{7,15}$').hasMatch(cleaned)) {
      return true;
    }
    
    return false;
  }

  @override
  bool validate(String? value) {
    if (value == null || value.isEmpty) {
      return !isRequired;
    }
    return super.validate(value) && _isValidPhone(value);
  }

  @override
  String errorMessage(String? value) {
    return messageError ?? (localizations ?? DefaultFormLocalizations()).phoneErrorMessage;
  }

  @override
  String? inputTransform(String? input) {
    if (input == null || input.isEmpty) return null;
    
    // Add country code if provided and not already present
    if (countryCode != null && !input.startsWith('+')) {
      final cleaned = input.replaceAll(RegExp(r'[\s\-\(\)]'), '');
      return '$countryCode$cleaned';
    }
    
    return input;
  }
}

