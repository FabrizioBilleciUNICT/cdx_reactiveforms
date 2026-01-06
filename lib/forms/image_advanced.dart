import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'package:cdx_core/injector.dart';
import 'package:cdx_reactiveforms/forms/base_form.dart';
import 'package:cdx_reactiveforms/models/disposable.dart';
import 'package:cdx_reactiveforms/models/form_localizations.dart';
import 'package:cdx_reactiveforms/models/image_pipeline.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/types.dart';

/// Advanced ImageForm with modular pipeline support
/// Supports custom types (e.g., CloudImage) and full pipeline customization
class ImageFormAdvanced<T> extends BaseForm<T?, T?> with Disposable {
  final String? messageError;
  final List<String>? allowedFormats;
  final int? maxSizeBytes;
  final Future<File?> Function()? imagePicker;
  final double? imagePreviewHeight;
  final bool enableDragDrop;
  final T? _initialValue;
  
  // Pipeline callbacks
  final ImageLoadCallback? onLoad;
  final ImageProcessCallback? onProcess;
  final ImageUploadCallback<T>? onUpload;
  final ImageCompleteCallback<T>? onComplete;
  final ImageErrorCallback? onError;
  
  // Preview URL (for remote images like Firebase Storage downloadURL)
  final String? Function(T? value)? previewUrlExtractor;
  
  // State
  Uint8List? _imageBytes; // For local preview (web)
  String? _previewUrl; // For remote preview
  final ValueNotifier<bool> _processingNotifier = ValueNotifier(false);
  final ValueNotifier<double> _progressNotifier = ValueNotifier(0.0);

  ImageFormAdvanced({
    required super.hint,
    required super.label,
    super.type = FormsType.image,
    super.labelInfo,
    super.isRequired,
    super.editable = true,
    super.visible,
    required T? initialValue,
    this.messageError,
    this.allowedFormats,
    this.maxSizeBytes,
    this.imagePicker,
    this.imagePreviewHeight = 200.0,
    this.enableDragDrop = true,
    this.onLoad,
    this.onProcess,
    this.onUpload,
    this.onComplete,
    this.onError,
    this.previewUrlExtractor,
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
    _updatePreviewFromValue(initialValue);
  }

  void _updatePreviewFromValue(T? value) {
    if (value == null) {
      _previewUrl = null;
      _imageBytes = null;
      return;
    }
    
    // Extract preview URL if extractor is provided
    if (previewUrlExtractor != null) {
      _previewUrl = previewUrlExtractor!(value);
    }
    
    // If value is a String and looks like a URL, use it as preview
    if (value is String && (value.startsWith('http://') || value.startsWith('https://'))) {
      _previewUrl = value;
    }
  }

  @override
  T? inputTransform(T? input) {
    return input;
  }

  @override
  T? outputTransform(T? output) {
    return output;
  }

  @override
  T? currentValue() {
    return valueNotifier.value;
  }

  @override
  void changeValue(T? newValue) {
    valueNotifier.value = newValue;
    _updatePreviewFromValue(newValue);
    listener(newValue);
  }

  @override
  void clear() {
    valueNotifier.value = null;
    _imageBytes = null;
    _previewUrl = null;
    _processingNotifier.value = false;
    _progressNotifier.value = 0.0;
    listener(null);
  }

  @override
  void reset() {
    valueNotifier.value = _initialValue;
    _imageBytes = null;
    _updatePreviewFromValue(_initialValue);
    _processingNotifier.value = false;
    _progressNotifier.value = 0.0;
    listener(_initialValue);
  }

  /// Set image bytes for web preview
  void setImageBytes(Uint8List? bytes) {
    _imageBytes = bytes;
  }

  /// Set preview URL for remote images
  void setPreviewUrl(String? url) {
    _previewUrl = url;
  }

  Future<void> _executePipeline(ImageLoadResult loadedImage) async {
    if (!editable) return;

    try {
      _processingNotifier.value = true;
      _progressNotifier.value = 0.0;

      // Stage 1: onLoad (e.g., crop, edit)
      ImageLoadResult? processedLoad = loadedImage;
      if (onLoad != null) {
        processedLoad = await onLoad!(loadedImage);
        if (processedLoad == null) {
          // User cancelled or error in onLoad
          _processingNotifier.value = false;
          return;
        }
      }

      // Stage 2: onProcess (e.g., compress, resize, convert to WebP)
      ImageProcessResult? processedImage;
      if (onProcess != null) {
        processedImage = await onProcess!(processedLoad);
        if (processedImage == null) {
          // Processing cancelled or failed
          _processingNotifier.value = false;
          return;
        }
      } else {
        // No processing, create a basic result from loaded image
        if (processedLoad.bytes != null) {
          processedImage = ImageProcessResult(
            bytes: processedLoad.bytes!,
            mimeType: processedLoad.mimeType ?? 'image/jpeg',
            sizeBytes: processedLoad.sizeBytes ?? processedLoad.bytes!.length,
          );
        } else if (processedLoad.file != null && !kIsWeb) {
          final bytes = await processedLoad.file!.readAsBytes();
          processedImage = ImageProcessResult(
            bytes: bytes,
            mimeType: processedLoad.mimeType ?? 'image/jpeg',
            sizeBytes: bytes.length,
          );
        }
      }

      if (processedImage == null) {
        _processingNotifier.value = false;
        return;
      }

      // Store bytes for preview (web)
      if (kIsWeb) {
        _imageBytes = processedImage.bytes;
      }

      // Stage 3: onUpload (e.g., upload to Firebase Storage)
      T? uploadResult;
      if (onUpload != null) {
        final progressController = StreamController<UploadProgress>();
        progressController.stream.listen((progress) {
          _progressNotifier.value = progress.progress;
        });

        try {
          uploadResult = await onUpload!(processedImage, progressController);
          await progressController.close();
        } catch (e) {
          await progressController.close();
          rethrow;
        }
      }

      // Stage 4: onComplete (final processing)
      T? finalResult = uploadResult;
      if (onComplete != null) {
        finalResult = await onComplete!(processedLoad, processedImage, uploadResult);
      }

      // Update form value
      if (finalResult != null) {
        changeValue(finalResult);
      } else if (uploadResult != null) {
        changeValue(uploadResult);
      } else {
        // Fallback: use path or create a simple value
        if (processedLoad.path != null) {
          changeValue(processedLoad.path as T);
        }
      }

      _processingNotifier.value = false;
      _progressNotifier.value = 1.0;
    } catch (e, stackTrace) {
      _processingNotifier.value = false;
      _progressNotifier.value = 0.0;
      
      final loc = localizations ?? DefaultFormLocalizations();
      errorNotifier.value = '${loc.defaultErrorMessage}: $e';
      showError(true);
      
      if (onError != null) {
        onError!(e, stackTrace, 'pipeline');
      } else {
        errorLogger?.logError(type.toString(), label, e, stackTrace);
      }
    }
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

      // Validate file size (skip on web)
      int? fileSize;
      if (maxSizeBytes != null && !kIsWeb) {
        try {
          fileSize = await file.length();
          if (fileSize > maxSizeBytes!) {
            final maxSizeMB = maxSizeBytes! / (1024 * 1024);
            final loc = localizations ?? DefaultFormLocalizations();
            errorNotifier.value = loc.imageSizeErrorMessage(maxSizeMB);
            showError(true);
            return;
          }
        } catch (e) {
          // On web, skip size validation
        }
      }

      // Determine MIME type
      final mimeType = _getMimeType(file.path);

      // Create load result
      final loadResult = ImageLoadResult(
        file: file,
        path: file.path,
        mimeType: mimeType,
        sizeBytes: fileSize,
      );

      // Execute pipeline
      await _executePipeline(loadResult);
    } catch (e, stackTrace) {
      final loc = localizations ?? DefaultFormLocalizations();
      errorNotifier.value = '${loc.defaultErrorMessage}: $e';
      showError(true);
      
      if (onError != null) {
        onError!(e, stackTrace, 'file_handling');
      } else {
        errorLogger?.logError(type.toString(), label, e, stackTrace);
      }
    }
  }

  String _getMimeType(String path) {
    final extension = path.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'bmp':
        return 'image/bmp';
      default:
        return 'image/jpeg';
    }
  }

  @override
  void onTap(BuildContext context, TextEditingController controller) async {
    if (!editable || imagePicker == null) return;
    
    try {
      final file = await imagePicker!();
      if (file != null) {
        // On web, we might need to handle bytes separately
        // The imagePicker callback should handle this
        await _handleDroppedFile(file);
      }
    } catch (e, stackTrace) {
      final loc = localizations ?? DefaultFormLocalizations();
      errorNotifier.value = '${loc.defaultErrorMessage}: $e';
      showError(true);
      
      if (onError != null) {
        onError!(e, stackTrace, 'picker');
      } else {
        errorLogger?.logError(type.toString(), label, e, stackTrace);
      }
    }
  }

  @override
  bool validate(T? value) {
    if (!isRequired) return true;
    if (value == null) return false;
    
    // Custom validation can be done via isValid callback
    return isValid == null || isValid!(value);
  }

  @override
  String errorMessage(T? value) {
    return messageError ?? (localizations ?? DefaultFormLocalizations()).defaultErrorMessage;
  }

  Widget _buildPreview() {
    // Priority: 1. Remote URL, 2. Local bytes (web), 3. Local file, 4. Placeholder
    if (_previewUrl != null) {
      return Image.network(
        _previewUrl!,
        height: imagePreviewHeight,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: imagePreviewHeight,
            color: Colors.grey[300],
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: imagePreviewHeight,
            color: Colors.grey[300],
            child: const Center(
              child: Icon(Icons.error, color: Colors.red),
            ),
          );
        },
      );
    }

    if (kIsWeb && _imageBytes != null) {
      return Image.memory(
        _imageBytes!,
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
      );
    }

    final value = valueNotifier.value;
    if (value != null && value is String && !value.startsWith('http')) {
      if (!kIsWeb) {
        try {
          final file = File(value as String);
          if (file.existsSync()) {
            return Image.file(
              file,
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
            );
          }
        } catch (e) {
          // File doesn't exist or can't be read
        }
      }
    }

    // Placeholder
    return Container(
      height: imagePreviewHeight,
      width: double.infinity,
      color: Colors.grey[300],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.image, size: 48, color: Colors.grey),
            const SizedBox(height: 8),
            if (value != null)
              Text(
                value.toString().split('/').last,
                style: const TextStyle(color: Colors.grey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget buildInput(BuildContext context) {
    return ValueListenableBuilder<T?>(
      valueListenable: valueNotifier,
      builder: (context, value, child) {
        return ValueListenableBuilder<bool>(
          valueListenable: _processingNotifier,
          builder: (context, isProcessing, _) {
            return ValueListenableBuilder<double>(
              valueListenable: _progressNotifier,
              builder: (context, progress, __) {
                Widget content = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: editable && !isProcessing
                          ? () => onTap(context, TextEditingController())
                          : null,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isProcessing
                                ? DI.colors().primary
                                : theme.enabledBorder.color,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            if (isProcessing)
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  value: progress > 0 ? progress : null,
                                ),
                              )
                            else
                              Icon(
                                Icons.image,
                                color: DI.colors().primary,
                              ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isProcessing
                                        ? 'Processing... ${(progress * 100).toStringAsFixed(0)}%'
                                        : (value != null
                                            ? _getDisplayText(value)
                                            : hint),
                                    style: value != null && !isProcessing
                                        ? theme.textStyle
                                        : theme.textStyle.copyWith(color: Colors.grey),
                                  ),
                                  if (isProcessing && progress > 0)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: LinearProgressIndicator(
                                        value: progress,
                                        backgroundColor: Colors.grey[300],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (value != null && editable && !isProcessing)
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => clear(),
                                color: DI.colors().primary,
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (value != null || _imageBytes != null || _previewUrl != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _buildPreview(),
                        ),
                      ),
                  ],
                );

                // Wrap with drag&drop support if enabled
                if (enableDragDrop && editable && !isProcessing) {
                  return _DragDropWrapper(
                    onFileDropped: _handleDroppedFile,
                    child: content,
                  );
                }

                return content;
              },
            );
          },
        );
      },
    );
  }

  String _getDisplayText(T? value) {
    if (value == null) return '';
    if (value is String) {
      // If it's a URL, show just the filename or a friendly name
      if (value.startsWith('http://') || value.startsWith('https://')) {
        try {
          final uri = Uri.parse(value);
          final path = uri.path;
          if (path.isNotEmpty) {
            return path.split('/').last;
          }
        } catch (e) {
          // Invalid URL
        }
        return 'Remote image';
      }
      // Local file path
      return value.split('/').last;
    }
    return value.toString();
  }

  @override
  void dispose() {
    _processingNotifier.dispose();
    _progressNotifier.dispose();
  }
}

/// Internal widget wrapper for drag&drop visual feedback
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

