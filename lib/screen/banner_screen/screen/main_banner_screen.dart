import 'package:dashboard_admin/screen/banner_screen/controller/banner_controller.dart';
import 'package:dashboard_admin/screen/banner_screen/screen/ativity_banner_screen.dart';
import 'package:dashboard_admin/screen/banner_screen/screen/bannner_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainBannerScreen extends StatelessWidget {
  const MainBannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BannerController _banner = Get.find();
    return IndexedStack(
      index: _banner.currentScreen.value,
      children: [
        BannnerScreen(),
        AtivityBannerScreen()
      ],
    );
  }
}
