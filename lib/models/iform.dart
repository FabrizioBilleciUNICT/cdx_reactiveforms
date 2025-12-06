import 'package:cdx_reactiveforms/models/types.dart';
import 'package:cdx_reactiveforms/models/conditional_field.dart';
import 'package:flutter/material.dart';

abstract class IForm<T, K> {
  final String hint;
  final String label;
  final bool labelInfo;
  final FormsType type;
  final bool isRequired;
  final bool editable;
  final bool visible;
  final ValueNotifier<String> errorNotifier;
  final ValueNotifier<bool> showErrorNotifier;
  final ValueNotifier<K?> valueNotifier;
  final K? minValue;
  final K? maxValue;
  final bool Function(T? value)? isValid;
  final String? semanticsLabel;
  final String? tooltip;
  final String? hintText;
  final FieldCondition? visibilityCondition;
  final FieldCondition? editableCondition;

  void showError(bool show) {
    showErrorNotifier.value = show;
  }

  void onTap(BuildContext context, TextEditingController controller);
  T? currentValue();
  bool validate(T? value);
  void listener(T? value);
  K? inputTransform(T? input);
  T? outputTransform(K? output);
  String errorMessage(T? value);
  Widget build(BuildContext context, ValueListenableBuilder<String> Function() errorBuilder);
  void changeValue(T? newValue);
  void reset();
  void clear();
  Widget actionWidget() => const SizedBox();

  IForm({
    required this.hint,
    required this.label,
    required this.type,
    required this.labelInfo,
    required this.isRequired,
    required this.editable,
    required this.errorNotifier,
    required this.showErrorNotifier,
    required this.visible,
    required this.minValue,
    required this.maxValue,
    required this.valueNotifier,
    this.isValid,
    this.semanticsLabel,
    this.tooltip,
    this.hintText,
    this.visibilityCondition,
    this.editableCondition,
  });
}