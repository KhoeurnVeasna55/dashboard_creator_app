import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/product_controller.dart';

class MainProductScreen extends StatelessWidget {
  MainProductScreen({super.key});
  final ProductController _productScreenController = Get.put(ProductController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => _productScreenController
            .screens[_productScreenController.currentIndex.value],
      ),
    );
  }
}
