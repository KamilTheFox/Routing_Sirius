import 'package:application_front/CORE/repositories/RoomData.dart';
import 'package:application_front/UI/widgets/SearchHelperWidget.dart';
import 'package:flutter/material.dart';
import 'package:application_front/UI/widgets/MapWidgets/PathContainer.dart';

enum RouteSheetDisplayMode {
  routeButtonStart,  // Режим с полями "Откуда"/"Куда"
  routeSelection, // Режим отображения маршрута и информации о нем
  roomSelection    // Режим с кнопками "Отсюда"/"Сюда"
}

class RouteSheet extends StatefulWidget {

  final DraggableScrollableController dragController;

  final void Function(RoomData? from, RoomData? to)? onRouteChanged;

  final RouteSheetDisplayMode initialMode;

  const RouteSheet({
    super.key, 
    required this.dragController,
    this.onRouteChanged,
    this.initialMode = RouteSheetDisplayMode.routeButtonStart,
  });

  static final GlobalKey<RouteSheetState> globalKey = GlobalKey<RouteSheetState>();

  @override
  State<RouteSheet> createState() => RouteSheetState();
}

class RouteSheetState extends State<RouteSheet> {
  RoomData? _fromRoom;
  RoomData? _toRoom;
  RoomData? _currentRoom;

  late RouteSheetDisplayMode _displayMode;

  final ValueNotifier<bool> isVisibleNotifier = ValueNotifier(true);

  double _sheetPosition = 1.0;

  bool get canBuildRoute => _fromRoom != null && _toRoom != null;

  @override
  void initState() {
    super.initState();
    _displayMode = widget.initialMode;
  }

  // Методы для внешнего управления
  void updateDisplayMode(RouteSheetDisplayMode mode) {
    setState(() {
      _displayMode = mode;
    });
  }

  void setCurrentRoom(RoomData room) {
    setState(() {
        _displayMode = RouteSheetDisplayMode.roomSelection;
        _currentRoom = room;
    });
  }

  void setFromRoom(RoomData? room) {
    setState(() {
      _fromRoom = room;
    });
  }

  void setToRoom(RoomData? room) {
    setState(() {
      _toRoom = room;
    });
  }

  Widget _buildTargetWidget(RouteSheetDisplayMode mode)
  {
    switch(mode)
    {
      case RouteSheetDisplayMode.roomSelection:
        return _buildRoomSelectionMode();
      case RouteSheetDisplayMode.routeButtonStart:
        return _buildrouMode();
      case RouteSheetDisplayMode.routeSelection:
        return _buildRouteInfo();
    }
  }

  List<double> _buildTargetSnapSize(RouteSheetDisplayMode mode)
  {
    switch(mode)
    {
      case RouteSheetDisplayMode.roomSelection:
        return const [0.35, 0.9] ;
      case RouteSheetDisplayMode.routeButtonStart:
        return const [0.15, 0.35, 0.9];
      case RouteSheetDisplayMode.routeSelection:
        return const [0.04, 0.15, 0.35, 0.9];
    }
  }
  double _buildTargetSnapCurrent(RouteSheetDisplayMode mode)
  {
    switch(mode)
    {
      case RouteSheetDisplayMode.roomSelection:
        return 0.35;
      case RouteSheetDisplayMode.routeButtonStart:
        return 0.35;
      case RouteSheetDisplayMode.routeSelection:
        return 0.15;
    }
  }


  Widget _buildRouteInfo()
  {
      return  Row(
          children: [
            const Text('Информация',style: TextStyle(color: Color.fromARGB(255, 0, 0, 0))),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  PathPaiting.globalKey.currentState?.clearPath();
                  _toRoom = null;
                  setFromRoom(null);
                  updateDisplayMode(RouteSheetDisplayMode.routeButtonStart);
                },
                style:  ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 49, 69, 93)
                ),
                child: const Text('Сбросить маршрут',style: TextStyle(color: Colors.white),),
              ),
            ),
          ],
        );
    }

  Widget _buildrouMode() {
    return Column(
      children: [
         const Text('Маршрут',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
          onTap: () => _showSearchHelper(context, setFromRoom),
          child: Container(
              height: 40,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    _fromRoom?.name ?? 'Откуда',
                    style: TextStyle(
                      color: _fromRoom == null ? Colors.grey : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
          onTap: () => _showSearchHelper(context, setToRoom),
          child: Container(
              height: 40,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  const Icon(Icons.location_on, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    _toRoom?.name ?? 'Куда',
                    style: TextStyle(
                      color: _toRoom == null ? Colors.grey : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildBuildRouteButton(),
      ],
    );
  }

  Widget _buildRoomSelectionMode() {
    var column = Column(
      children: [
        Text(_currentRoom?.name ?? 'Выберите комнату',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  setFromRoom(_currentRoom);
                  updateDisplayMode(RouteSheetDisplayMode.routeButtonStart);
                },
                style:  ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 49, 69, 93)
                ),
                child: const Text('Отсюда',style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  setToRoom(_currentRoom);
                  updateDisplayMode(RouteSheetDisplayMode.routeButtonStart);
                },
                style:  ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 49, 69, 93)
                ),
                child: const Text('Сюда',style: TextStyle(color: Colors.white),),
              ),
            ),
          ],
        ),
      ],
    );

    return column;
  }
  Widget _buildBuildRouteButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: ElevatedButton(
        onPressed: canBuildRoute ? _buildRoute : null,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          backgroundColor: canBuildRoute ? const Color.fromARGB(255, 49, 69, 93) : const Color.fromARGB(255, 39, 59, 83),
        ),
        child: const Text(
          'Построить маршрут',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Future<void> _showSearchHelper(BuildContext context, Function(RoomData) setRoomData) async {
    final result = await showModalBottomSheet<RoomData>(
      context: context,
      isScrollControlled: true, 
      builder: (BuildContext context) {
        return SearchHelperWidget(
          onRoomSelected: (RoomData room) {
            Navigator.pop(context, room);
          },
        );
      },
    );
    
    if (result != null)
    {
      setRoomData(result);
    }
  }

  Widget buildCloseButton() {
    return Positioned(
      right: 8,
      top: 8,
      child: GestureDetector(
        onTap: () {
          updateDisplayMode(RouteSheetDisplayMode.routeButtonStart);
        },
        child: Container(
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.close,
            size: 24,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

 void _buildRoute() {
    if (_fromRoom != null && _toRoom != null) {
      PathPaiting.globalKey.currentState?.updatePath(
        _fromRoom!.id,
        _toRoom!.id,
      );
      updateDisplayMode(RouteSheetDisplayMode.routeSelection);
      widget.onRouteChanged?.call(_fromRoom, _toRoom);
    }
  }

Widget _buildDraggableScrollableSheet() {
  var minChildSize = _buildTargetSnapSize(_displayMode)[0];

  return DraggableScrollableSheet(
    controller: widget.dragController,
    initialChildSize: _buildTargetSnapCurrent(_displayMode),
    minChildSize: minChildSize,
    maxChildSize: 0.9,
    snapAnimationDuration: const Duration(milliseconds: 300),
    snap: true,
    snapSizes: _buildTargetSnapSize(_displayMode),
    builder: (context, scrollController) {
      widget.dragController.addListener(() {
        _sheetPosition = scrollController.position.viewportDimension /
            MediaQuery.of(context).size.height;
        isVisibleNotifier.value = _sheetPosition > (minChildSize + 0.15);
      });

      return ValueListenableBuilder<bool>(
        valueListenable: isVisibleNotifier,
        builder: (context, isVisible, child) {
          Widget contentWidget;
          
          // Простое условное отображение без анимаций
          if (_displayMode == RouteSheetDisplayMode.routeButtonStart && !isVisible) {
            contentWidget = Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  widget.dragController.animateTo(
                    0.35,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                  isVisibleNotifier.value = true;
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.white,
                ),
                child: const Text(
                  'Задать маршрут',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
            );
          } else {
            contentWidget = _buildTargetWidget(_displayMode);
          }

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                )
              ],
            ),
            child: Stack(
              children: [
                ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    contentWidget,
                  ],
                ),
                if (_displayMode == RouteSheetDisplayMode.roomSelection)
                  buildCloseButton(),
              ],
            ),
          );
        },
      );
    },
  );
}
  @override
  Widget build(BuildContext context) {
    var selectedRoomName = "";
    if(_currentRoom != null) {
      selectedRoomName = _currentRoom!.name;
    }
    var sheet = _buildDraggableScrollableSheet();

    // var stack = Stack(
    //   children: [
    //       sheet,
    //       if(_displayMode == RouteSheetDisplayMode.routeButtonStart)
    //         Positioned(
    //           left: 16,
    //           right: 16,
    //           bottom: 16,
    //           child: _buildBuildRouteButton(),
    //         ),
          
    //   ]
    // );

    return sheet;
  }
}