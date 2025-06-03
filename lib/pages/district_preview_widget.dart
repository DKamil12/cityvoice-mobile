import 'package:flutter/material.dart';
import 'package:cityvoice/models/district.dart';
import 'package:cityvoice/pages/district_list_screen.dart';
import 'package:cityvoice/pages/district_stats_screen.dart';


// Виджет предварительного просмотра районов с горизонтальным списком
class DistrictsPreviewWidget extends StatelessWidget {
  final List<District> districts; // Список районов, который отображается

  const DistrictsPreviewWidget({super.key, required this.districts});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Заголовок и кнопка "Все" для перехода на полный список районов
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Активность по районам",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DistrictListScreen(),
                ),
              ),
              child: const Text('Все', style: TextStyle(color: Colors.green)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Горизонтальный список с карточками районов
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: districts.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final district = districts[index];
              return GestureDetector(
                // При нажатии — переход к экрану со статистикой района
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DistrictStatsScreen(district: district),
                  ),
                ),
                child: Container(
                  width: 130,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Картинка района
                      Container(
                        height: 90,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: Image.network(
                            district.image,
                            width: double.infinity,
                            height: 90,
                            fit: BoxFit.cover,
                            // Обработка ошибок при загрузке изображения
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                              );
                            },
                            // Отображение индикатора загрузки
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                          ),
                        ),
                      ),
                      // Название района
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              district.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
