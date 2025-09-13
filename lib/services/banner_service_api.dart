import 'dart:convert';
import 'dart:developer';

import 'package:dashboard_admin/core/URL/url.dart';
import 'package:dashboard_admin/core/utils/custom_toast_noti.dart';
import 'package:dashboard_admin/core/utils/header_util.dart';
import 'package:dashboard_admin/screen/banner_screen/model/banner_model.dart';
import 'package:dashboard_admin/services/api_clint.dart';
import 'package:dashboard_admin/services/store_token.dart';
import 'package:flutter/foundation.dart';

class BannerServiceApi {
  final StoreToken _storeToken = StoreToken();

  Future<PaginatedBanner> fetchBanners({
    required int page,
    required int limit,
    String? title,
    String? subtitle,
    String? search,
    bool? isActive,
    DateTime? startDate,
    DateTime? endDate,
    String sortBy = 'createdAt',
    bool ascending = false,
    int? position,
  }) async {
    final uri = Uri.parse('$URL/api/banners').replace(
      queryParameters: {
        'title': title,
        'subtitle': subtitle,
        'page': page.toString(),
        'limit': limit.toString(),
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (isActive != null) 'isActive': isActive.toString(),
        'sortBy': sortBy,
        'order': ascending ? 'asc' : 'desc',
        'position': position,
      },
    );

    final resp = await ApiClient.instance.get(uri);
    if (resp.statusCode != 200) {
      throw Exception('Failed to load: ${resp.statusCode} ${resp.body}');
    }
    final data = json.decode(resp.body) as Map<String, dynamic>;
    return PaginatedBanner.fromJson(data);
  }

  Future<BannerModel?> createBanner(
    String title,
    String subtitle,
    String description,
    String imageUrl,
    String? linkUrl,
    int? position,
    bool isActive,
    DateTime? startDate,
    DateTime? endDate,
  ) async {
    try {
      final token = await _storeToken.getToken();
      final uri = Uri.parse('$URL/api/banners');

      final body = {
        'title': title,
        'subtitle': subtitle,
        'description': description,
        'imageUrl': imageUrl,
        if (linkUrl != null) 'linkUrl': linkUrl,
        if (position != null) 'position': position,
        'isActive': isActive,
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
      };

      final response = await ApiClient.instance.post(
        uri,
        headers: header(token: token ?? ''),
        body: json.encode(body),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return BannerModel.fromJson(data);
      } else {
        throw Exception(
          'Failed to create banner: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      log('Error creating banner: $e');
      rethrow; // keep the error visible for debugging
    }
  }

  Future<BannerModel?> updateBannerStatus({
    required String id,
    required bool isActive,
  }) async {
    try {
      final token = await StoreToken().getToken();
      final uri = Uri.parse('$URL/api/banners/status');
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
      return BannerModel.fromJson(data);
    } catch (e) {
      if (kDebugMode) {
        print("Failed to update status: $e");
      }
      return null;
    }
  }

  Future<BannerModel> updateBannerModel({
    required String id,
    String? title,
    String? subtitle,
    String? description,
    String? imageUrl,
    String? linkUrl,
    int? position,
    bool? isActive,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final token = await StoreToken().getToken();
      final uri = Uri.parse('$URL/api/banners/$id');

      final body = <String, dynamic>{
        if (title != null) 'title': title,
        if (subtitle != null) 'subtitle': subtitle,
        if (description != null) 'description': description,
        if (imageUrl != null) 'imageUrl': imageUrl,
        if (linkUrl != null) 'linkUrl': linkUrl,
        if (position != null) 'position': position,
        if (isActive != null) 'isActive': isActive,
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
      };

      final resp = await ApiClient.instance.put(
        uri,
        headers: header(token: token ?? ""),
        body: json.encode(body),
      );

      if (resp.statusCode == 200) {
        final Map<String, dynamic> jsonResponse =
            jsonDecode(resp.body) as Map<String, dynamic>;
        return BannerModel.fromJson(jsonResponse);
      } else if (resp.statusCode == 304) {
        throw Exception("Banner not modified (304).");
      } else {
        throw Exception(
          "Failed to update banner: ${resp.statusCode} ${resp.body}",
        );
      }
    } catch (e) {
      log(' Error updating banner: $e');
      rethrow;
    }
  }

  Future<BannerModel> fetchBannerById(String id) async {
    final uri = Uri.parse('$URL/api/Banners/$id');
    final resp = await ApiClient.instance.get(uri);
    if (resp.statusCode != 200) {
      throw Exception(
        'Failed to fetch category $id: ${resp.statusCode} ${resp.body}',
      );
    }
    final data = json.decode(resp.body) as Map<String, dynamic>;
    return BannerModel.fromJson(data);
  }

  Future<void> deleteBanner(List<String> selectId) async {
    try {
      final token = await _storeToken.getToken();
      final uri = Uri.parse('$URL/api/banners/bulk-delete');

      final response = await ApiClient.instance.post(
        uri,
        headers: header(token: token ?? ''),
        body: jsonEncode({"ids": selectId}),
      );
      if (response.statusCode != 200) throw Exception(response.body);
    } catch (e) {
      log('error to delete $e');
    }
  }
}
