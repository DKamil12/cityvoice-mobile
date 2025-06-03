import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cityvoice/models/survey_stat.dart';


// Виджет CorrelationChart отображает диаграмму с данными корреляции для выбранных категорий
class CorrelationChart extends StatefulWidget {
  final List<CategoryCorrelationStat> data; // Список данных (категории)
  final List<Color> barColors; // Цвета для диаграмм

  const CorrelationChart({super.key, required this.data, required this.barColors});

  @override
  State<CorrelationChart> createState() => _CorrelationChartState();
}

class _CorrelationChartState extends State<CorrelationChart> with TickerProviderStateMixin {
  late final TabController _tabController; // Контроллер вкладок
  int _currentIndex = 0; // Текущий индекс выбранной категории

  @override
  void initState() {
    super.initState();
    // Инициализация контроллера вкладок (по количеству категорий)
    _tabController = TabController(length: widget.data.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _currentIndex = _tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxRating = 10.0; // Максимальная оценка (для шкалы)
    // Определяем максимальное количество жалоб (для масштабирования диаграмм)
    final maxComplaint = widget.data.map((e) => e.complaintCount).fold<int>(0, (prev, el) => el > prev ? el : prev);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Основная диаграмма с оценками
        SizedBox(
          height: 260,
          child: BarChart(
            BarChartData(
              maxY: maxRating,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final category = widget.data[group.x.toInt()].categoryName;
                    return BarTooltipItem(
                      '$category\n${rod.toY.toStringAsFixed(1)}',
                      const TextStyle(color: Colors.white),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true, reservedSize: 28),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              groupsSpace: 16,
              barGroups: widget.data.asMap().entries.map((entry) {
                final i = entry.key;
                final item = entry.value;

                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: item.averageRating,
                      color: widget.barColors[i % widget.barColors.length],
                      width: 12,
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Легенда для диаграммы (цвета и названия категорий)
        ...widget.data.asMap().entries.map(
          (entry) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: widget.barColors[entry.key % widget.barColors.length],
                    shape: BoxShape.rectangle,
                  ),
                ),
                Expanded(
                  child: Text(
                    entry.value.categoryName,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                Text(
                  entry.value.averageRating.toStringAsFixed(1),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                )
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          "Корреляция между оценкой и количеством жалоб",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        // Отображение детализированной диаграммы по каждой категории (с вкладками)
        SizedBox(
          height: 360,
          child: Column(
            children: [
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: widget.data.map((item) {
                    final barColor = widget.barColors[widget.data.indexOf(item) % widget.barColors.length];
                    // Перевод количества жалоб в шкалу 0-10
                    final complaintRatio = maxComplaint > 0
                        ? (item.complaintCount / maxComplaint) * 10
                        : 0.0;
                    return SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.categoryName,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 30),
                            SizedBox(
                              height: 200,
                              child: BarChart(
                                BarChartData(
                                  maxY: 10,
                                  barTouchData: BarTouchData(
                                    enabled: true,
                                    touchTooltipData: BarTouchTooltipData(
                                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                        return BarTooltipItem(
                                          '${rod.toY.toStringAsFixed(1)}',
                                          const TextStyle(color: Colors.white),
                                        );
                                      },
                                    ),
                                  ),
                                  titlesData: FlTitlesData(
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: true, reservedSize: 30),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, _) {
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 4.0),
                                          child: Text(
                                            value.toInt() == 0 ? "Оценка" : "Жалобы",
                                            style: const TextStyle(fontSize: 10),
                                          ),
                                        );
                                      }),
                                    ),
                                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  barGroups: [
                                    BarChartGroupData(x: 0, barRods: [
                                      BarChartRodData(toY: item.averageRating, color: barColor, width: 18),
                                    ]),
                                    BarChartGroupData(x: 1, barRods: [
                                      BarChartRodData(toY: complaintRatio, color: Colors.red, width: 18),
                                    ]),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text("Оценка: ${item.averageRating.toStringAsFixed(1)}"),
                            Text("Количество жалоб: ${item.complaintCount} (${complaintRatio.toStringAsFixed(1)})"),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Center(child: TabPageSelector(controller: _tabController)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
