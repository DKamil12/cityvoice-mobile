import 'dart:io'; 
import 'package:flutter/material.dart'; 
import 'package:image_picker/image_picker.dart'; 

// Класс для выбора фотографии
class PhotoPicker {
  // Метод, который открывает диалог выбора изображения и возвращает файл (File), если пользователь выбрал изображение
  static Future<File?> pickImage(BuildContext context) async {
    // Отображаем нижнее модальное окно с выбором источника
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt), // Иконка "Камера"
              title: const Text('Снять новое'), // Текст "Снять новое"
              onTap: () => Navigator.pop(context, ImageSource.camera), // Закрываем модалку и передаём камеру
            ),
            ListTile(
              leading: const Icon(Icons.photo_library), // Иконка "Галерея"
              title: const Text('Выбрать из галереи'), // Текст "Выбрать из галереи"
              onTap: () => Navigator.pop(context, ImageSource.gallery), // Закрываем модалку и передаём галерею
            ),
          ],
        ),
      ),
    );

    // Если пользователь не выбрал источник (нажал "Отмена"), возвращаем null
    if (source == null) return null;

    // Используем ImagePicker для выбора/съёмки изображения
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(
      source: source,
      imageQuality: 80, // Снижаем качество до 80% (для экономии памяти и сетевого трафика)
    );

    // Если пользователь не выбрал изображение, возвращаем null
    if (file == null) return null;

    // Преобразуем путь к файлу в объект File и возвращаем
    return File(file.path);
  }
}
