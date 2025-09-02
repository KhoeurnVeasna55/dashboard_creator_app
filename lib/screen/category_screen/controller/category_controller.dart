
import 'package:dashboard_admin/core/utils/custom_toast_noti.dart';
import 'package:dashboard_admin/screen/category_screen/models/category_model.dart';
import 'package:dashboard_admin/services/category_service_api.dart';
import 'package:get/get.dart';

/// ---------------------------
/// GetX Controller
/// ---------------------------
class CategoryController extends GetxController {
  final CategoryServiceApi api= CategoryServiceApi();

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

  // Selection state (IDs)
  final selected = <String>{}.obs;

  bool get isAllSelectedOnPage =>
      items.isNotEmpty && items.every((c) => selected.contains(c.id));

  Future<void> load({int? toPage}) async {
    loading.value = true;
    error.value = null;
    try {
      final res = await api.fetchCategories(
        page: toPage ?? page.value,
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
      // Clear selection for safety when page changes
      selected.clear();
    } catch (e) {
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

  // Selection helpers
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

  // Inline toggle (single)
  Future<void> toggleStatus(Category c) async {
    try {
      final updated =
          await api.updateCategoryStatus(id: c.id, isActive: !c.isActive);
      final idx = items.indexWhere((x) => x.id == c.id);
      if (idx != -1) {
        items[idx] = updated!;
        items.refresh();
      }
    } catch (e) {
      CustomToastNoti.show(context: Get.context!, title: 'Update failed', description: 'Bulk update failed$e');
    }
  }

  // Bulk activate/deactivate selected
  Future<void> bulkSetStatus(bool active) async {
    if (selected.isEmpty) return;
    loading.value = true;
    try {
      // naive sequential; for prod you might create a batch endpoint
      for (final id in selected.toList()) {
        await api.updateCategoryStatus(id: id, isActive: active);
      }
      await load(toPage: page.value); 
      Get.snackbar('Updated',
          'Status set to ${active ? "Active" : "Inactive"} for selected',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      CustomToastNoti.show(context: Get.context!, title: "ERROR", description: 'Bulk update failed$e');
    } finally {
      loading.value = false;
    }
  }
}
