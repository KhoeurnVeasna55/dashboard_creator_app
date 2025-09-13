import 'package:dashboard_admin/screen/attributes/controller/attributes_controller.dart';
import 'package:get/get.dart';

class AttributesScreenController extends GetxController {
  final RxInt currentIndex = 0.obs;
  final RxString editId = ''.obs;
  final RxBool isEditing = false.obs;
  final manageId = ''.obs;
  final manageName = ''.obs;
  final manageType = ''.obs;

  void goManage(String id) {
    manageId.value = id;
    currentIndex.value = 2;
    Get.find<AttributesController>().loadValues(id);
  }

  void goList() {
    currentIndex.value = 0;
    manageId.value = '';
    editId.value = '';
    isEditing.value = false;
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
