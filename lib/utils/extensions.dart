
import 'package:cdx_core/utils/extensions.dart';
import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  String format([String pattern = 'dd/MM/yyyy', String? locale]) {
    return DateFormat(pattern, locale).format(this);
  }

  bool isSameOrAfterDate(DateTime other) {
    final a = DateTime.parse(format('yyyy-MM-dd'));
    final b = DateTime.parse(other.format('yyyy-MM-dd'));
    return a.isSameDate(b) || a.isAfter(b);
  }
}