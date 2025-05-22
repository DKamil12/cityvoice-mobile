import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'log_in.dart';
import 'package:cityvoice/services/auth_service.dart';
import 'menu_shell.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _password2Controller = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  bool _isLoading = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final url = Uri.parse('https://cityvoice-api.onrender.com/api/v1/register/');
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
      final data = jsonDecode(response.body);
      await _authService.saveTokens(data['access'], data['refresh']);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    } else {
      final error = jsonDecode(response.body);
      final message = error['message'] ?? 'Ошибка регистрации';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

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
              Center(
                child: const Text(
                  'Регистрация',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 6),

              Center(
                child: const Text(
                  'Добро пожаловать',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 24),

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

              TextFormField(
                controller: _passwordController,
                decoration: _inputDecoration('Пароль'),
                obscureText: true,
                validator:
                    (value) => value!.length < 8 ? 'Минимум 8 символов' : null,
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: _password2Controller,
                decoration: _inputDecoration('Повторить пароль'),
                obscureText: true,
                validator:
                    (val) =>
                        val != _passwordController.text
                            ? 'Пароли не совпадают'
                            : null,
              ),
              const SizedBox(height: 24),

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
