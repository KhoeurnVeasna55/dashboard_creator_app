import 'dart:developer';
import 'dart:io';
import 'package:dashboard_admin/models/image_model.dart';
import 'package:dashboard_admin/services/upload_image_service_api.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class CloudinaryImageController extends GetxController {
  final imageFiles = <File>[].obs;
  final imageBytesList = <Uint8List>[].obs;
  final imageNames = <String>[].obs;
  final uploadedImages = <CloudinaryResponse>[].obs;
  final uploadedUrls = <String>[].obs; // Kept for backward compatibility
  final isUploading = false.obs;
  final uploadProgress = 0.0.obs;

  final ImagePicker _picker = ImagePicker();

  void clearImages() {
    imageFiles.clear();
    imageBytesList.clear();
    imageNames.clear();
    uploadedImages.clear();
    uploadedUrls.clear();
  }

  void removeImageAt(int index) {
    if (kIsWeb) {
      if (index < imageBytesList.length) {
        imageBytesList.removeAt(index);
        imageNames.removeAt(index);
      }
    } else {
      if (index < imageFiles.length) {
        imageFiles.removeAt(index);
      }
    }

    if (index < uploadedImages.length) {
      uploadedImages.removeAt(index);
    }

    if (index < uploadedUrls.length) {
      uploadedUrls.removeAt(index);
    }
  }

  Future<void> pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      clearImages();
      if (kIsWeb) {
        imageBytesList.add(await pickedFile.readAsBytes());
        imageNames.add(pickedFile.name);
      } else {
        imageFiles.add(File(pickedFile.path));
      }
    }
  }

  Future<void> pickMultipleImages() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage();

    if (pickedFiles.isNotEmpty) {
      clearImages();
      for (var file in pickedFiles) {
        if (kIsWeb) {
          imageBytesList.add(await file.readAsBytes());
          imageNames.add(file.name);
        } else {
          imageFiles.add(File(file.path));
        }
      }
    }
  }

  /// Upload multiple images and return CloudinaryResponse objects
  Future<List<CloudinaryResponse>> uploadToCloudinary({String? folder}) async {
    if ((kIsWeb && imageBytesList.isEmpty) || (!kIsWeb && imageFiles.isEmpty)) {
      throw Exception('No images to upload');
    }

    isUploading.value = true;
    uploadProgress.value = 0.0;

    try {
      List<CloudinaryResponse> cloudinaryResponses =
          await UploadService.uploadMultipleImages(
            imageFiles: kIsWeb ? null : imageFiles,
            imageBytesList: kIsWeb ? imageBytesList : null,
            fileNames: kIsWeb ? imageNames : null,
            folder: folder ?? 'products',
          );

      uploadedImages.assignAll(cloudinaryResponses);

      uploadedUrls.assignAll(
        cloudinaryResponses.map((response) => response.url).toList(),
      );

      uploadProgress.value = 1.0;
      return cloudinaryResponses;
    } catch (e) {
      rethrow;
    } finally {
      isUploading.value = false;
    }
  }

  Future<CloudinaryResponse?> uploadSingleImage({String? folder}) async {
    if ((kIsWeb && imageBytesList.isEmpty) || (!kIsWeb && imageFiles.isEmpty)) {
      return null;
    }

    isUploading.value = true;

    try {
      CloudinaryResponse? cloudinaryResponse =
          await UploadService.uploadSingleImage(
            imageFile: kIsWeb
                ? null
                : (imageFiles.isNotEmpty ? imageFiles.first : null),
            imageBytes: kIsWeb && imageBytesList.isNotEmpty
                ? imageBytesList.first
                : null,
            fileName: kIsWeb && imageNames.isNotEmpty ? imageNames.first : null,
            folder: folder,
          );

      if (cloudinaryResponse != null) {
        uploadedImages.add(cloudinaryResponse);
        // --- ✅ FIXED: Use .url directly ---
        // Add URL for backward compatibility
        uploadedUrls.add(cloudinaryResponse.url);
      }

      return cloudinaryResponse;
    } catch (e) {
      log('Error uploading image: $e');
      rethrow;
    } finally {
      isUploading.value = false;
    }
  }

  /// Convenient method for category images
  Future<CloudinaryResponse?> uploadCategoryImage() async {
    return await uploadSingleImage(folder: 'categories');
  }

  /// Convenient method for product images
  Future<List<CloudinaryResponse>> uploadProductImages() async {
    return await uploadToCloudinary(folder: 'products');
  }

  /// Convenient method for user avatars
  Future<CloudinaryResponse?> uploadUserAvatar() async {
    return await uploadSingleImage(folder: 'avatars');
  }

  /// Convenient method for banner images
  Future<CloudinaryResponse?> uploadBannerImage() async {
    return await uploadSingleImage(folder: 'banners');
  }

  /// Safe upload method for single image
  Future<UploadResult<CloudinaryResponse>> uploadSingleImageSafe({
    required String folder,
  }) async {
    try {
      final result = await uploadSingleImage(folder: folder);
      if (result != null) {
        return UploadResult.success(result);
      } else {
        return const UploadResult.error('No image to upload');
      }
    } catch (e) {
      return UploadResult.error(e.toString());
    }
  }

  /// Safe upload method for multiple images
  Future<UploadResult<List<CloudinaryResponse>>> uploadMultipleImagesSafe({
    String folder = 'categories',
  }) async {
    try {
      final result = await uploadToCloudinary(folder: folder);
      return UploadResult.success(result);
    } catch (e) {
      return UploadResult.error(e.toString());
    }
  }

  Future<List<String>> uploadMultipleImageUrls({String? folder}) async {
    final responses = await uploadToCloudinary(folder: folder);
    return responses.map((response) => response.url).toList();
  }

  // --- Getters ---
  bool get hasImages => imageFiles.isNotEmpty || imageBytesList.isNotEmpty;
  bool get hasUploadedImages => uploadedImages.isNotEmpty;
  CloudinaryResponse? get firstUploadedImage =>
      uploadedImages.isNotEmpty ? uploadedImages.first : null;
  String? get firstUploadedUrl =>
      uploadedUrls.isNotEmpty ? uploadedUrls.first : null;
  int get selectedImageCount =>
      kIsWeb ? imageBytesList.length : imageFiles.length;
  int get uploadedImageCount => uploadedImages.length;
  List<String> get allUploadedUrls => uploadedUrls.toList();
  List<CloudinaryResponse> get allUploadedImages => uploadedImages.toList();
}
