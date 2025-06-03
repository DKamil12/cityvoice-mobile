import 'package:flutter/material.dart';
import 'package:cityvoice/services/api_service.dart';
import 'package:cityvoice/services/auth_service.dart';
import 'package:cityvoice/models/report.dart';
import 'report_details.dart';

// Экран, отображающий список заявок в выбранной категории и районе
class CategoryReportsScreen extends StatefulWidget {
  final int districtId; // Идентификатор района
  final int categoryId; // Идентификатор категории
  final String categoryName; // Название категории (отображается в AppBar)

  const CategoryReportsScreen({
    Key? key,
    required this.districtId,
    required this.categoryId,
    required this.categoryName,
  }) : super(key: key);

  @override
  State<CategoryReportsScreen> createState() => _CategoryReportsScreenState();
}

// Состояние экрана CategoryReportsScreen
class _CategoryReportsScreenState extends State<CategoryReportsScreen> {
  final ApiService _api = ApiService(); // Сервис для работы с API
  bool _loading = true; // Флаг загрузки
  bool? _isStaff;
  List<Report> _reports = []; // Список заявок

  @override
  void initState() {
    super.initState();
    _loadReports(); // Загружаем заявки при инициализации экрана
  }

  // проверяет, является ли пользователь обработчиком 
  Future<void> _checkIfStaff() async {
    bool isStaff = await AuthService().isStaff();
    setState(() {
      _isStaff = isStaff;
    });
  }

  // Метод для загрузки заявок с сервера
  Future<void> _loadReports() async {
    try {
      final reports = await _api.getReports(
        districtId: widget.districtId,
        categoryId: widget.categoryId,
      );
      setState(() {
        _reports = reports; // Сохраняем полученные заявки
        _loading = false; // Отключаем индикатор загрузки
      });
    } catch (e) {
      setState(() => _loading = false); 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки: $e')), // Выводим ошибку
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _checkIfStaff();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: _loading
          // Пока идёт загрузка — отображаем индикатор
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppBar(
                  leading: const BackButton(), // Кнопка "назад"
                  title: Text(widget.categoryName), // Заголовок с названием категории
                  centerTitle: true,
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: _reports.isEmpty
                      // Если заявок нет — показываем текст
                      ? const Center(child: Text('Заявки не найдены'))
                      // Иначе — отображаем список
                      : ListView.separated(
                          itemCount: _reports.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final report = _reports[index];
                            return Card(
                              margin: EdgeInsets.zero,
                              child: ListTile(
                                title: Text(report.name), // Заголовок заявки
                                subtitle: Text(report.description), // Краткое описание
                                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                onTap: () {
                                  // Переход к экрану деталей заявки
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
              ],
            ),
    );
  }
}
