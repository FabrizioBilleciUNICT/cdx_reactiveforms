
import 'package:cdx_components/injector.dart';
import 'package:cdx_components/utils/extensions.dart';
import 'package:cdx_reactiveforms/forms/text.dart';
import 'package:flutter/material.dart';

class PasswordForm extends TextForm<String> {

  PasswordForm({
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
      inputType: TextInputType.text
  );

  @override
  bool validate(String? value) {
    return super.validate(value) && value?.isValidPassword() == true;
  }

  @override
  Widget prefix(void Function(String p1) onAction) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Icon(Icons.lock_rounded,
          color: DI.colors().primary
      ),
    );
  }

}