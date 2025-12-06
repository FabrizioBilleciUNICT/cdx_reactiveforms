
import 'package:cdx_core/injector.dart';
import 'package:cdx_reactiveforms/forms/text.dart';
import 'package:flutter/material.dart';
import '../models/types.dart';

class TimeForm extends TextForm<String> {
  final bool readOnly;
  final String outputFormat;

  TimeForm({
    required super.hint,
    required super.label,
    super.type = FormsType.time,
    super.labelInfo,
    super.isRequired,
    super.editable,
    super.visible,
    required super.initialValue,
    this.outputFormat = 'HH:mm',
    this.readOnly = false,
    String? minTime,
    String? maxTime,
  }) : super(
    errorNotifier: ValueNotifier(''),
    formatters: [],
    inputType: TextInputType.datetime,
    minValue: minTime ?? '00:00',
    maxValue: maxTime ?? '23:59',
  ) {
    _minTime = _parseTime(minTime ?? '00:00') ?? TimeOfDay(hour: 0, minute: 0);
    _maxTime = _parseTime(maxTime ?? '23:59') ?? TimeOfDay(hour: 23, minute: 59);
  }

  late final TimeOfDay _minTime;
  late final TimeOfDay _maxTime;

  @override
  void onTap(BuildContext context, TextEditingController controller) async {
    if (readOnly) return;
    
    final currentTime = _parseTime(controller.text) ?? TimeOfDay.now();
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: currentTime,
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
    
    if (pickedTime != null) {
      final timeString = _formatTime(pickedTime);
      changeValue(timeString);
    }
  }

  TimeOfDay? _parseTime(String? input) {
    if (input == null || input.isEmpty) return null;
    final parts = input.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  String? inputTransform(String? input) {
    // For JSON serialization, return the string directly
    return input;
  }

  @override
  String? outputTransform(String? output) {
    // For TextForm<String>, outputTransform is identity
    return output;
  }

  @override
  bool validate(String? value) {
    if (value == null || value.isEmpty) {
      return !isRequired;
    }
    
    final time = _parseTime(value);
    if (time == null) return false;

    // Check if time is within min/max range
    final timeInMinutes = time.hour * 60 + time.minute;
    final minInMinutes = _minTime.hour * 60 + _minTime.minute;
    final maxInMinutes = _maxTime.hour * 60 + _maxTime.minute;

    if (timeInMinutes < minInMinutes || timeInMinutes > maxInMinutes) {
      return false;
    }

    return isValid == null || isValid!(value);
  }
}

