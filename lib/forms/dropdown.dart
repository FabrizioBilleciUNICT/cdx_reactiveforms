import 'dart:async';
import 'package:cdx_reactiveforms/ui/components.dart';
import 'package:flutter/material.dart';
import '../forms/base_form.dart';
import '../models/dropdown_item.dart';
import '../models/types.dart';

class DropdownForm<K> extends BaseForm<K, K> {
  final K? _initialValue;
  final Stream<List<DropdownItem<K>>> optionsStream;
  final FocusNode? focusNode;

  K? _currentValue;
  final ValueNotifier<List<DropdownItem<K>>> _optionsNotifier = ValueNotifier([]);
  StreamSubscription<List<DropdownItem<K>>>? _subscription;

  DropdownForm({
    required super.hint,
    required super.label,
    super.type = FormsType.dropdown,
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
  Widget build(BuildContext context, ValueListenableBuilder<String> Function() errorBuilder) {
    return StreamBuilder<List<DropdownItem<K>>>(
      stream: optionsStream,
      builder: (context, snapshot) {
        // Update ValueNotifier if we receive data from stream
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_optionsNotifier.value.isEmpty || _optionsNotifier.value != snapshot.data) {
              _optionsNotifier.value = snapshot.data!;
            }
          });
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            labelWidget(),
            ValueListenableBuilder<List<DropdownItem<K>>>(
              valueListenable: _optionsNotifier,
              builder: (context, items, child) {
                return _buildDropdown(items);
              },
            ),
            ValueListenableBuilder(
              valueListenable: showErrorNotifier,
              builder: (context, show, child) {
                if (!show) return const SizedBox();
                return errorBuilder();
              }
            )
          ],
        );
      },
    );
  }

  Widget _buildDropdown(List<DropdownItem<K>> items) {
    if (items.isEmpty) {
      return DropdownButtonFormField<K>(
        focusNode: focusNode,
        value: null,
        isExpanded: true,
        onChanged: null,
        hint: Text(hint, style: theme.hintStyle),
        decoration: FormComponents.inputDecoration(theme, hint, editable),
        items: const [],
      );
    }
    
    return DropdownButtonFormField<K>(
      focusNode: focusNode,
      value: _currentValue,
      isExpanded: true,
      onChanged: editable ? (K? newValue) => changeValue(newValue) : null,
      hint: Text(hint, style: theme.hintStyle),
      decoration: FormComponents.inputDecoration(theme, hint, editable),
      items: items.map((item) {
        return DropdownMenuItem<K>(
          value: item.value,
          child: Text(item.title, style: theme.textStyle),
        );
      }).toList(),
    );
  }

  @override
  Widget buildInput(BuildContext context) {
    return ValueListenableBuilder<List<DropdownItem<K>>>(
      valueListenable: _optionsNotifier,
      builder: (context, items, child) {
        return _buildDropdown(items);
      },
    );
  }
}
