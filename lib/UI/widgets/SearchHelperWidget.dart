import 'dart:async';

import 'package:application_front/CORE/repositories/MapData.dart';
import 'package:application_front/CORE/repositories/RoomData.dart';
import 'package:flutter/material.dart';

class SearchHelperWidget extends StatefulWidget {
  final Function(RoomData) onRoomSelected;
  
  const SearchHelperWidget({super.key, required this.onRoomSelected});

  @override
  _SearchHelperWidgetState createState() => _SearchHelperWidgetState();
}

class _SearchHelperWidgetState extends State<SearchHelperWidget> {
  Timer? _debounceTimer;
  List<RoomData> _rooms = [];
  bool _isLoading = false;
  
  void _onSearchChanged(String query) {
    setState(() => _isLoading = true);
    _rooms = [];
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    
    _debounceTimer = Timer(const Duration(seconds: 1), () async 
    {
      try {
        final rooms = await MapData.FindRoom(query);
        setState(() {
          _rooms = rooms;
          _isLoading = false;
        });
      } catch (e) {
        setState(() => _isLoading = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                onChanged: _onSearchChanged,
                decoration: const InputDecoration(
                  hintText: 'Введите название помещения...',
                  prefixIcon: Icon(Icons.search),
                ),
              ),

              if (_isLoading) ...[
                const SizedBox(height: 20.0),
                const CircularProgressIndicator()
              ]
              else
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: _rooms.length,
                    itemBuilder: (context, index) {
                      final room = _rooms[index];
                      return ListTile(
                        title: Text(room.name),
                        onTap: () => widget.onRoomSelected(room),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}