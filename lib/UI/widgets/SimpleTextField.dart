import 'package:flutter/material.dart';

class SimpleTextField 
{
  Color backgroundColor;

  SimpleTextField({required this.backgroundColor});

  Widget GetInput(String text, TextEditingController? editController, Icon? icon,
   [Color colorText = Colors.white, bool isPassword = false])
  {
    return TextField(
      controller: editController,
      obscureText: isPassword,
      decoration: InputDecoration(
        prefixIcon: icon,
        hintText: text,
        border: 
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }
}