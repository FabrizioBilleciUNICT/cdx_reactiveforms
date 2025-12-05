
import 'package:cdx_core/injector.dart';
import 'package:cdx_core/utils/numeric_range_formatter.dart';
import 'package:cdx_reactiveforms/forms/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/types.dart';

class IntNumberForm extends TextForm<int> {

  IntNumberForm({
    required super.hint,
    required super.label,
    super.type = FormsType.intNumber,
    super.labelInfo,
    super.isRequired,
    super.editable,
    super.visible,
    super.errorNotifier,
    required super.initialValue,
    super.isValid,
    super.minValue = 0,
    super.maxValue = 1000000000000,
  }) : super(
    formatters: [
      NumericIntRangeFormatter(min: minValue!, max: maxValue!),
      FilteringTextInputFormatter.allow(RegExp(r"\d")),
      TextInputFormatter.withFunction((oldValue, newValue) {
        final text = newValue.text;
        return text.isEmpty
            ? newValue
            : (int.tryParse(text) == null ? oldValue : newValue);
      }),
    ],
    inputType: TextInputType.number,
  );

  @override
  int inputTransform(String? input) {
    return int.tryParse(input?.toString().trim() ?? '') ?? 0;
  }

  @override
  bool validate(String? value) {
    return !isRequired || super.validate(value);
  }

  @override
  Widget actionWidget() {
    return StatefulBuilder(
        builder: (context, setState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      width: 0.5,
                    ),
                  ),
                ),
                child: InkWell(
                  child: Icon(
                    Icons.arrow_drop_up_rounded,
                    size: 14,
                    color: DI.colors().primary,
                  ),
                  onTap: () {
                    int value = inputTransform(currentValue());
                    if (value < (formatters[0] as NumericIntRangeFormatter).max) {
                      setState(() => value++);
                      changeValue(value.toString());
                    }
                  },
                ),
              ),
              InkWell(
                child: Icon(
                  Icons.arrow_drop_down_rounded,
                  size: 14,
                  color: DI.colors().primary,
                ),
                onTap: () {
                  int value = inputTransform(currentValue());
                  if (value > (formatters[0] as NumericIntRangeFormatter).min) {
                    setState(() => value--);
                    changeValue(currentValue.toString());
                  }
                },
              ),
            ],
          );
        }
    );
  }
}

class DoubleNumberForm extends TextForm<double> {

  DoubleNumberForm({
    required super.hint,
    required super.label,
    super.type = FormsType.number,
    super.labelInfo,
    super.isRequired,
    super.editable,
    super.visible,
    super.errorNotifier,
    required super.initialValue,
    super.isValid,
    super.minValue = double.minPositive,
    super.maxValue = double.maxFinite
  }) : super(
      formatters: [
        NumericRangeFormatter(min: minValue!, max: maxValue!),
        FilteringTextInputFormatter.allow(RegExp(r"[\d.]")),
        TextInputFormatter.withFunction((oldValue, newValue) {
          final text = newValue.text;
          return text.isEmpty
              ? newValue
              : (double.tryParse(text) == null ? oldValue : newValue);
        }),
      ],
      inputType: TextInputType.number
  );

  @override
  double inputTransform(String? input) {
    return double.tryParse(input?.toString().trim() ?? '') ?? 0.0;
  }

  @override
  bool validate(String? value) {
    final v = inputTransform(value);
    return !isRequired || (value?.trim().isNotEmpty == true && ((v >= minValue! && v <= maxValue!) &&
        (isValid == null || isValid!(value))));
  }
}