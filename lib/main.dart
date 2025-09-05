import 'package:dashboard_admin/controllers/auth_controller.dart';
import 'package:dashboard_admin/myapp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'services/store_token.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  usePathUrlStrategy();
  await GetStorage.init();
  await dotenv.load(fileName: ".env");
  StoreToken.initialize();
  Get.put(AuthController());
  runApp(const MyApp());
}