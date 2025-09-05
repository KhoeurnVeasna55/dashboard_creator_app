import 'dart:developer';
import 'package:dashboard_admin/core/utils/app_colors.dart';
import 'package:dashboard_admin/screen/category_screen/controller/category_controller.dart';
import 'package:dashboard_admin/screen/category_screen/category_screen_controller.dart';
import 'package:dashboard_admin/screen/category_screen/models/category_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// ---------------------------
/// Fixed CategoryTableSource with proper pagination handling
/// ---------------------------
class CategoryTableSource extends DataTableSource {
  CategoryTableSource(this.controller) {
    _wItems = ever<List<Category>>(controller.items, (items) {
      // log('📊 Items changed: ${items.length} items');
      notifyListeners();
    });
    _wTotal = ever<int>(controller.total, (total) {
      // log('📊 Total changed: $total');
      notifyListeners();
    });
    _wSelected = ever<Set<String>>(controller.selected, (selected) {
      notifyListeners();
    });
  }

  final CategoryController controller;
  final _fmt = DateFormat('yyyy-MM-dd');

  late final Worker _wItems;
  late final Worker _wTotal;
  late final Worker _wSelected;

  @override
  void dispose() {
    super.dispose();
    _wItems.dispose();
    _wTotal.dispose();
    _wSelected.dispose();
  }

  Widget _statusPill(bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: active ? AppColors.activeBg : AppColors.inactiveBg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        active ? 'Active' : 'Inactive',
        style: TextStyle(
          color: active ? AppColors.activeText : AppColors.inactiveText,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  DataRow? getRow(int index) {
    final currentPage = controller.page.value;
    final itemsPerPage = controller.limit.value;
    final startIndex = (currentPage - 1) * itemsPerPage;
    final localIndex = index - startIndex;

    // log(
    //   '🔍 getRow: global=$index, currentPage=$currentPage, startIndex=$startIndex, localIndex=$localIndex',
    // );
    // log('🔍 Items available: ${controller.items.length}');

    // Check if this index belongs to current page
    if (localIndex < 0 || localIndex >= controller.items.length) {
      log('❌ Index $localIndex out of bounds or not in current page');
      return null;
    }

    // Check if we have data for this index
    if (controller.items.isEmpty) {
      log('❌ No items available');
      return null;
    }

    final c = controller.items[localIndex];
    // log('✅ Rendering row: ${c.name} (localIndex: $localIndex)');

    return DataRow.byIndex(
      index: index,
      selected: controller.selected.contains(c.id),
      onSelectChanged: (v) {
        controller.toggleSelect(c.id, v ?? false);
      },
      cells: [
        DataCell(
          Row(
            children: [
              if (c.imageUrl != null && c.imageUrl!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      c.imageUrl!,
                      height: 24,
                      width: 24,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 24,
                          height: 24,
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 12,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              Flexible(
                child: Text(
                  c.name,
                  style: const TextStyle(color: AppColors.text),
                ),
              ),
            ],
          ),
        ),
        DataCell(
          Text(c.slug, style: const TextStyle(color: AppColors.textMuted)),
        ),
        DataCell(_statusPill(c.isActive)),
        DataCell(
          Text(
            // ignore: unnecessary_null_comparison
            c.createdAt != null ? _fmt.format(c.createdAt) : '—',
            style: const TextStyle(color: AppColors.text),
          ),
        ),
        DataCell(
          Text(
            c.description ?? '—',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.text),
          ),
        ),
        DataCell(
          Row(
            children: [
              IconButton(
                tooltip: (c.isActive) ? 'Deactivate' : 'Activate',
                icon: Icon(
                  (c.isActive)
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20,
                  color: AppColors.icon,
                ),
                onPressed: () => controller.toggleStatus(c),
              ),
              IconButton(
                tooltip: 'Edit',
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 20,
                  color: AppColors.icon,
                ),
                onPressed: () {
                  controller.loadCategoryForEdit(c);
                  Get.find<CategoryScreenController>().goEdit(c.id);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => controller.total.value;

  @override
  int get selectedRowCount => controller.selected.length;
}
