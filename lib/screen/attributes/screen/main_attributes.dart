import 'package:dashboard_admin/core/routes/router_utils.dart';
import 'package:dashboard_admin/screen/attributes/controller/attributes_controller.dart'
    show AttributesController;
import 'package:dashboard_admin/screen/attributes/controller/attributes_screen_controller.dart';
import 'package:dashboard_admin/screen/attributes/screen/ativity_attributes_screen.dart';
import 'package:dashboard_admin/screen/attributes/screen/attributes_screen.dart';
import 'package:dashboard_admin/screen/attributes/screen/manage_values_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainAttributes extends StatefulWidget {
  const MainAttributes({super.key});
  @override
  State<MainAttributes> createState() => _MainAttributesState();
}

class _MainAttributesState extends State<MainAttributes> {
  late final AttributesScreenController screen;
  final _router = WebPathRouter();

  String _normalize(String p) => _router.normalize(p);

  int _indexForPath(String p) {
    p = _normalize(p);

    final match = RegExp(r'^/attributes/editattributes/([^/]+)$').firstMatch(p);
    if (match != null) {
      final id = match.group(1)!;
      if (id.isNotEmpty) {
        Get.find<AttributesController>().loadAttributeForEditById(id);
      }
      if (screen.editId.value != id) screen.editId.value = id;
      if (!screen.isEditing.value) screen.isEditing.value = true;
      return 1;
    }

    final manageMatch = RegExp(r'^/attributes/manage/([^/]+)$').firstMatch(p);
    if (manageMatch != null) {
      final id = manageMatch.group(1)!;
      if (id.isNotEmpty) {
        screen.manageId.value = id;
      }
      return 2;
    }

    if (p.startsWith('/attributes/editattributes')) {
      if (screen.isEditing.value) screen.isEditing.value = false;
      screen.editId.value = '';
      return 1;
    }

    return 0;
  }

  String _pathForIndex(int i) {
    if (i == 0) return '/attributes';
    if (i == 1) {
      return screen.isEditing.value && screen.editId.value.isNotEmpty
          ? '/attributes/editattributes/${screen.editId.value}'
          : '/attributes/editattributes';
    }
    if (i == 2) {
      return screen.manageId.value.isNotEmpty
          ? '/attributes/manage/${screen.manageId.value}'
          : '/attributes/manage';
    }
    return '/attributes';
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
    screen = Get.isRegistered<AttributesScreenController>()
        ? Get.find<AttributesScreenController>()
        : Get.put(AttributesScreenController());
    if (!Get.isRegistered<AttributesController>()) {
      Get.lazyPut<AttributesController>(
        () => AttributesController(),
        fenix: true,
      );
    }

    screen.currentIndex.value = _indexForPath(_router.read());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _router.write(_pathForIndex(screen.currentIndex.value), replace: true);
    });

    _router.addListeners(() {
      if (_router.isWriting) return;
      _applyPathToState();
    });

    final attributesController = Get.find<AttributesController>();

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
        attributesController.isEditing.value = true;
        attributesController.loadAttributeForEditById(id);
      } else {
        attributesController.isEditing.value = false;
        attributesController.editingAttributesId.value = null;
        attributesController.clearForm();
      }
    });
    ever<bool>(screen.isEditing, (v) {
      attributesController.isEditing.value = v;
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
          AttributesScreen(),
          AtivityAttributesScreen(),
          ManageValuesScreen(
            // 2
            attributeId: screen.manageId.value,
            attributeName: screen.manageName.value,
            attributeType: screen.manageType.value,
          ),
        ],
      );
    });
  }
}
