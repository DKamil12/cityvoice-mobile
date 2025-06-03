import 'dart:io';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:cityvoice/models/report.dart';
import 'package:cityvoice/services/api_service.dart';
import 'full_image_screen.dart';


/// Экран обработки заявки — позволяет сотруднику просмотреть подробности заявки
/// и обновить её статус, добавить комментарий.
class ReportProcessingScreen extends StatefulWidget {
  final Report report;
  final bool isStaff;

  const ReportProcessingScreen({
    super.key,
    required this.report,
    required this.isStaff,
  });

  @override
  State<ReportProcessingScreen> createState() => _ReportProcessingScreenState();
}

class _ReportProcessingScreenState extends State<ReportProcessingScreen> {
  final _commentController = TextEditingController();
  File? _pickedImage;
  String _selectedStatus = 'in_progress';
  bool _isLoading = false;

  final _statusOptions = [
    {'label': 'В процессе', 'value': 'in_progress'},
    {'label': 'Завершена', 'value': 'resolved'},
    {'label': 'Отклонена', 'value': 'rejected'},
  ];


  /// Отправка обновлённого статуса и комментария
  Future<void> _submitUpdate() async {
    if (_selectedStatus == 'resolved' && _commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Комментарий обязателен для завершения заявки'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await ApiService().updateReportStatus(
      reportId: widget.report.id,
      status: _selectedStatus,
      comment: _commentController.text,
    );

    setState(() => _isLoading = false);

    if (result.error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заявка обновлена')),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: ${result.error}')),
      );
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final report = widget.report;

    return Scaffold(
      appBar: AppBar(title: const Text('Обработка заявки')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок
            Text('Заголовок: ${report.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            // Фото заявки
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: report.image != null
                  ? GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FullImageScreen(imageUrl: report.image!),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(report.image!, height: 200, fit: BoxFit.cover),
                      ),
                    )
                  : const Center(child: Icon(Icons.image, size: 50)),
            ),
            const SizedBox(height: 8),

            // Описание
            Text(report.description),
            const SizedBox(height: 8),

            // Статус
            Row(
              children: [
                const Text("Статус: ", style: TextStyle(fontWeight: FontWeight.bold)),
                Text(report.status, style: const TextStyle(fontStyle: FontStyle.italic)),
              ],
            ),
            const SizedBox(height: 8),

            // Категория
            Row(
              children: [
                const Text("Категория жалобы: ", style: TextStyle(fontWeight: FontWeight.bold)),
                Text(report.categoryName, style: const TextStyle(color: Colors.green)),
              ],
            ),
            const SizedBox(height: 16),

            // Карта с местоположением
            const Text('Местоположение:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 150,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(report.latitude ?? 0, report.longitude ?? 0),
                  initialZoom: 16,
                  interactionOptions: const InteractionOptions(enableMultiFingerGestureRace: false),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.cityvoice',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(report.latitude ?? 0, report.longitude ?? 0),
                        width: 40,
                        height: 40,
                        child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Форма обновления (для staff)
            if (widget.isStaff) ...[
              TextField(
                controller: _commentController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Введите комментарий или решение',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              // Смена статуса
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(labelText: 'Обновите статус'),
                items: _statusOptions.map((s) {
                  return DropdownMenuItem(value: s['value'], child: Text(s['label']!));
                }).toList(),
                onChanged: (value) => setState(() => _selectedStatus = value!),
              ),
              const SizedBox(height: 16),

              // Кнопка отправки
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitUpdate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Отправить', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
