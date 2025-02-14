import 'dart:async';

import 'package:application_front/UI/widgets/MapWidgets/PathContainer.dart';
import 'package:application_front/UI/widgets/MapWidgets/RoomOrderWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:application_front/CORE/repositories/MapCoordinateTransformer.dart';
import 'package:application_front/CORE/repositories/MapData.dart';
import 'package:application_front/CORE/repositories/NodeMap.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

class InteractiveMap extends StatefulWidget
{
  final Function(String, int) onRoomTap;

  const InteractiveMap({super.key, required this.onRoomTap});
  @override
  State<StatefulWidget> createState() 
  {
    return _InteractiveMap();
  }
}

class _InteractiveMap extends State<InteractiveMap>
  {
  late final Image _mapImage;

  late Size _originalSvgSize;

  late final List<NodeMap> nodes;

  late final MapData _mapData;

  bool _isDataLoaded = false;

  late final Function(String, int) OnTap;

  MapCoordinateTransformer? _coordinator;

  @override
  void initState()
  {
    _mapData = MapData();

    _mapImage = Image.asset(
      'Resources/Names_rooms.png',
      fit: BoxFit.contain,
    );
    super.initState();
  }

  Future<void> _initializeData() async {
    if(_isDataLoaded) {
      return;
    }
    try {
      _originalSvgSize = await getImageSize('Resources/Names_rooms.png');
      await _mapData.GetRoomData(_originalSvgSize);

      setState(() {_isDataLoaded = true;});
    } catch (e) {
      print('Ошибка при инициализации данных: $e');
    }
  }

  Future<Size> getImageSize(String assetName) async {
    final ImageProvider provider = AssetImage(assetName);
    final ImageStream stream = provider.resolve(ImageConfiguration());
    final Completer<Size> completer = Completer<Size>();
    
    final listener = ImageStreamListener(
      (ImageInfo info, bool synchronousCall) {
        final Size size = Size(
          info.image.width.toDouble(),
          info.image.height.toDouble(),
        );
        completer.complete(size);
      },
      onError: (dynamic exception, StackTrace? stackTrace) {
        completer.completeError(exception);
      },
    );

    stream.addListener(listener);
    return completer.future;
  }

  @override
 Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(child: Text('Ошибка загрузки: ${snapshot.error}'));
        }

        return Container(
          child: InteractiveViewer(
            transformationController: _coordinator?.transformationController,
            boundaryMargin: const EdgeInsets.all(20),
            scaleFactor: 1.5,
            minScale: 0.5,
            maxScale: 100,
            child: LayoutBuilder(
              builder: (context, constraints)
              {
                // Получаем актуальные размеры для масштабирования
                 final svgScale = _originalSvgSize.width/1280; // коэффициент масштабирования SVG/База
    
                  // Получаем актуальные размеры для масштабирования
                  final Size actualSize = Size(
                    constraints.maxWidth,
                    constraints.maxWidth * (_originalSvgSize.height / _originalSvgSize.width) // используем реальные пропорции SVG
                  );

                  final double mapTopOffset = (constraints.maxHeight - actualSize.height) / 2;
                  
                  // Функция для пересчета координат
                  Offset calculatePosition(Offset original) {
                    // Сначала масштабируем координаты базы в координаты SVG
                    final svgX = original.dx * svgScale;
                    final svgY = original.dy * svgScale;
                    
                    // Затем масштабируем под текущий размер экрана
                    final result = Offset(
                      svgX * (actualSize.width / _originalSvgSize.width),  // делим на ширину SVG
                      mapTopOffset + (svgY * (actualSize.height / _originalSvgSize.height))  // делим на высоту SVG
                    );
                    return result;
                  }

                return Stack(
                  children: [
                    ...MapData.GetRooms.values.map((room) {
                      return room.GetRoomButton(
                        widget.onRoomTap,
                        transformOffset: calculatePosition  
                      );
                    }),
                    RoomOrderPaiting( key: RoomOrderPaiting.globalKey,),
                    PathPaiting(
                     key: PathPaiting.globalKey,
                     mapData: _mapData,
                     transformOffset: calculatePosition),
                     Align(
                      alignment: AlignmentDirectional.center, 
                      child:IgnorePointer( 
                          child: _mapImage,
                        ),
                    ),
                  ],
                );
              }
            ),
          )
        );
      }
    );
  }
}
  