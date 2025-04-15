
import 'package:cdx_core/utils/extensions.dart';
import 'package:cdx_reactiveforms/forms/text.dart';
import 'package:flutter/material.dart';

import '../models/types.dart';

class EmailForm extends TextForm<String> {

  final String messageError;

  EmailForm({
    required super.hint,
    required super.label,
    super.type = FormsType.email,
    super.labelInfo,
    super.isRequired,
    super.editable,
    super.visible,
    required super.initialValue,
    super.minValue = '',
    super.maxValue = '',
    required this.messageError,
    super.onChange
  }) : super(
      formatters: [],
      inputType: TextInputType.emailAddress
  );

  @override
  bool validate(String? value) {
    return !isRequired || (super.validate(value) && value?.isValidEmail() == true);
  }

  @override
  String errorMessage(String? value) {
    return messageError;
  }
}