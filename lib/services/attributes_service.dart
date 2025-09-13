import 'dart:convert';
import 'dart:developer';

import 'package:dashboard_admin/core/URL/url.dart';
import 'package:dashboard_admin/core/utils/custom_toast_noti.dart';
import 'package:dashboard_admin/core/utils/header_util.dart';
import 'package:dashboard_admin/models/pagination_meta.dart';
import 'package:dashboard_admin/screen/attributes/model/attributes_model.dart';
import 'package:dashboard_admin/services/api_clint.dart';
import 'package:dashboard_admin/services/store_token.dart';
import 'package:flutter/foundation.dart';

class AttributesService {
  Future<AttributesModel> fatchAttributes({
    required int page,
    required int limit,
    String? search,
    bool? isActive,
    String sortBy = 'createdAt',
    bool ascending = false,
  }) async {
    try {
      final token = await StoreToken().getToken();
      final uri = Uri.parse('$URL/api/');
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (isActive != null) 'isActive': isActive.toString(),
        'sortBy': sortBy,
        'order': ascending ? 'asc' : 'desc',
      };

      final uriWithParams = Uri.parse(
        '${uri}attributes',
      ).replace(queryParameters: queryParams);

      final response = await ApiClient.instance.get(
        uriWithParams,
        headers: header(token: token!),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is Map<String, dynamic> &&
            data.containsKey('items') &&
            data.containsKey('meta')) {
          return AttributesModel.fromJson(data);
        }

        if (data is Map<String, dynamic>) {
          final item = Item.fromJson(data);
          return AttributesModel(
            items: [item],
            meta: PaginationMeta(
              page: 1,
              limit: 10,
              total: 1,
              pages: 1,
              sortBy: sortBy,
              order: ascending ? 'asc' : 'desc',
              hasPrev: false,
              hasNext: false,
            ),
          );
        }

        throw Exception("Unexpected response format: $data");
      } else {
        throw Exception('Failed to load attributes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching attributes: $e');
    }
  }

  Future<Item> fetchAttributesById(String idOrCode) async {
    final token = await StoreToken().getToken();
    final uri = Uri.parse('$URL/api/attributes/$idOrCode');
    final resp = await ApiClient.instance.get(
      uri,
      headers: header(token: token ?? ''),
    );
    if (resp.statusCode != 200) {
      throw Exception(
        'Failed to fetch Attribute $idOrCode : ${resp.statusCode} ${resp.body}',
      );
    }
    final data = json.decode(resp.body) as Map<String, dynamic>;
    return Item.fromJson(data);
  }

  Future<Item?> createAttribute({
    required String name,
    required String code,
    required String type,
    List<Map<String, dynamic>>? values,

    bool isActive = true,
  }) async {
    try {
      final body = {
        "name": name,
        "code": code,
        "type": type,
        "values": values ?? [],
        if (values != null && values.isNotEmpty) "values": values,
      };

      final token = await StoreToken().getToken();
      final uri = Uri.parse('$URL/api/attributes');

      final resp = await ApiClient.instance.post(
        uri,
        headers: header(token: token ?? ""),
        body: jsonEncode(body),
      );

      if (resp.statusCode == 201) {
        final data = jsonDecode(resp.body);
        log('seccessful create ');
        return Item.fromJson(data);
      } else {
        throw Exception("Failed: ${resp.statusCode} ${resp.body}");
      }
    } catch (e) {
      log("createAttribute error: $e");
      return null;
    }
  }

  Future<Item?> createValue(
    String idOrCode,
    String label,
    String value,
    Meta? meta,
  ) async {
    try {
      final token = await StoreToken().getToken();
      final uri = Uri.parse('$URL/api/attributes/$idOrCode/values');

      final body = {
        'label': label,
        'value': value,
        if (meta != null) 'meta': meta.toJson(),
      };

      final response = await ApiClient.instance.post(
        uri,
        headers: header(token: token ?? ""),
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Item.fromJson(data);
      } else {
        throw Exception(
          'Failed to create value: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      log('error to create value $e');
      return null;
    }
  }

  Future<Item?> updateAttribute({
    required String idOrCode,
    required String name,
    required String code,
    required String type,
    List<Map<String, dynamic>>? values,
    bool isActive = true,
  }) async {
    try {
      final body = {
        "name": name,
        "code": code,
        "type": type,
        "isActive": isActive,
        "values": values ?? [],
      };

      final token = await StoreToken().getToken();
      final uri = Uri.parse('$URL/api/attributes/$idOrCode');

      final resp = await ApiClient.instance.put(
        uri,
        headers: header(token: token ?? ""),
        body: jsonEncode(body),
      );

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        return Item.fromJson(data);
      } else {
        throw Exception("Failed: ${resp.statusCode} ${resp.body}");
      }
    } catch (e) {
      log("updateAttribute error: $e");
      return null;
    }
  }

  Future<Item?> updateStatus({
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
      return Item.fromJson(data);
    } catch (e) {
      if (kDebugMode) {
        print("Failed to update status: $e");
      }
      return null;
    }
  }

  Future<void> deleteAttributes(List<String> attributeIds) async {
    final token = await StoreToken().getToken();
    final uri = Uri.parse('$URL/api/attributes/remove-many');
    final response = await ApiClient.instance.post(
      uri,
      headers: header(token: token ?? ''),
      body: jsonEncode({"ids": attributeIds}),
    );
    if (response.statusCode != 200) throw Exception(response.body);
  }

  Future<void> deleteValue(String attributeId, String valueId) async {
    try {
      final token = await StoreToken().getToken();
      final uri = Uri.parse(
        '$URL/api/attributes/$attributeId/values/remove-many',
      );

      final response = await ApiClient.instance.post(
        uri,
        headers: header(token: token ?? ''),
        body: jsonEncode({
          "valueIds": [valueId],
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete value: ${response.body}');
      }
    } catch (e) {
      log('error to delete value $e');
      rethrow;
    }
  }
}
