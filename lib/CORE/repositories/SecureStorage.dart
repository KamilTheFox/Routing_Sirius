import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  final _storage = const FlutterSecureStorage();
  static const _tokenKey = 'auth_token';

  Future<void> saveToken(String token) async 
  {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async 
  {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> deleteToken() async 
  {
    await _storage.delete(key: _tokenKey);
  }

  Future<bool> hasToken() async 
  {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
  
  // Можно добавить другие методы для хранения
  Future<void> saveUserData(String key, String value) async {
    await _storage.write(key: key, value: value);
  }
}