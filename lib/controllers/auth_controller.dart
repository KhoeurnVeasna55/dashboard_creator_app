import 'dart:developer';
import 'package:dashboard_admin/services/store_token.dart';
import 'package:get/get.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../models/user_model.dart';
import '../services/auth_service_api.dart';

class AuthController extends GetxController {
  final isLoading = false.obs;
  final userModel = Rxn<UserModel>();
  final currentUser = ''.obs;
  final token = ''.obs;

  final tokenLoaded = false.obs; 

  final isLogin = true.obs;

  // @override
  // void onInit(){
  //   super.onInit();
  //   checkLogin();
  // }

  Future<void> checkLogin() async {
    final tokenFromStorage = await StoreToken().getToken();
    if (tokenFromStorage != null && tokenFromStorage.isNotEmpty) {
      isLogin.value = !JwtDecoder.isExpired(tokenFromStorage);
      currentUser.value = tokenFromStorage;
      token.value = tokenFromStorage;
      
    } else {
      isLogin.value = false;
    }
    tokenLoaded.value = true;
  }

  Future<bool> login(String email, String password) async {
    try {
      isLoading.value = true;
      final result = await AuthServiceApi().login(email, password);
      return result;
    } catch (e) {
      log(' Error during login: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchUser(String token) async {
    try {
      isLoading.value = true;
      final fetchedUser = await AuthServiceApi().fetchCurrentUser();
      userModel.value = fetchedUser; 
    } catch (e) {
      log('Error fetching user: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
