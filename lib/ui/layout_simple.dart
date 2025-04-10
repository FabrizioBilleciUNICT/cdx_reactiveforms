
import 'package:cdx_reactiveforms/models/iform.dart';
import 'package:flutter/material.dart';
import 'delegate.dart';

class SimpleFormLayout extends FormBuilderDelegate {

  @override
  Widget buildFormFields(
      BuildContext context,
      Map<String, IForm<dynamic, dynamic>> forms,
      FieldBuilder fieldBuilder,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: forms.entries.map((entry) {
        final form = entry.value;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: fieldBuilder(context, form),
        );
      }).toList(),
    );
  }
}
