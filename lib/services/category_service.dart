import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../core/URL/url.dart';
import '../models/category_model.dart';

class CategoryService {
  Future<CategoriesResponseModel?> getAllCategories(
    int page,
    int limit,
    String? search,
    bool? isActive,
  ) async {
    try {
      Map<String, String> queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      if (isActive != null) {
        queryParams['isActive'] = isActive.toString();
      }

      final uri = Uri.parse(
        '$URL/api/categories',
      ).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return CategoriesResponseModel.fromJson(jsonData);
      } else {
        log(
          'Failed to get categories: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      log('Error getting categories: $e');
      return null;
    }
  }

  Future<CategoryModel?> createCategory(
    String name,
    String description,
    bool isActive,
    String? imageUrl,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$URL/api/categories'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'description': description,
          'isActive': isActive,
          if (imageUrl != null) 'imageUrl': imageUrl,
        }),
      );

      if (response.statusCode == 201) {
        return CategoryModel.fromJson(json.decode(response.body));
      } else {
        log('Failed to create category: ${response.body}');
        return null;
      }
    } catch (e) {
      log('Error creating category: $e');
      return null;
    }
  }

  Future<File?> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        return File(image.path);
      } else {
        log('No image selected.');
        return null;
      }
    } catch (e) {
      log('Error picking image: $e');
      return null;
    }
  }

  Future<String?> uploadImage(File imageFile, String folder) async {
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
        log('Failed to upload image: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      log('Error uploading image: $e');
      return null;
    }
  }
}
