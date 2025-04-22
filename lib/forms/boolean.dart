import 'package:cdx_core/core/models/input_theme_data.dart';
import 'package:cdx_core/injector.dart';
import 'package:flutter/material.dart';
import '../models/iform.dart';
import '../models/types.dart';
import '../ui/components.dart';

class BooleanForm extends IForm<bool, bool> {
  late final bool _initialValue;
  late final CdxInputThemeData theme;

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
    ValueNotifier<String>? errorNotifier,
    ValueNotifier<bool>? showErrorNotifier,
    CdxInputThemeData? themeData,
  })  : _currentValue = initialValue,
        super(
        minValue: null,
        maxValue: null,
        errorNotifier: errorNotifier ?? ValueNotifier(''),
        showErrorNotifier: showErrorNotifier ?? ValueNotifier(false),
        valueNotifier: ValueNotifier(initialValue),
      ) {
    _initialValue = initialValue;
    theme = themeData ?? DI.theme().inputTheme;
  }

  @override
  bool validate(bool? value) {
    final isValidResult = !isRequired || (value != null && (isValid == null || isValid!(value)));
    errorNotifier.value = isValidResult ? '' : errorMessage(value);
    return isValidResult;
  }

  @override
  void listener(bool? value) {
    showError(false);
    validate(value);
    valueNotifier.value = value ?? false;
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
  String errorMessage(bool? value) => 'Campo obbligatorio';

  @override
  Widget build(BuildContext context, ValueListenableBuilder<String> Function() errorBuilder) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        labelWidget(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(hint, style: DI.theme().inputTheme.textStyle),
            ValueListenableBuilder(
              valueListenable: valueNotifier,
              builder: (context, value, _) {
                return Switch(
                  value: value ?? false,
                  onChanged: editable ? (val) => changeValue(val) : null,
                );
              }
            ),
          ],
        ),
        ValueListenableBuilder(
          valueListenable: showErrorNotifier,
          builder: (context, show, child) {
            if (!show) return const SizedBox();
            return errorBuilder();
          },
        )
      ],
    );
  }

  Widget labelWidget() => FormComponents.label(label, theme);
}
