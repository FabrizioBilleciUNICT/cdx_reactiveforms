import 'package:cdx_core/injector.dart';
import 'package:cdx_reactiveforms/controllers/form_controller.dart';
import 'package:cdx_reactiveforms/forms/base_form.dart';
import 'package:cdx_reactiveforms/models/iform.dart';
import 'package:cdx_reactiveforms/models/disposable.dart';
import 'package:cdx_reactiveforms/models/inested_form.dart';
import 'package:cdx_reactiveforms/models/form_localizations.dart';
import 'package:cdx_reactiveforms/models/types.dart';
import 'package:cdx_reactiveforms/ui/delegate.dart';
import 'package:cdx_reactiveforms/ui/layout_simple.dart';
import 'package:flutter/material.dart';

class NestedForm extends BaseForm<Map<String, dynamic>, Map<String, dynamic>> with Disposable implements INestedForm {
  final FormController _innerController;
  final FormBuilderDelegate? layoutDelegate;
  final FieldBuilder? fieldBuilder;
  final EdgeInsets? padding;
  final Decoration? containerDecoration;
  int _lastFormCount = 0;

  NestedForm({
    required super.hint,
    required super.label,
    required Map<String, IForm> innerForms,
    super.type = FormsType.nested,
    super.labelInfo = false,
    super.isRequired = true,
    super.editable = true,
    super.visible = true,
    super.minValue,
    super.maxValue,
    super.isValid,
    super.errorNotifier,
    super.showErrorNotifier,
    super.themeData,
    super.errorMessageText,
    super.localizations,
    super.semanticsLabel,
    super.tooltip,
    super.hintText,
    this.layoutDelegate,
    this.fieldBuilder,
    this.padding,
    this.containerDecoration,
  }) : _innerController = FormController(innerForms),
        super() {
    valueNotifier.value = _innerController.getValues();
    _innerController.isValid.addListener(_onInnerFormChange);
    _initInnerFormListeners();
    _lastFormCount = _innerController.forms.length;
  }

  void _initInnerFormListeners() {
    for (var form in _innerController.forms.values) {
      form.valueNotifier.addListener(_onInnerFormChange);
    }
  }

  void _syncInnerFormListeners() {
    // Only sync if form count changed to avoid unnecessary work
    final currentFormCount = _innerController.forms.length;
    if (currentFormCount == _lastFormCount) {
      return;
    }
    _lastFormCount = currentFormCount;
    
    // Re-sync listeners in case forms were added dynamically
    for (var form in _innerController.forms.values) {
      // Note: addListener is idempotent in Flutter, so calling it multiple times is safe
      form.valueNotifier.addListener(_onInnerFormChange);
    }
  }

  void _onInnerFormChange() {
    // Sync listeners in case new forms were added
    _syncInnerFormListeners();
    final values = _innerController.getValues();
    valueNotifier.value = values;
    listener(values);
  }

  FormController get innerController {
    // Ensure listeners are synced when accessing innerController
    _syncInnerFormListeners();
    return _innerController;
  }

  @override
  bool validate(Map<String, dynamic>? value) {
    if (!isRequired && (value == null || value.isEmpty)) {
      return true;
    }
    if (value == null || value.isEmpty) {
      return false;
    }
    // Validate inner forms first to ensure isValid.value is up to date
    _innerController.validateAll();
    final innerValid = _innerController.isValid.value;
    if (isValid != null) {
      return innerValid && isValid!(value);
    }
    return innerValid;
  }

  @override
  String errorMessage(Map<String, dynamic>? value) {
    return errorMessageText ?? (localizations ?? DefaultFormLocalizations()).nestedFormErrorMessage;
  }

  @override
  void listener(Map<String, dynamic>? value) {
    showError(false);
    final bool valid = validate(value);
    if (!valid) {
      errorNotifier.value = errorMessage(value);
    } else {
      errorNotifier.value = '';
    }
    valueNotifier.value = value;
  }

  @override
  Map<String, dynamic>? currentValue() {
    return _innerController.getValues();
  }

  @override
  void changeValue(Map<String, dynamic>? newValue) {
    if (newValue == null) return;
    for (var entry in newValue.entries) {
      final form = _innerController.forms[entry.key];
      if (form != null) {
        form.changeValue(entry.value);
      }
    }
    _onInnerFormChange();
  }

  @override
  void clear() {
    _innerController.clearAll();
    valueNotifier.value = {};
  }

  @override
  void reset() {
    _innerController.resetAll();
    valueNotifier.value = _innerController.getValues();
  }

  @override
  void onTap(BuildContext context, TextEditingController controller) {}

  @override
  Map<String, dynamic>? inputTransform(Map<String, dynamic>? input) => input;

  @override
  Map<String, dynamic>? outputTransform(Map<String, dynamic>? output) => output;

  @override
  Widget buildInput(BuildContext context) {
    final delegate = layoutDelegate ?? SimpleFormLayout();
    final builder = fieldBuilder ?? _defaultFieldBuilder;

    return Container(
      padding: padding ?? const EdgeInsets.all(8.0),
      decoration: containerDecoration ??
          BoxDecoration(
            border: Border.all(color: theme.enabledBorder.color),
            borderRadius: BorderRadius.circular(8),
          ),
      child: delegate.buildFormFields(
        context,
        _innerController.forms,
        builder,
      ),
    );
  }

  Widget _defaultFieldBuilder(BuildContext context, IForm form) {
    final errorBuilder = _defaultErrorBuilder(form);
    return form.build(context, errorBuilder);
  }

  ValueListenableBuilder<String> Function() _defaultErrorBuilder(IForm form) {
    return () => ValueListenableBuilder(
      valueListenable: form.errorNotifier,
      builder: (context, value, child) => value.isNotEmpty
          ? Text(value, style: DI.theme().inputTheme.errorTextStyle)
          : const SizedBox(),
    );
  }

  void dispose() {
    _innerController.isValid.removeListener(_onInnerFormChange);
    for (var form in _innerController.forms.values) {
      form.valueNotifier.removeListener(_onInnerFormChange);
    }
    _innerController.dispose();
  }
}

