import 'package:cityvoice/models/district.dart';
import 'package:flutter/material.dart';
import 'package:cityvoice/services/auth_service.dart';
import 'package:cityvoice/services/api_service.dart';
import 'my_reports_screen.dart';
import 'DistrictPreviewWidget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();

  String _username = '';
  Map<String, int> _stats = {};
  List<District> _districts = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadDistricts();
  }

  Future<void> _loadUserData() async {
    final username = await _authService.getUsername();
    final stats = await _apiService.getUserReportStats();
    if (mounted) {
      setState(() {
        _username = username ?? '';
        _stats = stats;
      });
    }
  }

  Future<void> _loadDistricts() async {
    final districts = await ApiService().getDistricts();
    if (mounted) {
      setState(() {
        _districts = districts;
      });
    }
  }

  void _navigateToFilteredReports(String status) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MyReportsScreen(initialStatus: status),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusWidgets = [
      {'label': 'В процессе', 'status': 'in_progress', 'icon': Icons.schedule},
      {'label': 'Новые', 'status': 'pending', 'icon': Icons.fiber_new},
      {'label': 'Завершенные', 'status': 'resolved', 'icon': Icons.check_circle},
    ];

    return Scaffold(
      body: ListView(
        // padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
            decoration: BoxDecoration(
              color: Colors.lightGreen[300],
              // borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Добро пожаловать!', style: TextStyle(color: Colors.white)),
                    Text(
                      _username,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const Icon(Icons.emoji_events, color: Colors.yellow),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Мои заявки:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: statusWidgets.map((item) {
              final count = _stats[item['status']] ?? 0;
              return GestureDetector(
                onTap: () => _navigateToFilteredReports(item['status'] as String),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Icon(item['icon'] as IconData, color: Colors.teal),
                      const SizedBox(height: 4),
                      Text('${item['label']}\n$count', textAlign: TextAlign.center),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          DistrictsPreviewWidget(districts: _districts),
          const SizedBox(height: 50),

          ElevatedButton.icon(
              icon: const Icon(Icons.bar_chart),
              label: const Text('Показатели качества по городу'),
              onPressed: () {
                Navigator.of(context).pushNamed('/stats');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              ),
            ),
            const SizedBox(height: 16),
        ],
      ),
    );
  }
}
