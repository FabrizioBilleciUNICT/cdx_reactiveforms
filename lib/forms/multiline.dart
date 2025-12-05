import 'package:cdx_reactiveforms/ui/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/disposable.dart';
import '../models/types.dart';
import 'base_form.dart';

class MultilineForm<K> extends BaseForm<String, K> with Disposable {
  late final TextEditingController _controller;
  late final String _initialValue;
  final List<TextInputFormatter> formatters;
  final TextInputType inputType;
  final FocusNode? focusNode;
  final int minLines;
  final int? maxLines;
  final void Function(String?)? onChange;

  MultilineForm({
    required super.hint,
    required super.label,
    super.type = FormsType.multiline,
    super.labelInfo = false,
    super.isRequired = true,
    super.editable = true,
    super.visible = true,
    super.minValue,
    super.maxValue,
    super.isValid,
    required K? initialValue,
    this.formatters = const [],
    this.inputType = TextInputType.multiline,
    this.focusNode,
    this.minLines = 3,
    this.maxLines,
    super.errorNotifier,
    super.showErrorNotifier,
    super.themeData,
    super.errorMessageText = 'This field is not valid',
    this.onChange,
  }) : super() {
    _controller = TextEditingController(text: outputTransform(initialValue));
    _initialValue = outputTransform(initialValue) ?? '';
    valueNotifier.value = inputTransform(outputTransform(initialValue));
  }

  @override
  K? inputTransform(String? input) {
    // For MultilineForm, K should be String. This cast is safe when K is String.
    if (input == null) return null;
    // Type-safe conversion: if K is String, this works
    return input as K?;
  }

  @override
  String? outputTransform(K? output) {
    return output?.toString();
  }

  @override
  void listener(String? value) {
    super.listener(value);
    onChange?.call(value ?? '');
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
  Widget buildInput(BuildContext context) {
    return TextFormField(
      controller: _controller,
      focusNode: focusNode,
      minLines: minLines,
      maxLines: maxLines,
      onChanged: listener,
      readOnly: !editable,
      onTap: () => onTap(context, _controller),
      inputFormatters: formatters,
      keyboardType: inputType,
      cursorColor: theme.cursorColor,
      style: theme.textStyle,
      showCursor: editable,
      decoration: FormComponents.inputDecoration(theme, hint, editable),
    );
  }

  void dispose() {
    _controller.dispose();
  }
}

