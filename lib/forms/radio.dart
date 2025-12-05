import 'dart:async';
import 'package:flutter/material.dart';
import '../forms/base_form.dart';
import '../models/dropdown_item.dart';
import '../models/types.dart';

class RadioForm<K> extends BaseForm<K, K> {
  final K? _initialValue;
  final Stream<List<DropdownItem<K>>> optionsStream;
  final FocusNode? focusNode;

  K? _currentValue;
  final ValueNotifier<List<DropdownItem<K>>> _optionsNotifier = ValueNotifier([]);
  StreamSubscription<List<DropdownItem<K>>>? _subscription;

  RadioForm({
    required super.hint,
    required super.label,
    super.type = FormsType.radio,
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
    super.errorNotifier,
    super.showErrorNotifier,
    super.themeData,
    super.errorMessageText = 'Please select a value',
  }) : _initialValue = initialValue,
        _currentValue = initialValue,
        super() {
    valueNotifier.value = initialValue;
    _subscription = optionsStream.listen((list) {
      if (list.isNotEmpty) {
        _optionsNotifier.value = list;
      }
      if (!list.any((item) => item.value == _currentValue)) {
        _currentValue = null;
        valueNotifier.value = null;
        errorNotifier.value = '';
      }
    });
  }

  void dispose() {
    _subscription?.cancel();
    _optionsNotifier.dispose();
  }

  @override
  bool validate(K? value) {
    return !isRequired || (value != null && (isValid == null || isValid!(value)));
  }

  @override
  void listener(K? value) {
    super.listener(value);
  }

  @override
  void changeValue(K? newValue) {
    _currentValue = newValue;
    listener(newValue);
  }

  @override
  K? currentValue() => _currentValue;

  @override
  void clear() {
    _currentValue = null;
    valueNotifier.value = null;
  }

  @override
  void reset() {
    _currentValue = _initialValue;
    valueNotifier.value = _initialValue;
  }

  @override
  void onTap(BuildContext context, TextEditingController controller) {}

  @override
  K? inputTransform(K? input) => input;

  @override
  K? outputTransform(K? output) => output;

  @override
  Widget buildInput(BuildContext context) {
    return ValueListenableBuilder<List<DropdownItem<K>>>(
      valueListenable: _optionsNotifier,
      builder: (context, items, child) {
        if (items.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hint,
                style: theme.hintStyle,
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: items.map((item) {
            final isSelected = _currentValue == item.value;
            return RadioListTile<K>(
              title: Text(item.title, style: theme.textStyle),
              value: item.value,
              groupValue: _currentValue,
              onChanged: editable ? (K? value) => changeValue(value) : null,
              selected: isSelected,
            );
          }).toList(),
        );
      },
    );
  }
}

