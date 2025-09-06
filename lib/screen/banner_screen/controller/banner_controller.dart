import 'dart:developer';
import 'dart:ui';

import 'package:dashboard_admin/controllers/image_upload.dart';
import 'package:dashboard_admin/screen/banner_screen/model/banner_model.dart';
import 'package:dashboard_admin/services/banner_service_api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BannerController extends GetxController {
  final BannerServiceApi api = BannerServiceApi();
  final CloudinaryImageController imageController = Get.put(
    CloudinaryImageController(),
  );

  final items = <BannerModel>[].obs;
  final loading = false.obs;
  final error = RxnString();

  final page = 1.obs;
  final limit = 10.obs;
  final search = ''.obs;
  final isActive = RxnBool();
  final sortBy = 'createdAt'.obs;
  final ascending = false.obs;

  final total = 0.obs;
  final pages = 1.obs;

  final RxBool isCreated = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool isEditing = false.obs;

  late TextEditingController ctrname;
  late TextEditingController ctrdescription;

  final RxBool isActiveCategory = true.obs;

  final selected = <String>{}.obs;

  final RxString existingImageUrl = ''.obs;
  final editingCategoryId = RxnString();
  final RxInt currentScreen = 0.obs;

  void toggleScreen(int index) {
    currentScreen.value = index;
  }

  Future<void> load({int? toPage}) async {
    loading.value = true;
    error.value = null;

    log('🚀 Loading page: ${toPage ?? page.value}');

    try {
      final res = await api.fetchBanners(
        page: toPage ?? page.value,
        limit: limit.value,
        search: search.value,
        isActive: isActive.value,
        sortBy: sortBy.value,
        ascending: ascending.value,
      );

      // log('📡 API Response:');
      // log('  - Items received: ${res.items.length}');
      // log('  - Meta total: ${res.meta.total}');
      // log('  - Meta pages: ${res.meta.pages}');
      // log('  - Meta page: ${res.meta.page}');

      items.assignAll(res.items);

      total.value = res.meta.total;
      pages.value = res.meta.pages;
      page.value = res.meta.page;
      selected.clear();

      // // Debug after assignment
      // log('✅ After assignment:');
      // log('  - items.length: ${items.length}');
      // log('  - total.value: ${total.value}');
      // log('  - page.value: ${page.value}');
    } catch (e) {
      log('❌ Load error: $e');
      error.value = e.toString();
    } finally {
      loading.value = false;
    }
  }
}
