import 'package:application_front/CORE/services/ApiClient.dart';
import 'package:application_front/CORE/services/Authentication.dart';
import 'package:application_front/UI/menus/AuthenticationMenu.dart';
import 'package:application_front/UI/screens/MainScreen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget 
{
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) 
  {
    return MaterialApp(
      title: 'Sirius Routing Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 49, 69, 93)),
        useMaterial3: true,
      ),
      routes: 
      {
        '/auth': (context) => AuthenticationMenu(),
        '/main': (context) => const MainScreen()
      },
      initialRoute: '/auth',
    );
  }

}




