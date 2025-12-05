import 'package:cdx_core/core/models/input_theme_data.dart';
import 'package:cdx_core/injector.dart';
import 'package:cdx_reactiveforms/models/iform.dart';
import 'package:cdx_reactiveforms/ui/components.dart';
import 'package:flutter/material.dart';

abstract class BaseForm<T, K> extends IForm<T, K> {
  final String? errorMessageText;
  late final CdxInputThemeData theme;

  BaseForm({
    required super.hint,
    required super.label,
    required super.type,
    super.labelInfo = false,
    super.isRequired = true,
    super.editable = true,
    super.visible = true,
    super.minValue,
    super.maxValue,
    super.isValid,
    ValueNotifier<String>? errorNotifier,
    ValueNotifier<bool>? showErrorNotifier,
    CdxInputThemeData? themeData,
    this.errorMessageText,
  }) : super(
    errorNotifier: errorNotifier ?? ValueNotifier(''),
    showErrorNotifier: showErrorNotifier ?? ValueNotifier(false),
    valueNotifier: ValueNotifier(null),
  ) {
    theme = themeData ?? DI.theme().inputTheme;
  }

  @override
  void listener(T? value) {
    showError(false);
    final bool valid = validate(value);
    if (!valid) {
      errorNotifier.value = errorMessage(value);
    } else {
      errorNotifier.value = '';
    }
    valueNotifier.value = inputTransform(value);
  }

  @override
  String errorMessage(T? value) {
    return errorMessageText ?? 'This field is not valid';
  }

  Widget labelWidget() => FormComponents.label(label, theme);

  @override
  Widget build(BuildContext context, ValueListenableBuilder<String> Function() errorBuilder) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        labelWidget(),
        buildInput(context),
        ValueListenableBuilder(
          valueListenable: showErrorNotifier,
          builder: (context, show, child) {
            if (!show) return const SizedBox();
            return errorBuilder();
          },
        ),
      ],
    );
  }

  Widget buildInput(BuildContext context);
}

