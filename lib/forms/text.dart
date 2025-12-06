
import 'dart:async';
import 'package:cdx_reactiveforms/ui/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/disposable.dart';
import '../models/types.dart';
import 'base_form.dart';

class TextForm<K> extends BaseForm<String, K> with Disposable {

  late final TextEditingController _controller;
  late final String _initialValue;
  final List<TextInputFormatter> formatters;
  final TextInputType inputType;
  final FocusNode? focusNode;
  final int? minLines;
  final int? maxLines;
  final void Function(String?)? onChange;
  late final ValueNotifier<bool> hideText;
  final Duration? validationDebounce;
  Timer? _debounceTimer;

  TextForm({
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
    this.formatters = const [],
    this.inputType = TextInputType.text,
    this.focusNode,
    this.minLines,
    this.maxLines,
    super.errorNotifier,
    super.showErrorNotifier,
    super.themeData,
    bool initialHideText = false,
    this.onChange,
    super.errorMessageText,
    super.localizations,
    super.semanticsLabel,
    super.tooltip,
    super.hintText,
    this.validationDebounce,
  }) : super() {
    _controller = TextEditingController(text: outputTransform(initialValue));
    _initialValue = outputTransform(initialValue) ?? '';
    hideText = ValueNotifier(initialHideText);
    // Initialize valueNotifier with initialValue (BaseForm initializes it to null)
    valueNotifier.value = inputTransform(outputTransform(initialValue));
  }

  Widget? suffix(void Function(String) onAction) => null;
  Widget? prefix(void Function(String) onAction) => null;

  @override
  K? inputTransform(String? input) {
    // For TextForm, K should be String. This cast is safe when K is String.
    // Subclasses like IntNumberForm and DoubleNumberForm override this method.
    if (input == null) return null;
    // Type-safe conversion: if K is String, this works; otherwise subclasses must override
    return input as K?;
  }

  @override
  String? outputTransform(K? output) {
    return output?.toString();
  }

  @override
  void listener(String? value) {
    // Update value immediately for UI responsiveness
    valueNotifier.value = inputTransform(value);
    onChange?.call(value ?? '');
    
    // Debounce validation if specified
    if (validationDebounce != null) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(validationDebounce!, () {
        // Perform validation after debounce delay
        final bool valid = validate(value);
        if (!valid) {
          final errorMsg = errorMessage(value);
          errorNotifier.value = errorMsg;
          errorLogger?.logValidationError(type.toString(), label, errorMsg);
        } else {
          errorNotifier.value = '';
        }
      });
    } else {
      // No debouncing, validate immediately
      super.listener(value);
    }
  }

  @override
  bool validate(String? value) {
    if (!isRequired) return true;
    if (value == null || value.isEmpty) return false;
    if (isValid != null) {
      return isValid!(value);
    }
    return true;
  }

  @override
  void changeValue(String? newValue) {
    _controller.text = newValue ?? '';
    // Also update valueNotifier to keep it in sync
    valueNotifier.value = inputTransform(newValue);
    // Trigger listener to validate and update state
    listener(newValue);
  }

  @override
  String? currentValue() {
    return _controller.text;
  }

  @override
  void clear() {
    _controller.text = '';
    valueNotifier.value = inputTransform('');
  }

  @override
  void reset() {
    _controller.text = _initialValue;
    valueNotifier.value = inputTransform(_initialValue);
  }

  @override
  void onTap(BuildContext context, TextEditingController controller) {}

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    hideText.dispose();
  }

  @override
  Widget buildInput(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: hideText,
      builder: (context, obscureText, child) {
        return input(context, obscureText);
      }
    );
  }

  Widget input(BuildContext context, bool obscureText) {
    return Row(
      children: [
        Flexible(
          child: TextFormField(
            controller: _controller,
            focusNode: focusNode,
            minLines: obscureText ? 1 : minLines,
            maxLines: obscureText ? 1 : maxLines,
            onChanged: listener,
            readOnly: !editable,
            onTap: () => onTap(context, _controller),
            inputFormatters: formatters,
            keyboardType: TextInputType.text,
            cursorColor: theme.cursorColor,
            style: theme.textStyle,
            showCursor: editable && type != FormsType.date,
            obscureText: obscureText,
            decoration: FormComponents.inputDecoration(theme, hint, editable).copyWith(
              suffixIcon: suffix(changeValue),
              prefixIcon: prefix(changeValue),
            ),
          ),
        ),
        actionWidget()
      ],
    );
  }
}