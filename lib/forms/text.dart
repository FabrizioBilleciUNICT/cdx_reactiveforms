
import 'package:cdx_core/core/models/input_theme_data.dart';
import 'package:cdx_core/injector.dart';
import 'package:cdx_reactiveforms/ui/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/iform.dart';
import '../models/types.dart';

class TextForm<K> extends IForm<String, K> {

  late final TextEditingController _controller;
  late final String _initialValue;
  final List<TextInputFormatter> formatters;
  final TextInputType inputType;
  final FocusNode? focusNode;
  final int? minLines;
  final int? maxLines;
  late final CdxInputThemeData theme;
  final void Function(String?)? onChange;
  late final ValueNotifier<bool> hideText;

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
    ValueNotifier<String>? errorNotifier,
    ValueNotifier<bool>? showErrorNotifier,
    CdxInputThemeData? themeData,
    bool initialHideText = false,
    this.onChange,
  }) : super(
    errorNotifier: errorNotifier ?? ValueNotifier(''),
    showErrorNotifier: showErrorNotifier ?? ValueNotifier(false),
    valueNotifier: ValueNotifier(initialValue),
  ) {
    _controller = TextEditingController(text: outputTransform(initialValue));
    _initialValue = outputTransform(initialValue) ?? '';
    hideText = ValueNotifier(initialHideText);
    theme = themeData ?? DI.theme().inputTheme;
  }

  Widget? suffix(void Function(String) onAction) => null;
  Widget? prefix(void Function(String) onAction) => null;

  @override
  K? inputTransform(String? input) {
    return input as K?;
  }

  @override
  String? outputTransform(K? output) {
    return output?.toString();
  }

  @override
  void listener(String? value) {
    showError(false);
    final bool valid = validate(value);
    if (!valid) {
      errorNotifier.value = errorMessage(value);
    }
    else {
      errorNotifier.value = '';
    }
    onChange?.call(value ?? '');
    valueNotifier.value = inputTransform(value);
  }

  @override
  bool validate(String? value) {
    return !isRequired || (((value?.length ?? 0) >= (minValue?.toString().length ?? 0)) &&
        (isValid == null || isValid!(value)));
  }

  @override
  void changeValue(String? newValue) {
    _controller.text = newValue ?? '';
  }

  @override
  String? currentValue() {
    return _controller.text;
  }

  @override
  void clear() {
    _controller.text = '';
  }

  @override
  void reset() {
    _controller.text = _initialValue;
  }

  @override
  void onTap(BuildContext context, TextEditingController controller) {}

  @override
  String errorMessage(String? value) {
    return 'Field is not valid';
  }
  
  @override
  Widget build(BuildContext context, ValueListenableBuilder<String> Function() errorBuilder) {
    return Column(
      children: [
        labelWidget(),
        ValueListenableBuilder(
            valueListenable: hideText,
            builder: (context, obscureText, child) {
              return input(context, obscureText);
            }
        ),
        ValueListenableBuilder(
            valueListenable: showErrorNotifier,
            builder: (context, value, child) {
              if (!value) return const SizedBox();
              return errorBuilder();
            }
        )
      ],
    );
  }

  Widget labelWidget() => FormComponents.label(label, theme);

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

  Widget errorBuilder() {
    return ValueListenableBuilder(
        valueListenable: errorNotifier,
        builder: (context, value, child) {
          if (value.isNotEmpty) {
            return Text(value, style: TextStyle(fontSize: 12, color: DI.colors().error));
          }

          return const SizedBox();
        }
    );
  }
}