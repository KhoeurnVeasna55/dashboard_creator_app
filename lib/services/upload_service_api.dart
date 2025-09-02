import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:dashboard_admin/core/URL/url.dart';

class UploadServiceApi {
  static Future<String?> uploadImage(File imageFile, String folder) async {
    try {
      final uri = Uri.parse('$URL/api/upload/$folder');
      final request = http.MultipartRequest('POST', uri);

      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final jsonData = json.decode(responseBody);
        return jsonData['imageUrl'];
      } else {
        if(kDebugMode){
        log('Failed to upload image: ${response.statusCode}');
        }

        return null;
      }
    } catch (e) {
      if(kDebugMode){
log('Error uploading image: $e');
      }
      
      return null;
    }
  }
}
