import 'dart:developer';
import 'package:dashboard_admin/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

abstract class BaseTableSource<T> extends DataTableSource {
  BaseTableSource({
    required this.items,
    this.selectedIds = const <String>{},
    this.onToggleSelect,
  });

  final List<T> items;
  final Set<String> selectedIds;
  final Function(String id, bool selected)? onToggleSelect;

  String getItemId(T item);
  List<DataCell> buildCells(T item, int index);

  @override
  DataRow? getRow(int index) {
    if (index < 0 || index >= items.length) {
      log(' Index $index out of bounds');
      return null;
    }

    if (items.isEmpty) {
      log(' No items available');
      return null;
    }

    final item = items[index];
    final itemId = getItemId(item);

    return DataRow.byIndex(
      index: index,
      selected: selectedIds.contains(itemId),
      onSelectChanged: (v) {
        onToggleSelect?.call(itemId, v ?? false);
      },
      cells: buildCells(item, index),
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => items.length;

  @override
  int get selectedRowCount => selectedIds.length;
}

class CategoryTableSource extends BaseTableSource<dynamic> {
  CategoryTableSource({
    required super.items,
    super.selectedIds,
    super.onToggleSelect,
    this.onToggleStatus,
    this.onEdit,
  });

  final void Function()? onToggleStatus;
  final void Function()? onEdit;

  dynamic _currentItem;

  final _fmt = DateFormat('yyyy-MM-dd');

  @override
  String getItemId(dynamic item) => item.id;

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
  List<DataCell> buildCells(dynamic item, int index) {
    _currentItem = item;

    return [
      DataCell(
        Row(
          children: [
            if (item.imageUrl != null && item.imageUrl!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    item.imageUrl!,
                    height: 24,
                    width: 24,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 24,
                        height: 24,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported, size: 12),
                      );
                    },
                  ),
                ),
              ),
            Flexible(
              child: Text(
                item.name,
                style: const TextStyle(color: AppColors.text),
              ),
            ),
          ],
        ),
      ),
      DataCell(
        Text(item.slug, style: const TextStyle(color: AppColors.textMuted)),
      ),
      DataCell(_statusPill(item.isActive)),
      DataCell(
        Text(
          _fmt.format(item.createdAt),
          style: const TextStyle(color: AppColors.text),
        ),
      ),
      DataCell(
        Text(
          item.description ?? '—',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: AppColors.text),
        ),
      ),
      DataCell(
        Row(
          children: [
            IconButton(
              tooltip: (item.isActive) ? 'Deactivate' : 'Activate',
              icon: Icon(
                (item.isActive)
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 20,
                color: AppColors.icon,
              ),
              onPressed: () {
                _currentItem = item;
                onToggleStatus?.call();
              },
            ),
            IconButton(
              tooltip: 'Edit',
              icon: const Icon(
                Icons.edit_outlined,
                size: 20,
                color: AppColors.icon,
              ),
              onPressed: () {
                _currentItem = item;
                onEdit?.call();
              },
            ),
          ],
        ),
      ),
    ];
  }

  dynamic get currentItem => _currentItem;
}
