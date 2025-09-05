import 'package:dashboard_admin/core/routes/router_utils.dart';
import 'package:dashboard_admin/screen/category_screen/category_screen.dart';
import 'package:dashboard_admin/screen/category_screen/create_category_screen.dart';
import 'package:dashboard_admin/screen/category_screen/category_screen_controller.dart';
import 'package:dashboard_admin/screen/category_screen/controller/category_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainCategory extends StatefulWidget {
  const MainCategory({super.key});
  @override
  State<MainCategory> createState() => _MainCategoryState();
}

class _MainCategoryState extends State<MainCategory> {
  late final CategoryScreenController screen;
  final _router = WebPathRouter();

  String _normalize(String p) => _router.normalize(p);

  int _indexForPath(String p) {
    p = _normalize(p);
    final match = RegExp(r'^/categories/editcategories/([^/]+)$').firstMatch(p);
    if (match != null) {
      final id = match.group(1)!;
      if (id.isNotEmpty) {
        Get.find<CategoryController>().loadCategoryForEditById(id);
      }
      if (screen.editId.value != id) screen.editId.value = id;
      if (!screen.isEditing.value) screen.isEditing.value = true;
      return 1;
    }
    if (p.startsWith('/categories/addcategories')) {
      if (screen.isEditing.value) screen.isEditing.value = false;
      screen.editId.value = '';
      return 1;
    }

    // default list
    return 0;
  }

  // index -> canonical path (list or form path)
  String _pathForIndex(int i) {
    if (i == 0) return '/categories';
    if (i == 1) {
      return screen.isEditing.value && screen.editId.value.isNotEmpty
          ? '/categories/editcategories/${screen.editId.value}'
          : '/categories/addcategories';
    }
    return '/categories';
  }

  void _applyPathToState() {
    final idx = _indexForPath(_router.read());
    if (screen.currentIndex.value != idx) {
      screen.currentIndex.value = idx;
    }
  }

  @override
  void initState() {
    super.initState();

    // ensure controllers...
    screen = Get.isRegistered<CategoryScreenController>()
        ? Get.find<CategoryScreenController>()
        : Get.put(CategoryScreenController());
    if (!Get.isRegistered<CategoryController>()) {
      Get.lazyPut<CategoryController>(() => CategoryController(), fenix: true);
    }

    // init from URL
    screen.currentIndex.value = _indexForPath(_router.read());

    // assert canonical subroute on first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _router.write(_pathForIndex(screen.currentIndex.value), replace: true);
    });

    // react to browser nav
    _router.addListeners(() {
      if (_router.isWriting) return;
      _applyPathToState();
    });

    final categoryController = Get.find<CategoryController>();

    // ✅ When user switches between list/form, push the matching path
    ever<int>(screen.currentIndex, (i) {
      if (_router.isWriting) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _router.write(_pathForIndex(i)); // push
      });
    });

    // ✅ When switching add<->edit or changing :id, fix the form URL
    everAll([screen.isEditing, screen.editId], (_) {
      if (_router.isWriting) return;
      if (screen.currentIndex.value != 1) return; // only care on form
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _router.write(
          _pathForIndex(1),
          replace: true,
        ); // replace so history is clean
      });
    });

    // existing data-loading hooks (keep these)
    ever<String>(screen.editId, (id) {
      if (id.isNotEmpty) {
        screen.isEditing.value = true;
        categoryController.isEditing.value = true;
        categoryController.loadCategoryForEditById(id);
      } else {
        categoryController.isEditing.value = false;
        categoryController.editingCategoryId.value = null;
        categoryController.clearForm();
      }
    });
    ever<bool>(screen.isEditing, (v) {
      categoryController.isEditing.value = v;
    });
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final i = screen.currentIndex.value;
      return IndexedStack(
        index: i,
        children: [
          CategoryPage(),
          CreateCategoryScreen(),
        ],
      );
    });
  }
}
