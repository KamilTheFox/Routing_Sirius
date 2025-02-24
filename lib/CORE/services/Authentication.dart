import '../repositories/DataApplication.dart';
import 'ApiClient.dart';
import '../repositories/LoginRequest.dart';
import '../repositories/User.dart';


class Authentication
{
  final ApiClient _client = ApiClient(url: DataApplication.urlService);

  static UserInfo? _currentUser;

  static UserInfo? get CurrentUser => _currentUser;

  static bool debug = true;

  Future<void> Login(LoginRequest login, [Function? OnComplited]) async
  {
    if(CurrentUser != null) {
      throw Exception('Вы уже вошли');
    }

    _currentUser = await _Login(login);

    OnComplited?.call();
  }

  Future<UserInfo> _Login(LoginRequest request) async {
    try {
      final response = await _client.PostAuth(request);
      UserInfo user = UserInfo();

      await user.SetToken(response.data);
      return user;
    } catch (e) {
      //return UserInfo();
      throw Exception('Ошибка аутентификации: ${e.toString()}');
    }
  }

  void Logout() async
  {
    _currentUser?.Delete();
    _currentUser = null;
  }

  static void CheckAuth()
  {
    if(Authentication.CurrentUser == null)
    {
      throw Exception('Вы не авторизованы');
    }
  }

}