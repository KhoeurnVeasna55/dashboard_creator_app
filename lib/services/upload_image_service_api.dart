import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dashboard_admin/core/utils/header_util.dart';
import 'package:dashboard_admin/models/image_model.dart';
import 'package:dashboard_admin/services/store_token.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../core/URL/url.dart';

// --- SERVICE CLASS ---
class UploadService {
  UploadService._();

  static const String _singleUploadEndpoint = '/api/uploads';
  static const String _multipleUploadEndpoint = '/api/uploads/many';
  static const String _fileFieldKey = 'file';
  static const String _filesFieldKey = 'files';
  static const String _folderFieldKey = 'folder';

  static Future<CloudinaryResponse?> uploadSingleImage({
    File? imageFile,
    Uint8List? imageBytes,
    String? fileName,
    String? folder,
    Map<String, String>? additionalFields,
  }) async {
    final uri = Uri.parse('$URL$_singleUploadEndpoint');
    final request = http.MultipartRequest('POST', uri);

    try {
      final token = await StoreToken().getToken();
      final headers = header(token: token ?? "");
      request.headers.addAll(headers);

      request.fields[_folderFieldKey] = folder ?? 'products';

      if (additionalFields != null) {
        request.fields.addAll(additionalFields);
      }

      // Add file based on platform
      if (kIsWeb && imageBytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            _fileFieldKey,
            imageBytes,
            filename:
                fileName ??
                'image-${DateTime.now().millisecondsSinceEpoch}.png',
            contentType: MediaType('image', 'png'),
          ),
        );
      } else if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            _fileFieldKey,
            imageFile.path,
          ), // Used constant
        );
      } else {
        throw const UploadException('No image provided');
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(responseBody);
        final cloudinaryResponse = CloudinaryResponse.fromJson(data);
        log('Upload successful! URL: ${cloudinaryResponse.url}');
        return cloudinaryResponse;
      } else {
        final errorData = json.decode(responseBody);
        throw UploadException(
          errorData['message'] ??
              'Upload failed with status ${response.statusCode}',
        );
      }
      // --- 🚀 CHANGE 2: REFINED ERROR HANDLING ---
    } on UploadException {
      rethrow; // Keep custom exceptions as they are
    } on SocketException catch (e) {
      log('Network error (SocketException): $e');
      throw const UploadException('Please check your network connection.');
    } on FormatException catch (e) {
      log('Error parsing server response: $e');
      throw const UploadException('Invalid response from server.');
    } catch (e) {
      log('Error uploading single image: $e');
      throw UploadException('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Uploads multiple images.
  static Future<List<CloudinaryResponse>> uploadMultipleImages({
    List<File>? imageFiles,
    List<Uint8List>? imageBytesList,
    List<String>? fileNames,
    String folder = 'products',
    Map<String, String>? additionalFields,
  }) async {
    final uri = Uri.parse('$URL$_multipleUploadEndpoint');
    final request = http.MultipartRequest('POST', uri);

    try {
      final token = await StoreToken().getToken();
      final headers = header(token: token ?? "");
      request.headers.addAll(headers);

      request.fields[_folderFieldKey] = folder;

      if (additionalFields != null) {
        request.fields.addAll(additionalFields);
      }

      // Add files based on platform
      if (kIsWeb && imageBytesList != null && imageBytesList.isNotEmpty) {
        for (int i = 0; i < imageBytesList.length; i++) {
          request.files.add(
            http.MultipartFile.fromBytes(
              _filesFieldKey, // Used constant
              imageBytesList[i],
              filename:
                  fileNames?[i] ??
                  'image-$i-${DateTime.now().millisecondsSinceEpoch}.png',
              contentType: MediaType('image', 'png'),
            ),
          );
        }
      } else if (imageFiles != null && imageFiles.isNotEmpty) {
        for (final file in imageFiles) {
          request.files.add(
            await http.MultipartFile.fromPath(
              _filesFieldKey,
              file.path,
            ), // Used constant
          );
        }
      } else {
        throw const UploadException('No images provided');
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(responseBody);
        List<CloudinaryResponse> cloudinaryResponses = [];

        if (data is List) {
          cloudinaryResponses = data
              .map((item) => CloudinaryResponse.fromJson(item))
              .toList();
        } else if (data['images'] is List) {
          cloudinaryResponses = (data['images'] as List)
              .map((item) => CloudinaryResponse.fromJson(item))
              .toList();
        } else if (data['results'] is List) {
          cloudinaryResponses = (data['results'] as List)
              .map((item) => CloudinaryResponse.fromJson(item))
              .toList();
        } else {
          throw const UploadException(
            'Unexpected response format for multiple images',
          );
        }
        return cloudinaryResponses;
      } else {
        final errorData = json.decode(responseBody);
        throw UploadException(
          errorData['message'] ??
              'Upload failed with status ${response.statusCode}',
        );
      }
      // --- 🚀 CHANGE 2: REFINED ERROR HANDLING ---
    } on UploadException {
      rethrow;
    } on SocketException catch (e) {
      log('Network error (SocketException): $e');
      throw const UploadException('Please check your network connection.');
    } on FormatException catch (e) {
      log('Error parsing server response: $e');
      throw const UploadException('Invalid response from server.');
    } catch (e) {
      log('Error uploading multiple images: $e');
      throw UploadException('An unexpected error occurred: ${e.toString()}');
    }
  }

  // --- No changes needed in the helper and validation methods below ---
  static String? getUrlFromResponse(CloudinaryResponse? response) {
    return response?.url;
  }

  static Future<CloudinaryResponse?> uploadSingleImageWithValidation({
    File? imageFile,
    Uint8List? imageBytes,
    String? fileName,
    String folder = 'products',
    int maxSizeMB = 10,
    Map<String, String>? additionalFields,
  }) async {
    if (imageBytes != null) {
      if (!isValidFileSize(imageBytes.length, maxSizeMB: maxSizeMB)) {
        throw UploadException('File size exceeds ${maxSizeMB}MB limit');
      }
    } else if (imageFile != null) {
      final fileSize = await imageFile.length();
      if (!isValidFileSize(fileSize, maxSizeMB: maxSizeMB)) {
        throw UploadException('File size exceeds ${maxSizeMB}MB limit');
      }
    }

    if (fileName != null && !isValidImageExtension(fileName)) {
      throw const UploadException(
        'Invalid image format. Please use JPG, PNG, GIF, or WebP',
      );
    }

    return uploadSingleImage(
      imageFile: imageFile,
      imageBytes: imageBytes,
      fileName: fileName,
      folder: folder,
      additionalFields: additionalFields,
    );
  }

  static Future<List<CloudinaryResponse>> uploadMultipleImagesWithValidation({
    List<File>? imageFiles,
    List<Uint8List>? imageBytesList,
    List<String>? fileNames,
    String folder = 'products',
    int maxSizeMB = 10,
    int maxFileCount = 10,
    Map<String, String>? additionalFields,
  }) async {
    final fileCount = imageFiles?.length ?? imageBytesList?.length ?? 0;
    if (fileCount > maxFileCount) {
      throw UploadException(
        'Too many files. Maximum $maxFileCount files allowed',
      );
    }
    // (Validation logic remains the same)
    if (imageBytesList != null) {
      for (int i = 0; i < imageBytesList.length; i++) {
        if (!isValidFileSize(imageBytesList[i].length, maxSizeMB: maxSizeMB)) {
          throw UploadException('File ${i + 1} exceeds ${maxSizeMB}MB limit');
        }
        if (fileNames != null &&
            fileNames.length > i &&
            !isValidImageExtension(fileNames[i])) {
          throw UploadException('File ${i + 1} has invalid format');
        }
      }
    }
    if (imageFiles != null) {
      for (int i = 0; i < imageFiles.length; i++) {
        final fileSize = await imageFiles[i].length();
        if (!isValidFileSize(fileSize, maxSizeMB: maxSizeMB)) {
          throw UploadException('File ${i + 1} exceeds ${maxSizeMB}MB limit');
        }
        if (!isValidImageExtension(imageFiles[i].path)) {
          throw UploadException('File ${i + 1} has invalid format');
        }
      }
    }

    return uploadMultipleImages(
      imageFiles: imageFiles,
      imageBytesList: imageBytesList,
      fileNames: fileNames,
      folder: folder,
      additionalFields: additionalFields,
    );
  }

  static String getFileExtension(String filename) {
    try {
      return '.${filename.split('.').last}';
    } catch (_) {
      return '.jpg'; // Default extension
    }
  }

  static String generateUniqueFileName(String? originalName, String prefix) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = originalName != null
        ? getFileExtension(originalName)
        : '.jpg';
    return '$prefix-$timestamp$extension';
  }

  static bool isValidFileSize(int sizeInBytes, {int maxSizeMB = 10}) {
    final maxSizeBytes = maxSizeMB * 1024 * 1024;
    return sizeInBytes <= maxSizeBytes;
  }

  static bool isValidImageExtension(String filename) {
    final validExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp'];
    final extension = getFileExtension(filename).toLowerCase();
    return validExtensions.contains(extension);
  }
}

// --- SUPPORTING CLASSES (No changes needed) ---
class UploadException implements Exception {
  final String message;
  const UploadException(this.message);
  @override
  String toString() => 'UploadException: $message';
}

class UploadResult<T> {
  final T? data;
  final String? error;
  final bool isSuccess;
  const UploadResult.success(this.data) : error = null, isSuccess = true;
  const UploadResult.error(this.error) : data = null, isSuccess = false;
}

class SafeUploadService {
  static Future<UploadResult<CloudinaryResponse?>> uploadSingleImageSafe({
    File? imageFile,
    Uint8List? imageBytes,
    String? fileName,
    String folder = 'products',
    int maxSizeMB = 10,
    Map<String, String>? additionalFields,
  }) async {
    try {
      final result = await UploadService.uploadSingleImageWithValidation(
        imageFile: imageFile,
        imageBytes: imageBytes,
        fileName: fileName,
        folder: folder,
        maxSizeMB: maxSizeMB,
        additionalFields: additionalFields,
      );
      return UploadResult.success(result);
    } catch (e) {
      return UploadResult.error(e.toString());
    }
  }

  static Future<UploadResult<List<CloudinaryResponse>>>
  uploadMultipleImagesSafe({
    List<File>? imageFiles,
    List<Uint8List>? imageBytesList,
    List<String>? fileNames,
    String folder = 'products',
    int maxSizeMB = 10,
    int maxFileCount = 10,
    Map<String, String>? additionalFields,
  }) async {
    try {
      final result = await UploadService.uploadMultipleImagesWithValidation(
        imageFiles: imageFiles,
        imageBytesList: imageBytesList,
        fileNames: fileNames,
        folder: folder,
        maxSizeMB: maxSizeMB,
        maxFileCount: maxFileCount,
        additionalFields: additionalFields,
      );
      return UploadResult.success(result);
    } catch (e) {
      return UploadResult.error(e.toString());
    }
  }
}
