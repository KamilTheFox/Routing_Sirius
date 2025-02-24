import 'package:flutter/material.dart';

class SimpleButton {
  final Color backgroundColor;
  final ValueNotifier<bool> _isLock = ValueNotifier<bool>(false);

  SimpleButton({required this.backgroundColor});

  // Геттер для проверки состояния загрузки
  bool get IsLocked => _isLock.value;

  // Метод для установки состояния загрузки
  void SetLock(bool lock) {
    _isLock.value = lock;
  }

   Widget GetButton(
    String text,
    Function()? onClick, [
    Color colorText = Colors.white,
    String loadingText = 'Подождите...'
  ]) 
  {
    return ValueListenableBuilder<bool>(
      valueListenable: _isLock,
      builder: (context, isLocked, child)
      {
        return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLocked ? null : onClick,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: isLocked
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorText,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    loadingText,
                    style: TextStyle(
                      color: colorText,
                      fontSize: 15,
                    ),
                  ),
                ],
              )
            : Text(
                text,
                style: TextStyle(
                  color: colorText,
                  fontSize: 15,
                ),
              ),
      ),
    );
      }
    );
  }
}

