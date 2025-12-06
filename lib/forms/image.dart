
import 'dart:io';
import 'package:cdx_core/injector.dart';
import 'package:cdx_reactiveforms/forms/base_form.dart';
import 'package:cdx_reactiveforms/models/disposable.dart';
import 'package:cdx_reactiveforms/models/form_localizations.dart';
import 'package:flutter/material.dart';
import '../models/types.dart';

class ImageForm extends BaseForm<String?, String?> with Disposable {
  final String? messageError;
  final List<String>? allowedFormats;
  final int? maxSizeBytes;
  final Future<File?> Function()? imagePicker;
  final double? imagePreviewHeight;
  final bool enableDragDrop;
  final String? _initialValue;

  ImageForm({
    required super.hint,
    required super.label,
    super.type = FormsType.image,
    super.labelInfo,
    super.isRequired,
    super.editable = true,
    super.visible,
    required String? initialValue,
    this.messageError,
    this.allowedFormats,
    this.maxSizeBytes,
    this.imagePicker,
    this.imagePreviewHeight = 200.0,
    this.enableDragDrop = true,
    super.errorMessageText,
    super.errorNotifier,
    super.showErrorNotifier,
    super.themeData,
    super.localizations,
    super.semanticsLabel,
    super.tooltip,
    super.hintText,
  }) : _initialValue = initialValue,
        super(
    minValue: null,
    maxValue: null,
  ) {
    valueNotifier.value = initialValue;
  }

  @override
  String? inputTransform(String? input) {
    return input;
  }

  @override
  String? outputTransform(String? output) {
    return output;
  }

  @override
  String? currentValue() {
    return valueNotifier.value;
  }

  @override
  void changeValue(String? newValue) {
    valueNotifier.value = newValue;
    listener(newValue);
  }

  @override
  void clear() {
    valueNotifier.value = null;
    listener(null);
  }

  @override
  void reset() {
    valueNotifier.value = _initialValue;
    listener(_initialValue);
  }

  Future<void> _handleDroppedFile(File file) async {
    if (!editable) return;

    try {
      // Validate image format
      final allowed = allowedFormats ?? ['jpg', 'jpeg', 'png', 'gif', 'webp'];
      final extension = file.path.split('.').last.toLowerCase();
      if (!allowed.any((format) => format.toLowerCase() == extension)) {
        final loc = localizations ?? DefaultFormLocalizations();
        errorNotifier.value = loc.imageFormatErrorMessage(allowed);
        showError(true);
        return;
      }

      // Validate file size
      if (maxSizeBytes != null) {
        final fileSize = await file.length();
        if (fileSize > maxSizeBytes!) {
          final maxSizeMB = maxSizeBytes! / (1024 * 1024);
          final loc = localizations ?? DefaultFormLocalizations();
          errorNotifier.value = loc.imageSizeErrorMessage(maxSizeMB);
          showError(true);
          return;
        }
      }

      changeValue(file.path);
    } catch (e, stackTrace) {
      final loc = localizations ?? DefaultFormLocalizations();
      errorNotifier.value = '${loc.defaultErrorMessage}: $e';
      showError(true);
      errorLogger?.logError(type.toString(), label, e, stackTrace);
    }
  }

  @override
  void onTap(BuildContext context, TextEditingController controller) async {
    if (!editable || imagePicker == null) return;
    
    try {
      final file = await imagePicker!();
      if (file != null) {
        await _handleDroppedFile(file);
      }
    } catch (e, stackTrace) {
      final loc = localizations ?? DefaultFormLocalizations();
      errorNotifier.value = '${loc.defaultErrorMessage}: $e';
      showError(true);
      errorLogger?.logError(type.toString(), label, e, stackTrace);
    }
  }

  @override
  bool validate(String? value) {
    if (!isRequired) return true;
    if (value == null || value.isEmpty) return false;
    
    // Check if file exists and is a valid image
    final file = File(value);
    if (!file.existsSync()) {
      return false;
    }
    
    // Basic image format check
    final extension = value.split('.').last.toLowerCase();
    final imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'];
    if (!imageExtensions.contains(extension)) {
      return false;
    }
    
    return isValid == null || isValid!(value);
  }

  @override
  String errorMessage(String? value) {
    return messageError ?? (localizations ?? DefaultFormLocalizations()).defaultErrorMessage;
  }

  @override
  Widget buildInput(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: valueNotifier,
      builder: (context, imagePath, child) {
        Widget content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: editable ? () => onTap(context, TextEditingController()) : null,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.enabledBorder.color),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.image,
                      color: DI.colors().primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        imagePath != null
                            ? imagePath.split('/').last
                            : hint,
                        style: imagePath != null
                            ? theme.textStyle
                            : theme.textStyle.copyWith(color: Colors.grey),
                      ),
                    ),
                    if (imagePath != null && editable)
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => clear(),
                        color: DI.colors().primary,
                      ),
                  ],
                ),
              ),
            ),
            if (imagePath != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(imagePath),
                    height: imagePreviewHeight,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: imagePreviewHeight,
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(Icons.error, color: Colors.red),
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        );

        // Wrap with drag&drop support if enabled
        if (enableDragDrop && editable) {
          return _DragDropWrapper(
            onFileDropped: _handleDroppedFile,
            child: content,
          );
        }

        return content;
      },
    );
  }

  @override
  void dispose() {
    // No resources to dispose for ImageForm
  }
}

/// Internal widget wrapper for drag&drop visual feedback
/// Note: Actual drag&drop implementation requires:
/// - For web: dart:html with HTML5 drag&drop events
/// - For desktop: platform channels or a library like 'desktop_drop'
class _DragDropWrapper extends StatefulWidget {
  final Widget child;
  final Function(File) onFileDropped;

  const _DragDropWrapper({
    required this.child,
    required this.onFileDropped,
  });

  @override
  State<_DragDropWrapper> createState() => _DragDropWrapperState();
}

class _DragDropWrapperState extends State<_DragDropWrapper> {
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        // Visual feedback when dragging over the area
        // Actual drop handling should be implemented in the application
        // using platform-specific code or libraries
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          border: _isDragging
              ? Border.all(color: DI.colors().primary, width: 2, style: BorderStyle.solid)
              : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: widget.child,
      ),
    );
  }

  /// Call this method from application code when a file is dropped
  /// Example for web (requires dart:html):
  /// ```dart
  /// import 'dart:html' as html;
  /// html.document.querySelector('#your-element')?.onDrop.listen((e) {
  ///   e.preventDefault();
  ///   final files = e.dataTransfer?.files;
  ///   if (files != null && files.isNotEmpty) {
  ///     final file = File(files[0].name);
  ///     wrapperState.handleDroppedFile(file);
  ///   }
  /// });
  /// ```
  void handleDroppedFile(File file) {
    widget.onFileDropped(file);
    if (mounted) {
      setState(() => _isDragging = false);
    }
  }

  void setDragging(bool dragging) {
    if (mounted) {
      setState(() => _isDragging = dragging);
    }
  }
}

