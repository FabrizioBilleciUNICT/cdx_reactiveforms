import 'dart:io';
import 'package:cdx_reactiveforms/forms/image_advanced.dart';
import '../models/types.dart';

/// Simple ImageForm for basic use cases (backward compatible)
/// For advanced features, use ImageFormAdvanced<T> directly
class ImageForm extends ImageFormAdvanced<String> {
  ImageForm({
    required super.hint,
    required super.label,
    super.type = FormsType.image,
    super.labelInfo,
    super.isRequired,
    super.editable = true,
    super.visible,
    required String? initialValue,
    String? messageError,
    List<String>? allowedFormats,
    int? maxSizeBytes,
    Future<File?> Function()? imagePicker,
    double? imagePreviewHeight = 200.0,
    bool enableDragDrop = true,
    super.errorMessageText,
    super.errorNotifier,
    super.showErrorNotifier,
    super.themeData,
    super.localizations,
    super.semanticsLabel,
    super.tooltip,
    super.hintText,
    super.onLoad,
    super.onProcess,
    super.onUpload,
    super.onComplete,
    super.onError,
    super.previewUrlExtractor,
  }) : super(
    initialValue: initialValue,
    allowedFormats: allowedFormats,
    maxSizeBytes: maxSizeBytes,
    imagePicker: imagePicker,
    imagePreviewHeight: imagePreviewHeight,
    enableDragDrop: enableDragDrop,
  );
}
