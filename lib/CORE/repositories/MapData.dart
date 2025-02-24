import 'package:application_front/CORE/repositories/DataApplication.dart';
import 'package:application_front/CORE/repositories/NodeMap.dart';
import 'package:application_front/CORE/repositories/RoomData.dart';
import 'package:application_front/CORE/services/ApiClient.dart';
import 'package:application_front/CORE/services/Authentication.dart';
import 'package:flutter/material.dart';

class MapData
{
  static const String room_id = 'id', floor = 'floor', parent = 'parent', bounds = 'bounds', name = 'name';

  static final ApiClient _apiClient = ApiClient(url: DataApplication.urlService);

  static final Map<int, RoomData> _rooms = {};

  final Map<int, NodeMap> navigationPoints = {};
  
  late Size _originalSvgSize;

  late double svgScale;

  static Map<int, RoomData> get GetRooms => _rooms;

  final Map<String, dynamic> testJson = 
  {
    "rooms": [
      {
        "id": 1,
        "floor": 1,
        "parent": 0,
        "name": "Комната 1",
        "bounds": [
            {"x": 344, "y": 91},
            {"x": 428, "y": 91},
            {"x": 428, "y": 150},
            {"x": 344, "y": 150},
          ]
      },
     
    ]
  };

  BoxConstraints get boxConstraints => _boxConstraints;

  set boxConstraints(BoxConstraints boxConstraints) {
    if (_boxConstraints == boxConstraints) return;
    
    _boxConstraints = boxConstraints;
  }

  late BoxConstraints _boxConstraints;

  static Future<List<RoomData>> FindRoom(String findName) async
  {
    Authentication.CheckAuth();

    try
    {
      final response = await _apiClient.Get('/rooms?query=$findName', Authentication.CurrentUser!);

      return (response.data['rooms'] as List<dynamic>)
      .map((room) => ParseRoomDataAtMap(room as Map<String, dynamic>))
      .toList();

    }
    catch(e)
    {
      print('Ошибка при поиске комнат: $e');
      throw Exception('Не удалось загрузить комнаты с именем $findName: $e');
    }

  }


  Future<void> GetRoomData(Size originalSvgSize) async
  {
    _originalSvgSize = originalSvgSize;
    svgScale = _originalSvgSize.width/1280; // коэффициент масштабирования SVG/База
    
    Authentication.CheckAuth();

    try
    {
        final response = await _apiClient.Get('/rooms', Authentication.CurrentUser!);

        if (response.data == null) 
        {
          throw Exception('Пустой ответ от сервера');
        }
        
        final roomsList =  response.data['rooms'] as List<dynamic>; //testJson['rooms'] as List<dynamic>;
        for(var room in roomsList) 
        {
            RoomData roomData = ParseRoomDataAtMap(room);
            _rooms[roomData.id] = roomData;
        }
    }
    catch(e)
    {
      print('Ошибка при загрузке комнат: $e');
      throw Exception('Не удалось загрузить комнаты: $e');
    }
  }

  static RoomData ParseRoomDataAtMap(Map<String,dynamic> room)
  {
    int id = room['id'];
    return RoomData(
                id: id, 
                floor: room['floor'], 
                parent: room['parent'] ?? -1, 
                name: room['name'],
                shortName: room['short_name'],
                bounds: RoomBounds.Create(id,room['short_name'] , room['bounds']
                )
            );
  }

  Future<List<dynamic>> getPathData(int startPoint, int endPoint) async {
    final path = '/route?room_start=$startPoint&room_end=$endPoint';
    final user = Authentication.CurrentUser;
    
    if(user == null) {
      throw Exception('Пользователь не авторизован');
    }

    try {
      final response = await _apiClient.Get(path, user);
      
      if (response.data == null) 
      {
        throw Exception('Получен пустой ответ от сервера');
      }

      final mapResponse = response.data as Map<String, dynamic>;
      final route = mapResponse['route'];
      
      if (route == null) {
        throw Exception('Маршрут не найден в ответе сервера');
      }

      return route as List<dynamic>;
      
    } on FormatException catch (e) {
      throw Exception('Ошибка парсинга ответа: ${e.message}');
    } catch (e) {
      throw Exception('Ошибка при получении маршрута: ${e.toString()}');
    }
  }
}