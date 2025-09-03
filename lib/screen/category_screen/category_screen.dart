import 'package:dashboard_admin/core/utils/app_colors.dart';
import 'package:dashboard_admin/screen/category_screen/controller/category_controller.dart';
import 'package:dashboard_admin/screen/category_screen/models/category_model.dart';
import 'package:dashboard_admin/widgets/category_table_source.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// ---------------------------
/// Page with PaginatedDataTable in a styled Container
/// ---------------------------
class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});
  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  late final CategoryTableSource _source;
  final _searchCtrl = TextEditingController();
  int? _sortColumnIndex;
  bool _sortAscending = false;

  @override
  void initState() {
    super.initState();
    final ctrl = Get.find<CategoryController>();
    _source = CategoryTableSource(ctrl); // listens internally; safe to notify
    _searchCtrl.addListener(() => setState(() {})); // update suffix icon
    ctrl.load();
  }

  @override
  void dispose() {
    _source.dispose(); // <-- important: dispose workers inside source
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
    Get.find<CategoryController>().setSort(field, _sortAscending);
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<CategoryController>();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Categories'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          // --- NEW: Create button in header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: FilledButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Create'),
              onPressed: () => ctrl.create(),
              style: FilledButton.styleFrom(foregroundColor: Colors.white),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (ctrl.error.value != null) {
          return Center(
            child: Text(
              'Error: ${ctrl.error.value}',
              style: const TextStyle(color: AppColors.text),
            ),
          );
        }
        return Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  // Toolbar (Search + Filter + Bulk Delete)
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Search
                        SizedBox(
                          width: 320,
                          child: TextField(
                            controller: _searchCtrl,
                            textInputAction: TextInputAction.search,
                            onSubmitted: (q) => ctrl.setSearch(q),
                            decoration: InputDecoration(
                              hintText: 'Search name/description',
                              prefixIcon: const Icon(
                                Icons.search,
                                color: AppColors.iconMuted,
                              ),
                              suffixIcon: (_searchCtrl.text.isNotEmpty)
                                  ? IconButton(
                                      icon: const Icon(
                                        Icons.clear,
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
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Status Filter
                        DropdownButton<bool?>(
                          value: ctrl.isActive.value,
                          underline: const SizedBox(),
                          items: const [
                            DropdownMenuItem(value: null, child: Text('All')),
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
                        const Spacer(),
                        // --- CHANGED: Bulk Delete only
                        Obx(() {
                          final count = ctrl.selected.length;
                          final hasSel = count > 0;
                          return Row(
                            children: [
                              Text(
                                'Selected: $count',
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(width: 8),
                              FilledButton.icon(
                                onPressed: hasSel
                                    ? () async {
                                        final confirmed = await showDialog<bool>(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: const Text(
                                              'Delete selected',
                                            ),
                                            content: Text(
                                              'Are you sure you want to delete $count selected item(s)? This cannot be undone.',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(ctx, false),
                                                child: const Text('Cancel'),
                                              ),
                                              FilledButton(
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
                                icon: const Icon(Icons.delete),
                                label: const Text('Delete'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.red.shade600,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: Colors.red.shade200,
                                  disabledForegroundColor: Colors.white70,
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),

                  // The table
                  Theme(
                    // Local theme JUST for this table + paginator
                    data: Theme.of(context).copyWith(
                      cardColor: AppColors.surface,
                      canvasColor: AppColors.surface,
                      colorScheme: Theme.of(context).colorScheme.copyWith(
                        surface: AppColors.surface,
                        onSurface: AppColors.text,
                        surfaceContainerHighest: AppColors.surface,
                        surfaceContainerHigh: AppColors.surface,
                        surfaceContainer: AppColors.surface,
                      ),
                      dividerTheme: const DividerThemeData(
                        color: AppColors.border,
                        thickness: 0.6,
                        space: 0.6,
                      ),
                      iconButtonTheme: IconButtonThemeData(
                        style: ButtonStyle(
                          foregroundColor: WidgetStateProperty.all(
                            AppColors.icon,
                          ),
                          overlayColor: WidgetStateProperty.all(
                            Colors.black.withOpacity(.05),
                          ),
                        ),
                      ),
                      dropdownMenuTheme: const DropdownMenuThemeData(
                        textStyle: TextStyle(color: AppColors.text),
                        menuStyle: MenuStyle(
                          backgroundColor: WidgetStatePropertyAll(
                            AppColors.surface,
                          ),
                          surfaceTintColor: WidgetStatePropertyAll(
                            Colors.transparent,
                          ),
                          elevation: WidgetStatePropertyAll(2),
                        ),
                      ),
                      textTheme: Theme.of(context).textTheme.copyWith(
                        bodyMedium: const TextStyle(color: AppColors.text),
                        titleMedium: const TextStyle(color: AppColors.text),
                      ),
                      dataTableTheme: DataTableThemeData(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        headingRowColor: WidgetStateProperty.all(
                          AppColors.surface,
                        ),
                        headingTextStyle: const TextStyle(
                          color: AppColors.text,
                          fontWeight: FontWeight.w600,
                        ),
                        dataRowColor: WidgetStateProperty.resolveWith<Color?>((
                          states,
                        ) {
                          if (states.contains(WidgetState.selected)) {
                            return const Color(0xFFF0F2F5);
                          }
                          return AppColors.surface;
                        }),
                        dividerThickness: 0.6,
                      ),
                    ),
                    child: PaginatedDataTable(
                      header: Text(
                        ctrl.search.value.isEmpty
                            ? 'All Categories'
                            : 'Filtered (query: "${ctrl.search.value}")',
                        style: const TextStyle(color: AppColors.text),
                      ),
                      onSelectAll: (v) => ctrl.selectAllOnPage(v ?? false),

                      columns: [
                        DataColumn(
                          label: const Text(
                            'Name',
                            style: TextStyle(color: AppColors.text),
                          ),
                          onSort: (_, __) => _applySort('name', 0),
                        ),
                        const DataColumn(
                          label: Text(
                            'Slug',
                            style: TextStyle(color: AppColors.text),
                          ),
                        ),
                        DataColumn(
                          label: const Text(
                            'Status',
                            style: TextStyle(color: AppColors.text),
                          ),
                          onSort: (_, __) => _applySort('isActive', 2),
                        ),
                        DataColumn(
                          label: const Text(
                            'Created',
                            style: TextStyle(color: AppColors.text),
                          ),
                          onSort: (_, __) => _applySort('createdAt', 3),
                        ),
                        const DataColumn(
                          label: Text(
                            'Description',
                            style: TextStyle(color: AppColors.text),
                          ),
                        ),
                        const DataColumn(
                          label: Text(
                            'Actions',
                            style: TextStyle(color: AppColors.text),
                          ),
                        ),
                      ],
                      source: _source,
                      sortColumnIndex: _sortColumnIndex,
                      sortAscending: _sortAscending,
                      onPageChanged: (startIndex) {
                        final newPage = (startIndex ~/ ctrl.limit.value) + 1;
                        ctrl.load(toPage: newPage);
                      },
                      rowsPerPage: ctrl.limit.value,
                      onRowsPerPageChanged: (v) =>
                          v != null ? ctrl.setRowsPerPage(v) : null,
                      availableRowsPerPage: const [5, 10, 15, 20, 25, 50, 100],
                      showFirstLastButtons: true,
                      dividerThickness: 0.6,
                    ),
                  ),
                ],
              ),
            ),

            if (ctrl.loading.isTrue)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator.adaptive(),
                ),
              ),
          ],
        );
      }),
    );
  }
}
