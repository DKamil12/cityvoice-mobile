import 'package:flutter/material.dart';
import 'package:cityvoice/services/api_service.dart';
import 'package:cityvoice/models/district.dart';
import 'package:cityvoice/models/district_stat.dart';
import 'CategoryReportsScreen.dart';

/// Экран статистики по выбранному району
class DistrictStatsScreen extends StatefulWidget {
  final District district;
  const DistrictStatsScreen({Key? key, required this.district})
    : super(key: key);

  @override
  State<DistrictStatsScreen> createState() => _DistrictStatsScreenState();
}

class _DistrictStatsScreenState extends State<DistrictStatsScreen> {
  final ApiService _api = ApiService();
  bool _loading = true;
  DistrictStats? _stats;
  String _period = 'month';

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

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
      // Обработка ошибок
      setState(() => _loading = false);
    }
  }

  void _selectPeriod() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder:
          (_) => SafeArea(
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
      _loadStats();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.district.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child:
            _loading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Период
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
                    // Всего жалоб
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
                    // По категориям
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
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => CategoryReportsScreen(
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
