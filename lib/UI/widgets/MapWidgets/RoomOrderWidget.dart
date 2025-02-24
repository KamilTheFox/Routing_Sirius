import 'dart:math';

import 'package:application_front/CORE/repositories/MapData.dart';
import 'package:application_front/CORE/repositories/RoomData.dart';
import 'package:flutter/material.dart';

class RoomOrderPaiting extends StatefulWidget 
{

  static final GlobalKey<_RoomOrderState> globalKey = GlobalKey<_RoomOrderState>();

  const RoomOrderPaiting({
    super.key,
  });
  
  @override
  State<RoomOrderPaiting> createState() => _RoomOrderState();
}

class _RoomOrderState extends State<RoomOrderPaiting> {
  // Добавляем HashMap для хранения комнат
  final Map<int, ({RoomBounds bounds, Offset offset})> _rooms = {};
  // Счетчик для генерации уникальных индексов
  int _lastIndex = 0;

  // Новый метод добавления комнаты
  int addRoomClick(RoomBounds newBounds, Offset newOffset, int index) 
  {

    if (index != 0 && _rooms.containsKey(index)) {
      return index;
    }
    
    // Определяем какой индекс использовать
    final actualIndex = index == 0 ? _lastIndex + 1 : index;
    
    setState(() {
      _rooms[actualIndex] = (
        bounds: newBounds,
        offset: newOffset
      );
      _lastIndex = max(_lastIndex, actualIndex);
    });
    
    return actualIndex;
  }

  // Метод удаления комнаты
  void removeRoom(int index) {
    setState(() {
      _rooms.remove(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Если нет комнат, возвращаем пустой виджет
    if (_rooms.isEmpty) {
      return const SizedBox.shrink();
    }

    // Возвращаем стек из всех комнат
    return Stack(
      children: _rooms.entries.map((entry) {
        return CustomPaint(
          painter: PressedRoomPainter(
            bounds: entry.value.bounds,
            offset: entry.value.offset
          ),
        );
      }).toList(),
    );
  }
}

