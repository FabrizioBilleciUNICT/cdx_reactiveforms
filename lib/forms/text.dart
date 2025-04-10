
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

  TextForm({
    required super.hint,
    required super.label,
    super.type = FormsType.text,
    super.labelInfo = false,
    super.required = false,
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
    CdxInputThemeData? themeData,
  }) : super(errorNotifier: errorNotifier ?? ValueNotifier('')) {
    _controller = TextEditingController(text: outputTransform(initialValue));
    _initialValue = outputTransform(initialValue) ?? '';
    theme = themeData ?? DI.theme().inputTheme;
  }

  Widget suffix(void Function(String) onAction) => const SizedBox();
  Widget prefix(void Function(String) onAction) => const SizedBox();

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
    final bool valid = validate(value);
    if (!valid) {
      errorNotifier.value = 'Errore';
    }
    else {
      errorNotifier.value = '';
    }
  }

  @override
  bool validate(String? value) {
    return ((value?.length ?? 0) >= (minValue?.toString().length ?? 0)) &&
        (isValid == null || isValid!(value));
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
        input(context),
        errorBuilder()
      ],
    );
  }

  Widget labelWidget() => FormComponents.label(label, theme);

  Widget input(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: TextFormField(
            controller: _controller,
            focusNode: focusNode,
            minLines: minLines,
            maxLines: maxLines,
            onChanged: listener,
            readOnly: !editable,
            onTap: () => onTap(context, _controller),
            inputFormatters: formatters,
            keyboardType: TextInputType.text,
            cursorColor: theme.cursorColor,
            style: theme.textStyle,
            showCursor: editable && type != FormsType.date,
            decoration: FormComponents.inputDecoration(theme, hint, editable).copyWith(
              suffix: suffix(changeValue),
              prefix: prefix(changeValue),
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