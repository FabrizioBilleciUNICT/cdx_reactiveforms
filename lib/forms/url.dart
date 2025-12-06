
import 'package:cdx_reactiveforms/forms/text.dart';
import 'package:cdx_reactiveforms/models/form_localizations.dart';
import 'package:flutter/material.dart';
import '../models/types.dart';

class URLForm extends TextForm<String> {
  final String? messageError;

  URLForm({
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
    super.onChange,
    super.localizations,
    super.semanticsLabel,
    super.tooltip,
    super.hintText,
  }) : super(
    errorNotifier: ValueNotifier(''),
    formatters: [],
    inputType: TextInputType.url,
  );

  bool _isValidUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    
    // Basic URL validation pattern
    final urlPattern = RegExp(
      r'^https?://' // http:// or https://
      r'([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}' // domain
      r'(/.*)?$', // optional path
      caseSensitive: false,
    );
    
    // Also accept URLs without protocol (will be added automatically)
    final urlWithoutProtocol = RegExp(
      r'^([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}' // domain
      r'(/.*)?$', // optional path
      caseSensitive: false,
    );
    
    return urlPattern.hasMatch(url) || urlWithoutProtocol.hasMatch(url);
  }

  @override
  bool validate(String? value) {
    if (value == null || value.isEmpty) {
      return !isRequired;
    }
    return super.validate(value) && _isValidUrl(value);
  }

  @override
  String errorMessage(String? value) {
    return messageError ?? (localizations ?? DefaultFormLocalizations()).urlErrorMessage;
  }

  @override
  String? inputTransform(String? input) {
    if (input == null || input.isEmpty) return null;
    
    // Add protocol if missing
    if (!input.startsWith('http://') && !input.startsWith('https://')) {
      return 'https://$input';
    }
    
    return input;
  }
}

