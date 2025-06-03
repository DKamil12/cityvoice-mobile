import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


/// Экран выбора точки на карте с поиском и определением текущего местоположения
class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({Key? key}) : super(key: key);

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  LatLng _center = LatLng(43.238949, 76.889709); // начальный центр - Алматы
  LatLng? _selectedPoint; // выбранная точка пользователем

  /// Поиск адреса с помощью Nominatim API
  Future<void> _searchAddress() async {
    final query = _searchController.text;
    if (query.isEmpty) return;

    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=1',
    );

    try {
      final response = await http.get(
        url,
        headers: {'User-Agent': 'flutter-app-cityvoice/1.0'},
      );

      final List data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        final firstResult = data.first;
        final double lat = double.parse(firstResult['lat']);
        final double lon = double.parse(firstResult['lon']);

        final LatLng location = LatLng(lat, lon);

        // Перемещаем карту к найденной точке
        _mapController.move(location, 16);
        setState(() {
          _selectedPoint = location;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ничего не найдено')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка поиска: $e')),
      );
    }
  }

  /// Определение текущего местоположения пользователя
  Future<void> _goToUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Проверяем, включена ли служба геолокации
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Службы геолокации отключены')),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Разрешение на доступ к геолокации отклонено')),
        );
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Доступ к геолокации навсегда запрещён')),
      );
      return;
    }

    // Получаем текущее местоположение
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    final LatLng currentLocation = LatLng(
      position.latitude,
      position.longitude,
    );

    _mapController.move(currentLocation, 17);
    setState(() {
      _selectedPoint = currentLocation;
    });
  }

  /// Выбор точки (отправка её в предыдущий экран)
  void _selectPoint() {
    if (_selectedPoint != null) {
      Navigator.pop(context, _selectedPoint);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, выберите место на карте')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Выберите точку на карте')),
      body: Stack(
        children: [
          // Карта с возможностью выбора точки
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: 13.0,
              onTap: (tapPosition, point) {
                setState(() {
                  _selectedPoint = point;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.cityvoice',
              ),
              if (_selectedPoint != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 80,
                      height: 80,
                      point: _selectedPoint!,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Поиск адреса
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Поиск адреса...',
                fillColor: Colors.white,
                filled: true,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchAddress,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          // Кнопка перехода к текущему местоположению
          Positioned(
            bottom: 100,
            right: 16,
            child: FloatingActionButton(
              heroTag: 'locate',
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              onPressed: _goToUserLocation,
              child: const Icon(Icons.my_location),
            ),
          ),

          // Кнопка подтверждения выбора
          Positioned(
            bottom: 30,
            right: 16,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _selectPoint,
              icon: const Icon(Icons.check, color: Colors.white),
              label: const Text(
                'Выбрать это место',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
