import 'package:application_front/UI/widgets/WavePainter.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget 
{
  static const Color colorComponents = Color.fromARGB(255, 49, 69, 93);

  late BuildContext _currentContext;

  late List<Widget> widgets;


  final Widget widget = CustomPaint(
    painter: WavePainter(colorWave: colorComponents),
    size: const Size(double.infinity, 100));

  LoginScreen({super.key});

  void AddWidgets(List<Widget> newWidgets)
  {
    widgets = 
    [
      Image.asset('Resources/Logo.png', height: 100),
      const SizedBox(height: 40),
      ...newWidgets,
      widget
    ];
  }
  @override
  Widget build(BuildContext context) 
  {
    _currentContext = context;
    return Scaffold
    (
      resizeToAvoidBottomInset: false,
      body: SafeArea
      (
        child: Padding
        (
          padding: const EdgeInsets.all(40),
          child: Column(children: widgets),
        )
      )
    );
  }
  void ShowErrorDialog(String message) 
  {
    showDialog(
      context: _currentContext,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: 
            [
              Icon(Icons.error_outline, color: Colors.red),
              SizedBox(width: 8),
              Text('Ошибка'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: 
            [
              Text(message)
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Понятно', selectionColor: colorComponents),
            ),
          ],
        );
      },
    );
  }
}