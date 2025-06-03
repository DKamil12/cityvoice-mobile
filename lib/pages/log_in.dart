import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cityvoice/services/api_service.dart';
import 'package:cityvoice/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'menu_shell.dart';
import 'package:cityvoice/pages/password_widgets.dart';
import 'register.dart';


/// Основная форма входа (логина)
class CustomForm extends StatefulWidget {
  const CustomForm({super.key});

  @override
  State<CustomForm> createState() => _CustomFormState();
}

class _CustomFormState extends State<CustomForm> {
  final apiService = ApiService();
  final authService = AuthService();
  final _keyForm = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    // Освобождение ресурсов
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Отправка запроса авторизации и сохранение токенов
  void _login() async {
    final response = await http.post(
      Uri.parse('https://cityvoice-api.onrender.com/api/v1/token/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': _emailController.text,
        'password': _passwordController.text,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await authService.saveTokens(data['access'], data['refresh']);

      // Переход к главному экрану приложения
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    } else if (response.statusCode == 401) {
      _showErrorMessage(context, 'Неверный логин или пароль');
    } else {
      _showErrorMessage(context, 'Ошибка: ${response.statusCode}');
    }
  }

  /// Отображение ошибки
  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.displayMedium?.copyWith(
      color: Colors.black,
    );

    return Form(
      key: _keyForm,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 25),
        child: Center(
          child: Column(
            children: [
              Text('Войти', style: textStyle),
              const SizedBox(height: 10),
              const Text(
                'Добро пожаловать!',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Поле для ввода email
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Email', style: TextStyle(fontSize: 14)),
                  TextFormField(
                    controller: _emailController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Введите email в формате Example@mail.com';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      hintText: 'Example@email.com',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue, width: 2),
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                    ),
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),

              // Поле для ввода пароля (с кастомным виджетом)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Пароль', style: TextStyle(fontSize: 14)),
                  PasswordField(controller: _passwordController),
                ],
              ),

              const SizedBox(height: 20),

              // Кнопка входа
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                  onPressed: () {
                    if (_keyForm.currentState!.validate()) {
                      _login();
                    }
                  },
                  child: const Text(
                    'Войти',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Ссылка на экран регистрации
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  );
                },
                child: const Text("Нет аккаунта? Зарегистрироваться"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Обёртка для отображения экрана входа
class LogInPage extends StatelessWidget {
  const LogInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: CustomForm());
  }
}
