import 'package:cdx_core/core/models/input_theme_data.dart';
import 'package:cdx_core/injector.dart';
import 'package:cdx_reactiveforms/models/iform.dart';
import 'package:cdx_reactiveforms/models/form_localizations.dart';
import 'package:cdx_reactiveforms/models/form_error_logger.dart';
import 'package:cdx_reactiveforms/ui/components.dart';
import 'package:flutter/material.dart';

abstract class BaseForm<T, K> extends IForm<T, K> {
  final String? errorMessageText;
  final FormLocalizations? localizations;
  final FormErrorLogger? errorLogger;
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
    this.localizations,
    this.errorLogger,
    super.semanticsLabel,
    super.tooltip,
    super.hintText,
    super.visibilityCondition,
    super.editableCondition,
  }) : super(
    errorNotifier: errorNotifier ?? ValueNotifier(''),
    showErrorNotifier: showErrorNotifier ?? ValueNotifier(false),
    valueNotifier: ValueNotifier(null),
  ) {
    theme = themeData ?? DI.theme().inputTheme;
  }
  
  FormLocalizations get _localizations => localizations ?? DefaultFormLocalizations();

  @override
  void listener(T? value) {
    showError(false);
    final bool valid = validate(value);
    if (!valid) {
      final errorMsg = errorMessage(value);
      errorNotifier.value = errorMsg;
      errorLogger?.logValidationError(type.toString(), label, errorMsg);
    } else {
      errorNotifier.value = '';
    }
    valueNotifier.value = inputTransform(value);
  }

  @override
  String errorMessage(T? value) {
    return errorMessageText ?? _localizations.defaultErrorMessage;
  }

  Widget labelWidget() {
    Widget labelWidget = FormComponents.label(label, theme);
    if (tooltip != null && tooltip!.isNotEmpty) {
      labelWidget = Tooltip(
        message: tooltip!,
        child: labelWidget,
      );
    }
    return labelWidget;
  }

  /// Wraps the input widget with Semantics for accessibility
  Widget wrapWithSemantics(Widget input) {
    final effectiveLabel = semanticsLabel ?? label;
    final effectiveHint = hintText ?? hint;
    
    return Semantics(
      label: effectiveLabel,
      hint: effectiveHint,
      value: valueNotifier.value?.toString() ?? '',
      enabled: editable,
      child: input,
    );
  }

  @override
  Widget build(BuildContext context, ValueListenableBuilder<String> Function() errorBuilder) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        labelWidget(),
        wrapWithSemantics(buildInput(context)),
        ValueListenableBuilder<bool>(
          valueListenable: showErrorNotifier,
          builder: (context, show, child) {
            if (!show) return const SizedBox.shrink();
            return errorBuilder();
          },
          child: const SizedBox.shrink(), // Child parameter for optimization
        ),
      ],
    );
  }

  Widget buildInput(BuildContext context);
}

