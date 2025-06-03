import 'package:flutter/material.dart';
import 'home.dart';
import 'create_report.dart';
import 'package:cityvoice/pages/survey_screen.dart';
import 'package:cityvoice/pages/rewards_shop_screen.dart';
import 'package:cityvoice/pages/log_in.dart';
import 'package:cityvoice/pages/citywide_chart.dart';
import 'package:cityvoice/services/auth_service.dart';

/// Основной каркас приложения с навигацией
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  // Ключ навигатора для управления переходами внутри вложенного Navigator
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  // Индекс выбранной кнопки нижнего меню
  int _selectedIndex = 0;

  // Флаг, указывающий, является ли пользователь сотрудником (staff)
  bool? _isStaff;

  @override
  void initState() {
    super.initState();
    // Проверяем роль пользователя (staff или обычный пользователь)
    _checkIfStaff();
  }

  /// Метод для проверки роли пользователя (staff или нет)
  Future<void> _checkIfStaff() async {
    final isStaff = await AuthService().isStaff();
    setState(() {
      _isStaff = isStaff;
    });
  }

  /// Список маршрутов, который зависит от роли пользователя
  List<String> get _mainRoutes {
    if (_isStaff == true) {
      // Для сотрудников: домашняя страница и графики
      return ['/home', '/stats'];
    } else {
      // Для обычных пользователей: домашняя страница, опрос, магазин
      return ['/home', '/survey', '/shop'];
    }
  }

  /// Обработчик нажатия на кнопки нижней панели
  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    // Меняем маршрут в Navigator на выбранный
    _navigatorKey.currentState!.pushNamedAndRemoveUntil(
      _mainRoutes[index],
      (route) => false,
    );
  }

  /// Выход пользователя из аккаунта и переход на экран авторизации
  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LogInPage()),
      (route) => false,
    );
  }

  /// Открытие экрана создания новой заявки (только для обычных пользователей)
  void _openCreateReport() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NewReportScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Основное содержимое - вложенный Navigator
      body: Navigator(
        key: _navigatorKey,
        initialRoute: '/home',
        onGenerateRoute: (settings) {
          late Widget page;
          switch (settings.name) {
            case '/home':
              page = const HomeScreen(); // Главная страница
              break;
            case '/survey':
              page = const SurveyScreen(); // Экран опроса
              break;
            case '/shop':
              page = const RewardsShopScreen(); // Экран магазина наград
              break;
            case '/stats':
              page = const CitywideSurveyStatsScreen(); // Графики (для staff)
              break;
            default:
              page = const HomeScreen(); // fallback
          }
          return MaterialPageRoute(builder: (_) => page, settings: settings);
        },
      ),

      // Нижняя панель навигации
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(), // Вырез для плавающей кнопки
        notchMargin: 8.0,
        child: Row(
          children: [
            // Первая кнопка: Домашняя страница
            Expanded(
              child: IconButton(
                icon: const Icon(Icons.home),
                onPressed: () => _onItemTapped(0),
              ),
            ),

            // Вторая кнопка: Графики (для staff) или опрос (для обычных пользователей)
            if (_isStaff == true)
              Expanded(
                child: IconButton(
                  icon: const Icon(Icons.query_stats),
                  onPressed: () => _onItemTapped(1),
                ),
              )
            else
              Expanded(
                child: IconButton(
                  icon: const Icon(Icons.poll),
                  onPressed: () => _onItemTapped(1),
                ),
              ),

            // Промежуток для плавающей кнопки "+"
            if (_isStaff != true)
              const SizedBox(width: 48),

            // Третья кнопка: Магазин (только для обычных пользователей)
            if (_isStaff != true)
              Expanded(
                child: IconButton(
                  icon: const Icon(Icons.shopping_bag),
                  onPressed: () => _onItemTapped(2),
                ),
              ),

            // Четвёртая кнопка: Выход
            Expanded(
              child: IconButton(
                icon: const Icon(Icons.logout),
                onPressed: _logout,
              ),
            ),
          ],
        ),
      ),

      // Плавающая кнопка для создания новой заявки (только для обычных пользователей)
      floatingActionButton: _isStaff == true
          ? null
          : FloatingActionButton(
              backgroundColor: Colors.teal,
              onPressed: _openCreateReport,
              child: const Icon(Icons.add),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
