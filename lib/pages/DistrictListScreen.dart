import 'package:flutter/material.dart';
import 'package:cityvoice/services/api_service.dart';
import 'package:cityvoice/models/district.dart';
import 'DistrictStatsScreen.dart';


class DistrictListScreen extends StatefulWidget {
  const DistrictListScreen({Key? key}) : super(key: key);

  @override
  State<DistrictListScreen> createState() => _DistrictListScreenState();
}

class _DistrictListScreenState extends State<DistrictListScreen> {
  final ApiService _api = ApiService();
  bool _loading = true;
  List<District> _districts = [];

  @override
  void initState() {
    super.initState();
    _loadDistricts();
  }

  Future<void> _loadDistricts() async {
    final list = await _api.getDistricts();
    setState(() {
      _districts = list;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Заявки по районам')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _districts.length,
              itemBuilder: (context, index) {
                final d = _districts[index];
                return ListTile(
                  title: Text(d.name),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DistrictStatsScreen(district: d),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}