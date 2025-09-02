import 'dart:async';

import 'package:get_storage/get_storage.dart';

class StoreToken {
  // final _storeToken = GetStorage();
  static final _box = GetStorage();
  static const _key = 'token';
  static final _tokenController = StreamController<String?>.broadcast();
  static void initialize() {
    _tokenController.add(_box.read(_key));
  }

  static Stream<String?> get tokenStream => _tokenController.stream;

  Future<void> createToken(String token) async {
    await _box.write(_key, token);
    _tokenController.add(token);
  }

  Future<String?> getToken() async {
    return _box.read(_key);
  }

  Future<void> removeToken() async {
    await _box.remove(_key);
    _tokenController.add(null); 
  }
}
