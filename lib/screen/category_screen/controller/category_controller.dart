import 'dart:convert';
import 'dart:developer';

import 'package:dashboard_admin/controllers/image_upload.dart';
import 'package:dashboard_admin/core/URL/url.dart';
import 'package:dashboard_admin/core/utils/custom_toast_noti.dart';
import 'package:dashboard_admin/core/utils/header_util.dart';
import 'package:dashboard_admin/screen/category_screen/models/category_model.dart';
import 'package:dashboard_admin/services/api_clint.dart';
import 'package:dashboard_admin/services/category_service_api.dart';
import 'package:dashboard_admin/services/store_token.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../category_screen_controller.dart';

class CategoryController extends GetxController {
  final CategoryServiceApi api = CategoryServiceApi();
  final CategoryScreenController _categoryScreenController = Get.find();
  final CloudinaryImageController imageController = Get.put(
    CloudinaryImageController(),
  );

  final items = <Category>[].obs;
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
    load();
  }

  @override
  void onClose() {
    ctrname.dispose();
    ctrdescription.dispose();
    super.onClose();
  }

  bool get isAllSelectedOnPage =>
      items.isNotEmpty && items.every((c) => selected.contains(c.id));

  bool get hasSelectedImage =>
      imageController.hasImages || existingImageUrl.isNotEmpty;

  Future<void> pickImage() => imageController.pickImage();
  Future<void> pickMultipleImages() => imageController.pickMultipleImages();
  void clearImages() {
    imageController.clearSelection();
    existingImageUrl.value = '';
  }

  void removeImage() => clearImages();

  Future<void> load({int? toPage}) async {
    loading.value = true;
    error.value = null;

    log('🚀 Loading page: ${toPage ?? page.value}');

    try {
      final res = await api.fetchCategories(
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

  Future<void> toggleStatus(c) async {
    try {
      if (c.id == null) return;

      await api.updateCategoryStatus(
        id: c.id!,
        isActive: !(c.isActive ?? false),
      );
      await load(toPage: page.value);
    } catch (e) {
      CustomToastNoti.show(
        title: 'Update failed',
        description: 'Update failed: $e',
      );
    }
  }

  Future<String?> _handleImageUpload() async {
    final uploadResult = await imageController.uploadImages(
      folder: 'categories',
    );

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

  Future<void> createCategory() async {
    if (ctrname.text.isEmpty) {
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

      await api.createCategory(
        ctrname.text.trim(),
        ctrdescription.text.trim(),
        isActiveCategory.value,
        finalImageUrl,
      );

      CustomToastNoti.show(
        title: 'Success',
        description: 'Category created successfully!',
      );
      clearForm();
      _categoryScreenController.toggleChange(0);
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

  void clearForm() {
    ctrname.clear();
    ctrdescription.clear();
    clearImages();
    isActiveCategory.value = true;
    isEditing.value = false;
    isCreated.value = false;
  }

  void loadCategoryForEdit(Category category) {
    isEditing.value = true;
    editingCategoryId.value = category.id;
    ctrname.text = category.name;
    ctrdescription.text = category.description ?? '';
    isActiveCategory.value = category.isActive;

    existingImageUrl.value = category.imageUrl ?? '';

    log('Existing image URL: ${existingImageUrl.value}');

    imageController.clearSelection();
  }

  Future<void> updateCategory() async {
    final categoryId = editingCategoryId.value;
    if (categoryId == null) {
      CustomToastNoti.show(
        title: 'Error',
        description: 'No category selected.',
      );
      return;
    }

    if (ctrname.text.isEmpty) {
      CustomToastNoti.show(title: 'Error', description: 'Name is required.');
      return;
    }

    isSaving.value = true;
    String? finalImageUrl = existingImageUrl.value;

    try {
      if (imageController.hasImages) {
        finalImageUrl = await _handleImageUpload();
        if (finalImageUrl == null) {
          isSaving.value = false;
          return;
        }
      }

      await api.updateCategory(
        id: categoryId,
        name: ctrname.text.trim(),
        description: ctrdescription.text.trim(),
        isActive: isActiveCategory.value,
        imageUrl: finalImageUrl,
      );

      CustomToastNoti.show(
        title: 'Success',
        description: 'Category updated successfully!',
      );
      clearForm();
      _categoryScreenController.toggleChange(0);
      await load();
    } catch (e) {
      CustomToastNoti.show(
        title: 'Error',
        description: 'Failed to update category: $e',
      );
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> bulkDelete() async {
    if (selected.isEmpty) return;
    loading.value = true;
    try {
      final token = await StoreToken().getToken();
      final uri = Uri.parse('$URL/api/categories/bulk-delete');

      final resp = await ApiClient.instance.post(
        uri,
        headers: header(token: token ?? ""),
        body: jsonEncode({"ids": selected.toList()}),
      );

      if (resp.statusCode != 200) throw Exception(resp.body);

      await load(toPage: page.value);
      CustomToastNoti.show(
        title: 'Deleted',
        description: jsonDecode(resp.body)['message'],
      );
    } catch (e) {
      CustomToastNoti.show(
        title: "ERROR",
        description: 'Bulk delete failed: $e',
      );
    } finally {
      loading.value = false;
    }
  }

  Future<void> create() async {
    clearForm();
    _categoryScreenController.toggleChange(1);
  }
}
