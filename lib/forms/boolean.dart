import 'package:flutter/material.dart';
import '../forms/base_form.dart';
import '../models/types.dart';

class BooleanForm extends BaseForm<bool, bool> {
  final bool _initialValue;
  bool _currentValue;

  BooleanForm({
    required super.hint,
    required super.label,
    super.type = FormsType.boolean,
    super.labelInfo = false,
    super.isRequired = true,
    super.editable = true,
    super.visible = true,
    super.isValid,
    required bool initialValue,
    super.errorNotifier,
    super.showErrorNotifier,
    super.themeData,
    super.errorMessageText = 'This field is required',
  })  : _currentValue = initialValue,
        _initialValue = initialValue,
        super(
        minValue: null,
        maxValue: null,
      ) {
    valueNotifier.value = initialValue;
  }

  @override
  bool validate(bool? value) {
    return !isRequired || (value != null && (isValid == null || isValid!(value)));
  }

  @override
  void listener(bool? value) {
    super.listener(value ?? false);
  }

  @override
  void changeValue(bool? newValue) {
    _currentValue = newValue ?? false;
    listener(_currentValue);
  }

  @override
  bool? currentValue() => _currentValue;

  @override
  void clear() {
    _currentValue = false;
    valueNotifier.value = false;
  }

  @override
  void reset() {
    _currentValue = _initialValue;
    valueNotifier.value = _initialValue;
  }

  @override
  void onTap(BuildContext context, TextEditingController controller) {}

  @override
  bool? inputTransform(bool? input) => input ?? false;

  @override
  bool? outputTransform(bool? output) => output ?? false;

  @override
  Widget buildInput(BuildContext context) {
    final hintText = Text(hint, style: theme.textStyle);
    return ValueListenableBuilder(
      valueListenable: valueNotifier,
      child: hintText,
      builder: (context, value, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            child!,
            Switch(
              value: value ?? false,
              onChanged: editable ? (val) => changeValue(val) : null,
            ),
          ],
        );
      }
    );
  }
}
