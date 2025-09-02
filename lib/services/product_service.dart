import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dashboard_admin/core/URL/url.dart';
import 'package:dashboard_admin/models/product_model.dart';
import 'package:dashboard_admin/services/store_token.dart';
import 'package:http/http.dart' as http;

class ProductService {
  static Future<String?> _getToken() async {
    return await StoreToken().getToken();
  }

  static Future<List<ProductModel>> fetchAllProduct() async {
    final token = await _getToken();
    try {
      final url = Uri.parse('$URL/api/products');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      log('Product response: ${response.body}');
      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = jsonDecode(response.body);
        return jsonResponse.map((item) => ProductModel.fromJson(item)).toList();
      } else {
        log('Failed to fetch products: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      log('Error to fetch Product by service: $e');
      return [];
    }
  }

  Future<void> uploadProduct(
    String name,
    String description,
    double price,
    List<File> images,
  ) async {
    final token = await _getToken();
    try {
      final uri = Uri.parse('$URL/api/products');
      final request = http.MultipartRequest('POST', uri);

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['name'] = name;
      request.fields['description'] = description;
      request.fields['price'] = price.toString();

      for (var file in images) {
        request.files.add(
          await http.MultipartFile.fromPath('images', file.path),
        );
      }

      final response = await request.send();

      if (response.statusCode == 201) {
        log('Product uploaded successfully');
      } else {
        log('Failed to upload product: ${response.statusCode}');
      }
    } catch (e) {
      log('Error uploading product: $e');
    }
  }

  Future<bool> deleteProduct(String id) async {
    try {
      final uri = Uri.parse('$URL/api/products/$id');
      final response = await http.delete(
        uri,
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 204) {
        log('Product deleted successfully');
        return true;
      } else {
        log('Failed to delete product: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      log('Error deleting product: $e');
    }
    return false;
  }

  Future<bool> updateProduct(
    String productId,
    Map<String, String> fields,
    List<http.MultipartFile> files,
  ) async {
    try {
      final token = await StoreToken().getToken();
      if (token == null) {
        log('Auth token not found');
        return false;
      }

      final uri = Uri.parse('$URL/api/products/$productId');

      final request = http.MultipartRequest('PUT', uri);
      request.fields.addAll(fields);
      request.files.addAll(files);
      final response = await request.send();

      if (response.statusCode == 200) {
        log('Product updated successfully');
        return true;
      } else {
        final respStr = await response.stream.bytesToString();

        log('Failed to update product: ${response.statusCode} - $respStr');

        return false;
      }
    } catch (e) {
      log('Error updating product in service: $e');
      return false;
    }
  }
}
