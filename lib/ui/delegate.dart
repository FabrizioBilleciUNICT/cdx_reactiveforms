
import 'package:cdx_core/injector.dart';
import 'package:cdx_reactiveforms/models/iform.dart';
import 'package:flutter/material.dart';

typedef FieldBuilder = Widget Function(
    BuildContext context,
    IForm<dynamic, dynamic> form,
    );

abstract class FormBuilderDelegate {
  Widget buildFormFields(
      BuildContext context,
      Map<String, IForm<dynamic, dynamic>> forms,
      FieldBuilder fieldBuilder
  );

  ValueListenableBuilder<String> Function() error(IForm<dynamic, dynamic> form) {
    return () => ValueListenableBuilder(
      valueListenable: form.errorNotifier,
      builder: (context, value, child) => value.isNotEmpty
          ? Text(value, style: DI.theme().inputTheme.errorTextStyle)
          : const SizedBox(),
    );
  }
}
