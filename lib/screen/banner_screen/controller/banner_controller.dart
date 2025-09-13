import 'dart:developer';

import 'package:dashboard_admin/controllers/image_upload.dart';
import 'package:dashboard_admin/core/utils/custom_toast_noti.dart';
import 'package:dashboard_admin/screen/banner_screen/controller/createbanner_controller.dart';
import 'package:dashboard_admin/screen/banner_screen/model/banner_model.dart';
import 'package:dashboard_admin/services/banner_service_api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BannerController extends GetxController {
  final BannerServiceApi api = BannerServiceApi();
  final CloudinaryImageController imageController = Get.put(
    CloudinaryImageController(),
  );
  final CreatebannerscreenController _createbannerscreenController = Get.put(
    CreatebannerscreenController(),
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

  late TextEditingController title;
  late TextEditingController desc;
  late TextEditingController subtitle;
  late TextEditingController linkUrl;
  late TextEditingController position;
  final startDate = Rx<DateTime?>(null);
  final endDate = Rx<DateTime?>(null);

  final RxBool isActiveBanner = true.obs;

  final selected = <String>{}.obs;

  final RxString existingImageUrl = ''.obs;
  final editingCategoryId = RxnString();
  final RxInt currentScreen = 0.obs;
  @override
  void onInit() {
    super.onInit();
    title = TextEditingController();
    desc = TextEditingController();
    subtitle = TextEditingController();
    linkUrl = TextEditingController();
    position = TextEditingController();

    load();
  }

  @override
  void onClose() {
    title.dispose();
    desc.dispose();
    subtitle.dispose();
    linkUrl.dispose();
    position.dispose();
    super.onClose();
  }

  void setSearch(String q) {
    search.value = q;
    load(toPage: 1);
  }

  void setIsActiveFilter(bool? v) {
    isActive.value = v;
    load(toPage: 1);
  }

  void setSort(String field, bool asc) {
    sortBy.value = field;
    ascending.value = asc;
    load(toPage: 1);
  }

  void setRowsPerPage(int rpp) {
    limit.value = rpp;
    load(toPage: 1);
  }

  Future<void> pickImage() => imageController.pickImage();

  void goFirst() => load(toPage: 1);
  void goPrev() => page.value > 1 ? load(toPage: page.value - 1) : null;
  void goNext() =>
      page.value < pages.value ? load(toPage: page.value + 1) : null;
  void goLast() => load(toPage: pages.value);

  void toggleSelect(String id, bool value) {
    if (value) {
      selected.add(id);
    } else {
      selected.remove(id);
    }
  }

  void selectAllOnPage(bool value) {
    if (value) {
      for (final c in items) {
        selected.add(c.id);
      }
    } else {
      for (final c in items) {
        selected.remove(c.id);
      }
    }
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

  Future<void> toggleStatus(c) async {
    try {
      if (c.id == null) return;

      await api.updateBannerStatus(id: c.id!, isActive: !(c.isActive ?? false));
      await load(toPage: page.value);
    } catch (e) {
      CustomToastNoti.show(
        title: 'Update failed',
        description: 'Update failed: $e',
      );
    }
  }

  Future<void> loadBannerForEditById(String id) async {
    try {
      loading.value = true;
      error.value = null;

      final category = await api.fetchBannerById(id);
      loadForEdit(category);
      editingCategoryId.value = category.id;
      isEditing.value = true;
    } catch (e) {
      error.value = 'Failed to load category: $e';
      CustomToastNoti.show(title: 'Error', description: error.value!);
    } finally {
      loading.value = false;
    }
  }

  void loadForEdit(BannerModel banner) {
    isEditing.value = true;
    editingCategoryId.value = banner.id;
    title.text = banner.title ?? '';
    subtitle.text = banner.subtitle ?? '';
    linkUrl.text = banner.linkUrl ?? '';
    position.text = (banner.position ?? 0).toString();

    desc.text = banner.description ?? '';

    isActiveBanner.value = banner.isActive ?? true;
    startDate.value = banner.startDate;
    endDate.value = banner.endDate;
    existingImageUrl.value = banner.imageUrl ?? '';
    imageController.clearSelection();
  }

  Future<String?> _handleImageUpload() async {
    final uploadResult = await imageController.uploadImages(folder: 'Banners');

    if (uploadResult.isSuccess &&
        uploadResult.data != null &&
        uploadResult.data!.isNotEmpty) {
      final imageUrl = uploadResult.data!.first.url;
      log('Image upload successful. URL: $imageUrl');
      return imageUrl;
    } else {
      CustomToastNoti.show(
        title: 'Upload Error',
        description: uploadResult.error ?? 'Image upload failed',
      );
      return null;
    }
  }

  Future<void> createBanner() async {
    if (title.text.isEmpty) {
      CustomToastNoti.show(title: 'Error', description: 'Name is required.');
      return;
    }

    isSaving.value = true;
    String? finalImageUrl;

    try {
      if (imageController.hasImages) {
        finalImageUrl = await _handleImageUpload();
        if (finalImageUrl == null) {
          isSaving.value = false;
          return;
        }
      }

      await api.createBanner(
        title.text.trim(),
        subtitle.text.trim(),
        desc.text.trim(),
        finalImageUrl ?? '',
        linkUrl.text.trim(),

        int.tryParse(position.text),
        isActiveBanner.value,
        startDate.value,
        endDate.value,
      );

      CustomToastNoti.show(
        title: 'Success',
        description: 'Category created successfully!',
      );
      clearForm();
      _createbannerscreenController.goList();
      await load();
    } catch (e) {
      CustomToastNoti.show(
        title: 'Error',
        description: 'Failed to create category: $e',
      );
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> updateBanner() async {
    if (editingCategoryId.value == null) {
      CustomToastNoti.show(
        title: 'Error',
        description: 'No banner selected for editing.',
      );
      return;
    }

    if (title.text.isEmpty) {
      CustomToastNoti.show(title: 'Error', description: 'Title is required.');
      return;
    }

    isSaving.value = true;

    try {
      String? finalImageUrl = existingImageUrl.value;

      if (imageController.hasImages) {
        final uploadedUrl = await _handleImageUpload();
        if (uploadedUrl == null) {
          isSaving.value = false;
          return;
        }
        finalImageUrl = uploadedUrl;
      }

      int? pos = int.tryParse(position.text.trim());

      await api.updateBannerModel(
        id: editingCategoryId.value!,
        title: title.text.trim(),
        subtitle: subtitle.text.trim().isEmpty ? null : subtitle.text.trim(),
        description: desc.text.trim().isEmpty ? null : desc.text.trim(),
        imageUrl: finalImageUrl,
        linkUrl: linkUrl.text.trim().isEmpty ? null : linkUrl.text.trim(),
        position: pos,
        isActive: isActiveBanner.value,
        startDate: startDate.value,
        endDate: endDate.value,
      );

      CustomToastNoti.show(
        title: 'Success',
        description: 'Banner updated successfully!',
      );

      clearForm();
      _createbannerscreenController.goList();
    } catch (e) {
      CustomToastNoti.show(
        title: 'Error',
        description: 'Failed to update banner: $e',
      );
    } finally {
      isSaving.value = false;
    }
  }

  void clearImages() {
    imageController.clearSelection();
    existingImageUrl.value = '';
  }

  void clearForm() {
    title.clear();
    subtitle.clear();
    desc.clear();
    linkUrl.clear();
    position.clear();
    clearImages();

    startDate.value = null;
    endDate.value = null;
    isActiveBanner.value = true;
    isEditing.value = false;
    isCreated.value = false;
    editingCategoryId.value = null;
  }

  Future<void> bulkDelete() async {
    if (selected.isEmpty) return;
    loading.value = true;
    try {
      await api.deleteBanner(selected.toList());

      await load(toPage: page.value);
      CustomToastNoti.show(title: 'Deleted', description: 'Deleted Successful');
    } catch (e) {
      CustomToastNoti.show(
        title: "ERROR",
        description: 'Bulk delete failed: $e',
      );
    } finally {
      loading.value = false;
    }
  }
}
