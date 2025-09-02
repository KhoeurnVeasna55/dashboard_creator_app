import 'package:dashboard_admin/binding/binding.dart';
import 'package:dashboard_admin/controllers/auth_controller.dart';
import 'package:dashboard_admin/core/theme/theme.dart';
import 'package:dashboard_admin/screen/auth/login_page.dart';
import 'package:dashboard_admin/screen/main_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toastification/toastification.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AuthController authController = Get.put(AuthController());

  @override
  void initState() {
    super.initState();
    authController.checkLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ToastificationWrapper(
        config: ToastificationConfig(
          maxTitleLines: 2,
          maxDescriptionLines: 6,
          marginBuilder: (context, alignment) =>
              const EdgeInsets.fromLTRB(0, 16, 0, 110),
        ),
        child: GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          initialBinding: Binding(),
          theme: AppTheme.darkTheme,
          home: authController.isLogin.isTrue ? MainPage() : LoginPage(),
        ),
      ),
    );
  }
}
