import 'package:application_front/UI/widgets/DraggingScrollbarInfo.dart';
import 'package:application_front/UI/widgets/MapWidgets/InteractiveMap.dart';
import 'package:application_front/CORE/repositories/MapData.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
{
  final DraggableScrollableController _dragController = DraggableScrollableController();

  late InteractiveMap interactiveMap;

  void _handleRoomTap(String roomName, int roomId) 
  {
    final room = MapData.GetRooms[roomId];
    if (room != null) {
        RouteSheet.globalKey.currentState?.setCurrentRoom(room);
    } else 
    {
        print('Комната с ID $roomId не найдена!');
    }
  }
    

  @override
  Widget build(BuildContext context) 
  {
    interactiveMap = InteractiveMap(onRoomTap: _handleRoomTap);

    return Scaffold(
      body: Stack(
        children: [
          // Карта на весь экран
          Container(
            height: double.infinity,
            color: Colors.grey[200], // Временный фон для карты
            child: interactiveMap
          ),
          
          RouteSheet(
            key: RouteSheet.globalKey,
            dragController: _dragController,
            onRouteChanged: (from, to) {
              print('Маршрут изменен: ${from!.name} -> ${to!.name}');
            },
          ),
          
        ],
      ),
    );
  }
}