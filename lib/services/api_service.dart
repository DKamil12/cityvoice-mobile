import 'dart:io';
import 'package:cityvoice/models/result.dart';
import 'package:cityvoice/models/survey_stat.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'auth_service.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'package:cityvoice/models/report.dart';
import 'package:cityvoice/models/district.dart';
import 'package:cityvoice/models/district_stat.dart';
import 'package:cityvoice/models/question.dart';
import 'package:cityvoice/models/product.dart';

class ApiService {
  final String _baseUrl = 'https://cityvoice-api.onrender.com/api/v1';
  final String _host = 'cityvoice-api.onrender.com';
  final AuthService _auth = AuthService();

  Future<Result<void>> submitReport({
    required String title,
    required String description,
    required String categoryId,
    required double latitude,
    required double longitude,
    File? image,
  }) async {
    final url = Uri.parse('$_baseUrl/reports/reports/');
    final token = await _auth.getValidAccessToken();

    final request = http.MultipartRequest('POST', url);

    request.headers['Authorization'] = 'Bearer $token';
    request.fields['name'] = title;
    request.fields['description'] = description;
    request.fields['category'] = categoryId;
    request.fields['latitude'] = latitude.toString();
    request.fields['longtitude'] = longitude.toString();

    if (image != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          image.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        return Result.success(null);
      } else {
        return Result.failure(
          'Ошибка: ${response.statusCode}, ${response.body}',
        );
      }
    } catch (e) {
      return Result.failure('Сетевая ошибка: $e');
    }
  }

  Future<String?> getAddressFromCoordinates(LatLng location) async {
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

  Future<List<Report>> getUserReports() async {
    final token = await _auth.getValidAccessToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/reports/reports/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List jsonList = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonList.map((e) => Report.fromJson(e)).toList();
    } else {
      throw Exception('Не удалось загрузить список заявок');
    }
  }

  Future<Map<String, int>> getUserReportStats() async {
    final all = await getUserReports();
    final stats = <String, int>{};
    for (final r in all) {
      stats[r.status] = (stats[r.status] ?? 0) + 1;
    }
    return stats;
  }

  Future<List<Report>> getReports({
    int? districtId,
    int? categoryId,
    String? startDate,
    String? endDate,
  }) async {
    final token = await _auth.getValidAccessToken();
    final queryParams = <String, String>{};

    if (districtId != null) queryParams['district'] = districtId.toString();
    if (categoryId != null) queryParams['category'] = categoryId.toString();
    if (startDate != null) queryParams['start_date'] = startDate;
    if (endDate != null) queryParams['end_date'] = endDate;

    final uri = Uri.http(_host, '/api/v1/reports/reports/', queryParams);

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes)) as List;
      return data.map((item) => Report.fromJson(item)).toList();
    } else {
      throw Exception('Не удалось загрузить список заявок');
    }
  }

  Future<Result<void>> updateReportStatus({
    required int reportId,
    required String comment,
    required String status,
  }) async {
    final token = await _auth.getValidAccessToken();
    final response = await http.put(
      Uri.parse('$_baseUrl/reports/reports/$reportId/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'comment': comment, 'status': status}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Result.success(null);
    } else {
      return Result.failure('Ошибка: ${response.statusCode}, ${response.body}');
    }
  }

  Future<List<District>> getDistricts() async {
    final token = await _auth.getValidAccessToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/reports/districts/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final List jsonList = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonList.map((e) => District.fromJson(e)).toList();
    } else {
      throw Exception('Не удалось загрузить список районов');
    }
  }

  Future<DistrictStats> getDistrictCategoryStats({
    required int districtId,
    String? startDate,
    String? endDate,
  }) async {
    final token = await _auth.getValidAccessToken();
    final uri = Uri.parse(
      '$_baseUrl/charts/reports-by-district/$districtId/stats/',
    ).replace(
      queryParameters: {
        if (startDate != null) 'start_date': startDate,
        if (endDate != null) 'end_date': endDate,
      },
    );

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      return DistrictStats.fromJson(json);
    } else {
      throw Exception('Не удалось загрузить заявки по району');
    }
  }

  Future<List<SurveyQuestion>> loadQuestions() async {
    final token = await _auth.getValidAccessToken();
    final uri = Uri.parse('$_baseUrl/statistics/survey/questions/');

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<dynamic> jsonList = jsonDecode(
        utf8.decode(response.bodyBytes),
      );
      return jsonList.map((e) => SurveyQuestion.fromJson(e)).toList();
    } else {
      throw Exception('Не удалось загрузить вопросы');
    }
  }

  Future<void> submitResponses(Map<int, int> responses, int districtId) async {
    final token = await _auth.getValidAccessToken();
    final uri = Uri.parse('$_baseUrl/statistics/survey/submit/');

    final futures = responses.entries.map((entry) {
      return http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'question': entry.key,
          'rating': entry.value,
          'district': districtId,
        }),
      );
    });

    final responsesList = await Future.wait(futures);

    for (final response in responsesList) {
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Ошибка при отправке одного из ответов');
      }
    }
  }

  Future<bool> isSurveyAvailable() async {
    final token = await _auth.getValidAccessToken();
    final uri = Uri.parse('$_baseUrl/statistics/survey/available/');

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      dynamic data = jsonDecode(response.body);
      return data['available'] == true;
    } else {
      throw Exception('Не удалось проверить доступность опроса!');
    }
  }

  Future<List<CityWideSurveyStat>> getCitywideSurveyStats() async {
    final token = await _auth.getValidAccessToken();
    final uri = Uri.parse('$_baseUrl/statistics/survey/statistics/citywide/');

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((e) => CityWideSurveyStat.fromJson(e)).toList();
    } else {
      throw Exception('Не удалось загрузить городскую статистику');
    }
  }

  Future<List<CategoryCorrelationStat>> getCategoryCorrelationStats() async {
    final token = await _auth.getValidAccessToken();
    final uri = Uri.parse('$_baseUrl/charts/statistics/citywide/correlation/');

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((e) => CategoryCorrelationStat.fromJson(e)).toList();
    } else {
      throw Exception('Ошибка загрузки корреляции по категориям');
    }
  }

  Future<List<CategoryCorrelationStat>> getDistrictCategoryCorrelationStats(
    int districtId,
  ) async {
    final token = await _auth.getValidAccessToken();
    final uri = Uri.parse(
      '$_baseUrl/charts/statistics/survey/statistics/by-district/$districtId/',
    );

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((e) => CategoryCorrelationStat.fromJson(e)).toList();
    } else {
      throw Exception('Не удалось загрузить данные по району');
    }
  }

  Future<List<SurveyStat>> getDistrictSurveyStats(int districtId) async {
    final token = await _auth.getValidAccessToken();
    final uri = Uri.parse(
      '$_baseUrl/statistics/survey/statistics/?district=$districtId',
    );

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(
        utf8.decode(response.bodyBytes),
      );
      return jsonList.map((e) => SurveyStat.fromJson(e)).toList();
    } else {
      throw Exception('Не удалось загрузить статистику для района');
    }
  }

  Future<bool> checkRewardExists(int reportId) async {
    final token = await _auth.getValidAccessToken();
    final uri = Uri.parse('$_baseUrl/rewards/check/?report_id=$reportId');
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return data['exists'] == true;
    } else {
      throw Exception('Ошибка при проверке награды');
    }
  }

  Future<List<Product>> getProducts() async {
    final token = await _auth.getValidAccessToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/rewards/products/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<int> getBalance() async {
    final token = await _auth.getValidAccessToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/rewards/shop/balance/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['balance'];
    } else {
      throw Exception('Failed to load balance');
    }
  }

  Future<bool> purchaseProduct(int productId) async {
    final token = await _auth.getValidAccessToken();
    final response = await http.post(
      Uri.parse('$_baseUrl/rewards/shop/purchase/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'product_id': productId}),
    );

    if (response.statusCode != 201) {
      throw Exception(
        jsonDecode(utf8.decode(response.bodyBytes))['error'] ??
            'Failed to complete purchase',
      );
    }
    return true;
  }
}
