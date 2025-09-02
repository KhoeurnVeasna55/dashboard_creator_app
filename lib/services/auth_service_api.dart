import 'dart:convert';
import 'dart:developer';
import 'package:dashboard_admin/core/URL/url.dart';
import 'package:dashboard_admin/models/user_model.dart';
import 'package:dashboard_admin/services/store_token.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthServiceApi {
  final _storeToken = StoreToken();

  Future<bool> login(String email, String password) async {
    try {
      final url = Uri.parse('$URL/api/auth/login');
      final response = await http.post(
        url,
        body: jsonEncode({'email': email, 'password': password}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final token = jsonDecode(response.body)['token'];
        final userRole = jsonDecode(response.body)['user']['role'];
        if (userRole == 'admin') {
          await _storeToken.createToken(token);
        }
        return true;
      }
      return false;
    } catch (e) {
      log('Login error: $e');
      return false;
    }
  }

  Future<UserModel> fetchCurrentUser() async {
    final token = await _storeToken.getToken();

    if (token == null || JwtDecoder.isExpired(token)) {
      throw Exception('Token is invalid or expired');
    }

    try {
      final url = Uri.parse('$URL/api/auth/me');

      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return UserModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load user data');
      }
    } catch (e) {
      log('fetchCurrentUser error: $e');
      rethrow; 
    }
  }
}
