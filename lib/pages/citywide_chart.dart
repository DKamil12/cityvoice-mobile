// import 'package:cityvoice/models/survey_stat.dart';
// import 'package:flutter/material.dart';
// import 'package:cityvoice/services/api_service.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:cityvoice/models/district.dart';
// import 'package:cityvoice/pages/district_survey_stat.dart';

// class CorrelationChart extends StatelessWidget {
//   final List<CategoryCorrelationStat> data;

//   const CorrelationChart({super.key, required this.data});

//   @override
//   Widget build(BuildContext context) {
//     final maxY = data.map((e) => e.complaintCount.toDouble()).fold<double>(10, (prev, val) => val > prev ? val : prev) + 5;

//     return BarChart(
//       BarChartData(
//         maxY: maxY,
//         barTouchData: BarTouchData(enabled: true),
//         titlesData: FlTitlesData(
//           leftTitles: AxisTitles(
//             sideTitles: SideTitles(showTitles: true),
//           ),
//           bottomTitles: AxisTitles(
//             sideTitles: SideTitles(
//               showTitles: true,
//               getTitlesWidget: (value, meta) {
//                 final i = value.toInt();
//                 return i < data.length
//                     ? RotatedBox(
//                         quarterTurns: 3,
//                         child: Text(data[i].categoryName.split(' ').first, style: const TextStyle(fontSize: 10)),
//                       )
//                     : const SizedBox.shrink();
//               },
//             ),
//           ),
//           rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//           topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//         ),
//         borderData: FlBorderData(show: false),
//         barGroups: data.asMap().entries.map((entry) {
//           final i = entry.key;
//           final item = entry.value;
//           return BarChartGroupData(
//             x: i,
//             barRods: [
//               BarChartRodData(
//                 toY: item.averageRating,
//                 color: Colors.blue,
//                 width: 6,
//               ),
//               BarChartRodData(
//                 toY: item.complaintCount.toDouble(),
//                 color: Colors.red,
//                 width: 6,
//               ),
//             ],
//             barsSpace: 4,
//           );
//         }).toList(),
//         groupsSpace: 16,
//       ),
//     );
//   }
// }

// class CitywideSurveyStatsScreen extends StatefulWidget {
//   const CitywideSurveyStatsScreen({super.key});

//   @override
//   State<CitywideSurveyStatsScreen> createState() =>
//       _CitywideSurveyStatsScreenState();
// }

// class _CitywideSurveyStatsScreenState extends State<CitywideSurveyStatsScreen> {
//   final ApiService _api = ApiService();
//   bool _loading = true;
//   List<CityWideSurveyStat> _data = [];

//   List<District> _districts = [];
//   int? _selectedDistrictId;

//   final List<Color> _barColors = [
//     Colors.green,
//     Colors.green[800]!,
//     Colors.lightBlue,
//     Colors.blue[900]!,
//     Colors.red,
//     Colors.grey,
//     Colors.amber,
//     Colors.teal,
//     Colors.purple,
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _loadStats();
//     _loadDistricts();
//   }

//   Future<void> _loadDistricts() async {
//     final districts = await _api.getDistricts();
//     setState(() => _districts = districts);
//   }

//   Future<void> _loadStats() async {
//     try {
//       final result = await _api.getCitywideSurveyStats();
//       setState(() {
//         _data = result;
//         _loading = false;
//       });
//     } catch (e) {
//       setState(() => _loading = false);
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Ошибка загрузки статистики')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child:
//           _loading
//               ? const Center(child: CircularProgressIndicator())
//               : Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   AppBar(
//                     leading: BackButton(),
//                     title: const Text('Городская статистика'),
//                     centerTitle: true,
//                   ),
//                   const SizedBox(height: 16),

//                   DropdownButtonFormField<int>(
//                     value: _selectedDistrictId,
//                     hint: const Text('Выберите район'),
//                     decoration: const InputDecoration(
//                       border: OutlineInputBorder(),
//                       contentPadding: EdgeInsets.symmetric(
//                         horizontal: 12,
//                         vertical: 10,
//                       ),
//                     ),
//                     items: [
//                       DropdownMenuItem<int>(
//                         value: -1,
//                         child: Text('Весь город'),
//                       ),
//                       ..._districts.map(
//                         (d) => DropdownMenuItem<int>(
//                           value: d.id,
//                           child: Text(d.name),
//                         ),
//                       ),
//                     ],
//                     onChanged: (value) {
//                       if (value == -1) {
//                         // Перезагружаем городскую статистику
//                         _loadStats();
//                         setState(() => _selectedDistrictId = null);
//                       } else {
//                         final selectedDistrict = _districts.firstWhere(
//                           (d) => d.id == value,
//                         );
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder:
//                                 (_) => DistrictSurveyStatsScreen(
//                                   district: selectedDistrict,
//                                 ),
//                           ),
//                         );
//                       }
//                     },
//                   ),
//                   const SizedBox(height: 16),
//                   SizedBox(
//                     height: 250,
//                     child: BarChart(
//                       BarChartData(
//                         alignment: BarChartAlignment.spaceAround,
//                         maxY: 10,
//                         barTouchData: BarTouchData(enabled: false),
//                         titlesData: FlTitlesData(
//                           bottomTitles: AxisTitles(
//                             sideTitles: SideTitles(
//                               showTitles: true,
//                               getTitlesWidget: (value, meta) {
//                                 final index = value.toInt();
//                                 return index < _data.length
//                                     ? Transform.rotate(
//                                       angle: -0.6,
//                                       child: Text(
//                                         _data[index].question
//                                             .split(' ')
//                                             .first,
//                                         style: const TextStyle(fontSize: 10),
//                                       ),
//                                     )
//                                     : const SizedBox.shrink();
//                               },
//                               reservedSize: 40,
//                             ),
//                           ),
//                           leftTitles: AxisTitles(
//                             sideTitles: SideTitles(
//                               showTitles: true,
//                               reservedSize: 30,
//                             ),
//                           ),
//                           topTitles: AxisTitles(
//                             sideTitles: SideTitles(showTitles: false),
//                           ),
//                           rightTitles: AxisTitles(
//                             sideTitles: SideTitles(showTitles: false),
//                           ),
//                         ),
//                         borderData: FlBorderData(show: false),
//                         barGroups:
//                             _data
//                                 .asMap()
//                                 .map(
//                                   (i, item) => MapEntry(
//                                     i,
//                                     BarChartGroupData(
//                                       x: i,
//                                       barRods: [
//                                         BarChartRodData(
//                                           toY: item.average * 1.0,
//                                           width: 14,
//                                           borderRadius: BorderRadius.circular(
//                                             4,
//                                           ),
//                                           color: _barColors[i % _barColors.length],
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 )
//                                 .values
//                                 .toList(),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   ..._data.asMap().entries.map(
//                     (entry) => Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 4),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Container(
//                           width: 16,
//                           height: 16,
//                           margin: const EdgeInsets.only(right: 8),
//                           decoration: BoxDecoration(
//                             color: _barColors[entry.key % _barColors.length],
//                             shape: BoxShape.rectangle,
//                           ),
//                         ),
//                           Expanded(
//                             child: Text(
//                               entry.value.question.split('–').first.trim(),
//                               style: const TextStyle(fontSize: 14),
//                             ),
//                           ),
//                           Text(entry.value.average.toStringAsFixed(1)),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cityvoice/models/district.dart';
import 'package:cityvoice/models/survey_stat.dart';
import 'package:cityvoice/services/api_service.dart';
import 'package:cityvoice/pages/correlation_chart.dart';
import 'package:cityvoice/pages/district_survey_stat.dart';

class CitywideSurveyStatsScreen extends StatefulWidget {
  const CitywideSurveyStatsScreen({super.key});

  @override
  State<CitywideSurveyStatsScreen> createState() =>
      _CitywideSurveyStatsScreenState();
}

class _CitywideSurveyStatsScreenState extends State<CitywideSurveyStatsScreen> {
  final ApiService _api = ApiService();
  bool _loading = true;
  List<CategoryCorrelationStat> _correlationData = [];
  List<District> _districts = [];
  int? _selectedDistrictId;

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
    _loadDistricts();
    _loadCorrelationStats();
  }

  Future<void> _loadDistricts() async {
    final districts = await _api.getDistricts();
    setState(() => _districts = districts);
  }

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
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                        DropdownMenuItem<int>(
                          value: -1,
                          child: Text('Весь город'),
                        ),
                        ..._districts.map(
                          (d) => DropdownMenuItem<int>(
                            value: d.id,
                            child: Text(d.name),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == -1) {
                          _loadCorrelationStats();
                          setState(() => _selectedDistrictId = null);
                        } else {
                          final selectedDistrict = _districts.firstWhere(
                            (d) => d.id == value,
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => DistrictSurveyStatsScreen(
                                    district: selectedDistrict,
                                  ),
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 16),
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
