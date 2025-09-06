import 'dart:developer';

import 'package:dashboard_admin/controllers/image_upload.dart';
import 'package:dashboard_admin/screen/banner_screen/model/banner_model.dart';
import 'package:dashboard_admin/services/banner_service_api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BannerController extends GetxController {
  final BannerServiceApi _bannerServiceApi = BannerServiceApi();
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

  @override
  void onInit() {
    super.onInit();
    ctrname = TextEditingController();
    ctrdescription = TextEditingController();
    loadData();
  }

  @override
  void onClose() {
    ctrname.dispose();
    ctrdescription.dispose();
    super.onClose();
  }

  final RxInt currentScreen = 0.obs;

  Future<void> loadData({int? toPage}) async {
    loading.value = true;
    error.value = null;
    try {
      final response = await _bannerServiceApi.fetchBanners(
        page: toPage ?? page.value,
        limit: limit.value,
        search: search.value,
        isActive: isActive.value,
        sortBy: sortBy.value,
        ascending: ascending.value,
      );

      items.assignAll(response.items);

      total.value = response.meta.total;
      pages.value = response.meta.pages;
      page.value = response.meta.page;
      selected.clear();
    } catch (e) {
      log('error to load banner $e');
    } finally {
      loading.value = false;
    }
  }

  void toggleScreen(int index) {
    currentScreen.value = index;
  }
}
