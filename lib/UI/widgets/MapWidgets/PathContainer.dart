import 'dart:ui';

import 'package:application_front/CORE/repositories/MapData.dart';
import 'package:application_front/CORE/repositories/RoomData.dart';
import 'package:flutter/material.dart';


class PathPaiting extends StatefulWidget 
{
  final Offset Function(Offset original) transformOffset;

  final MapData mapData;

  static final GlobalKey<_PathContentState> globalKey = GlobalKey<_PathContentState>();

  const PathPaiting({
    super.key,
    required this.mapData,
    required this.transformOffset
  });
  @override
  State<PathPaiting> createState() => _PathContentState();
}

class _PathContentState extends State<PathPaiting> {
  
  int? fromRoomId;
  int? toRoomId;

  bool _isDataLoaded = false;

  bool _isDataEmpty = true;

  List<Vector2> route = [];
  
  @override
  void initState() {
    super.initState();
  }

  Future<void> _loadPathData() async {
    setState(() => _isDataLoaded = false);
    if(fromRoomId == null && toRoomId == null)
    {
      return;
    }
    try {
      final pathJson = await widget.mapData.getPathData(
        fromRoomId!, 
        toRoomId!
      );
      route = parseRouteFromJson(pathJson);
      // Обновляем _mapData с новым маршрутом
      setState(() {
        _isDataLoaded = true;
      });
    } catch (e) 
    {
      print('---------> Ошибка загрузки пути: $e');
      setState(() => _isDataEmpty = true);
    }
  }

  void clearPath()
  {
    setState(() {
      fromRoomId = null;
      toRoomId = null;
      _isDataEmpty = true;
    });
  }

  // Метод для обновления пути
  Future<void> updatePath(int from, int to) async {
    _isDataEmpty = false;
    fromRoomId = from;
    toRoomId = to;
    await _loadPathData();
  }

  List<Vector2> parseRouteFromJson(List<dynamic> jsonRoute) {
    return jsonRoute.map((pointStr) {
      // Убираем фигурные скобки и разделяем по запятой
      String cleanStr = pointStr.toString()
          .replaceAll('{', '')
          .replaceAll('}', '');
      
      List<String> coordinates = cleanStr.split(',');
      
      return Vector2(
        x: double.parse(coordinates[0].trim()),
        y: double.parse(coordinates[1].trim())
      );
    }).toList();
  }


  @override
  Widget build(BuildContext context) 
  {
    if(_isDataEmpty)
    {
      return const SizedBox.shrink();
    }
    if (_isDataLoaded == false || route.isEmpty)
    {
      return const Center(child: CircularProgressIndicator());
    }
   return CustomPaint(painter:  _PathPainter(path: route, transforns: widget.transformOffset));
  }
}

class _PathPainter extends CustomPainter {

  final List<Vector2> path;
  final Offset Function(Offset original) transforns;

  _PathPainter({
    required this.path, required  this.transforns});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke  
      ..color = const Color.fromARGB(255, 49, 69, 93)
      ..strokeWidth = 1
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    final path = Path();
    
    // Предполагая, что GetPathOffset() возвращает List<Offset>
    final points = GetPathOffset();
    
    if (points.isNotEmpty) {
      path.moveTo(points[0].dx, points[0].dy); // Начинаем с первой точки
      
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
    }

    canvas.drawPath(path, paint);
  }

  List<Offset> GetPathOffset()
  {
    List<Offset> pathBuild = [];
    for(int i = 0; i < path.length; i++)
    {
      if(path.isEmpty) {
        return pathBuild;
      }
      Vector2 curPoint = path[i];
      pathBuild.add(transforns(Offset(curPoint.x, curPoint.y)));
    }
    return pathBuild;
  }

  @override
  bool shouldRepaint(covariant _PathPainter oldDelegate) => 
      true; 
}