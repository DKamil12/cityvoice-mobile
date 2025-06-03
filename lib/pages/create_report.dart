import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cityvoice/pages/choose_photo.dart';
import 'package:cityvoice/pages/map_picker.dart';
import 'package:cityvoice/services/api_service.dart';

// Экран для создания новой жалобы
class NewReportScreen extends StatefulWidget {
  const NewReportScreen({Key? key}) : super(key: key);

  @override
  State<NewReportScreen> createState() => _NewReportScreenState();
}

class _NewReportScreenState extends State<NewReportScreen> {
  final _formKey = GlobalKey<FormState>(); // Ключ для формы
  final _titleController = TextEditingController(); // Контроллер для заголовка
  final _descController = TextEditingController(); // Контроллер для описания

  File? _pickedImage; // Выбранное изображение
  LatLng? _pickedLocation; // Выбранные координаты
  String? _pickedAddress; // Определённый адрес
  String? _selectedCategoryId; // Выбранная категория

  // Выбор и установка фото
  Future<void> _pickAndSetImage() async {
    final File? image = await PhotoPicker.pickImage(context);
    if (image != null && mounted) {
      setState(() => _pickedImage = image);
    }
  }

  // Получение адреса по координатам (через OpenStreetMap API)
  Future<String?> _getAddressFromCoordinates(LatLng location) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse?lat=${location.latitude}&lon=${location.longitude}&format=json',
    );
    try {
      final response = await http.get(
        url,
        headers: {'User-Agent': 'flutter-app-cityvoice/1.0'},
      );
      final data = jsonDecode(response.body);
      return data['display_name'];
    } catch (e) {
      return null;
    }
  }

  // Отправка формы (создание жалобы)
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_pickedLocation == null) {
      _showErrorMessage('Пожалуйста, выберите местоположение');
      return;
    }
    if (_selectedCategoryId == null) {
      _showErrorMessage('Пожалуйста, выберите категорию');
      return;
    }

    try {
      final result = await ApiService().submitReport(
        title: _titleController.text,
        description: _descController.text,
        categoryId: _selectedCategoryId!,
        latitude: _pickedLocation!.latitude,
        longitude: _pickedLocation!.longitude,
        image: _pickedImage,
      );

      if (result.error == null) {
        // Если успешно — уведомляем пользователя
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Жалоба успешно отправлена')),
        );
        Navigator.pop(context, true); // Закрываем экран
      } else {
        _showErrorMessage('${result.error}');
        return;
      }
    } catch (e) {
      _showErrorMessage('$e');
      return;
    }
  }

  // Показать сообщение об ошибке
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: const Text('Новая жалоба'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Блок для выбора изображения
              GestureDetector(
                onTap: _pickAndSetImage,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child:
                      _pickedImage != null
                          ? Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.file(_pickedImage!, fit: BoxFit.cover),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: CircleAvatar(
                                  backgroundColor: Colors.black45,
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                    ),
                                    onPressed:
                                        () =>
                                            setState(() => _pickedImage = null),
                                  ),
                                ),
                              ),
                            ],
                          )
                          : const Center(child: Icon(Icons.image, size: 50)),
                ),
              ),
              const SizedBox(height: 16),
              // Поле ввода заголовка
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Заголовок',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Введите заголовок'
                            : null,
              ),
              const SizedBox(height: 16),
              // Поле ввода описания
              TextFormField(
                controller: _descController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Описание',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Введите описание'
                            : null,
              ),
              const SizedBox(height: 16),
              // Выбор категории
              DropdownButtonFormField<String>(
                isExpanded: true,
                value: _selectedCategoryId,
                items: const [
                  DropdownMenuItem(
                    value: '1',
                    child: Text('Транспортная доступность'),
                  ),
                  DropdownMenuItem(
                    value: '2',
                    child: Text('Состояние дорожной инфраструктуры'),
                  ),
                  DropdownMenuItem(
                    value: '3',
                    child: Text('Общественный транспорт'),
                  ),
                  DropdownMenuItem(
                    value: '4',
                    child: Text('Загруженность/пробки'),
                  ),
                  DropdownMenuItem(
                    value: '5',
                    child: Text('Озеленение и благоустройство'),
                  ),
                  DropdownMenuItem(
                    value: '6',
                    child: Text('Шумовое загрязнение'),
                  ),
                  DropdownMenuItem(value: '7', child: Text('Качество воздуха')),
                  DropdownMenuItem(
                    value: '8',
                    child: Text('Чистота территорий'),
                  ),
                  DropdownMenuItem(
                    value: '9',
                    child: Text('Уличное освещение'),
                  ),
                  DropdownMenuItem(
                    value: '10',
                    child: Text('Безопасность (общая)'),
                  ),
                  DropdownMenuItem(
                    value: '11',
                    child: Text('Доступность городской среды'),
                  ),
                  DropdownMenuItem(
                    value: '12',
                    child: Text('Развитость инфраструктуры досуга'),
                  ),
                  DropdownMenuItem(
                    value: '13',
                    child: Text('Жилищные условия'),
                  ),
                  DropdownMenuItem(
                    value: '14',
                    child: Text('Коммунальные услуги'),
                  ),
                ],
                onChanged: (val) => setState(() => _selectedCategoryId = val),
                decoration: const InputDecoration(
                  labelText: 'Категория жалобы',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // Выбор местоположения
              GestureDetector(
                onTap: () async {
                  final LatLng? point = await Navigator.of(
                    context,
                  ).push<LatLng>(
                    MaterialPageRoute(builder: (_) => const MapPickerScreen()),
                  );
                  if (point != null && mounted) {
                    final address = await _getAddressFromCoordinates(point);
                    setState(() {
                      _pickedLocation = point;
                      _pickedAddress = address;
                    });
                  }
                },
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[200],
                  ),
                  clipBehavior: Clip.hardEdge,
                  child:
                      _pickedLocation != null
                          ? Stack(
                            children: [
                              // Отображение карты с маркером
                              FlutterMap(
                                options: MapOptions(
                                  center: _pickedLocation,
                                  initialZoom: 16,
                                  interactiveFlags: InteractiveFlag.none,
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate:
                                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    userAgentPackageName:
                                        'com.example.cityvoice',
                                  ),
                                  MarkerLayer(
                                    markers: [
                                      Marker(
                                        point: _pickedLocation!,
                                        width: 40,
                                        height: 40,
                                        child: const Icon(
                                          Icons.location_on,
                                          color: Colors.red,
                                          size: 40,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              if (_pickedAddress != null)
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    color: Colors.white70,
                                    child: Text(
                                      _pickedAddress!,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          )
                          : const Center(
                            child: Text(
                              'Нажмите, чтобы выбрать точку на карте',
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 24),
              // Кнопка отправки жалобы
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor: Colors.teal,
                ),
                child: const Text(
                  'Отправить жалобу',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
