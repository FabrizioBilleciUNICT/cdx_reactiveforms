import 'package:cdx_core/core/models/input_theme_data.dart';
import 'package:cdx_core/core/models/color_set.dart';
import 'package:cdx_core/core/models/button_theme_data.dart';
import 'package:cdx_core/core/services/app/itheme_service.dart';
import 'package:cdx_core/app/theme.dart';
import 'package:cdx_core/injector.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';

/// Setup mock services for testing
void setupTestServices() {
  final getIt = GetIt.instance;
  
  // Register mock IThemeService if not already registered
  if (!getIt.isRegistered<IThemeService>()) {
    getIt.registerSingleton<IThemeService>(_MockThemeService());
  }
}

class _MockThemeService extends IThemeService {
  _MockThemeService() : super(theme: _MockTheme()) {
    setTheme(ThemeType.light);
  }

  @override
  ThemeData get themeData => ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      );

  @override
  CdxButtonThemeData get buttonTheme => CdxButtonThemeData(
        containerHeight: 50,
        contentPadding: const EdgeInsets.all(16),
        containerPadding: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
        textStyle: const TextStyle(fontSize: 16),
        iconColor: Colors.blue,
        borderWidth: 1,
      );

  @override
  CdxInputThemeData get inputTheme => CdxInputThemeData(
        labelPadding: const EdgeInsets.all(8),
        contentPadding: const EdgeInsets.all(16),
        containerPadding: const EdgeInsets.all(8),
        containerHeight: 50,
        backgroundColor: Colors.white,
        disabledBackgroundColor: Colors.grey.shade200,
        cursorColor: Colors.blue,
        iconColor: Colors.blue,
        textStyle: const TextStyle(color: Colors.black87, fontSize: 16),
        hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 16),
        labelTextStyle: const TextStyle(
          color: Colors.black87,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        errorTextStyle: const TextStyle(
          color: Colors.red,
          fontSize: 12,
        ),
        borderRadius: BorderRadius.circular(8),
        enabledBorder: BorderSide(color: Colors.grey.shade400, width: 1),
        focusedBorder: const BorderSide(color: Colors.blue, width: 2),
        errorBorder: const BorderSide(color: Colors.red, width: 2),
        disabledBorder: BorderSide(color: Colors.grey.shade300, width: 1),
        outlinedLabel: false,
      );
}

class _MockTheme implements ITheme {
  @override
  final Map<ScreenType, ScreenPadding> paddings = {
    ScreenType.mobile: ScreenPadding(
      card: EdgeInsets.all(16),
      internalCard: EdgeInsets.all(8),
      smallCard: EdgeInsets.all(12),
      internalSmallCard: EdgeInsets.all(6),
      page: EdgeInsets.all(20),
      form: EdgeInsets.all(16),
      title: EdgeInsets.all(16),
    ),
  };

  @override
  final Map<ScreenType, ScreenRadius> radius = {
    ScreenType.mobile: ScreenRadius(
      card: BorderRadius.circular(12),
      smallCard: BorderRadius.circular(8),
    ),
  };

  @override
  final Map<ScreenType, ButtonMeasures> button = {
    ScreenType.mobile: ButtonMeasures(
      containerHeight: 50,
      fontSize: 16,
      contentPadding: EdgeInsets.symmetric(horizontal: 16),
      containerPadding: EdgeInsets.all(8),
      borderRadius: 8,
      borderWidth: 1,
    ),
  };

  @override
  final Map<ScreenType, InputMeasures> input = {
    ScreenType.mobile: InputMeasures(
      containerHeight: 50,
      fontSize: 16,
      contentPadding: EdgeInsets.symmetric(horizontal: 16),
      containerPadding: EdgeInsets.all(8),
      labelPadding: EdgeInsets.all(8),
      borderRadius: 8,
      borderWidth: 1,
    ),
  };

  @override
  final Map<ScreenType, TextMeasures> text = {
    ScreenType.mobile: TextMeasures(
      titleSize: 24,
      subtitleSize: 18,
      textSize: 16,
      minorTextSize: 12,
    ),
  };

  @override
  final Map<ScreenType, MiscMeasures> misc = {
    ScreenType.mobile: _MockMiscMeasures(),
  };

  @override
  final String fontFamilyBold = 'RobotoBold';

  @override
  final String fontFamily = 'Roboto';

  @override
  final ColorSet light = ColorSet(
    mainText: Colors.black87,
    minorText: Colors.grey.shade600,
    subtext: Colors.grey.shade400,
    mainBackground: Colors.white,
    minorBackground: Colors.grey.shade100,
    mainDetails: Colors.blue.shade700,
    minorDetails: Colors.blue.shade300,
    shadow: Colors.black.withOpacity(0.1),
    accent: Colors.orange,
    primary: Colors.blue,
    dark: Colors.black,
    error: Colors.red,
    disabledText: Colors.grey.shade500,
    disabledBackground: Colors.grey.shade200,
    disabledPrimary: Colors.blue.shade100,
    textOnPrimary: Colors.white,
    textOnAccent: Colors.white,
    textOnDark: Colors.white,
    textOnError: Colors.white,
  );

  @override
  final ColorSet dark = ColorSet(
    mainText: Colors.white,
    minorText: Colors.grey.shade400,
    subtext: Colors.grey.shade600,
    mainBackground: Colors.grey.shade900,
    minorBackground: Colors.grey.shade800,
    mainDetails: Colors.blue.shade300,
    minorDetails: Colors.blue.shade700,
    shadow: Colors.black.withOpacity(0.5),
    accent: Colors.orange.shade300,
    primary: Colors.blue.shade700,
    dark: Colors.white,
    error: Colors.red.shade300,
    disabledText: Colors.grey.shade600,
    disabledBackground: Colors.grey.shade700,
    disabledPrimary: Colors.blue.shade900,
    textOnPrimary: Colors.black87,
    textOnAccent: Colors.black87,
    textOnDark: Colors.black87,
    textOnError: Colors.black87,
  );
}

class _MockMiscMeasures extends MiscMeasures {
  _MockMiscMeasures() : super(maxContentWidth: 1200);

  @override
  BoxConstraints bottomSheetConstraints(BuildContext context) {
    return BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.9,
      maxWidth: double.infinity,
    );
  }
}

