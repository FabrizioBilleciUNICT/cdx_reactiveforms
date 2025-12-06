
import 'dart:io';
import 'package:cdx_core/injector.dart';
import 'package:cdx_reactiveforms/forms/base_form.dart';
import 'package:cdx_reactiveforms/models/disposable.dart';
import 'package:cdx_reactiveforms/models/form_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/types.dart';

class FileForm extends BaseForm<String?, String?> with Disposable {
  final String? messageError;
  final List<String>? allowedExtensions;
  final int? maxSizeBytes;
  final Future<File?> Function()? filePicker;
  final bool enableDragDrop;
  final String? _initialValue;

  FileForm({
    required super.hint,
    required super.label,
    super.type = FormsType.custom,
    super.labelInfo,
    super.isRequired,
    super.editable = true,
    super.visible,
    required String? initialValue,
    this.messageError,
    this.allowedExtensions,
    this.maxSizeBytes,
    this.filePicker,
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

  @override
  void onTap(BuildContext context, TextEditingController controller) async {
    if (!editable || filePicker == null) return;
    
    try {
      final file = await filePicker!();
      if (file != null) {
        // Validate file extension
        if (allowedExtensions != null && allowedExtensions!.isNotEmpty) {
          final extension = file.path.split('.').last.toLowerCase();
          if (!allowedExtensions!.any((ext) => ext.toLowerCase() == extension)) {
            final loc = localizations ?? DefaultFormLocalizations();
            errorNotifier.value = loc.fileExtensionErrorMessage(allowedExtensions!);
            showError(true);
            return;
          }
        }
        
        // Validate file size (skip on web as File.length() doesn't work)
        if (maxSizeBytes != null && !kIsWeb) {
          try {
            final fileSize = await file.length();
            if (fileSize > maxSizeBytes!) {
              final maxSizeMB = maxSizeBytes! / (1024 * 1024);
              final loc = localizations ?? DefaultFormLocalizations();
              errorNotifier.value = loc.fileSizeErrorMessage(maxSizeMB);
              showError(true);
              return;
            }
          } catch (e) {
            // On web or if file doesn't exist, skip size validation
            // In a real app, you'd get size from PlatformFile.bytes.length
          }
        }
        
        // Use the file path
        // On web, this will be a temporary path created in the picker callback
        changeValue(file.path);
      }
    } catch (e) {
      errorNotifier.value = 'Error selecting file: $e';
      showError(true);
    }
  }

  @override
  bool validate(String? value) {
    if (!isRequired) return true;
    if (value == null || value.isEmpty) return false;
    
    // On web, file paths work differently - just check if value is not empty
    // On other platforms, check if file exists
    if (kIsWeb) {
      return isValid == null || isValid!(value);
    }
    
    // On web, skip file existence check (files are handled differently)
    if (kIsWeb || value.startsWith('/tmp/')) {
      return isValid == null || isValid!(value);
    }
    
    // Check if file exists (only on non-web platforms)
    try {
      final file = File(value);
      if (!file.existsSync()) {
        return false;
      }
    } catch (e) {
      // If File operations fail, assume invalid
      return false;
    }
    
    return isValid == null || isValid!(value);
  }

  @override
  String errorMessage(String? value) {
    return messageError ?? (localizations ?? DefaultFormLocalizations()).defaultErrorMessage;
  }

  Future<void> _handleDroppedFile(File file) async {
    if (!editable) return;

    try {
      // Validate file extension
      if (allowedExtensions != null && allowedExtensions!.isNotEmpty) {
        final extension = file.path.split('.').last.toLowerCase();
        if (!allowedExtensions!.any((ext) => ext.toLowerCase() == extension)) {
          final loc = localizations ?? DefaultFormLocalizations();
          errorNotifier.value = loc.fileExtensionErrorMessage(allowedExtensions!);
          showError(true);
          return;
        }
      }

      // Validate file size (skip on web as File.length() doesn't work)
      if (maxSizeBytes != null && !kIsWeb) {
        try {
          final fileSize = await file.length();
          if (fileSize > maxSizeBytes!) {
            final maxSizeMB = maxSizeBytes! / (1024 * 1024);
            final loc = localizations ?? DefaultFormLocalizations();
            errorNotifier.value = loc.fileSizeErrorMessage(maxSizeMB);
            showError(true);
            return;
          }
        } catch (e) {
          // On web or if file doesn't exist, skip size validation
          // In a real app, you'd get size from PlatformFile.bytes.length
        }
      }

      changeValue(file.path);
    } catch (e) {
      final loc = localizations ?? DefaultFormLocalizations();
      errorNotifier.value = '${loc.defaultErrorMessage}: $e';
      showError(true);
    }
  }

  @override
  Widget buildInput(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: valueNotifier,
      builder: (context, filePath, child) {
        Widget content = InkWell(
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
                  Icons.attach_file,
                  color: DI.colors().primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    filePath != null
                        ? filePath.split('/').last
                        : hint,
                    style: filePath != null
                        ? theme.textStyle
                        : theme.textStyle.copyWith(color: Colors.grey),
                  ),
                ),
                if (filePath != null && editable)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => clear(),
                    color: DI.colors().primary,
                  ),
              ],
            ),
          ),
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
    // No resources to dispose for FileForm
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

