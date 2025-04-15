import 'package:cdx_reactiveforms/models/types.dart';
import 'package:flutter/material.dart';

abstract class IForm<T, K> {
  /// Hint inside the input
  final String hint;

  /// Input's label
  final String label;

  /// Show facility on hint
  final bool labelInfo;

  /// FormType
  final FormsType type;

  /// Field is required
  final bool isRequired;

  /// Field is editable
  final bool editable;

  /// Field is visible
  final bool visible;

  /// Show error on form send
  final ValueNotifier<String> errorNotifier;

  final ValueNotifier<bool> showErrorNotifier;

  void showError(bool show) {
    showErrorNotifier.value = show;
  }

  /// Notify value changes
  final ValueNotifier<K?> valueNotifier;

  final K? minValue;
  final K? maxValue;

  /// Custom validation
  bool Function(T? value)? isValid;

  /// Field on tap callback
  void onTap(BuildContext context, TextEditingController controller);

  /// Current value
  T? currentValue();

  /// Returns the validation
  bool validate(T? value);

  /// Listen to value change
  void listener(T? value);

  /// Transform an input from 'K' to the right type, if not null
  K? inputTransform(T? input);

  /// Transform the output from 'K' to the right type, if not null
  T? outputTransform(K? output);

  /// Error message
  String errorMessage(T? value);

  /// The build method
  Widget build(BuildContext context, ValueListenableBuilder<String> Function() errorBuilder);

  /// Change dynamically the current field value
  void changeValue(T? newValue);

  /// Reset to initial value
  void reset();

  /// Clear input
  void clear();

  /// Optional extra widget
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
  });
}