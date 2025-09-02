
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

  // Workers to notify DataTable when data/meta change
  late final Worker _wItems;
  late final Worker _wTotal;
  late final Worker _wSelection;

  @override
  void initState() {
    super.initState();
    final ctrl = Get.find<CategoryController>();
    _source = CategoryTableSource(ctrl);

    _wItems =
        ever<List<Category>>(ctrl.items, (_) => _source.notifyListeners());
    _wTotal = ever<int>(ctrl.total, (_) => _source.notifyListeners());
    _wSelection =
        ever<Set<String>>(ctrl.selected, (_) => _source.notifyListeners());

    ctrl.load();
  }

  @override
  void dispose() {
    _wItems.dispose();
    _wTotal.dispose();
    _wSelection.dispose();
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
      ),
      body: Obx(() {
        if (ctrl.error.value != null) {
          return Center(
              child: Text('Error: ${ctrl.error.value}',
                  style: const TextStyle(color: AppColors.text)));
        }
        return SingleChildScrollView(
          child: Column(
            children: [
              // Toolbar (Search + Filter + Bulk Actions)
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
                        offset: const Offset(0, 4))
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
                          prefixIcon: const Icon(Icons.search,
                              color: AppColors.iconMuted),
                          suffixIcon: (_searchCtrl.text.isNotEmpty)
                              ? IconButton(
                                  icon: const Icon(Icons.clear,
                                      color: AppColors.iconMuted),
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
                            borderSide:
                                const BorderSide(color: AppColors.border),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                const BorderSide(color: AppColors.border),
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
                        DropdownMenuItem(value: true, child: Text('Active')),
                        DropdownMenuItem(value: false, child: Text('Inactive')),
                      ],
                      onChanged: ctrl.setIsActiveFilter,
                    ),
                    const Spacer(),
                    // Bulk actions on selection
                    Obx(() {
                      final count = ctrl.selected.length;
                      final hasSel = count > 0;
                      return Row(
                        children: [
                          Text('Selected: $count',
                              style: const TextStyle(
                                  color: AppColors.textMuted)),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.text,
                              side: const BorderSide(color: AppColors.border),
                            ),
                            onPressed:
                                hasSel ? () => ctrl.bulkSetStatus(true) : null,
                            child: const Text('Set Active'),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.text,
                              side: const BorderSide(color: AppColors.border),
                            ),
                            onPressed:
                                hasSel ? () => ctrl.bulkSetStatus(false) : null,
                            child: const Text('Set Inactive'),
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
                  // Make the table “sheet” and paginator use your surface color
                  cardColor: AppColors.surface,
                  canvasColor: AppColors.surface,
                  colorScheme: Theme.of(context).colorScheme.copyWith(
                        surface: AppColors.surface,
                        onSurface: AppColors.text,
                        // (M3 tokens some builds use)
                        surfaceContainerHighest: AppColors.surface,
                        surfaceContainerHigh: AppColors.surface,
                        surfaceContainer: AppColors.surface,
                      ),
                  // Divider/border look
                  dividerTheme: const DividerThemeData(
                    color: AppColors.border,
                    thickness: 0.6,
                    space: 0.6,
                  ),
                  // Paginator buttons (chevrons etc.)
                  iconButtonTheme: IconButtonThemeData(
                    style: ButtonStyle(
                      foregroundColor:
                          WidgetStateProperty.all(AppColors.icon),
                      overlayColor: WidgetStateProperty.all(
                          Colors.black.withOpacity(.05)),
                    ),
                  ),
                  // Rows-per-page dropdown & menu
                  dropdownMenuTheme: const DropdownMenuThemeData(
                    textStyle: TextStyle(color: AppColors.text),
                    menuStyle: MenuStyle(
                      backgroundColor:
                          WidgetStatePropertyAll(AppColors.surface),
                      surfaceTintColor:
                          WidgetStatePropertyAll(Colors.transparent),
                      elevation: WidgetStatePropertyAll(2),
                    ),
                  ),
                  // Text defaults inside the paginator/footer
                  textTheme: Theme.of(context).textTheme.copyWith(
                        bodyMedium: const TextStyle(color: AppColors.text),
                        titleMedium: const TextStyle(color: AppColors.text),
                      ),
                  // Core DataTable visuals (rows/header)
                  dataTableTheme: DataTableThemeData(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    headingRowColor:
                        WidgetStateProperty.all(AppColors.surface),
                    headingTextStyle: const TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.w600,
                    ),
                    dataRowColor:
                        WidgetStateProperty.resolveWith<Color?>((states) {
                      // Selected rows subtle gray; others white/very light gray stripe
                      if (states.contains(WidgetState.selected)) {
                        return const Color(0xFFF0F2F5);
                      }
                      return AppColors
                          .surface; // solid white; or set stripes in getRow()
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
                  // Selection: header checkbox
                  onSelectAll: (v) => ctrl.selectAllOnPage(v ?? false),
              
                  columns: [
                    DataColumn(
                      label: const Text('Name',
                          style: TextStyle(color: AppColors.text)),
                      onSort: (_, __) => _applySort('name', 0),
                    ),
                    const DataColumn(
                        label: Text('Slug',
                            style: TextStyle(color: AppColors.text))),
                    DataColumn(
                      label: const Text('Status',
                          style: TextStyle(color: AppColors.text)),
                      onSort: (_, __) => _applySort('isActive', 2),
                    ),
                    DataColumn(
                      label: const Text('Created',
                          style: TextStyle(color: AppColors.text)),
                      onSort: (_, __) => _applySort('createdAt', 3),
                    ),
                    const DataColumn(
                        label: Text('Description',
                            style: TextStyle(color: AppColors.text))),
                    const DataColumn(
                        label: Text('Actions',
                            style: TextStyle(color: AppColors.text))),
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
                  // Neutralize default divider color a bit
                  dividerThickness: 0.6,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}