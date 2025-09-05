import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:dashboard_admin/core/utils/custom_toast_noti.dart';
import 'package:dashboard_admin/core/utils/header_util.dart';
import 'package:dashboard_admin/screen/category_screen/models/category_model.dart';
import 'package:dashboard_admin/services/api_clint.dart';
import 'package:dashboard_admin/services/store_token.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:http/http.dart' as http;
import '../core/URL/url.dart';

class CategoryServiceApi {
  // Your existing methods remain unchanged...

  Future<PaginatedCategories> fetchCategories({
    required int page,
    required int limit,
    String? search,
    bool? isActive,
    String sortBy = 'createdAt',
    bool ascending = false,
  }) async {
    final uri = Uri.parse('$URL/api/categories').replace(
      queryParameters: {
        'page': page.toString(),
        'limit': limit.toString(),
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (isActive != null) 'isActive': isActive.toString(),
        'sortBy': sortBy,
        'order': ascending ? 'asc' : 'desc',
      },
    );

    final resp = await ApiClient.instance.get(uri);
    if (resp.statusCode != 200) {
      throw Exception('Failed to load: ${resp.statusCode} ${resp.body}');
    }
    final data = json.decode(resp.body) as Map<String, dynamic>;
    return PaginatedCategories.fromJson(data);
  }

  Future<Category?> updateCategoryStatus({
    required String id,
    required bool isActive,
  }) async {
    try {
      final token = await StoreToken().getToken();
      final uri = Uri.parse('$URL/api/categories/status');
      final resp = await ApiClient.instance.post(
        uri,
        headers: header(token: token ?? ""),
        body: json.encode({'isActive': isActive, "id": id}),
      );

      if (resp.statusCode == 200) {
        CustomToastNoti.show(
          title: "Success",
          description: json.decode(resp.body)['message'],
        );
      }
      if (resp.statusCode != 200) {
        throw Exception(
          'Failed to update status: ${resp.statusCode} ${resp.body}',
        );
      }

      final data = json.decode(resp.body) as Map<String, dynamic>;
      return Category.fromJson(data);
    } catch (e) {
      if (kDebugMode) {
        print("Failed to update status: $e");
      }
      return null;
    }
  }

  Future<Category> updateCategory({
    required String id,
    required String name,
    String? description,
    String? imageUrl,
    bool? isActive,
  }) async {
    final token = await StoreToken().getToken();
    final uri = Uri.parse('$URL/api/categories/$id');
    final body = <String, dynamic>{
      'name': name,
      if (description != null) 'description': description,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (isActive != null) 'isActive': isActive,
    };
    final resp = await ApiClient.instance.put(
      uri,
      headers: header(token: token ?? ""),
      body: json.encode(body),
    );
    if (resp.statusCode != 200) {
      throw Exception('Failed to update: ${resp.statusCode} ${resp.body}');
    }
    final data = json.decode(resp.body) as Map<String, dynamic>;
    return Category.fromJson(data);
  }


  Future<Category?> createCategoryWithImage({
    required String name,
    required String description,
    required bool isActive,
    required String folder,
    File? imageFile,
    Uint8List? imageBytes,
    String? fileName,
  }) async {
    try {
      final token = await StoreToken().getToken();
      final uri = Uri.parse('$URL/api/categories');

      final request = http.MultipartRequest('POST', uri);

      final headers = header(token: token ?? "");
      request.headers.addAll(headers);

      // Add form fields
      request.fields.addAll({
        'name': name,
        'description': description,
        'isActive': isActive.toString(),
        'folder': folder,
      });

      if (kIsWeb && imageBytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            imageBytes,
            filename: fileName ?? 'category-image.jpg',
          ),
        );
      } else if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('file', imageFile.path),
        );
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        final data = json.decode(responseBody);
        CustomToastNoti.show(
          title: 'Success',
          description: 'Category created successfully!',
        );
        return Category.fromJson(data);
      } else {
        final errorData = json.decode(responseBody);
        CustomToastNoti.show(
          title: 'Error',
          description: errorData['message'] ?? 'Failed to create category',
        );
        log('Failed to create category: $responseBody');
        return null;
      }
    } catch (e) {
      log('Error creating category with image: $e');
      CustomToastNoti.show(
        title: 'Error',
        description: 'Network error: Failed to create category',
      );
      return null;
    }
  }

  Future<Category?> updateCategoryWithImage({
    required String id,
    required String name,
    String? description,
    bool? isActive,
    File? imageFile,
    Uint8List? imageBytes,
    String? fileName,
  }) async {
    try {
      final token = await StoreToken().getToken();
      final uri = Uri.parse('$URL/api/categories/$id');

      // Create multipart request
      final request = http.MultipartRequest('PUT', uri);

      // Add headers
      final headers = header(token: token ?? "");
      request.headers.addAll(headers);

      // Add form fields
      request.fields.addAll({
        'name': name,
        if (description != null) 'description': description,
        if (isActive != null) 'isActive': isActive.toString(),
        'folder': 'categories',
      });

      // Add image file if provided
      if (kIsWeb && imageBytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            imageBytes,
            filename: fileName ?? 'category-image.jpg',
          ),
        );
      } else if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('file', imageFile.path),
        );
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = json.decode(responseBody);
        CustomToastNoti.show(
          title: 'Success',
          description: 'Category updated successfully!',
        );
        return Category.fromJson(data);
      } else {
        final errorData = json.decode(responseBody);
        CustomToastNoti.show(
          title: 'Error',
          description: errorData['message'] ?? 'Failed to update category',
        );
        log('Failed to update category: $responseBody');
        return null;
      }
    } catch (e) {
      log('Error updating category with image: $e');
      CustomToastNoti.show(
        title: 'Error',
        description: 'Network error: Failed to update category',
      );
      return null;
    }
  }

  Future<Category?> createCategory(
    String name,
    String description,
    bool isActive,
    String? imageUrl,
  ) async {
    try {
      final token = await StoreToken().getToken();

      final response = await ApiClient.instance.post(
        Uri.parse('$URL/api/categories'),
        headers: header(token: token ?? ""),
        body: json.encode({
          'name': name,
          'description': description,
          'isActive': isActive,
          if (imageUrl != null) 'imageUrl': imageUrl,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        CustomToastNoti.show(
          title: 'Success',
          description: 'Category created successfully!',
        );
        return Category.fromJson(data);
      } else {
        final errorData = json.decode(response.body);
        CustomToastNoti.show(
          title: 'Error',
          description: errorData['message'] ?? 'Failed to create category',
        );
        log('Failed to create category: ${response.body}');
        return null;
      }
    } catch (e) {
      log('Error creating category: $e');
      CustomToastNoti.show(
        title: 'Error',
        description: 'Network error: Failed to create category',
      );
      return null;
    }
  }
}
