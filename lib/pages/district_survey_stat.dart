import 'package:flutter/material.dart';
import 'package:cityvoice/services/api_service.dart';
import 'package:cityvoice/models/district.dart';
import 'package:cityvoice/models/survey_stat.dart';
import 'package:cityvoice/pages/district_correlation_chart.dart';

class DistrictSurveyStatsScreen extends StatefulWidget {
  final District district;
  const DistrictSurveyStatsScreen({super.key, required this.district});

  @override
  State<DistrictSurveyStatsScreen> createState() => _DistrictSurveyStatsScreenState();
}

class _DistrictSurveyStatsScreenState extends State<DistrictSurveyStatsScreen> {
  final ApiService _api = ApiService();
  bool _loading = true;
  List<CategoryCorrelationStat> _data = [];

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
    Colors.deepPurple,
    Colors.indigo,
    Colors.brown,
    Colors.orange,
    Colors.pink,
  ];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final result = await _api.getDistrictCategoryCorrelationStats(widget.district.id);
      setState(() {
        _data = result;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка загрузки данных')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Опрос: ${widget.district.name}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: DistrictCorrelationChart(
                  data: _data,
                  barColors: _barColors,
                ),
              ),
      ),
    );
  }
}
