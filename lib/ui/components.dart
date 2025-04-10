
import 'package:cdx_core/core/models/input_theme_data.dart';
import 'package:flutter/material.dart';

abstract class FormComponents {

  static Widget label(String label, CdxInputThemeData theme) {
    if (label.isEmpty) return const SizedBox();
    return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: theme.labelPadding,
            child: Text(
                label,
                style: theme.labelTextStyle
            ),
          ),
          //labelInfo ?? const SizedBox(),
        ]
    );
  }

  static InputDecoration inputDecoration(CdxInputThemeData theme, String hint, bool editable) {
    return InputDecoration(
      contentPadding: theme.contentPadding,
      filled: true,
      fillColor: !editable
          ? theme.disabledBackgroundColor
          : theme.backgroundColor,
      hintStyle: theme.hintStyle,
      hintText: hint,
      labelText: theme.outlinedLabel ? hint : null,
      labelStyle: theme.labelTextStyle,
      floatingLabelStyle: theme.labelTextStyle.copyWith(
          color: theme.focusedBorder.color),
      enabledBorder: OutlineInputBorder(
          borderRadius: theme.borderRadius,
          borderSide: theme.enabledBorder
      ),
      errorBorder: OutlineInputBorder(
          borderRadius: theme.borderRadius,
          borderSide: theme.errorBorder
      ),
      border: OutlineInputBorder(
          borderRadius: theme.borderRadius,
          borderSide: theme.enabledBorder
      ),
      errorStyle: const TextStyle(height: 0),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: theme.borderRadius,
          borderSide: theme.errorBorder
      ),
      disabledBorder: OutlineInputBorder(
          borderRadius: theme.borderRadius,
          borderSide: theme.disabledBorder
      ),
      focusedBorder: OutlineInputBorder(
          borderRadius: theme.borderRadius,
          borderSide: theme.focusedBorder
      ),
    );
  }

}