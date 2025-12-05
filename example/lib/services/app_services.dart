import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:cdx_core/app/components.dart';
import 'package:cdx_core/app/constants.dart';
import 'package:cdx_core/app/mappings.dart';
import 'package:cdx_core/app/theme.dart';
import 'package:cdx_core/core/models/button_theme_data.dart';
import 'package:cdx_core/core/models/color_set.dart';
import 'package:cdx_core/core/models/input_theme_data.dart';
import 'package:cdx_core/core/models/pic_data_wrapper.dart';
import 'package:cdx_core/core/models/result.dart';
import 'package:cdx_core/core/models/text_data.dart';
import 'package:cdx_core/core/models/widget_size.dart';
import 'package:cdx_core/core/services/app/iapp_service.dart';
import 'package:cdx_core/core/services/app/ievent_service.dart';
import 'package:cdx_core/core/services/app/imedia_service.dart';
import 'package:cdx_core/core/services/app/itheme_service.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class AppMappings extends Mappings {}

class AppComponents extends Components {}

class AppConstants extends Constants {
  AppConstants()
      : super(
          appName: 'CDX Reactive Forms Example',
          locale: 'en',
          locales: {'en': 'English'},
          localeCountryCode: 'US',
          supportedCountryCodes: ['US'],
          baseUrl: 'https://example.com',
          contacts: 'contact@example.com',
          termsConditions: 'https://example.com/terms',
          privacyPolicy: 'https://example.com/privacy',
          cookiePolicy: 'https://example.com/cookies',
          appStoreApp: '',
          playStoreApp: '',
          placeholder: 'placeholder',
        );
}

class AppTheme extends ITheme {
  AppTheme()
      : super(
          paddings: {
            ScreenType.mobile: const ScreenPadding(
              card: EdgeInsets.all(16),
              internalCard: EdgeInsets.all(12),
              smallCard: EdgeInsets.all(8),
              internalSmallCard: EdgeInsets.all(6),
              page: EdgeInsets.all(16),
              form: EdgeInsets.all(16),
              title: EdgeInsets.all(8),
            ),
          },
          radius: {
            ScreenType.mobile: const ScreenRadius(
              card: BorderRadius.all(Radius.circular(8)),
              smallCard: BorderRadius.all(Radius.circular(4)),
            ),
          },
          button: {
            ScreenType.mobile: const ButtonMeasures(
              containerHeight: 50,
              fontSize: 16,
              contentPadding: EdgeInsets.all(16),
              containerPadding: EdgeInsets.all(8),
              borderRadius: 8,
              borderWidth: 1,
            ),
          },
          input: {
            ScreenType.mobile: const InputMeasures(
              containerHeight: 50,
              fontSize: 16,
              contentPadding: EdgeInsets.all(16),
              containerPadding: EdgeInsets.all(8),
              labelPadding: EdgeInsets.all(8),
              borderRadius: 8,
              borderWidth: 1,
            ),
          },
          text: {
            ScreenType.mobile: const TextMeasures(
              titleSize: 24,
              subtitleSize: 20,
              textSize: 16,
              minorTextSize: 14,
            ),
          },
          misc: {
            ScreenType.mobile: _AppMiscMeasures(),
          },
          fontFamily: 'Roboto',
          fontFamilyBold: 'Roboto',
          light: const ColorSet(
            mainText: Color(0xFF000000),
            minorText: Color(0xFF666666),
            subtext: Color(0xFF999999),
            mainBackground: Color(0xFFFFFFFF),
            minorBackground: Color(0xFFF5F5F5),
            mainDetails: Color(0xFFE0E0E0),
            minorDetails: Color(0xFFF0F0F0),
            shadow: Color(0x1A000000),
            accent: Color(0xFF2196F3),
            primary: Color(0xFF2196F3),
            dark: Color(0xFF000000),
            error: Color(0xFFE53935),
            disabledText: Color(0xFFBDBDBD),
            disabledBackground: Color(0xFFE0E0E0),
            disabledPrimary: Color(0xFFBBDEFB),
            textOnPrimary: Color(0xFFFFFFFF),
            textOnAccent: Color(0xFFFFFFFF),
            textOnDark: Color(0xFFFFFFFF),
            textOnError: Color(0xFFFFFFFF),
          ),
          dark: const ColorSet(
            mainText: Color(0xFFFFFFFF),
            minorText: Color(0xFFBDBDBD),
            subtext: Color(0xFF757575),
            mainBackground: Color(0xFF121212),
            minorBackground: Color(0xFF1E1E1E),
            mainDetails: Color(0xFF2C2C2C),
            minorDetails: Color(0xFF242424),
            shadow: Color(0x40000000),
            accent: Color(0xFF64B5F6),
            primary: Color(0xFF64B5F6),
            dark: Color(0xFF000000),
            error: Color(0xFFEF5350),
            disabledText: Color(0xFF616161),
            disabledBackground: Color(0xFF2C2C2C),
            disabledPrimary: Color(0xFF1565C0),
            textOnPrimary: Color(0xFFFFFFFF),
            textOnAccent: Color(0xFFFFFFFF),
            textOnDark: Color(0xFFFFFFFF),
            textOnError: Color(0xFFFFFFFF),
          ),
        );
}

class _AppMiscMeasures extends MiscMeasures {
  _AppMiscMeasures() : super(maxContentWidth: 1200);

  @override
  BoxConstraints bottomSheetConstraints(BuildContext context) {
    return BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.9,
      maxWidth: double.infinity,
    );
  }
}

class AppThemeService extends IThemeService {
  AppThemeService() : super(theme: AppTheme()) {
    setTheme(ThemeType.light);
  }

  @override
  ThemeData get themeData => ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
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
}

class EventService extends IEventService {}

class MediaService implements IMediaService {
  @override
  Future<Uint8List?> getImage(String id, {bool forceDownload = false}) async {
    return null;
  }

  @override
  StreamSubscription getPicSubscription(
    String realId,
    BehaviorSubject imageSbj, {
    bool forceDownload = false,
  }) {
    return const Stream.empty().listen((_) {});
  }

  @override
  Future<File?> pickImage<Source>(Source source) async {
    return null;
  }

  @override
  Future<Result<int, String, String?>> uploadImage({
    required BehaviorSubject<PicDataWrapper> imageSbj,
    required String kind,
    required String id,
  }) async {
    return Result(code: 500, message: 'Not implemented');
  }

  @override
  Future<Uint8List> compressImage(Uint8List list) async {
    return list;
  }

  @override
  Future<File?> pickDocument() async {
    return null;
  }

  @override
  Future<void> downloadFile(String fileName, Uint8List bytes) async {}
}

class AppService extends IAppService {
  AppService({
    required super.components,
    required super.constants,
    required super.mappings,
  });

  @override
  String get prefix => 'example';

  @override
  Widget asset(String icon, {required WidgetSize size, Color? color, BoxFit fit = BoxFit.contain}) {
    return const SizedBox();
  }

  @override
  Widget themedAsset(String icon, {required WidgetSize size, Color? color, BoxFit fit = BoxFit.contain}) {
    return const SizedBox();
  }

  @override
  Text normal6(String title, {TextData? data}) => Text(title);
  @override
  Text normal8(String title, {TextData? data}) => Text(title);
  @override
  Text normal10(String title, {TextData? data}) => Text(title);
  @override
  Text normal12(String title, {TextData? data}) => Text(title);
  @override
  Text normal13(String title, {TextData? data}) => Text(title);
  @override
  Text normal14(String title, {TextData? data}) => Text(title);
  @override
  Text normal15(String title, {TextData? data}) => Text(title);
  @override
  Text normal16(String title, {TextData? data}) => Text(title);
  @override
  Text normal18(String title, {TextData? data}) => Text(title);
  @override
  Text normal20(String title, {TextData? data}) => Text(title);
  @override
  Text normal22(String title, {TextData? data}) => Text(title);
  @override
  Text normal24(String title, {TextData? data}) => Text(title);
  @override
  Text normal26(String title, {TextData? data}) => Text(title);
  @override
  Text normal28(String title, {TextData? data}) => Text(title);
  @override
  Text normal30(String title, {TextData? data}) => Text(title);
  @override
  Text normal32(String title, {TextData? data}) => Text(title);
  @override
  Text normal34(String title, {TextData? data}) => Text(title);
  @override
  Text normal36(String title, {TextData? data}) => Text(title);

  @override
  Text bold10(String title, {TextData? data}) => Text(title);
  @override
  Text bold12(String title, {TextData? data}) => Text(title);
  @override
  Text bold13(String title, {TextData? data}) => Text(title);
  @override
  Text bold14(String title, {TextData? data}) => Text(title);
  @override
  Text bold15(String title, {TextData? data}) => Text(title);
  @override
  Text bold16(String title, {TextData? data}) => Text(title);
  @override
  Text bold18(String title, {TextData? data}) => Text(title);
  @override
  Text bold20(String title, {TextData? data}) => Text(title);
  @override
  Text bold22(String title, {TextData? data}) => Text(title);
  @override
  Text bold24(String title, {TextData? data}) => Text(title);
  @override
  Text bold26(String title, {TextData? data}) => Text(title);
  @override
  Text bold28(String title, {TextData? data}) => Text(title);
  @override
  Text bold30(String title, {TextData? data}) => Text(title);
  @override
  Text bold32(String title, {TextData? data}) => Text(title);
  @override
  Text bold34(String title, {TextData? data}) => Text(title);
  @override
  Text bold36(String title, {TextData? data}) => Text(title);

  @override
  void openDialog(BuildContext context, Widget child) {}

  @override
  void openBottomSheet(BuildContext context, Widget child) {}

  @override
  void showInfoSnackbar(BuildContext context, String message) {}

  @override
  void showErrorSnackbar(BuildContext context, String message) {}

  @override
  void openConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmText,
    required String cancelText,
    required Function(bool) confirm,
    Widget? messageWidget,
  }) {}

  @override
  void openAlertDialog(
    BuildContext context,
    String title,
    String message,
    String ok,
    String cancel,
    void Function(bool confirm, BuildContext context) callback,
  ) {}

  @override
  Future<T?> openFutureDialog<T>(
    BuildContext context,
    Widget Function(BuildContext context) callback, {
    required EdgeInsets insetPadding,
  }) async {
    return null;
  }
}
