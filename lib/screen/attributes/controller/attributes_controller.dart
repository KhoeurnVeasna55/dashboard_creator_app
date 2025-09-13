import 'dart:developer';

import 'package:dashboard_admin/controllers/image_upload.dart';
import 'package:dashboard_admin/core/utils/custom_toast_noti.dart';
import 'package:dashboard_admin/screen/attributes/controller/attributes_screen_controller.dart';
import 'package:dashboard_admin/screen/attributes/model/attributes_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../services/attributes_service.dart';

class AttributesController extends GetxController {
  final AttributesService api = AttributesService();
  final AttributesScreenController _attributesScreenController = Get.find();
  final CloudinaryImageController imageController = Get.put(
    CloudinaryImageController(),
  );
  // final CreatebannerscreenController _createbannerscreenController = Get.put(
  //   CreatebannerscreenController(),
  // );

  final items = <Item>[].obs;
  final loading = false.obs;
  final error = RxnString();

  final RxList<dynamic> currentValues = <dynamic>[].obs;

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

  late TextEditingController name;
  late TextEditingController code;
  late TextEditingController type;

  late TextEditingController linkUrl;
  final createdAt = Rx<DateTime?>(null);
  final updatedAt = Rx<DateTime?>(null);

  final RxBool isActiveAttribute = true.obs;

  final selected = <String>{}.obs;
  final RxBool isDeleteValue = false.obs;

  final attributeIdOrCode = RxnString();
  final selectedTypeFilter = RxnString();

  final RxString existingImageUrl = ''.obs;
  final editingAttributesId = RxnString();
  final RxInt currentScreen = 0.obs;
  @override
  void onInit() {
    super.onInit();
    name = TextEditingController();
    code = TextEditingController();
    type = TextEditingController();

    load();
  }

  @override
  void onClose() {
    name.dispose();
    code.dispose();
    type.dispose();
    super.onClose();
  }

  void setSearch(String q) {
    search.value = q;
    load(toPage: 1);
  }

  List<Item> get filteredAttributes {
    var result = items.toList();

    // Apply type filter
    if (selectedTypeFilter.value != null) {
      result = result.where((a) => a.type == selectedTypeFilter.value).toList();
    }

    // Apply status filter
    if (isActive.value != null) {
      result = result.where((a) => a.isActive == isActive.value).toList();
    }

    return result;
  }

  void setIsActiveFilter(bool? v) {
    isActive.value = v;
    load(toPage: 1);
  }

  void setTypeFilter(String? type) {
    selectedTypeFilter.value = type;
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
      attributeIdOrCode.value = id;
    } else {
      selected.remove(id);
      if (selected.isEmpty) {
        attributeIdOrCode.value = null;
      } else {
        attributeIdOrCode.value = selected.first;
      }
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

    final targetPage = toPage ?? page.value;
    log('🚀 Loading page: $targetPage');

    try {
      final res = await api.fatchAttributes(
        page: targetPage,
        limit: limit.value,
        search: search.value,
        isActive: isActive.value,
        sortBy: sortBy.value,
        ascending: ascending.value,
      );

      items.assignAll(res.items);

      total.value = res.meta.total;
      pages.value = res.meta.pages;
      page.value = res.meta.page;

      // If no items found
      if (res.items.isEmpty) {
        log(' No attributes found for page $targetPage');
      }

      selected.clear();

      log(' Loaded ${items.length} items');
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

      await api.updateStatus(id: c.id!, isActive: !(c.isActive ?? false));
      await load(toPage: page.value);
    } catch (e) {
      CustomToastNoti.show(
        title: 'Update failed',
        description: 'Update failed: $e',
      );
    }
  }

  Future<void> loadAttributeForEditById(String id) async {
    try {
      loading.value = true;
      error.value = null;

      final attribute = await api.fetchAttributesById(id);
      loadForEdit(attribute);
      editingAttributesId.value = attribute.id;
      isEditing.value = true;
    } catch (e) {
      error.value = 'Failed to load category: $e';
      CustomToastNoti.show(title: 'Error', description: error.value!);
    } finally {
      loading.value = false;
    }
  }

  Future<void> loadValues(String attributeId) async {
    loading.value = true;

    try {
      final result = await api.fetchAttributesById(attributeId);
      currentValues.assignAll(result.values);
    } catch (e) {
      error.value = e.toString();
    } finally {
      loading.value = false;
    }
  }

  void loadForEdit(Item item) {
    isEditing.value = true;
    editingAttributesId.value = item.id;
    name.text = item.name;
    code.text = item.code;
    selectedTypeFilter.value = item.type;
    attributeIdOrCode.value = item.id;
  }

  Future<void> createAttributes() async {
    try {
      isSaving.value = true;

      final name = this.name.text.trim();
      final code = this.code.text.trim().isNotEmpty
          ? this.code.text.trim().toLowerCase()
          : name.toLowerCase().replaceAll(' ', '_');

      final type = selectedTypeFilter.value ?? 'select';
      final isActive = isActiveAttribute.value;

      await api.createAttribute(
        name: name,
        code: code,
        type: type,
        isActive: isActive,
      );

      CustomToastNoti.show(
        title: 'Success',
        description: 'Attribute created successfully!',
      );
      clearForm();
      _attributesScreenController.goList();

      await load();
    } catch (e) {
      log("createAttribute error: $e");
      CustomToastNoti.show(title: 'error', description: 'Error to Created $e');
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> addValues(
    String attributeId,
    List<Map<String, dynamic>> newValues,
  ) async {
    for (final v in newValues) {
      await api.createValue(
        attributeId,
        v['label'] as String,
        v['value'] as String,
        v['meta'] != null ? Meta.fromJson(v['meta']) : null,
      );
    }
  }

  Future<void> updateAttributes() async {
    if (editingAttributesId.value == null) {
      CustomToastNoti.show(
        title: 'Error',
        description: 'No Attribute selected for editing.',
      );
      return;
    }

    if (name.text.isEmpty) {
      CustomToastNoti.show(title: 'Error', description: 'Title is required.');
      return;
    }

    isSaving.value = true;

    final type = selectedTypeFilter.value!;
    final isActive = isActiveAttribute.value;

    try {
      await api.updateAttribute(
        idOrCode: editingAttributesId.value!,
        name: name.text.trim(),
        code: code.text.trim(),
        type: type,
        isActive: isActive,
      );

      CustomToastNoti.show(
        title: 'Success',
        description: 'Attribute updated successfully!',
      );

      clearForm();
      _attributesScreenController.goList();
      await load();
    } catch (e) {
      CustomToastNoti.show(
        title: 'Error',
        description: 'Failed to update Attribute: $e',
      );
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> addValueToAttribute(
    String attributeId,
    String label,
    String value,
    Meta? meta,
  ) async {
    try {
      final updatedItem = await api.createValue(
        attributeId,
        label,
        value,
        meta,
      );
      if (updatedItem != null) {
        final index = items.indexWhere((i) => i.id == updatedItem.id);
        if (index != -1) {
          items[index] = updatedItem;
        }
        CustomToastNoti.show(
          title: 'Success',
          description: 'Value added successfully!',
        );
      }
    } catch (e) {
      CustomToastNoti.show(
        title: 'Error',
        description: 'Failed to add value: $e',
      );
    }
  }

  // Future<void> updateValueInAttribute(
  //   String attributeId,
  //   String valueId,
  //   String label,
  //   String value,
  //   Meta? meta,
  // ) async {
  //   try {
  //     final updatedItem = await api.updateValue(
  //       attributeId,
  //       valueId,
  //       label,
  //       value,
  //       meta,
  //     );
  //     if (updatedItem != null) {
  //       final index = items.indexWhere((i) => i.id == updatedItem.id);
  //       if (index != -1) {
  //         items[index] = updatedItem;
  //       }
  //       CustomToastNoti.show(
  //         title: 'Success',
  //         description: 'Value updated successfully!',
  //       );
  //     }
  //   } catch (e) {
  //     CustomToastNoti.show(
  //       title: 'Error',
  //       description: 'Failed to update value: $e',
  //     );
  //   }
  // }

  void clearImages() {
    imageController.clearSelection();
    existingImageUrl.value = '';
  }

  void clearForm() {
    name.clear();
    type.clear();
    code.clear();
    selectedTypeFilter.value = null;
    isActiveAttribute.value = true;
    isEditing.value = false;
    isCreated.value = false;
    editingAttributesId.value = null;
  }

  Future<void> bulkDelete() async {
    if (selected.isEmpty) return;
    if (attributeIdOrCode.value == null || attributeIdOrCode.value!.isEmpty) {
      CustomToastNoti.show(
        title: "Error",
        description: "No attribute selected",
      );
      return;
    }

    loading.value = true;
    try {
      await api.deleteAttributes(selected.toList());

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

  Future<void> deleteValue(String attributeId, String valueId) async {
    try {
      loading.value = true;
      await api.deleteValue(attributeId, valueId);

      await loadValues(attributeId);

      CustomToastNoti.show(
        title: 'Deleted',
        description: 'Value deleted successfully',
      );
    } catch (e) {
      CustomToastNoti.show(title: 'Error', description: 'Delete failed: $e');
    } finally {
      loading.value = false;
    }
  }
}
