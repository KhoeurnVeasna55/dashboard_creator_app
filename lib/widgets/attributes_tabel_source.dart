import 'package:dashboard_admin/core/utils/app_colors.dart';
import 'package:dashboard_admin/widgets/category_table_source.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AttributesTableSource extends BaseTableSource<dynamic> {
  AttributesTableSource({
    required super.items,
    super.selectedIds,
    super.onToggleSelect,
    this.onToggleStatus,
    this.onEdit,
    this.onDelete,
    this.onManageValues,
  });

  final void Function()? onToggleStatus;
  final void Function()? onEdit;
  final void Function()? onDelete;
  final void Function()? onManageValues;

  dynamic _currentItem;
  final _fmt = DateFormat('yyyy-MM-dd');

  @override
  String getItemId(dynamic item) => item.id ?? '';

  @override
  List<DataCell> buildCells(dynamic item, int index) {
    _currentItem = item;

    return [
      // Name with Type indicator
      DataCell(
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.name ?? '—',
                style: const TextStyle(
                  color: AppColors.text,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                item.code ?? '—',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),

      // Type with colored badge
      DataCell(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _getTypeColor(item.type).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _getTypeColor(item.type).withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            _formatType(item.type ?? 'unknown'),
            style: TextStyle(
              color: _getTypeColor(item.type),
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ),
      ),

      // Values count with preview
      DataCell(_buildValuesPreview(item.values ?? [])),

      // Status
      DataCell(_statusPill(item.isActive ?? false)),

      // Created Date
      DataCell(
        Text(
          _fmt.format(item.createdAt),
          style: const TextStyle(color: AppColors.text, fontSize: 13),
        ),
      ),

      // Actions
      DataCell(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Manage Values
            IconButton(
              tooltip: 'Manage Values',
              icon: const Icon(
                Icons.tune_outlined,
                size: 18,
                color: Colors.blue,
              ),
              onPressed: () {
                _currentItem = item;
                onManageValues?.call();
              },
            ),

            // Status Toggle
            // IconButton(
            //   tooltip: (item.isActive ?? false) ? 'Deactivate' : 'Activate',
            //   icon: Icon(
            //     (item.isActive ?? false)
            //         ? Icons.visibility_off_outlined
            //         : Icons.visibility_outlined,
            //     size: 18,
            //     color: AppColors.icon,
            //   ),
            //   onPressed: () {
            //     _currentItem = item;
            //     onToggleStatus?.call();
            //   },
            // ),

            // Edit
            IconButton(
              tooltip: 'Edit Attribute',
              icon: const Icon(
                Icons.edit_outlined,
                size: 18,
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

  Widget _buildValuesPreview(List<dynamic> values) {
    if (values.isEmpty) {
      return const Text(
        'No values',
        style: TextStyle(color: AppColors.textMuted),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Count badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Text(
            '${values.length}',
            style: TextStyle(
              color: Colors.blue.shade700,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Preview of first few values
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < (values.length > 3 ? 3 : values.length); i++)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: _buildValueChip(values[i]),
                ),
              if (values.length > 3)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  child: Text(
                    '+${values.length - 3}',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildValueChip(dynamic value) {
    final swatch = value.meta?.swatch;
    final label = value.label ?? value.value ?? '—';

    if (swatch != null && swatch.toString().startsWith('#')) {
      // Color swatch
      return Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: _parseColor(swatch.toString()),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
      );
    } else {
      // Text value
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label.length > 8 ? '${label.substring(0, 8)}...' : label,
          style: const TextStyle(fontSize: 10, color: AppColors.text),
        ),
      );
    }
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.substring(1), radix: 16) + 0xFF000000);
    } catch (e) {
      return Colors.grey;
    }
  }

  Color _getTypeColor(String? type) {
    switch (type?.toLowerCase()) {
      case 'color':
        return Colors.purple;
      case 'size':
        return Colors.orange;
      case 'material':
        return Colors.brown;
      case 'style':
        return Colors.pink;
      case 'brand':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  String _formatType(String type) {
    return type
        .split('_')
        .map(
          (word) => word.isEmpty
              ? word
              : word[0].toUpperCase() + word.substring(1).toLowerCase(),
        )
        .join(' ');
  }
}
