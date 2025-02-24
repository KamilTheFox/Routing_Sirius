import 'package:flutter/material.dart';

class NodeMap extends StatelessWidget
{
  final double x,y;

  final int id;

  const NodeMap({super.key, required this.x, required this.y, required this.id});
  @override
  Widget build(BuildContext context) 
  {
    return Positioned(
      right: x,
      top: y,
      child: _GetPoint(),
    );
  }

  Widget _GetPoint()
  {
    return Container(width: 10, height: 10,color: Colors.red,);
  }
}