
import 'package:cdx_core/injector.dart';
import 'package:cdx_core/utils/date_utils.dart';
import 'package:cdx_core/utils/extensions.dart';
import 'package:cdx_reactiveforms/forms/text.dart';
import 'package:flutter/material.dart';
import '../models/types.dart';


class DateForm extends TextForm<String> {

  final bool readOnly;
  final String outputFormat;
  DateForm({
    required super.hint,
    required super.label,
    super.type = FormsType.date,
    super.labelInfo,
    super.isRequired,
    super.editable,
    super.visible,
    required super.initialValue,
    required this.outputFormat,
    this.readOnly = false,
    DateTime? minDate,
    DateTime? maxDate
  }) : super(
    errorNotifier: ValueNotifier(''),
    formatters: [],
    inputType: TextInputType.datetime,
    minValue: (minDate ?? DateTime(1900)).format(outputFormat),
    maxValue: (maxDate ?? DateTime(2100)).format(outputFormat),
  ) {
    _minDate = minDate ?? DateTime(1900);
    _maxDate = maxDate ?? DateTime(2100);
  }
  
  late final DateTime _minDate;
  late final DateTime _maxDate;

  @override
  void onTap(BuildContext context, TextEditingController controller) async {
    if (readOnly) return;
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _parseDate(controller.text) ?? _minDate,
      firstDate: _minDate,
      lastDate: _maxDate,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: DI.colors().primary,
              onPrimary: Colors.white,
              onSurface: DI.colors().primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      changeValue(pickedDate.format(outputFormat));
    }
  }

  @override
  String? inputTransform(String? input) {
    // For JSON serialization, return the string directly
    // DateTime parsing is handled internally for validation
    return input;
  }
  
  DateTime? _parseDate(String? input) {
    return DatesUtils.parse(input, outputFormat);
  }

  @override
  String? outputTransform(String? output) {
    // For TextForm<String>, outputTransform is identity
    return output;
  }

  @override
  bool validate(String? value) {
    DateTime? date = _parseDate(value);
    return !isRequired || (date != null
        && date.millisecondsSinceEpoch >= _minDate.millisecondsSinceEpoch
        && date.millisecondsSinceEpoch <= _maxDate.millisecondsSinceEpoch
        && (isValid == null || isValid!(value)));
  }
}