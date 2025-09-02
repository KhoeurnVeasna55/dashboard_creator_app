import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class PickerImageUtils {
  static Future<File?> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        return File(image.path);
      } else {
        if (kDebugMode) {
          log('No image selected.');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        log('Error picking image: $e');
      }

      return null;
    }
  }
}
