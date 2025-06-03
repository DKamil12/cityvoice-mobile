import 'package:flutter/material.dart';
import 'package:cityvoice/services/api_service.dart';
import 'package:cityvoice/models/district.dart';
import 'district_stats_screen.dart';


// Экран, отображающий список всех районов города с возможностью перейти к статистике
class DistrictListScreen extends StatefulWidget {
  const DistrictListScreen({Key? key}) : super(key: key);

  @override
  State<DistrictListScreen> createState() => _DistrictListScreenState();
}

class _DistrictListScreenState extends State<DistrictListScreen> {
  final ApiService _api = ApiService(); // Сервис для загрузки данных с API
  bool _loading = true; // Флаг для отображения загрузки
  List<District> _districts = []; // Список районов

  @override
  void initState() {
    super.initState();
    _loadDistricts(); // Загрузка данных при инициализации
  }

  // Метод для загрузки списка районов
  Future<void> _loadDistricts() async {
    final list = await _api.getDistricts();
    setState(() {
      _districts = list;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Заявки по районам')),
      // Если данные загружаются — показываем индикатор
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _districts.length,
              itemBuilder: (context, index) {
                final d = _districts[index];
                return ListTile(
                  title: Text(d.name),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  // При нажатии — переход к экрану статистики района
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DistrictStatsScreen(district: d),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
