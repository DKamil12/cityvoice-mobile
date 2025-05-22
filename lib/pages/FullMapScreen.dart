import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class FullMapScreen extends StatelessWidget {
  final LatLng location;
  const FullMapScreen({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    if (location.latitude == 0 && location.longitude == 0) {
      return const Scaffold(
        body: Center(child: Text('Местоположение не задано')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Местоположение')),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: location,
          initialZoom: 16,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.cityvoice',
          ),
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
