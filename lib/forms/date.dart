
import 'package:cdx_core/injector.dart';
import 'package:cdx_core/utils/date_utils.dart';
import 'package:cdx_core/utils/extensions.dart';
import 'package:cdx_reactiveforms/forms/text.dart';
import 'package:flutter/material.dart';
import '../models/types.dart';


class DateForm extends TextForm<DateTime> {

  final bool readOnly;
  final String outputFormat;
  DateForm({
    required super.hint,
    required super.label,
    super.type = FormsType.date,
    super.labelInfo = false,
    super.required = false,
    super.editable = true,
    super.visible = true,
    required super.initialValue,
    required this.outputFormat,
    this.readOnly = false,
    DateTime? minDate,
    DateTime? maxDate
  }) : super(
    errorNotifier: ValueNotifier(''),
    formatters: [],
    inputType: TextInputType.datetime,
    minValue: minDate ?? DateTime(1900),
    maxValue: maxDate ?? DateTime(2100),
  );

  @override
  void onTap(BuildContext context, TextEditingController controller) async {
    if (readOnly) return;
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: inputTransform(controller.text),
      firstDate: minValue!,
      lastDate: maxValue!,
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
      changeValue(outputTransform(pickedDate));
    }
  }

  @override
  DateTime? inputTransform(String? input) {
    return DatesUtils.parse(input, outputFormat);
  }

  @override
  String? outputTransform(DateTime? output) {
    return output?.format(outputFormat);
  }

  @override
  bool validate(String? value) {
    print(value);
    DateTime? date = inputTransform(value);
    return date != null
        && date.millisecondsSinceEpoch >= minValue!.millisecondsSinceEpoch
        && date.millisecondsSinceEpoch <= maxValue!.millisecondsSinceEpoch
        && (isValid == null || isValid!(value));
  }
}