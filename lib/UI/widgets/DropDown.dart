import 'package:flutter/material.dart';

class RoutePoint {
  final String id;
  final String name;
  final String description;

  RoutePoint({
    required this.id,
    required this.name,
    this.description = '',
  });
}

// Виджет выбора точки маршрута
Widget buildRouteSelector({
  required String title,
  required List<RoutePoint> points,
  required Function(RoutePoint?) onSelected,
}) {
  return SizedBox(
    height: 40,
    child: DropdownButtonHideUnderline(
      child: DropdownButton<RoutePoint>(
        isExpanded: true,
        hint: Text(title),
        items: points.map((point) {
          return DropdownMenuItem(
            value: point,
            child: Text(point.name),
          );
        }).toList(),
        onChanged: onSelected,
      ),
    ),
  );
}