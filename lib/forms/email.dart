
import 'package:cdx_core/utils/extensions.dart';
import 'package:cdx_reactiveforms/forms/text.dart';
import 'package:flutter/material.dart';

class EmailForm extends TextForm<String> {

  EmailForm({
    required super.hint,
    required super.label,
    required super.type,
    required super.labelInfo,
    required super.required,
    required super.editable,
    required super.errorNotifier,
    required super.visible,
    required super.initialValue,
    super.minValue = '',
    super.maxValue = '',
  }) : super(
      formatters: [],
      inputType: TextInputType.emailAddress
  );

  @override
  bool validate(String? value) {
    return super.validate(value) && value?.isValidEmail() == true;
  }
}