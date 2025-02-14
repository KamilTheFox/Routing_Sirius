import 'package:application_front/CORE/repositories/LoginRequest.dart';
import 'package:application_front/CORE/services/Authentication.dart';
import 'package:application_front/UI/screens/LoginScreen.dart';
import 'package:application_front/UI/widgets/SimpleButton.dart';
import 'package:application_front/UI/widgets/SimpleTextField.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AuthenticationMenu extends StatefulWidget {
  const AuthenticationMenu({super.key});

  @override
  State<AuthenticationMenu> createState() => _AuthenticationMenuState();
}

class _AuthenticationMenuState extends State<AuthenticationMenu> {
  static const double _verticalSpacing = 30.0;
  static const double _smallSpacing = 16.0;

  TextEditingController loginInput = TextEditingController();
  TextEditingController passwordInput = TextEditingController();

  late final SimpleButton interactiveButton;

  late final SimpleTextField writeField;

  bool _isLocding = false;

  LoginScreen screen = LoginScreen();

  @override
  void initState() 
  {
    super.initState();
    interactiveButton = SimpleButton(backgroundColor: const Color.fromARGB(255, 49, 69, 93));
    writeField = SimpleTextField(backgroundColor: Colors.white);
    SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  Widget build(BuildContext context) 
  {
    Color bcColor = const Color.fromARGB(255, 49, 69, 93);
    interactiveButton.SetLock(_isLocding);

    Text title = Text(
    'Добрый день!',
    style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: bcColor));

    Text titleDescription = Text(
    'Введите логин и пароль для авторизации',
    style: Theme.of(context).textTheme.bodyMedium,);
    screen.AddWidgets(
      [
        title,titleDescription,
        const SizedBox(height: _verticalSpacing),
        writeField.GetInput('Введите логин', loginInput, const Icon(Icons.person_outline) ,bcColor),
        const SizedBox(height: _smallSpacing),
        writeField.GetInput('Введите пароль', passwordInput, const Icon(Icons.lock_outline) ,bcColor, true),
        const SizedBox(height: _verticalSpacing),
        interactiveButton.GetButton('Войти', ClickEnterAuth, Colors.white ,'Выполняется вход...'),
        const Spacer(),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     Text('Нет аккаунта? '),
        //     TextButton(
        //       onPressed: () {},
        //       child: Text('Зарегистрируйтесь', style: TextStyle(color: bcColor, fontSize: 17)),
        //     ),
        //   ],
        // ),
      ]);

    return screen;
  }
  void ClickEnterAuth() async
  {
    if(_isLocding)
    {
      return;
    } 
    setState(() {
      _isLocding = true;
    });
    
    Authentication auth = Authentication();
    try
    {
      await auth.Login(LoginRequest.Create(loginInput.text, passwordInput.text));
      Navigator.pushReplacementNamed(context, '/main');
    }
    catch(e)
    {
      if (e.toString().contains('401') || 
            e.toString().contains('404') || 
            e.toString().contains('StatusCode: 404')) 
        {
          screen.ShowErrorDialog('Неверный логин или пароль');
        } else if (e.toString().contains('NetworkException') || 
                  e.toString().contains('SocketException')) {
          screen.ShowErrorDialog('Проверьте подключение к интернету');
        } else {
          screen.ShowErrorDialog('Произошла ошибка: ${e.toString()}');
        }
    }
    finally
    {
      setState(() {
      _isLocding = false;
    });
    }
  }
  @override
  void dispose() 
  {
    loginInput.dispose();
    passwordInput.dispose();
    super.dispose();
    SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }
}
