import 'package:flutter/material.dart';
import 'package:cityvoice/services/api_service.dart';
import 'package:cityvoice/models/district.dart';
import 'package:cityvoice/models/district_stat.dart';
import 'category_reports_screen.dart';


/// Экран, отображающий статистику по выбранному району.
/// Пользователь может выбрать период (неделя/месяц) и увидеть количество жалоб в целом и по категориям.
class DistrictStatsScreen extends StatefulWidget {
  final District district; // Данные о районе, передаются при открытии экрана

  const DistrictStatsScreen({Key? key, required this.district})
      : super(key: key);

  @override
  State<DistrictStatsScreen> createState() => _DistrictStatsScreenState();
}

class _DistrictStatsScreenState extends State<DistrictStatsScreen> {
  final ApiService _api = ApiService(); // Сервис для работы с API
  bool _loading = true; // Флаг загрузки
  DistrictStats? _stats; // Данные статистики
  String _period = 'month'; // Выбранный период (по умолчанию - месяц)

  @override
  void initState() {
    super.initState();
    _loadStats(); // Загрузка статистики при инициализации
  }

  // Метод для загрузки статистики с сервера
  Future<void> _loadStats() async {
    setState(() => _loading = true);
    try {
      final stats = await _api.getDistrictCategoryStats(
        districtId: widget.district.id,
        startDate: null,
        endDate: null,
      );
      if (mounted) {
        setState(() {
          _stats = stats;
          _loading = false;
        });
      }
    } catch (e) {
      // В случае ошибки просто останавливаем загрузку
      setState(() => _loading = false);
    }
  }

  // Метод для выбора периода (неделя/месяц)
  void _selectPeriod() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('За неделю'),
              onTap: () => Navigator.pop(context, 'week'),
            ),
            ListTile(
              title: const Text('За месяц'),
              onTap: () => Navigator.pop(context, 'month'),
            ),
          ],
        ),
      ),
    );
    if (choice != null && choice != _period) {
      setState(() => _period = choice);
      _loadStats(); // Загружаем данные заново с новым периодом
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.district.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Выбор периода
                  GestureDetector(
                    onTap: _selectPeriod,
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today),
                        const SizedBox(width: 8),
                        Text(_period == 'month' ? 'За месяц' : 'За неделю'),
                        const Spacer(),
                        const Icon(Icons.arrow_forward_ios, size: 16),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Блок с общим количеством жалоб
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Text(
                          'Всего жалоб',
                          style: TextStyle(fontSize: 16),
                        ),
                        const Spacer(),
                        Text(
                          '${_stats?.total ?? 0}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Список категорий с количеством жалоб
                  Expanded(
                    child: ListView.builder(
                      itemCount: _stats?.categories.length ?? 0,
                      itemBuilder: (ctx, i) {
                        final item = _stats!.categories[i];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          // Переход к экрану с жалобами по выбранной категории
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CategoryReportsScreen(
                                    districtId: widget.district.id,
                                    categoryId: item.id,
                                    categoryName: item.name,
                                  ),
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                Text(
                                  item.name,
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const Spacer(),
                                Text(
                                  item.count.toString(),
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
