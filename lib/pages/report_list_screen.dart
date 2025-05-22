import 'dart:convert';

import 'package:flutter/material.dart';
import '../models/report.dart';
import 'package:cityvoice/services/auth_service.dart';
// import 'package:cityvoice/pages/report_details.dart';

class ReportListScreen extends StatefulWidget {
  const ReportListScreen({super.key});

  @override
  State<ReportListScreen> createState() => _ReportListScreenState();
}

class _ReportListScreenState extends State<ReportListScreen> {
  final auth = AuthService(); 
  // late Future<List<Report>> _futureReports;

  Future<List<Report>> _loadReports() async {
    final response = await auth.authorizedGet('reports/reports/');
    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes)) as List;
      return data.map((json) => Report.fromJson(json)).toList();
    } else {
      throw Exception('Ошибка загрузки: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Мои жалобы')),
      body: FutureBuilder<List<Report>>(
        future: _loadReports(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Нет жалоб'));
          }

          final reports = snapshot.data!;

          return ListView.builder(
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              return ListTile(
                leading: const Icon(Icons.report),
                title: Text(report.name),
                subtitle: Text(report.categoryName),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                // onTap: () {
                //   Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //       builder: (_) => ReportDetailsScreen(report: report),
                //     ),
                //   );
                // },
              );
            },
          );
        },
      ),
    );
  }
}
