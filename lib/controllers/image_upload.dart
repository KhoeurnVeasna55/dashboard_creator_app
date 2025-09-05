import 'dart:developer';
import 'dart:io';
import 'package:dashboard_admin/models/image_model.dart';
import 'package:dashboard_admin/services/upload_image_service_api.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class CloudinaryImageController extends GetxController {
  // --- STATE ---
  final imageFiles = <File>[].obs;
  final imageBytesList = <Uint8List>[].obs;
  final imageNames = <String>[].obs;
  final uploadedImages = <CloudinaryResponse>[].obs;
  final isUploading = false.obs;

  final ImagePicker _picker = ImagePicker();

  // --- GETTERS ---
  bool get hasImages => imageFiles.isNotEmpty || imageBytesList.isNotEmpty;
  int get selectedImageCount => kIsWeb ? imageBytesList.length : imageFiles.length;
  List<String> get uploadedUrls => uploadedImages.map((img) => img.url).toList();

  void clearSelection() {
    imageFiles.clear();
    imageBytesList.clear();
    imageNames.clear();
    uploadedImages.clear();
  }

  Future<void> pickImage() async {
    clearSelection();
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      if (kIsWeb) {
        imageBytesList.add(await file.readAsBytes());
        imageNames.add(file.name);
      } else {
        imageFiles.add(File(file.path));
      }
    }
  }

  Future<void> pickMultipleImages() async {
    clearSelection();
    final List<XFile> pickedFiles = await _picker.pickMultiImage();

    if (pickedFiles.isNotEmpty) {
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

  Future<UploadResult<List<CloudinaryResponse>>> uploadImages({
    required String folder,
  }) async {
    if (!hasImages) {
      return const UploadResult.error('No images selected to upload.');
    }

    isUploading.value = true;
    
    final UploadResult<dynamic> result;

    if (selectedImageCount > 1) {
      result = await SafeUploadService.uploadMultipleImagesSafe(
        imageFiles: kIsWeb ? null : imageFiles.toList(),
        imageBytesList: kIsWeb ? imageBytesList.toList() : null,
        fileNames: kIsWeb ? imageNames.toList() : null,
        folder: folder,
      );
    } else {
      result = await SafeUploadService.uploadSingleImageSafe(
        imageFile: !kIsWeb && imageFiles.isNotEmpty ? imageFiles.first : null,
        imageBytes: kIsWeb && imageBytesList.isNotEmpty ? imageBytesList.first : null,
        fileName: kIsWeb && imageNames.isNotEmpty ? imageNames.first : null,
        folder: folder,
      );
    }

    if (result.isSuccess && result.data != null) {
      final newImages = result.data is List ? result.data : [result.data];
      uploadedImages.assignAll(List<CloudinaryResponse>.from(newImages));
      log('✅ Upload successful! ${newImages.length} images uploaded.');
      isUploading.value = false;
      return UploadResult.success(uploadedImages.toList());
    } else {
      log('❌ Upload failed: ${result.error}');
      isUploading.value = false;
      return UploadResult.error(result.error ?? 'An unknown error occurred.');
    }
  }
}