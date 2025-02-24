
import 'dart:convert';
import 'package:crypto/crypto.dart';

class LoginRequest
{
  final String login;
  final String password;
  LoginRequest({required this.login, required this.password});

  factory LoginRequest.Create(String login, String PassWord)
  {
    return LoginRequest(login: login, password: _GetSha256(PassWord));
  }

  Map<String,dynamic> toJson() =>
  
  {
    'login': login,
    'password': password
  };
  static String _GetSha256(String password)
  {
    List<int> data = utf8.encode(password);
    return sha256.convert(data).toString();
  }
}