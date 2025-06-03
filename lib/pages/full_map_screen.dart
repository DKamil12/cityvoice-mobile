import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';


/// Экран для отображения карты с заданной точкой.
/// Используется для отображения детального местоположения (например, адреса жалобы).
class FullMapScreen extends StatelessWidget {
  final LatLng location; // Координаты, которые нужно показать на карте

  const FullMapScreen({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    // Если координаты не заданы (0,0), показываем сообщение об ошибке
    if (location.latitude == 0 && location.longitude == 0) {
      return const Scaffold(
        body: Center(child: Text('Местоположение не задано')),
      );
    }

    // Отображаем карту с маркером в указанной точке
    return Scaffold(
      appBar: AppBar(title: const Text('Местоположение')),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: location, // Центрируем карту на указанной точке
          initialZoom: 16, // Устанавливаем начальный уровень масштабирования
        ),
        children: [
          // Слой с картами OpenStreetMap
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.cityvoice',
          ),
          // Слой с маркером в точке location
          MarkerLayer(
            markers: [
              Marker(
                point: location,
                width: 40,
                height: 40,
                child: const Icon(
                  Icons.location_pin,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
