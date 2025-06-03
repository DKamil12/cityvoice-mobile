import 'package:flutter/material.dart';


/// Экран для отображения выбранного изображения в полноэкранном режиме.
/// Позволяет пользователю увеличить или уменьшить изображение с помощью жестов.
class FullImageScreen extends StatelessWidget {
  final String imageUrl; // URL изображения, которое нужно показать

  const FullImageScreen({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Черный фон для лучшего контраста
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Прозрачный AppBar без цвета
      ),
      body: Center(
        // Виджет для взаимодействия с изображением: увеличение/уменьшение и перемещение
        child: InteractiveViewer(
          child: Image.network(imageUrl), // Загружаем изображение из сети
        ),
      ),
    );
  }
}
