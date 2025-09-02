import 'dart:convert';
import 'dart:developer';
import 'package:dashboard_admin/core/utils/header_util.dart';
import 'package:dashboard_admin/screen/category_screen/models/category_model.dart';
import 'package:dashboard_admin/services/store_token.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:http/http.dart' as http;
import '../core/URL/url.dart';
import '../models/category_model.dart';

class CategoryServiceApi {
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

    final resp = await http.get(uri);
    if (resp.statusCode != 200) {
      throw Exception('Failed to load: ${resp.statusCode} ${resp.body}');
    }
    final data = json.decode(resp.body) as Map<String, dynamic>;
    return PaginatedCategories.fromJson(data);
  }

  // PATCH /categories/:id { isActive }
  Future<Category?> updateCategoryStatus({
    required String id,
    required bool isActive,
  }) async {
    try {
      final token = await StoreToken().getToken();
      final uri = Uri.parse('$URL/api/categories/$id');
      final resp = await http.patch(
        uri,
        headers: header(token: token ?? ""),
        body: json.encode({'isActive': isActive}),
      );
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

  // PUT /categories/:id (simple edit)
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
    final resp = await http.put(
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
}
