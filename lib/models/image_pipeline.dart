import 'dart:io';
import 'dart:typed_data';
import 'dart:async';

/// Represents the result of loading an image
class ImageLoadResult {
  final File? file;
  final Uint8List? bytes;
  final String? path;
  final String? mimeType;
  final int? sizeBytes;

  ImageLoadResult({
    this.file,
    this.bytes,
    this.path,
    this.mimeType,
    this.sizeBytes,
  });
}

/// Represents the result of compressing/processing an image
class ImageProcessResult {
  final Uint8List bytes;
  final String mimeType;
  final int sizeBytes;
  final Map<String, dynamic>? metadata; // e.g., width, height, format

  ImageProcessResult({
    required this.bytes,
    required this.mimeType,
    required this.sizeBytes,
    this.metadata,
  });
}

/// Represents upload progress
class UploadProgress {
  final int bytesSent;
  final int totalBytes;
  final double progress; // 0.0 to 1.0

  UploadProgress({
    required this.bytesSent,
    required this.totalBytes,
  }) : progress = totalBytes > 0 ? bytesSent / totalBytes : 0.0;
}

/// Callback for when an image is loaded (e.g., from picker or drag&drop)
/// Return the processed image or null to cancel
typedef ImageLoadCallback = Future<ImageLoadResult?> Function(ImageLoadResult loadedImage);

/// Callback for processing/compressing an image
/// Return the processed image bytes and metadata
typedef ImageProcessCallback = Future<ImageProcessResult?> Function(ImageLoadResult loadedImage);

/// Callback for uploading an image
/// Return the upload result (e.g., path, downloadURL, etc.)
/// Progress updates are sent via the progressStream
typedef ImageUploadCallback<T> = Future<T?> Function(
  ImageProcessResult processedImage,
  StreamController<UploadProgress> progressController,
);

/// Callback for when the entire pipeline completes
/// The result is what will be stored in the form value
typedef ImageCompleteCallback<T> = Future<T?> Function(
  ImageLoadResult? loadedImage,
  ImageProcessResult? processedImage,
  T? uploadResult,
);

/// Callback for handling errors during the pipeline
typedef ImageErrorCallback = void Function(Object error, StackTrace stackTrace, String stage);

