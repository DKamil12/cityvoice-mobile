import 'package:flutter/material.dart';
import 'package:cityvoice/models/district.dart';
import 'package:cityvoice/models/survey_stat.dart'; 
import 'package:cityvoice/services/api_service.dart'; 
import 'package:cityvoice/pages/correlation_chart.dart'; 
import 'package:cityvoice/pages/district_survey_stat.dart'; 

// Экран отображения городской статистики (по опросам и жалобам)
class CitywideSurveyStatsScreen extends StatefulWidget {
  const CitywideSurveyStatsScreen({super.key});

  @override
  State<CitywideSurveyStatsScreen> createState() =>
      _CitywideSurveyStatsScreenState();
}

class _CitywideSurveyStatsScreenState extends State<CitywideSurveyStatsScreen> {
  final ApiService _api = ApiService(); // Сервис для взаимодействия с API
  bool _loading = true; // Флаг загрузки
  List<CategoryCorrelationStat> _correlationData = []; // Список корреляционных данных
  List<District> _districts = []; // Список районов
  int? _selectedDistrictId; // Выбранный район

  // Цвета для отображения диаграммы
  final List<Color> _barColors = [
    Colors.green,
    Colors.green[800]!,
    Colors.lightBlue,
    Colors.blue[900]!,
    Colors.red,
    Colors.grey,
    Colors.amber,
    Colors.teal,
    Colors.purple,
  ];

  @override
  void initState() {
    super.initState();
    _loadDistricts(); // Загружаем список районов
    _loadCorrelationStats(); // Загружаем общегородскую статистику
  }

  // Загрузка списка районов с сервера
  Future<void> _loadDistricts() async {
    final districts = await _api.getDistricts();
    setState(() => _districts = districts);
  }

  // Загрузка общегородской корреляционной статистики
  Future<void> _loadCorrelationStats() async {
    try {
      final result = await _api.getCategoryCorrelationStats();
      setState(() {
        _correlationData = result;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка загрузки статистики')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Городская статистика'),
        centerTitle: true,
      ),
      body: _loading
          // Индикатор загрузки, если данные ещё не получены
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Выпадающий список для выбора района
                  DropdownButtonFormField<int>(
                    value: _selectedDistrictId,
                    hint: const Text('Выберите район'),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    items: [
                      // Пункт "Весь город"
                      DropdownMenuItem<int>(
                        value: -1,
                        child: Text('Весь город'),
                      ),
                      // Пункты с районами
                      ..._districts.map(
                        (d) => DropdownMenuItem<int>(
                          value: d.id,
                          child: Text(d.name),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == -1) {
                        // При выборе "Весь город" загружаем общую статистику
                        _loadCorrelationStats();
                        setState(() => _selectedDistrictId = null);
                      } else {
                        // При выборе конкретного района открываем экран с районной статистикой
                        final selectedDistrict = _districts.firstWhere(
                          (d) => d.id == value,
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DistrictSurveyStatsScreen(
                              district: selectedDistrict,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  // Диаграмма с данными корреляции
                  CorrelationChart(
                    data: _correlationData,
                    barColors: _barColors,
                  ),
                ],
              ),
            ),
    );
  }
}
