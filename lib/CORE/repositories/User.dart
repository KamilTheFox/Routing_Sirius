import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserInfo
{
  static const String tokenKey = 'token';
  static const String userIDKey = 'user_id';
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  late int userID = -1;

  Future<void> SetToken(Map<String, dynamic> json) async
  {
    if(await storage.containsKey(key: tokenKey))
    {
      return;
    }
    await storage.write(key: tokenKey, value: json[tokenKey]);
  }

  Future<void> UseToken(Function(String token) usable) async
  {
    String? token = await storage.read(key: tokenKey);
    if(token == null) throw Exception('Вы не авторизованы');
    await usable(token);
  }

  void SetUserInfo(Map<String, dynamic> json)
  {
    _SetUserID(json);
  }

  void _SetUserID(Map<String, dynamic> json)
  {
    if(userID != -1) 
    {
      return;
    }
    userID = json[userIDKey] ?? 0;
  }
  void Delete()
  {
    userID = -1;
    storage.deleteAll();
  }
}

