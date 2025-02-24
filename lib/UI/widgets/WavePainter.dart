import 'package:flutter/material.dart';

class WavePainter extends CustomPainter {

  final Color colorWave;

  WavePainter({required this.colorWave});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = colorWave
      ..style = PaintingStyle.fill;
      
    double offset = size.width;
    canvas.drawCircle(Offset(0, size.height + 40), 245/2, paint);
    canvas.drawCircle(Offset(offset / 2, size.height + 70), 245/2, paint);
    canvas.drawCircle(Offset(offset, size.height + 40), 245/2, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}