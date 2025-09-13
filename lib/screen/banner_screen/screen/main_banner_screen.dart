import 'package:dashboard_admin/core/routes/router_utils.dart';
import 'package:dashboard_admin/screen/banner_screen/controller/banner_controller.dart';
import 'package:dashboard_admin/screen/banner_screen/controller/createbanner_controller.dart';
import 'package:dashboard_admin/screen/banner_screen/screen/ativity_banner_screen.dart';
import 'package:dashboard_admin/screen/banner_screen/screen/bannner_screen.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainBannerScreen extends StatefulWidget {
  const MainBannerScreen({super.key});
  @override
  State<MainBannerScreen> createState() => _MainBannerScreenState();
}

class _MainBannerScreenState extends State<MainBannerScreen> {
  late final CreatebannerscreenController screen;
  final _router = WebPathRouter();

  String _normalize(String p) => _router.normalize(p);

  int _indexForPath(String p) {
    p = _normalize(p);
    final match = RegExp(r'^/banner/editBanner/([^/]+)$').firstMatch(p);
    if (match != null) {
      final id = match.group(1)!;
      if (id.isNotEmpty) {
        Get.find<BannerController>().loadBannerForEditById(id);
      }
      if (screen.editId.value != id) screen.editId.value = id;
      if (!screen.isEditing.value) screen.isEditing.value = true;
      return 1;
    }
    if (p.startsWith('/banners/addbanners')) {
      if (screen.isEditing.value) screen.isEditing.value = false;
      screen.editId.value = '';
      return 1;
    }

    // default list
    return 0;
  }

  // index -> canonical path (list or form path)
  String _pathForIndex(int i) {
    if (i == 0) return '/banners';
    if (i == 1) {
      return screen.isEditing.value && screen.editId.value.isNotEmpty
          ? '/banner/editBanner/${screen.editId.value}'
          : '/banner/editBanner';
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
    screen = Get.isRegistered<CreatebannerscreenController>()
        ? Get.find<CreatebannerscreenController>()
        : Get.put(CreatebannerscreenController());
    if (!Get.isRegistered<BannerController>()) {
      Get.lazyPut<BannerController>(() => BannerController(), fenix: true);
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

    final bannerController = Get.find<BannerController>();

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
        bannerController.isEditing.value = true;
        bannerController.loadBannerForEditById(id);
      } else {
        bannerController.isEditing.value = false;
        bannerController.editingCategoryId.value = null;
        bannerController.clearForm();
      }
    });
    ever<bool>(screen.isEditing, (v) {
      bannerController.isEditing.value = v;
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
        children: [BannerScreen(), AtivityBannerScreen()],
      );
    });
  }
}
