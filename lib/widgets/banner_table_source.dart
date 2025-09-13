import 'package:dashboard_admin/core/utils/app_colors.dart';
import 'package:dashboard_admin/widgets/category_table_source.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BannerTableSource extends BaseTableSource<dynamic> {
  BannerTableSource({
    required super.items,
    super.selectedIds,
    super.onToggleSelect,
    this.onToggleStatus,
    this.onEdit,
    this.onDelete,
  });

  final void Function()? onToggleStatus;
  final void Function()? onEdit;
  final void Function()? onDelete;

  dynamic _currentItem;
  final _fmt = DateFormat('yyyy-MM-dd');

  @override
  String getItemId(dynamic item) => item.id ?? '';

  @override
  List<DataCell> buildCells(dynamic item, int index) {
    _currentItem = item;

    return [
      DataCell(
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 200),
          child: Row(
            children: [
              if (item.imageUrl != null && item.imageUrl!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.imageUrl!,
                      height: 40,
                      width: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 60,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 16,
                            color: AppColors.iconMuted,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.title ?? '—',
                      style: const TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.subtitle != null && item.subtitle!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          item.subtitle!,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      DataCell(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            '${item.position ?? 0}',
            style: const TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
      ),

      // Status
      DataCell(_statusPill(item.isActive ?? false)),

      // Start Date
      DataCell(
        Text(
          item.startDate != null ? _fmt.format(item.startDate!) : '—',
          style: const TextStyle(color: AppColors.text, fontSize: 13),
        ),
      ),

      DataCell(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              item.endDate != null ? _fmt.format(item.endDate!) : '—',
              style: const TextStyle(color: AppColors.text, fontSize: 13),
            ),
            if (item.endDate != null)
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Icon(
                  _getDateStatusIcon(item.endDate!),
                  size: 14,
                  color: _getDateStatusColor(item.endDate!),
                ),
              ),
          ],
        ),
      ),

      // Description
      DataCell(
        SizedBox(
          width: 150,
          child: Text(
            item.description ?? '—',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.text, fontSize: 13),
          ),
        ),
      ),

      // Link URL (clickable if present)
      DataCell(
        item.linkUrl != null && item.linkUrl!.isNotEmpty
            ? InkWell(
                onTap: () {
                  // You can add URL launching logic here
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.link, size: 14, color: Colors.blue),
                      const SizedBox(width: 4),
                      Text(
                        'View Link',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : const Text('—', style: TextStyle(color: AppColors.textMuted)),
      ),

      // Actions
      DataCell(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status Toggle
            IconButton(
              tooltip: (item.isActive ?? false) ? 'Deactivate' : 'Activate',
              icon: Icon(
                (item.isActive ?? false)
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 18,
                color: AppColors.icon,
              ),
              onPressed: () {
                _currentItem = item;
                onToggleStatus?.call();
              },
            ),

            // Edit
            IconButton(
              tooltip: 'Edit Banner',
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

            // Delete (optional)
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

  IconData _getDateStatusIcon(DateTime endDate) {
    final now = DateTime.now();
    final daysUntilEnd = endDate.difference(now).inDays;

    if (daysUntilEnd < 0) {
      return Icons.error_outline; // Expired
    } else if (daysUntilEnd <= 7) {
      return Icons.warning_outlined; // Expiring soon
    } else {
      return Icons.check_circle_outline; // Active
    }
  }

  Color _getDateStatusColor(DateTime endDate) {
    final now = DateTime.now();
    final daysUntilEnd = endDate.difference(now).inDays;

    if (daysUntilEnd < 0) {
      return Colors.red;
    } else if (daysUntilEnd <= 7) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }
}
