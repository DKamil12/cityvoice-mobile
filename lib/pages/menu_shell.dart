// import 'package:flutter/material.dart';
// import 'home.dart';
// import 'create_report.dart';
// import 'package:cityvoice/pages/survey_screen.dart';
// import 'package:cityvoice/pages/rewards_shop_screen.dart';
// import 'package:cityvoice/services/auth_service.dart';
// import 'package:cityvoice/pages/log_in.dart';

// class MainShell extends StatefulWidget {
//   const MainShell({Key? key}) : super(key: key);

//   @override
//   State<MainShell> createState() => _MainShellState();
// }

// class _MainShellState extends State<MainShell> {
//   final AuthService _api = AuthService();
//   int _selectedIndex = 0;

//   final List<Widget> _screens = [
//     HomeScreen(), // Список заявок
//     SurveyScreen(), // Опросы
//     RewardsShopScreen(), // Магазин
//   ];

//   void _onItemTapped(int index) {
//     setState(() => _selectedIndex = index);
//   }

//   void _logout() async {
//     await _api.logout();
//     if (!mounted) return;
//     Navigator.pushAndRemoveUntil(
//       context,
//       MaterialPageRoute(builder: (_) => const LogInPage()),
//       (route) => false,
//     );
//   }

//   void _openCreateReport() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => const NewReportScreen()),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _screens[_selectedIndex],
//       bottomNavigationBar: BottomAppBar(
//         shape: const CircularNotchedRectangle(),
//         notchMargin: 8.0,
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             IconButton(
//               icon: const Icon(Icons.home),
//               onPressed: () => _onItemTapped(0),
//             ),
//             IconButton(
//               icon: const Icon(Icons.query_stats),
//               onPressed: () => _onItemTapped(1),
//             ),
//             const SizedBox(width: 48), // место под FAB
//             IconButton(
//               icon: const Icon(Icons.shopping_bag),
//               onPressed: () => _onItemTapped(2),
//             ),
//             IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: Colors.teal,
//         onPressed: _openCreateReport,
//         child: const Icon(Icons.add),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'home.dart';
import 'create_report.dart';
import 'package:cityvoice/pages/survey_screen.dart';
import 'package:cityvoice/pages/rewards_shop_screen.dart';
import 'package:cityvoice/pages/log_in.dart';
import 'package:cityvoice/pages/citywide_chart.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  int _selectedIndex = 0;

  final List<String> _mainRoutes = ['/home', '/survey', '/shop'];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    _navigatorKey.currentState!.pushNamedAndRemoveUntil(
      _mainRoutes[index],
      (route) => false,
    );
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LogInPage()),
      (route) => false,
    );
  }

  void _openCreateReport() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NewReportScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Navigator(
        key: _navigatorKey,
        initialRoute: '/home',
        onGenerateRoute: (settings) {
          late Widget page;
          switch (settings.name) {
            case '/home':
              page = const HomeScreen();
              break;
            case '/survey':
              page = const SurveyScreen();
              break;
            case '/shop':
              page = const RewardsShopScreen();
              break;
            case '/stats':
              page = const CitywideSurveyStatsScreen();
              break;
            default:
              page = const HomeScreen(); // fallback
          }

          return MaterialPageRoute(builder: (_) => page, settings: settings);
        },
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () => _onItemTapped(0),
            ),
            IconButton(
              icon: const Icon(Icons.query_stats),
              onPressed: () => _onItemTapped(1),
            ),
            const SizedBox(width: 48),
            IconButton(
              icon: const Icon(Icons.shopping_bag),
              onPressed: () => _onItemTapped(2),
            ),
            IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: _openCreateReport,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
