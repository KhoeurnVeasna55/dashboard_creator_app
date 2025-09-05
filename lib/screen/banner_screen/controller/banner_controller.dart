import 'package:get/get.dart';

class BannerController extends GetxController {
  final RxInt currentScreen = 0.obs;

  void toggleScreen(int index) {
    currentScreen.value = index;
  }
}
