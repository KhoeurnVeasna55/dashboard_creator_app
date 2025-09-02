import 'package:dashboard_admin/screen/category_screen/category_screen.dart';
import 'package:dashboard_admin/screen/category_screen/category_screen_controller.dart';
import 'package:dashboard_admin/screen/category_screen/create_category_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainCategory extends StatelessWidget {
  const MainCategory({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CategoryScreenController());

    return Obx(() {
      return IndexedStack(
        index: controller.currentIndex.value,
        children: [CategoryScreen(), CreateCategoryScreen()],
      );
    });
  }
}
