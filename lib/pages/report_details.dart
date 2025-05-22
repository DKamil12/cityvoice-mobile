import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/report.dart';
import 'FullImageScreen.dart';
import 'FullMapScreen.dart';
import 'package:cityvoice/services/api_service.dart';
import 'ReportProcessingScreen.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReportDetailsScreen extends StatefulWidget {
  final Report report;
  final bool isStaff;
  const ReportDetailsScreen({super.key, required this.report, required this.isStaff});

  @override
  State<ReportDetailsScreen> createState() => _ReportDetailsScreenState();
}

class _ReportDetailsScreenState extends State<ReportDetailsScreen> {
  final ApiService _api = ApiService();
  String? _address;

  @override
  void initState() {
    super.initState();
    _loadAddress();
    _checkReward();
  }

  Future<void> _checkReward() async {
    final prefs = await SharedPreferences.getInstance();
    final shown = prefs.getBool('reward_shown_${widget.report.id}') ?? false;

    if (!shown) {
      final exists = await _api.checkRewardExists(widget.report.id);
      if (exists) {
        await prefs.setBool('reward_shown_${widget.report.id}', true);
        Future.delayed(Duration.zero, _showRewardDialog);
      }
    }
  }

  void _showRewardDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, size: 48, color: Colors.amber),
            const SizedBox(height: 12),
            const Text(
              'Спасибо, проблема решена!\nВы получили 100 монет',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ОК'),
          )
        ],
      ),
    );
  }

  Future<void> _loadAddress() async {
    final api = ApiService();
    final coords = LatLng(widget.report.latitude!, widget.report.longitude!);
    final fetched = await api.getAddressFromCoordinates(coords);
    if (mounted) {
      setState(() {
        _address = fetched;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final report = widget.report;

    final statuses = [
      {'label': 'В процессе', 'status': 'in_progress'},
      {'label': 'Новая', 'status': 'pending'},
      {'label': 'Завершена', 'status': 'resolved'},
      {'label': 'Отклонена', 'status': 'rejected'},
    ];

    final label =
        statuses.firstWhere(
          (item) => item['status'] == report.status,
          orElse:
              () => {'label': report.status}, // fallback если статус не найден
        )['label']!;

    return Scaffold(
      appBar: AppBar(
        title: Text(report.name, softWrap: true),
        centerTitle: true,
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child:
                  report.image != null
                      ? GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) =>
                                      FullImageScreen(imageUrl: report.image!),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            report.image!,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                      : const Center(child: Icon(Icons.image, size: 50)),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text(
                  "Статус: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  label,
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text(
                  "Категория жалобы: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  report.categoryName,
                  style: const TextStyle(color: Colors.green),
                  softWrap: true,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(report.description, softWrap: true),
            const SizedBox(height: 24),
            const Text(
              "Местоположение",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                if (report.latitude != null && report.longitude != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => FullMapScreen(
                            location: LatLng(
                              report.latitude!,
                              report.longitude!,
                            ),
                          ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Местоположение не задано')),
                  );
                }
              },
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                clipBehavior: Clip.hardEdge,
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(
                      report.latitude ?? 0,
                      report.longitude ?? 0,
                    ),
                    initialZoom: 15,
                    // interactionOptions: InteractiveFlag.none,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.cityvoice',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(
                            report.latitude ?? 0,
                            report.longitude ?? 0,
                          ),
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
              ),
            ),

            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Адрес: ${_address ?? 'Загрузка адреса...'}'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const CircleAvatar(radius: 18, child: Icon(Icons.person)),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.fullName,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      '@${report.username}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (report.comments != null && report.comments!.isNotEmpty) ...[
              const Text('Комментарии', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              ...report.comments!.map((comment) {
                final createdAt = DateTime.parse(comment['created_at']);
                final formattedDate = DateFormat('dd.MM.yyyy HH:mm').format(createdAt);
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person, size: 16, color: Colors.grey),
                          const SizedBox(width: 6),
                          Text(
                            "${comment['user']['first_name']} ${comment['user']['last_name']}",
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const Spacer(),
                          Text(
                            formattedDate,
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(comment['text']),
                    ],
                  ),
                );
              }),
            ],
            const SizedBox(height: 24),
            if (widget.isStaff)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  label: const Text('Обработать', style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReportProcessingScreen(report: report, isStaff: true),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
