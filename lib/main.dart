import 'package:flutter/material.dart';
import 'package:cityvoice/services/auth_service.dart';
import './pages/menu_shell.dart';
import './pages/log_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AuthService().logout();
  final isLoggedIn = await AuthService().isLoggedIn();
  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: isLoggedIn ? '/main' : '/login',
      onGenerateRoute: (RouteSettings settings) {
        late Widget page;

        switch (settings.name) {
          case '/main':
            page = const MainShell();
            break;
          case '/login':
            page = const LogInPage();
            break;
          default:
            page = const Scaffold(
              body: Center(child: Text('404 – Страница не найдена')),
            );
        }

        return MaterialPageRoute(builder: (_) => page, settings: settings);
      },
    );
  }
}
