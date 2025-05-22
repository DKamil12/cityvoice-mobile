import 'package:flutter/material.dart';
import 'package:cityvoice/models/question.dart';
import 'package:cityvoice/services/api_service.dart';
import 'package:cityvoice/models/district.dart';

class SurveyScreen extends StatefulWidget {
  const SurveyScreen({super.key});

  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  final ApiService _api = ApiService();

  bool _surveyCompleted = false;

  List<SurveyQuestion> _questions = [];
  Map<int, int> _responses = {};

  int? _selectedDistrictId;
  List<District> _districts = [];

  @override
  void initState() {
    super.initState();
    _loadQuestions();
    _loadDistricts();
    _checkSurveyAvailability();
  }

  Future<void> _checkSurveyAvailability() async {
    final isAvailable = await _api.isSurveyAvailable();
    setState(() {
      _surveyCompleted = !isAvailable;
    });
  }

  Future<void> _loadDistricts() async {
    final districts = await _api.getDistricts();
    setState(() => _districts = districts);
  }

  Future<void> _loadQuestions() async {
    final questions = await _api.loadQuestions();
    setState(() => _questions = questions);
  }

  Future<void> _submitResponses() async {
    if (_selectedDistrictId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, выберите район')),
      );
      return;
    }
    
    await _api.submitResponses(_responses, _selectedDistrictId!);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Спасибо за участие в опросе!')),
    );
    // Navigator.pop(context);
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    if (_surveyCompleted) {
      return const Center(child: Text("Активных опросов пока нет"));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Опрос")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<int>(
            value: _selectedDistrictId,
            decoration: const InputDecoration(labelText: 'Выберите район'),
            items:
                _districts.map((d) {
                  return DropdownMenuItem<int>(
                    value: d.id,
                    child: Text(d.name),
                  );
                }).toList(),
            onChanged: (value) => setState(() => _selectedDistrictId = value),
          ),
          const SizedBox(height: 16),
          ..._questions.map(
            (q) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  q.text,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Slider(
                  min: 1,
                  max: 10,
                  divisions: 9,
                  label: (_responses[q.id] ?? 5).toString(),
                  value: (_responses[q.id] ?? 5).toDouble(),
                  onChanged: (val) {
                    setState(() {
                      _responses[q.id] = val.toInt();
                    });
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _submitResponses,
            child: const Text("Отправить"),
          ),
        ],
      ),
    );
  }
}
