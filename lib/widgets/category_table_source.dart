import 'dart:developer';
import 'package:dashboard_admin/core/utils/app_colors.dart';
import 'package:dashboard_admin/screen/category_screen/models/category_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CategoryTableSource extends DataTableSource {
  CategoryTableSource({
    required this.items,
    this.selectedIds = const <String>{},
    this.onToggleSelect,
    this.onToggleStatus,
    this.onEdit,
  });

  final List<Category> items;
  final Set<String> selectedIds;
  final Function(String id, bool selected)? onToggleSelect;
  final Function(Category category)? onToggleStatus;
  final Function(Category category)? onEdit;

  final _fmt = DateFormat('yyyy-MM-dd');

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
    // Check if index is valid
    if (index < 0 || index >= items.length) {
      log('❌ Index $index out of bounds');
      return null;
    }

    if (items.isEmpty) {
      log('❌ No items available');
      return null;
    }

    final c = items[index];

    return DataRow.byIndex(
      index: index,
      selected: selectedIds.contains(c.id),
      onSelectChanged: (v) {
        onToggleSelect?.call(c.id, v ?? false);
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
            // c.createdAt  ? _fmt.format(c.createdAt) : '—',
            _fmt.format(c.createdAt),
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
                onPressed: () => onToggleStatus?.call(c),
              ),
              IconButton(
                tooltip: 'Edit',
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 20,
                  color: AppColors.icon,
                ),
                onPressed: () => onEdit?.call(c),
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
  int get rowCount => items.length;

  @override
  int get selectedRowCount => selectedIds.length;
}
