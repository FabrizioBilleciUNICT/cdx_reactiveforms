import 'dart:async';
import 'package:cdx_core/injector.dart';
import 'package:flutter/material.dart';
import '../forms/base_form.dart';
import '../models/dropdown_item.dart';
import '../models/disposable.dart';
import '../models/form_localizations.dart';
import '../models/types.dart';

class SelectableForm<K> extends BaseForm<List<K>, List<K>> with Disposable {
  final Stream<List<DropdownItem<K>>> optionsStream;
  final FocusNode? focusNode;
  final int? minSize;
  final int? maxSize;
  final Widget Function(BuildContext, DropdownItem<K>, bool isSelected)? itemBuilder;

  final List<K> _initialValue;
  List<K> _selectedValues = [];
  final ValueNotifier<List<DropdownItem<K>>> _optionsNotifier = ValueNotifier([]);
  StreamSubscription<List<DropdownItem<K>>>? _subscription;

  SelectableForm({
    required super.hint,
    required super.label,
    required List<K> initialValue,
    required this.optionsStream,
    this.focusNode,
    this.itemBuilder,
    super.isRequired = true,
    super.editable = true,
    super.visible = true,
    super.labelInfo = false,
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
    this.minSize = 1,
    this.maxSize = 1,
  }) : _initialValue = List.from(initialValue),
        _selectedValues = List.from(initialValue),
        super(type: FormsType.multiselect) {
    valueNotifier.value = initialValue;
    _subscription = optionsStream.listen((list) {
      if (list.isNotEmpty) {
        _optionsNotifier.value = list;
      }
      _selectedValues.removeWhere((sel) => !list.any((opt) => opt.value == sel));
      valueNotifier.value = List.from(_selectedValues);
    });
  }

  void dispose() {
    _subscription?.cancel();
    _optionsNotifier.dispose();
  }

  @override
  bool validate(List<K>? value) {
    if (!isRequired) return true;
    if (value == null || value.isEmpty) {
      return minSize == null || minSize! == 0;
    }
    
    if (minSize != null && value.length < minSize!) {
      return false;
    }
    if (maxSize != null && value.length > maxSize!) {
      return false;
    }
    
    return isValid == null || isValid!(value);
  }

  @override
  String errorMessage(List<K>? value) {
    if (errorMessageText != null) return errorMessageText!;
    final loc = localizations ?? DefaultFormLocalizations();
    
    if (value != null) {
      if (minSize != null && value.length < minSize!) {
        return loc.minSelectionErrorMessage(minSize!);
      }
      if (maxSize != null && value.length > maxSize!) {
        return loc.maxSelectionErrorMessage(maxSize!);
      }
    }
    
    return loc.defaultErrorMessage;
  }

  @override
  void listener(List<K>? value) {
    super.listener(value ?? []);
  }

  @override
  void changeValue(List<K>? newValue) {
    _selectedValues = newValue ?? [];
    listener(_selectedValues);
  }

  @override
  List<K>? currentValue() => _selectedValues;

  @override
  void clear() {
    _selectedValues = [];
    valueNotifier.value = [];
  }

  @override
  void reset() {
    _selectedValues = List.from(_initialValue);
    valueNotifier.value = List.from(_initialValue);
  }

  @override
  void onTap(BuildContext context, TextEditingController controller) {}

  @override
  List<K>? inputTransform(List<K>? input) => input;

  @override
  List<K>? outputTransform(List<K>? output) => output;

  @override
  Widget build(BuildContext context, ValueListenableBuilder<String> Function() errorBuilder) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        labelWidget(),
        ValueListenableBuilder<List<DropdownItem<K>>>(
          valueListenable: _optionsNotifier,
          builder: (context, items, child) {
            return ValueListenableBuilder(
              valueListenable: valueNotifier,
              builder: (context, value, child) => _buildOptionsList(context, items),
            );
          },
        ),
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

  Widget _buildOptionsList(BuildContext context, List<DropdownItem<K>> items) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: items.map((item) {
          final selected = _selectedValues.contains(item.value);
          final itemWidget = itemBuilder != null
              ? itemBuilder!(context, item, selected)
              : _defaultItemBuilder(context, item, selected);

          return GestureDetector(
            onTap: editable ? () {
              final max = maxSize ?? _optionsNotifier.value.length;

              if (selected) {
                if (_selectedValues.length > (minSize ?? 0)) {
                  _selectedValues.remove(item.value);
                }
              } else {
                if (max == 1) {
                  _selectedValues = [item.value];
                } else {
                  if (_selectedValues.length < max) {
                    _selectedValues.add(item.value);
                  }
                }
              }
              changeValue(List.of(_selectedValues));
            } : null,
            child: itemWidget,
          );
        }).toList(),
      ),
    );
  }

  Widget _defaultItemBuilder(BuildContext context, DropdownItem<K> item, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Container(
        padding: theme.contentPadding,
        decoration: BoxDecoration(
          color: DI.colors().minorBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.fromBorderSide(isSelected
              ? theme.focusedBorder
              : theme.enabledBorder
        )),
        child: Row(
          children: [
            Text(item.title, style: theme.textStyle),
            if (isSelected) Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Icon(Icons.check, color: DI.colors().primary, size: 14),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget buildInput(BuildContext context) {
    return ValueListenableBuilder<List<DropdownItem<K>>>(
      valueListenable: _optionsNotifier,
      builder: (context, items, child) {
        return ValueListenableBuilder(
          valueListenable: valueNotifier,
          builder: (context, value, child) => _buildOptionsList(context, items),
        );
      },
    );
  }
}
