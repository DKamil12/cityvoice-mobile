import 'package:cityvoice/models/district.dart';
import 'package:flutter/material.dart';
import 'package:cityvoice/services/auth_service.dart';
import 'package:cityvoice/services/api_service.dart';
import 'my_reports_screen.dart';
import 'district_preview_widget.dart';

/// Экран "Домашняя страница" приложения.
/// Отображает приветствие, краткую статистику по заявкам пользователя,
/// список районов (предпросмотр) и кнопку для перехода к городской статистике.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService(); // Сервис авторизации
  final ApiService _apiService = ApiService(); // Сервис для API-запросов
  bool? _isStaff; // проверяет роль пользователя
  bool _isSurveyActive = false; // проверка на наличие активных опросов

  String _username = ''; // Имя пользователя
  Map<String, int> _stats = {}; // Статистика заявок пользователя
  List<District> _districts = []; // Список районов города

  Future<void> _checkIfStaff() async {
    bool isStaff = await AuthService().isStaff();
    setState(() {
      _isStaff = isStaff;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Загрузка имени пользователя и статистики заявок
    _loadDistricts(); // Загрузка списка районов
    _checkSurveyAvailability();
  }

  /// Загружает данные пользователя: имя и статистику заявок
  Future<void> _loadUserData() async {
    final username = await _authService.getUsername();

    await _checkIfStaff();
    Map<String, int> stats;

    if (_isStaff == true) {
      stats = await _apiService.getReportsCount();
    } else {
      stats = await _apiService.getUserReportCount();
    }

    if (mounted) {
      setState(() {
        _username = username ?? '';
        _stats = stats;
      });
    }
  }

  /// Загружает список районов города
  Future<void> _loadDistricts() async {
    final districts = await _apiService.getDistricts();
    if (mounted) {
      setState(() {
        _districts = districts;
      });
    }
  }

  // проверка наличия активных опросов
  Future<void> _checkSurveyAvailability() async {
    final isActive = await _apiService.isSurveyAvailable(); // true/false
    if (mounted) {
      setState(() {
        _isSurveyActive = isActive;
      });
    }
  }

  /// Переход к экрану со списком заявок, отфильтрованных по статусу
  void _navigateToFilteredReports(String status) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MyReportsScreen(initialStatus: status)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Определяем "виджеты" для отображения статистики по заявкам
    final statusWidgets = [
      {'label': 'В процессе', 'status': 'in_progress', 'icon': Icons.schedule},
      {'label': 'Новые', 'status': 'pending', 'icon': Icons.fiber_new},
      {
        'label': 'Завершенные',
        'status': 'resolved',
        'icon': Icons.check_circle,
      },
    ];

    return Scaffold(
      body: ListView(
        children: [
          // Шапка приветствия
          Container(
            padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
            decoration: BoxDecoration(color: Colors.lightGreen[300]),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Добро пожаловать!',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    Text(
                      _username,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const Icon(Icons.emoji_events, color: Colors.yellow),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Блок "Мои заявки" — отображение количества заявок по статусам
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isStaff == true ? 'Заявки по статусам:' : 'Мои заявки:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children:
                          statusWidgets.map((item) {
                            final count = _stats[item['status']] ?? 0;
                            return GestureDetector(
                              onTap:
                                  () => _navigateToFilteredReports(
                                    item['status'] as String,
                                  ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      item['icon'] as IconData,
                                      color: Colors.teal,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${item['label']}\n$count',
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Предпросмотр активности по районам
                DistrictsPreviewWidget(districts: _districts),
                const SizedBox(height: 24),

                // виджет-уведомление о новом опросе
                if (_isStaff == false && _isSurveyActive) ...[
                  Card(
                    color: Colors.orange[100],
                    child: ListTile(
                      leading: const Icon(Icons.poll, color: Colors.deepOrange),
                      title: const Text(
                        'Новый опрос!',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text(
                        'Пожалуйста, пройдите опрос, чтобы улучшить качество сервиса.',
                      ),
                      trailing: const Icon(Icons.arrow_forward),
                      onTap: () {
                        // Переход к экрану с опросом
                        Navigator.of(context).pushNamed('/survey');
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 24),

                // Кнопка для перехода к городской статистике
                ElevatedButton.icon(
                  icon: const Icon(Icons.bar_chart),
                  label: const Text('Показатели качества по городу'),
                  onPressed: () {
                    Navigator.of(context).pushNamed('/stats');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 24,
                    ),
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
