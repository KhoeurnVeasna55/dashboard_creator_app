import 'dart:convert';

import 'package:dashboard_admin/core/URL/url.dart';
import 'package:dashboard_admin/core/utils/custom_toast_noti.dart';
import 'package:dashboard_admin/core/utils/header_util.dart';
import 'package:dashboard_admin/screen/banner_screen/model/banner_model.dart';
import 'package:dashboard_admin/services/api_clint.dart';
import 'package:dashboard_admin/services/store_token.dart';
import 'package:flutter/foundation.dart';

class BannerServiceApi {
  Future<PaginatedBanner> fetchBanners({
    required int page,
    required int limit,
    String? search,
    bool? isActive,
    String sortBy = 'createdAt',
    bool ascending = false,
    int? position,
  }) async {
    final uri = Uri.parse('$URL/api/banners').replace(
      queryParameters: {
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

  Future<BannerModel?> updateBannner({
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
}
