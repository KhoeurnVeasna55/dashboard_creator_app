// category_screen_controller.dart
import 'package:get/get.dart';

class CategoryScreenController extends GetxController {
  final RxInt currentIndex = 0.obs; // 0=list, 1=form
  final RxString editId = ''.obs;
  final RxBool isEditing = false.obs;

  void goList() {
    isEditing.value = false;
    editId.value = '';
    currentIndex.value = 0;
  }

  void goAdd() {
    isEditing.value = false;
    editId.value = '';
    currentIndex.value = 1;
  }

  void goEdit(String id) {
    editId.value = id;
    isEditing.value = true;
    currentIndex.value = 1;
  }
}
