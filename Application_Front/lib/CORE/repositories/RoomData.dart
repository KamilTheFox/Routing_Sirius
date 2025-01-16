import 'dart:async';
import 'dart:math';
import 'package:test/test.dart';

import 'package:flutter/material.dart';

class Vector2
{
  final double x;
  final double y;

  Vector2({required this.x, required this.y});

  factory Vector2.ToJson(Map<String, dynamic> json)
  {
    return Vector2(
      x: (json['x'] ?? 0).toDouble(),
      y: (json['y'] ?? 0).toDouble());
  }
  Vector2 operator +(Vector2 other) => Vector2(x: x + other.x, y: y + other.y);
  Vector2 operator -(Vector2 other) => Vector2(x: x - other.x, y: y - other.y);
  Vector2 operator *(double scalar) => Vector2(x: x * scalar, y: y * scalar);
  Vector2 operator /(double scalar) => Vector2(x: x / scalar, y: y / scalar);

  double dot(Vector2 other) => x * other.x + y * other.y;
  double cross(Vector2 other) => x * other.y - y * other.x;

  double get magnitude => sqrt(x * x + y * y);
  double get sqrMagnitude => x * x + y * y;
  
  Vector2 get normalized {
    double mag = magnitude;
    return mag > 0 ? this / mag : Vector2(x: 0, y: 0);
  }

  double distanceTo(Vector2 other) {
    final dx = x - other.x;
    final dy = y - other.y;
    return sqrt(dx * dx + dy * dy);
  }

  double angleTo(Vector2 other) {
    return atan2(cross(other), dot(other));
  }

  Vector2 lerp(Vector2 other, double t) {
    return Vector2(
      x: x + (other.x - x) * t,
      y: y + (other.y - y) * t
    );
  }

  @override
  String toString() => 'Vector2(x: $x, y: $y)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Vector2 && other.x == x && other.y == y;
  }

  static Vector2 zero()
  {
    return new Vector2(x: 0, y: 0);
  }

  @override
  int get hashCode => x.hashCode ^ y.hashCode;

}

class RoomBounds {
  final int id;
  final List<Vector2> bounds;
  
  RoomBounds({
    required this.id,
    required this.bounds,
  });

  factory RoomBounds.Create(int id,List<dynamic> json) {
    return RoomBounds(
      id: id,
      bounds: json.map((e) => Vector2.ToJson(e))
            .toList()
    );
  }
}

class RoomData 
{
  final int id;
  final int floor;
  final int parent;
  final String name;

  final Vector2 correctionCenterText;
  
  final RoomBounds bounds;

  late Vector2 LeftTopPosition; 

  RoomData({required this.id, required this.floor, required this.parent, required this.name, required this.bounds, required this.correctionCenterText});

  factory RoomData.ToJson(Map<String, dynamic> json)
  {
    return RoomData(
      id: json['id'] ?? -1,
      floor: json['floor'] ?? -1,
      parent: json['parent'] ?? -1,
      name: json['name'] ?? 'none',
      bounds: RoomBounds.Create(json['id'],json['bounds']),
      correctionCenterText: json['correctCenter'] ?? Vector2(x: 0, y: 0)
    );
  }

  bool isClickInside(double x, double y) {
    return _PointInPolygonChecker.isPointInPolygon(bounds.bounds, x, y);
  }

  Widget GetRoomButton(Function(String name, int id) OnTap, 
    {Function(Offset)? transformOffset})
  {
     if (bounds.bounds.isEmpty) {
        return const SizedBox.shrink();
      }
      return _ClickableRoomBounds(data: this, onTap: OnTap, transformOffset: transformOffset ?? ((offset) => offset),);
  }
}


class _ClickableRoomBounds extends StatefulWidget {
  final RoomData data;
  final Function(String name, int id) onTap;
  final Function(Offset p1) transformOffset;

  const _ClickableRoomBounds({
    required this.data,
    required this.onTap, required this.transformOffset,
  });

  @override
  _ClickableRoomBoundsState createState() => _ClickableRoomBoundsState();
}

class _ClickableRoomBoundsState extends State<_ClickableRoomBounds> {

  bool _isPressed = false;
  Timer? _timer;
  late double minX, minY;

  late List<Vector2> boundsClick;

  void _handleTapDown(PointerDownEvent details) {
    
    final globalX = details.localPosition.dx + minX;
    final globalY = details.localPosition.dy + minY;

    if (_PointInPolygonChecker.isPointInPolygon(boundsClick, globalX, globalY)) {
      setState(() => _isPressed = true);
      widget.onTap(widget.data.name, widget.data.id);
      
      _timer?.cancel();
      
      _timer = Timer(const Duration(milliseconds: 300), () {
        setState(() => _isPressed = false);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel(); // Очищаем таймер при уничтожении виджета
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    minX = double.infinity;
    minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    for (var point in widget.data.bounds.bounds) {
        var transformedPoint = widget.transformOffset(Offset(point.x, point.y));
        minX = min(minX, transformedPoint.dx);
        minY = min(minY, transformedPoint.dy);
        maxX = max(maxX, transformedPoint.dx);
        maxY = max(maxY, transformedPoint.dy);
      }

    boundsClick = widget.data.bounds.bounds.map((bound) {
                    return Vector2(
                        x: widget.transformOffset(Offset(bound.x, bound.y)).dx,
                        y: widget.transformOffset(Offset(bound.x, bound.y)).dy
                    );
                }).toList();
    
    final newRoomBounds = RoomBounds(id: widget.data.bounds.id, bounds: boundsClick);

    return Positioned(
      left: minX,
      top: minY,
      width: maxX - minX,
      height: maxY - minY,
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (event) {
          _handleTapDown(event);
        },
        child: Stack(

          children: [
            CustomPaint(
              painter: _RoomPainter(
                bounds: newRoomBounds,
                offset: Offset(-minX, -minY),
                isPressed: _isPressed,
              ),
            ),
            Align(
            alignment: Alignment(Alignment.center.x + widget.data.correctionCenterText.x, Alignment.center.y + widget.data.correctionCenterText.y),
            child: Text(widget.data.name, style: TextStyle(color: Colors.black, fontSize: min((maxX - minX) / maxX * 20, 15),))
            ),
          ],
        ),
        
      ),
    );
  }
}

class CrossSegmentFlag {
  bool value = false;
}
class _PointInPolygonChecker {
  static get math => null;

  
  static bool isPointInPolygon(List<Vector2> polygon, double px, double py) {
    int intersections = 0;
    int count = polygon.length;

    for (int i = 0; i < count; i++) {
      Vector2 vertex1 = polygon[i];
      Vector2 vertex2 = polygon[(i + 1) % count];

      // Проверяем, пересекает ли горизонтальный луч сторону многоугольника
      if (((vertex1.y > py) != (vertex2.y > py)) &&
          (px < (vertex2.x - vertex1.x) * (py - vertex1.y) / (vertex2.y - vertex1.y) + vertex1.x)) {
        intersections++;
      }
    }
    // Если количество пересечений нечётное, точка внутри
    return (intersections % 2 != 0);
  }
  static double isLeft(Vector2 p0, Vector2 p1, Vector2 point) {
  return ((p1.x - p0.x) * (point.y - p0.y) - 
          (point.x - p0.x) * (p1.y - p0.y));
  }

  static List<Vector2> sortPointsClockwise(List<Vector2> points)
  {
  // Находим центр полигона
    final center = points.reduce((value, element) => value + element) / points.length.toDouble();
    
    // Сортируем точки по углу относительно центра
    return List<Vector2>.from(points)
      ..sort((a, b) {
        final angleA = atan2(a.y - center.y, a.x - center.x);
        final angleB = atan2(b.y - center.y, b.x - center.x);
        return angleA.compareTo(angleB);
      }); 
    }

}

class _RoomPainter extends CustomPainter {
  final RoomBounds bounds;
  final Offset offset; // Смещение для корректного отображения
  final bool isPressed;

  _RoomPainter({
    required this.bounds, 
    required this.offset,
    required this.isPressed,});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color =  isPressed 
          ? const Color.fromARGB(255, 104, 65, 221).withOpacity(0.3) 
          : const Color.fromARGB(255, 180, 142, 72).withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint() // Добавляем обводку для наглядности
      ..color = isPressed 
          ? const Color.fromARGB(255, 55, 32, 126)
          : const Color.fromARGB(255, 228, 125, 8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path();
    
    // Применяем смещение к координатам
    path.moveTo(bounds.bounds[0].x + offset.dx, bounds.bounds[0].y + offset.dy);
    
    for(int i = 1; i < bounds.bounds.length; i++) {
      path.lineTo(bounds.bounds[i].x + offset.dx, bounds.bounds[i].y + offset.dy);
    }
    
    path.close();
    canvas.drawPath(path, paint);
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool hitTest(Offset position) {
    final path = Path();
    path.moveTo(bounds.bounds[0].x + offset.dx, bounds.bounds[0].y + offset.dy);
    for(int i = 1; i < bounds.bounds.length; i++) {
      path.lineTo(bounds.bounds[i].x + offset.dx, bounds.bounds[i].y + offset.dy);
    }
    path.close();
    return path.contains(position);
  }

  @override
  bool shouldRepaint(covariant _RoomPainter oldDelegate) => 
      isPressed != oldDelegate.isPressed; 
}