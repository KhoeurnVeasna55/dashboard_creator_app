
import 'package:get/get.dart';

class CategoryScreenController extends GetxController {
  final RxInt currentIndex = 0.obs;

  void toggleChange(int index) {
    currentIndex.value = index;
  }
}
