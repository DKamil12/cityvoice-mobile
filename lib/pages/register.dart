import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'log_in.dart';
import 'package:cityvoice/services/auth_service.dart';
import 'menu_shell.dart';
import 'package:cityvoice/pages/password_widgets.dart';

/// Экран для регистрации нового пользователя
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  // Контроллеры для текстовых полей
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  bool _isLoading = false;

  /// Метод отправки данных регистрации на сервер
  Future<void> _register() async {
    // Проверяем, что форма валидна
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final url = Uri.parse(
      'https://cityvoice-api.onrender.com/api/v1/register/',
    );
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': _usernameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
      }),
    );

    setState(() => _isLoading = false);

    if (response.statusCode == 201) {
      // Если регистрация успешна, сохраняем токены и переходим на главный экран
      final data = jsonDecode(response.body);
      await _authService.saveTokens(data['access'], data['refresh']);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    } else {
      // Отображаем сообщение об ошибке
      final error = jsonDecode(response.body);
      final message = error['message'] ?? 'Ошибка регистрации';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  /// Декоратор для текстовых полей с общими стилями
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.teal, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 25),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Заголовок
              const Center(
                child: Text(
                  'Регистрация',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 6),
              const Center(
                child: Text('Добро пожаловать', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 24),

              // Поля формы
              TextFormField(
                controller: _usernameController,
                decoration: _inputDecoration('Имя пользователя'),
                validator: (value) => value!.isEmpty ? 'Введите имя' : null,
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: _emailController,
                decoration: _inputDecoration('Email'),
                validator:
                    (value) =>
                        value!.contains('@')
                            ? null
                            : 'Введите корректный email',
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: _firstNameController,
                decoration: _inputDecoration('Имя'),
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: _lastNameController,
                decoration: _inputDecoration('Фамилия'),
              ),
              const SizedBox(height: 10),

              PasswordField(controller: _passwordController),
              const SizedBox(height: 10),

              ConfirmPasswordField(
                controller: _passwordConfirmController,
                originalPasswordController: _passwordController,
              ),
              const SizedBox(height: 24),

              // Кнопка регистрации
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _isLoading ? null : _register,
                child:
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                          'Зарегистрироваться',
                          style: TextStyle(color: Colors.white),
                        ),
              ),
              const SizedBox(height: 10),

              // Ссылка на экран входа
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LogInPage()),
                  );
                },
                child: const Text("Уже есть аккаунт? Войти"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
