import 'package:get/get.dart';
import 'package:dashboard_admin/screen/main_page.dart'; // Your main page with the sidebar
import 'package:dashboard_admin/screen/auth/login_page.dart';
// Add other page imports as you create them

class AppRoutes {
  // Define route names as constants to avoid typos
  static const String splash = '/';
  static const String login = '/login';
  static const String main = '/main';
  
}

class AppPages {
  // Define the list of pages for GetX
  static final List<GetPage> routes = [
    GetPage(name: AppRoutes.login, page: () => const LoginPage()),
    GetPage(
      name: AppRoutes.main,
      page: () => MainPage(),
      // You can add Bindings here later for your controllers
    ),
  ];
}
