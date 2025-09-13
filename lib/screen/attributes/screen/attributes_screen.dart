import 'package:dashboard_admin/core/utils/app_colors.dart';
import 'package:dashboard_admin/screen/attributes/controller/attributes_controller.dart';
import 'package:dashboard_admin/screen/attributes/controller/attributes_screen_controller.dart';
import 'package:dashboard_admin/screen/attributes/model/attributes_model.dart';
import 'package:dashboard_admin/widgets/attributes_tabel_source.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AttributesScreen extends StatefulWidget {
  const AttributesScreen({super.key});

  @override
  State<AttributesScreen> createState() => _AttributesScreenState();
}

class _AttributesScreenState extends State<AttributesScreen> {
  AttributesTableSource? _source;
  final _searchCtrl = TextEditingController();
  int? _sortColumnIndex;
  bool _sortAscending = false;
  final AttributesController _controller = Get.find();
  final AttributesScreenController _screenController = Get.find();

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() => setState(() {}));
    _controller.load();
  }

  @override
  void dispose() {
    _source?.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _applySort(String field, int columnIndex) {
    setState(() {
      if (_sortColumnIndex == columnIndex) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumnIndex = columnIndex;
        _sortAscending = false;
      }
    });
    Get.find<AttributesController>().setSort(field, _sortAscending);
  }

  AttributesTableSource _createDataSource(List<Item> list) {
    _source = AttributesTableSource(
      items: list,
      selectedIds: _controller.selected,
      onToggleSelect: (id, selected) {
        _controller.toggleSelect(id, selected);
        setState(() {});
      },
      onToggleStatus: () {
        final attribute = _source?.currentItem;
        if (attribute != null) {
          _controller.toggleStatus(attribute);
        }
      },
      onEdit: () {
        final attribute = _source?.currentItem;
        if (attribute != null) {
          _controller.loadForEdit(attribute);
          _screenController.goEdit(attribute.id);
        }
      },
      onManageValues: () {
        final attribute = _source?.currentItem;
        if (attribute != null) {
          _screenController.goManage(attribute.id);
          _screenController.manageName.value = attribute.name;
          _screenController.manageType.value = attribute.type;
        }
      },
      onDelete: () {
        final attribute = _source?.currentItem;
        if (attribute != null) {
          _showDeleteConfirmation(attribute);
        }
      },
    );
    return _source!;
  }

  Future<void> _showDeleteConfirmation(dynamic attribute) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Attribute'),
        content: Text(
          'Are you sure you want to delete "${attribute.name}"? This will also remove all its values and cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _controller.bulkDelete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AttributesController>();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text(
          'Product Attributes',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF0D0F2B),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: FilledButton.icon(
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create Attribute'),
              onPressed: () {
                Get.find<AttributesScreenController>().goAdd();
              },
              style: FilledButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue.shade600,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (ctrl.error.value != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
                const SizedBox(height: 16),
                Text(
                  'Error: ${ctrl.error.value}',
                  style: const TextStyle(color: AppColors.text, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ctrl.load(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        _source = _createDataSource(ctrl.filteredAttributes);

        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Search
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: _searchCtrl,
                                textInputAction: TextInputAction.search,
                                onSubmitted: (q) => ctrl.setSearch(q),
                                decoration: InputDecoration(
                                  hintText: 'Search attributes...',
                                  hintStyle: const TextStyle(
                                    color: AppColors.textMuted,
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.search_rounded,
                                    color: AppColors.iconMuted,
                                  ),
                                  suffixIcon: (_searchCtrl.text.isNotEmpty)
                                      ? IconButton(
                                          icon: const Icon(
                                            Icons.clear_rounded,
                                            color: AppColors.iconMuted,
                                          ),
                                          onPressed: () {
                                            _searchCtrl.clear();
                                            ctrl.setSearch('');
                                          },
                                        )
                                      : null,
                                  isDense: true,
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: AppColors.border,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: AppColors.border,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.blue.shade400,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 16),

                            // Type Filter
                            Obx(
                              () => DropdownButton<String?>(
                                value: ctrl.selectedTypeFilter.value,
                                underline: const SizedBox(),
                                hint: const Text('All Types'),
                                items: const [
                                  DropdownMenuItem(
                                    value: null,
                                    child: Text('All Types'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'color',
                                    child: Text('Color'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'size',
                                    child: Text('Size'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'material',
                                    child: Text('Material'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'style',
                                    child: Text('Style'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'brand',
                                    child: Text('Brand'),
                                  ),
                                ],
                                onChanged: ctrl.setTypeFilter,
                              ),
                            ),

                            const SizedBox(width: 16),

                            // Status Filter
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: AppColors.border),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButton<bool?>(
                                value: ctrl.isActive.value,
                                underline: const SizedBox(),
                                hint: const Text('Status'),
                                items: const [
                                  DropdownMenuItem(
                                    value: null,
                                    child: Text('All Status'),
                                  ),
                                  DropdownMenuItem(
                                    value: true,
                                    child: Text('Active'),
                                  ),
                                  DropdownMenuItem(
                                    value: false,
                                    child: Text('Inactive'),
                                  ),
                                ],
                                onChanged: ctrl.setIsActiveFilter,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Summary Row
                        Row(
                          children: [
                            Obx(() {
                              final count = ctrl.selected.length;
                              return Text(
                                count > 0
                                    ? '$count attribute(s) selected'
                                    : '${ctrl.items.length} attributes total',
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 14,
                                ),
                              );
                            }),

                            const Spacer(),

                            // Bulk Delete
                            Obx(() {
                              final count = ctrl.selected.length;
                              final hasSel = count > 0;
                              return FilledButton.icon(
                                onPressed: hasSel
                                    ? () async {
                                        final confirmed = await showDialog<bool>(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: const Text(
                                              'Delete Selected Attributes',
                                            ),
                                            content: Text(
                                              'Are you sure you want to delete $count selected attribute(s)? This cannot be undone.',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(ctx, false),
                                                child: const Text('Cancel'),
                                              ),
                                              FilledButton(
                                                style: FilledButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                ),
                                                onPressed: () =>
                                                    Navigator.pop(ctx, true),
                                                child: const Text('Delete'),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirmed == true) {
                                          await ctrl.bulkDelete();
                                        }
                                      }
                                    : null,
                                icon: const Icon(Icons.delete_rounded),
                                label: Text('Delete ($count)'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: hasSel
                                      ? Colors.red.shade600
                                      : Colors.red.shade200,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Enhanced Data Table
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        cardColor: AppColors.surface,
                        canvasColor: AppColors.surface,
                        dataTableTheme: DataTableThemeData(
                          headingRowColor: WidgetStateProperty.all(
                            AppColors.surface,
                          ),
                          headingTextStyle: const TextStyle(
                            color: AppColors.text,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          dataRowColor: WidgetStateProperty.resolveWith<Color?>(
                            (states) {
                              if (states.contains(WidgetState.selected)) {
                                return Colors.blue.shade50;
                              }
                              return AppColors.surface;
                            },
                          ),
                          dividerThickness: 0.5,
                        ),
                      ),
                      child: PaginatedDataTable(
                        header: Row(
                          children: [
                            const Icon(
                              Icons.tune_rounded,
                              color: AppColors.text,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              ctrl.search.value.isEmpty
                                  ? 'All Attributes'
                                  : 'Search Results: "${ctrl.search.value}"',
                              style: const TextStyle(
                                color: AppColors.text,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        onSelectAll: (v) {
                          ctrl.selectAllOnPage(v ?? false);
                          setState(() {});
                        },
                        columns: [
                          DataColumn(
                            label: const Text('Name & Code'),
                            onSort: (_, __) => _applySort('name', 0),
                          ),
                          DataColumn(
                            label: const Text('Type'),
                            onSort: (_, __) => _applySort('type', 1),
                          ),
                          const DataColumn(label: Text('Values')),
                          DataColumn(
                            label: const Text('Status'),
                            onSort: (_, __) => _applySort('isActive', 3),
                          ),
                          DataColumn(
                            label: const Text('Created'),
                            onSort: (_, __) => _applySort('createdAt', 4),
                          ),
                          const DataColumn(label: Text('Actions')),
                        ],
                        source: _source!,
                        sortColumnIndex: _sortColumnIndex,
                        sortAscending: _sortAscending,
                        onPageChanged: (startIndex) {
                          final newPage = (startIndex ~/ ctrl.limit.value) + 1;
                          ctrl.load(toPage: newPage);
                        },
                        rowsPerPage: ctrl.limit.value,
                        onRowsPerPageChanged: (v) =>
                            v != null ? ctrl.setRowsPerPage(v) : null,
                        availableRowsPerPage: const [5, 10, 15, 20, 25, 50],
                        showFirstLastButtons: true,
                        columnSpacing: 24,
                        horizontalMargin: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Loading Overlay
            if (ctrl.loading.isTrue)
              Container(
                color: Colors.black.withValues(alpha: 0.5),
                child: const Center(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Loading attributes...'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}
