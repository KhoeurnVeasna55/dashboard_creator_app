import 'package:dashboard_admin/core/utils/app_colors.dart';
import 'package:dashboard_admin/screen/category_screen/controller/category_controller.dart';
import 'package:dashboard_admin/screen/category_screen/models/category_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// ---------------------------
/// DataTableSource that listens to GetX and safely calls notifyListeners()
/// ---------------------------
class CategoryTableSource extends DataTableSource {
  CategoryTableSource(this.controller) {
    // listen to controller changes and refresh the table
    _wItems = ever<List<Category>>(controller.items, (_) => notifyListeners());
    _wTotal = ever<int>(controller.total, (_) => notifyListeners());
    _wSelected =
        ever<Set<String>>(controller.selected, (_) => notifyListeners());
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
    if (controller.total.value == 0) return null;

    if (index < 0 || index >= controller.items.length) {
      return const DataRow(cells: [
        DataCell(Text('—')),
        DataCell(Text('—')),
        DataCell(Text('—')),
        DataCell(Text('—')),
        DataCell(Text('—')),
        DataCell(Text('—')),
      ]);
    }

    final c = controller.items[index];

    return DataRow.byIndex(
      index: index,
      selected: controller.selected.contains(c.id),
      onSelectChanged: (v) => controller.toggleSelect(c.id, v ?? false),
      cells: [
        // Name (with optional thumb)
        DataCell(Row(
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
        )),
        DataCell(
          Text(c.slug, style: const TextStyle(color: AppColors.textMuted)),
        ),
        DataCell(_statusPill(c.isActive)),
        DataCell(Text(_fmt.format(c.createdAt))),
        DataCell(
          Text(
            c.description ?? '—',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // Actions
        DataCell(Row(
          children: [
            IconButton(
              tooltip: c.isActive ? 'Deactivate' : 'Activate',
              icon: Icon(
                c.isActive
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 20,
                color: AppColors.icon,
              ),
              onPressed: () => controller.toggleStatus(c),
            ),
            IconButton(
              tooltip: 'Edit',
              icon: const Icon(Icons.edit_outlined,
                  size: 20, color: AppColors.icon),
              onPressed: () {
                // hook up your edit here if needed
              },
            ),
          ],
        )),
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
