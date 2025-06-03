import 'package:flutter/material.dart';


/// Поле ввода пароля с возможностью показать/скрыть введённый текст
class PasswordField extends StatefulWidget {
  final TextEditingController controller;

  const PasswordField({super.key, required this.controller});

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _isObscure = true; // Переменная, указывающая скрыт или показан пароль

  /// Переключает видимость пароля
  void _toggleVisibility() {
    setState(() {
      _isObscure = !_isObscure;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      validator: (value) {
        if (value == null || value.length < 8) {
          return 'Пароль должен содержать не менее 8 символов!';
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: 'Введите пароль',
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue, width: 2),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        suffixIcon: IconButton(
          onPressed: _toggleVisibility,
          icon: Icon(_isObscure ? Icons.visibility : Icons.visibility_off),
        ),
      ),
      style: const TextStyle(fontSize: 16),
      obscureText: _isObscure,
    );
  }
}


/// Поле ввода пароля с возможностью показать/скрыть введённый пароль с логикой проверки на соответствие двух паролей 
class ConfirmPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final TextEditingController originalPasswordController;

  const ConfirmPasswordField({
    super.key,
    required this.controller,
    required this.originalPasswordController,
  });

  @override
  State<ConfirmPasswordField> createState() => _ConfirmPasswordFieldState();
}

class _ConfirmPasswordFieldState extends State<ConfirmPasswordField> {
  bool _isObscure = true;

  void _toggleVisibility() {
    setState(() {
      _isObscure = !_isObscure;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _isObscure,
      validator: (val) =>
          val != widget.originalPasswordController.text ? 'Пароли не совпадают' : null,
      decoration: InputDecoration(
        hintText: 'Повторите пароль',
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.teal, width: 2),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        suffixIcon: IconButton(
          onPressed: _toggleVisibility,
          icon: Icon(_isObscure ? Icons.visibility : Icons.visibility_off),
        ),
      ),
      style: const TextStyle(fontSize: 16),
    );
  }
}