
import 'package:cdx_core/core/models/input_theme_data.dart';
import 'package:cdx_core/injector.dart';
import 'package:flutter/material.dart';

import '../models/dropdown_item.dart';
import '../models/iform.dart';
import '../models/types.dart';
import '../ui/components.dart';

class SelectableForm<K> extends IForm<List<K>, List<K>> {
  final Stream<List<DropdownItem<K>>> optionsStream;
  final FocusNode? focusNode;
  final int? minSize;
  final int? maxSize;
  final Widget Function(BuildContext, DropdownItem<K>, bool isSelected)? itemBuilder;
  late final CdxInputThemeData theme;

  late final List<K> _initialValue;
  List<K> _selectedValues = [];
  List<DropdownItem<K>> _options = [];

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
    ValueNotifier<String>? errorNotifier,
    ValueNotifier<bool>? showErrorNotifier,
    CdxInputThemeData? themeData,
    this.minSize = 1,
    this.maxSize = 1
  }) : super(
    type: FormsType.multiselect,
    errorNotifier: errorNotifier ?? ValueNotifier(''),
    showErrorNotifier: showErrorNotifier ?? ValueNotifier(false),
    valueNotifier: ValueNotifier(initialValue),
  ) {
    _initialValue = initialValue;
    _selectedValues = List.from(initialValue);
    theme = themeData ?? DI.theme().inputTheme;

    optionsStream.listen((list) {
      _options = list;
      _selectedValues.removeWhere((sel) => !_options.any((opt) => opt.value == sel));
    });
  }

  @override
  bool validate(List<K>? value) {
    final isValidResult = !isRequired || (value != null && value.isNotEmpty && (isValid == null || isValid!(value)));
    errorNotifier.value = isValidResult ? '' : errorMessage(value);
    return isValidResult;
  }

  @override
  void listener(List<K>? value) {
    showError(false);
    validate(value);
    valueNotifier.value = value ?? [];
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
  }

  @override
  void reset() {
    _selectedValues = List.from(_initialValue);
  }

  @override
  void onTap(BuildContext context, TextEditingController controller) {}

  @override
  List<K>? inputTransform(List<K>? input) => input;

  @override
  List<K>? outputTransform(List<K>? output) => output;

  @override
  String errorMessage(List<K>? value) => 'Seleziona almeno un valore';

  @override
  Widget build(BuildContext context, ValueListenableBuilder<String> Function() errorBuilder) {
    return StreamBuilder<List<DropdownItem<K>>>(
      stream: optionsStream,
      builder: (context, snapshot) {
        final items = snapshot.data ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            labelWidget(),
            ValueListenableBuilder(
              valueListenable: valueNotifier,
              builder: (context, value, child) {
                return _buildOptionsList(context, items);
              }
            ),
            ValueListenableBuilder(
              valueListenable: showErrorNotifier,
              builder: (context, value, child) {
                if (!value) return const SizedBox();
                return errorBuilder();
              },
            ),
          ],
        );
      },
    );
  }

  Widget labelWidget() => FormComponents.label(label, theme);

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
              final max = maxSize ?? _options.length;

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
        padding: DI.theme().inputTheme.contentPadding,
        decoration: BoxDecoration(
          color: DI.colors().minorBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.fromBorderSide(isSelected
              ? DI.theme().inputTheme.focusedBorder
              : DI.theme().inputTheme.enabledBorder
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
}
