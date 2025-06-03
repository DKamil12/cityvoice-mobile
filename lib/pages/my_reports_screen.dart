import 'package:cityvoice/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:cityvoice/models/report.dart';
import 'package:cityvoice/services/api_service.dart';
import 'report_details.dart';

/// Экран для отображения всех заявок пользователя с возможностью фильтрации по статусу
class MyReportsScreen extends StatefulWidget {
  /// Начальный статус, который нужно отобразить (например, при переходе с кнопки главного экрана)
  final String? initialStatus;

  const MyReportsScreen({super.key, this.initialStatus});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  final ApiService _apiService = ApiService();
  bool? _isStaff; // true/false, если пользователь — сотрудник (is_staff)
  List<Report> _allReports = []; // Все загруженные заявки
  List<Report> _filteredReports = []; // Отфильтрованные заявки
  String? _selectedStatus; // Выбранный статус

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.initialStatus;
    _loadReports();
  }

  /// Загружает список заявок пользователя
  Future<void> _loadReports() async {
    await _checkIfStaff();
    List<Report> reports;

    if (_isStaff == true) {
      reports = await _apiService.getReports();
    } else {
      reports = await _apiService.getUserReports();
    }

    setState(() {
      _allReports = reports;
      _filteredReports = _selectedStatus != null
          ? reports.where((r) => r.status == _selectedStatus).toList()
          : reports;
    });
  }

  /// Проверяет, является ли пользователь сотрудником (is_staff)
  Future<void> _checkIfStaff() async {
    bool isStaff = await AuthService().isStaff();
    setState(() {
      _isStaff = isStaff;
    });
  }

  /// Обновляет фильтрацию по выбранному статусу
  void _onFilterChange(String? status) {
    setState(() {
      _selectedStatus = status;
      _filteredReports = status != null
          ? _allReports.where((r) => r.status == status).toList()
          : _allReports;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Определяем доступные статусы для фильтрации
    final statusOptions = [
      {'label': 'Все', 'value': null},
      {'label': 'Новые', 'value': 'pending'},
      {'label': 'В процессе', 'value': 'in_progress'},
      {'label': 'Завершенные', 'value': 'resolved'},
      {'label': 'Отклоненные', 'value': 'rejected'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Мои заявки')),
      body: Column(
        children: [
          const SizedBox(height: 8),
          // Горизонтальный список фильтров
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: statusOptions.length,
              itemBuilder: (_, index) {
                final item = statusOptions[index];
                final isSelected = item['value'] == _selectedStatus;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(item['label']!),
                    selected: isSelected,
                    onSelected: (_) => _onFilterChange(item['value']),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Список отфильтрованных заявок
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadReports,
              child: ListView.builder(
                itemCount: _filteredReports.length,
                itemBuilder: (context, index) {
                  final report = _filteredReports[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: ListTile(
                      title: Text(report.name),
                      subtitle: Text(
                        report.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReportDetailsScreen(
                              report: report,
                              isStaff: _isStaff!,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
