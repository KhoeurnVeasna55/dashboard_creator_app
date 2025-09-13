import 'package:dashboard_admin/core/utils/app_colors.dart';
import 'package:dashboard_admin/screen/banner_screen/controller/banner_controller.dart';
import 'package:dashboard_admin/screen/banner_screen/controller/createbanner_controller.dart';
import 'package:dashboard_admin/widgets/banner_table_source.dart';
import 'package:dashboard_admin/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BannerScreen extends StatefulWidget {
  const BannerScreen({super.key});

  @override
  State<BannerScreen> createState() => _BannerScreenState();
}

class _BannerScreenState extends State<BannerScreen> {
  BannerTableSource? _source;
  final _searchCtrl = TextEditingController();
  int? _sortColumnIndex;
  bool _sortAscending = false;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() => setState(() {}));
    Get.find<BannerController>().load();
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
    Get.find<BannerController>().setSort(field, _sortAscending);
  }

  BannerTableSource _createDataSource(BannerController ctrl) {
    _source = BannerTableSource(
      items: ctrl.items,
      selectedIds: ctrl.selected,
      onToggleSelect: (id, selected) {
        ctrl.toggleSelect(id, selected);
        setState(() {});
      },
      onToggleStatus: () {
        final banner = _source?.currentItem;
        if (banner != null) {
          ctrl.toggleStatus(banner);
        }
      },
      onEdit: () {
        final banner = _source?.currentItem;
        if (banner != null) {
          ctrl.loadForEdit(banner);
          Get.find<CreatebannerscreenController>().goEdit(banner.id);
        }
      },
      onDelete: () {
        final banner = _source?.currentItem;
        if (banner != null) {
          _showDeleteConfirmation(banner);
        }
      },
    );
    return _source!;
  }

  Future<void> _showDeleteConfirmation(dynamic banner) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Banner'),
        content: Text(
          'Are you sure you want to delete "${banner.title ?? 'this banner'}"? This cannot be undone.',
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
      // Call your delete method here
      // await Get.find<BannerController>().deleteBanner(banner.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<BannerController>();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text(
          'Banner Management',
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
              label: const Text('Create Banner'),
              onPressed: () {
                Get.find<CreatebannerscreenController>().goAdd();
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

        _source = _createDataSource(ctrl);

        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Enhanced Toolbar
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
                                  hintText: 'Search banners...',
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

                        // Bulk Actions Row
                        Row(
                          children: [
                            Obx(() {
                              final count = ctrl.selected.length;
                              return Text(
                                count > 0
                                    ? '$count banner(s) selected'
                                    : '${ctrl.items.length} banners total',
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
                                              'Delete Selected Banners',
                                            ),
                                            content: Text(
                                              'Are you sure you want to delete $count selected banner(s)? This cannot be undone.',
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
                              Icons.view_carousel_rounded,
                              color: AppColors.text,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              ctrl.search.value.isEmpty
                                  ? 'All Banners'
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
                            label: const Text('Banner'),
                            onSort: (_, __) => _applySort('title', 0),
                          ),
                          const DataColumn(
                            label: Text('Position'),
                            numeric: true,
                          ),
                          DataColumn(
                            label: const Text('Status'),
                            onSort: (_, __) => _applySort('isActive', 2),
                          ),
                          DataColumn(
                            label: const Text('Start Date'),
                            onSort: (_, __) => _applySort('startDate', 3),
                          ),
                          DataColumn(
                            label: const Text('End Date'),
                            onSort: (_, __) => _applySort('endDate', 4),
                          ),
                          const DataColumn(label: Text('Description')),
                          const DataColumn(label: Text('Link')),
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

            if (ctrl.loading.isTrue) LoadingWidget(text: 'Loading Banners'),
          ],
        );
      }),
    );
  }
}
