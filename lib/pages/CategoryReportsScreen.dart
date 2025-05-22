import 'package:flutter/material.dart';
import 'package:cityvoice/services/api_service.dart';
import 'package:cityvoice/models/report.dart';
import 'report_details.dart';

class CategoryReportsScreen extends StatefulWidget {
  final int districtId;
  final int categoryId;
  final String categoryName;

  const CategoryReportsScreen({
    Key? key,
    required this.districtId,
    required this.categoryId,
    required this.categoryName,
  }) : super(key: key);

  @override
  State<CategoryReportsScreen> createState() => _CategoryReportsScreenState();
}

class _CategoryReportsScreenState extends State<CategoryReportsScreen> {
  final ApiService _api = ApiService();
  bool _loading = true;
  List<Report> _reports = [];

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    try {
      final reports = await _api.getReports(
        districtId: widget.districtId,
        categoryId: widget.categoryId,
      );
      setState(() {
        _reports = reports;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppBar(
                  leading: const BackButton(),
                  title: Text(widget.categoryName),
                  centerTitle: true,
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: _reports.isEmpty
                      ? const Center(child: Text('Заявки не найдены'))
                      : ListView.separated(
                          itemCount: _reports.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final report = _reports[index];
                            return Card(
                              margin: EdgeInsets.zero,
                              child: ListTile(
                                title: Text(report.name),
                                subtitle: Text(report.description),
                                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ReportDetailsScreen(
                                        report: report,
                                        isStaff: false,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
