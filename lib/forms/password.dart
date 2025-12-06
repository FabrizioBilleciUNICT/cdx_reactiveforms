
import 'package:cdx_core/injector.dart';
import 'package:cdx_core/utils/extensions.dart';
import 'package:cdx_reactiveforms/forms/text.dart';
import 'package:cdx_reactiveforms/models/form_localizations.dart';
import 'package:flutter/material.dart';

import '../models/types.dart';

class PasswordForm extends TextForm<String> {

  final String? messageError;

  PasswordForm({
    required super.hint,
    required super.label,
    super.type = FormsType.password,
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
      inputType: TextInputType.text,
      initialHideText: true
  );

  @override
  bool validate(String? value) {
    return !isRequired || (super.validate(value) && value?.isValidPassword() == true);
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

  @override
  Widget suffix(void Function(String p1) onAction) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: InkWell(
        onTap: () {
          hideText.value = !hideText.value;
        },
        child: Icon(hideText.value
            ? Icons.visibility_off_rounded
            : Icons.visibility_rounded,
            color: DI.colors().primary
        ),
      ),
    );
  }

  @override
  String errorMessage(String? value) {
    return messageError ?? (localizations ?? DefaultFormLocalizations()).passwordErrorMessage;
  }

}