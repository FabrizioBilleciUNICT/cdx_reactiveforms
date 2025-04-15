
import 'package:cdx_core/core/models/input_theme_data.dart';
import 'package:cdx_core/injector.dart';
import 'package:cdx_reactiveforms/ui/components.dart';
import 'package:flutter/material.dart';
import '../models/dropdown_item.dart';
import '../models/iform.dart';
import '../models/types.dart';

class DropdownForm<K> extends IForm<K, K> {
  late final K _initialValue;
  final Stream<List<DropdownItem<K>>> optionsStream;
  final FocusNode? focusNode;
  late final CdxInputThemeData theme;

  K? _currentValue;
  List<DropdownItem<K>> _options = [];

  DropdownForm({
    required super.hint,
    required super.label,
    super.type = FormsType.text,
    super.labelInfo = false,
    super.isRequired = true,
    super.editable = true,
    super.visible = true,
    super.minValue,
    super.maxValue,
    super.isValid,
    required K? initialValue,
    required this.optionsStream,
    this.focusNode,
    ValueNotifier<String>? errorNotifier,
    ValueNotifier<bool>? showErrorNotifier,
    CdxInputThemeData? themeData,
  }) : super(
    errorNotifier: errorNotifier ?? ValueNotifier(''),
    showErrorNotifier: showErrorNotifier ?? ValueNotifier(false),
    valueNotifier: ValueNotifier(initialValue),
  ) {
    _initialValue = initialValue as K;
    _currentValue = initialValue;
    theme = themeData ?? DI.theme().inputTheme;
    optionsStream.listen((list) {
      _options = list;
      if (!_options.any((item) => item.value == _currentValue)) {
        _currentValue = null;
        errorNotifier?.value = '';
      }
    });
  }

  @override
  bool validate(K? value) {
    final isValidResult = !isRequired || (value != null && (isValid == null || isValid!(value)));
    errorNotifier.value = isValidResult ? '' : errorMessage(value);
    return isValidResult;
  }

  @override
  void listener(K? value) {
    showError(false);
    validate(value);
    valueNotifier.value = value;
  }

  @override
  void changeValue(K? newValue) {
    _currentValue = newValue;
    listener(newValue);
  }

  @override
  K? currentValue() {
    return _currentValue;
  }

  @override
  void clear() {
    _currentValue = null;
  }

  @override
  void reset() {
    _currentValue = _initialValue;
  }

  @override
  void onTap(BuildContext context, TextEditingController controller) {}

  @override
  K? inputTransform(K? input) => input;

  @override
  K? outputTransform(K? output) => output;

  @override
  String errorMessage(K? value) => 'Seleziona un valore';

  @override
  Widget build(BuildContext context, ValueListenableBuilder<String> Function() errorBuilder) {
    return StreamBuilder<List<DropdownItem<K>>>(
      stream: optionsStream,
      builder: (context, snapshot) {
        final items = snapshot.data ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            labelWidget(),
            input(items),
            ValueListenableBuilder(
              valueListenable: showErrorNotifier,
              builder: (context, value, child) {
                if (!value) return const SizedBox();
                return errorBuilder();
              }
            )
          ],
        );
      },
    );
  }

  Widget labelWidget() => FormComponents.label(label, theme);

  Widget input(List<DropdownItem<K>> items) {
    return DropdownButtonFormField<K>(
      focusNode: focusNode,
      value: _currentValue,
      isExpanded: true,
      onChanged: editable ? (K? newValue) {
        changeValue(newValue);
      } : null,
      hint: Text(hint, style: DI.theme().inputTheme.hintStyle),
      decoration: FormComponents.inputDecoration(theme, hint, editable),
      items: items.map((DropdownItem<K> item) {
        return DropdownMenuItem<K>(
          value: item.value,
          child: Text(item.title, style: DI.theme().inputTheme.textStyle),
        );
      }).toList(),
    );
  }
}
