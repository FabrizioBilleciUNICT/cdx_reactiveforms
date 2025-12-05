import 'package:cdx_core/injector.dart';
import 'package:cdx_reactiveforms/controllers/form_controller.dart';
import 'package:cdx_reactiveforms/forms/base_form.dart';
import 'package:cdx_reactiveforms/models/iform.dart';
import 'package:cdx_reactiveforms/models/disposable.dart';
import 'package:cdx_reactiveforms/models/iarray_form.dart';
import 'package:cdx_reactiveforms/models/types.dart';
import 'package:cdx_reactiveforms/ui/delegate.dart';
import 'package:cdx_reactiveforms/ui/layout_simple.dart';
import 'package:flutter/material.dart';

class ArrayForm extends BaseForm<List<Map<String, dynamic>>, List<Map<String, dynamic>>> with Disposable implements IArrayForm {
  final List<FormController> _itemControllers = [];
  final FormBuilderDelegate? layoutDelegate;
  final FieldBuilder? fieldBuilder;
  final EdgeInsets? padding;
  final Decoration? containerDecoration;
  final int? minItems;
  final int? maxItems;
  final Map<String, IForm> Function() itemFormFactory;
  final Map<FormController, int> _itemControllerFormCounts = {};

  ArrayForm({
    required super.hint,
    required super.label,
    required this.itemFormFactory,
    super.type = FormsType.customArray,
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
    super.errorMessageText = 'This array form is not valid',
    this.layoutDelegate,
    this.fieldBuilder,
    this.padding,
    this.containerDecoration,
    this.minItems,
    this.maxItems,
    List<Map<String, dynamic>>? initialValue,
  }) : super() {
    if (initialValue != null && initialValue.isNotEmpty) {
      for (var item in initialValue) {
        _addItem(item);
      }
    }
    valueNotifier.value = _getValues();
  }

  void _addItem([Map<String, dynamic>? initialData]) {
    if (maxItems != null && _itemControllers.length >= maxItems!) {
      return;
    }

    final itemForms = itemFormFactory();
    final controller = FormController(itemForms);
    
    if (initialData != null) {
      for (var entry in initialData.entries) {
        final form = controller.forms[entry.key];
        if (form != null) {
          form.changeValue(entry.value);
        }
      }
    }

    controller.isValid.addListener(_onItemChange);
    _syncItemControllerListeners(controller);
    _itemControllers.add(controller);
    // Initialize form count tracking for this controller
    _itemControllerFormCounts[controller] = controller.forms.length;
    _onItemChange();
  }

  void _syncItemControllerListeners(FormController controller) {
    // Only sync if form count changed for this controller to avoid unnecessary work
    final currentFormCount = controller.forms.length;
    final lastFormCount = _itemControllerFormCounts[controller] ?? 0;
    
    if (currentFormCount == lastFormCount) {
      return;
    }
    _itemControllerFormCounts[controller] = currentFormCount;
    
    // Ensure all forms in the controller have listeners registered
    for (var form in controller.forms.values) {
      // Note: addListener is idempotent in Flutter, so calling it multiple times is safe
      form.valueNotifier.addListener(_onItemChange);
    }
  }

  void _disposeItemController(FormController controller) {
    controller.isValid.removeListener(_onItemChange);
    for (var form in controller.forms.values) {
      form.valueNotifier.removeListener(_onItemChange);
    }
    _itemControllerFormCounts.remove(controller);
    controller.dispose();
  }

  void removeItem(int index) {
    if (index < 0 || index >= _itemControllers.length) return;
    if (minItems != null && _itemControllers.length <= minItems!) return;

    final controller = _itemControllers.removeAt(index);
    _disposeItemController(controller);
    _onItemChange();
  }

  void _onItemChange() {
    // Sync listeners for all item controllers in case forms were added dynamically
    for (var controller in _itemControllers) {
      _syncItemControllerListeners(controller);
    }
    final values = _getValues();
    valueNotifier.value = values;
    listener(values);
  }

  List<Map<String, dynamic>> _getValues() {
    return _itemControllers.map((controller) {
      final values = controller.getValues();
      // Deep copy and ensure all nested objects are converted to Map<String, dynamic>
      // This handles cases where form values might contain custom objects
      return Map<String, dynamic>.from(
        values.map((key, value) {
          // Recursively convert any nested objects to Map
          final convertedValue = _convertToJsonCompatible(value);
          return MapEntry(key, convertedValue);
        })
      );
    }).toList();
  }

  dynamic _convertToJsonCompatible(dynamic value) {
    if (value == null) return null;
    if (value is Map) {
      return Map<String, dynamic>.from(
        value.map((k, v) => MapEntry(k.toString(), _convertToJsonCompatible(v)))
      );
    }
    if (value is List) {
      return value.map((e) => _convertToJsonCompatible(e)).toList();
    }
    // If value is a custom object with toJson, convert it
    try {
      final json = (value as dynamic).toJson();
      return _convertToJsonCompatible(json);
    } catch (e) {
      // If toJson doesn't exist or fails, return as-is (primitive types)
      return value;
    }
  }

  List<FormController> get itemControllers => List.unmodifiable(_itemControllers);

  @override
  bool validate(List<Map<String, dynamic>>? value) {
    if (!isRequired && (value == null || value.isEmpty)) {
      return true;
    }
    if (value == null || value.isEmpty) {
      if (minItems != null && minItems! > 0) {
        return false;
      }
      return !isRequired;
    }

    // Check min/max items
    if (minItems != null && value.length < minItems!) {
      return false;
    }
    if (maxItems != null && value.length > maxItems!) {
      return false;
    }

    // Validate all items first to ensure isValid.value is up to date
    for (var controller in _itemControllers) {
      controller.validateAll();
      if (!controller.isValid.value) {
        return false;
      }
    }

    if (isValid != null) {
      return isValid!(value);
    }
    return true;
  }

  @override
  void listener(List<Map<String, dynamic>>? value) {
    showError(false);
    final bool valid = validate(value);
    if (!valid) {
      errorNotifier.value = errorMessage(value);
    } else {
      errorNotifier.value = '';
    }
    valueNotifier.value = value ?? [];
  }

  @override
  List<Map<String, dynamic>>? currentValue() {
    return _getValues();
  }

  @override
  void changeValue(List<Map<String, dynamic>>? newValue) {
    if (newValue == null) {
      clear();
      return;
    }

    // Optimize: clear existing items at once instead of one by one (O(n) instead of O(n²))
    for (var controller in _itemControllers) {
      _disposeItemController(controller);
    }
    _itemControllers.clear();
    _itemControllerFormCounts.clear();

    // Add new items
    for (var itemData in newValue) {
      _addItem(itemData);
    }
    _onItemChange();
  }

  void showErrors() {
    showError(true);
    for (var controller in _itemControllers) {
      controller.showErrors();
    }
  }

  @override
  void clear() {
    // Optimize: remove all items at once instead of one by one (O(n) instead of O(n²))
    for (var controller in _itemControllers) {
      controller.isValid.removeListener(_onItemChange);
      for (var form in controller.forms.values) {
        form.valueNotifier.removeListener(_onItemChange);
      }
      controller.dispose();
    }
    _itemControllers.clear();
    _itemControllerFormCounts.clear();
    valueNotifier.value = [];
  }

  @override
  void reset() {
    clear();
    valueNotifier.value = [];
  }

  @override
  void onTap(BuildContext context, TextEditingController controller) {}

  @override
  List<Map<String, dynamic>>? inputTransform(List<Map<String, dynamic>>? input) => input;

  @override
  List<Map<String, dynamic>>? outputTransform(List<Map<String, dynamic>>? output) => output;

  @override
  Widget buildInput(BuildContext context) {
    final delegate = layoutDelegate ?? SimpleFormLayout();
    final builder = fieldBuilder ?? _defaultFieldBuilder;

    return ValueListenableBuilder<List<Map<String, dynamic>>?>(
      valueListenable: valueNotifier,
      builder: (context, value, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (editable)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Items: ${_itemControllers.length}${minItems != null || maxItems != null ? ' (min: ${minItems ?? 0}, max: ${maxItems ?? '∞'})' : ''}',
                      style: theme.textStyle.copyWith(fontSize: 12),
                    ),
                    ElevatedButton.icon(
                      onPressed: (maxItems != null && _itemControllers.length >= maxItems!)
                          ? null
                          : () => _addItem(),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Item'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ),
            ...List.generate(_itemControllers.length, (index) {
              final itemController = _itemControllers[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 8.0),
                padding: padding ?? const EdgeInsets.all(8.0),
                decoration: containerDecoration ??
                    BoxDecoration(
                      border: Border.all(color: theme.enabledBorder.color),
                      borderRadius: BorderRadius.circular(8),
                    ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Item ${index + 1}',
                          style: theme.labelTextStyle,
                        ),
                        if (editable)
                          IconButton(
                            icon: const Icon(Icons.delete, size: 20),
                            onPressed: (minItems != null && _itemControllers.length <= minItems!)
                                ? null
                                : () => removeItem(index),
                            color: theme.errorBorder.color,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    delegate.buildFormFields(
                      context,
                      itemController.forms,
                      builder,
                    ),
                  ],
                ),
              );
            }),
            if (_itemControllers.isEmpty)
              Container(
                padding: padding ?? const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.enabledBorder.color),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'No items. Click "Add Item" to add one.',
                    style: theme.hintStyle,
                  ),
                ),
              ),
          ],
        );
      },
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
    for (var controller in _itemControllers) {
      _disposeItemController(controller);
    }
    _itemControllers.clear();
    _itemControllerFormCounts.clear();
  }
}

