import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/hospital_model.dart';

class HospitalService {
  static const String baseUrl =
      'https://old-med-api-18037738556.asia-southeast1.run.app/api';

  static Future<List<Hospital>> getHospitals() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/legit-hospitals'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final hospitals =
            jsonData.map((json) => Hospital.fromJson(json)).toList();
        return hospitals;
      } else {
        throw Exception('Failed to load hospitals: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi tải danh sách bệnh viện: $e');
    }
  }

  static Future<Hospital> getHospitalById(String hospitalId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/legit-hospital/$hospitalId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return Hospital.fromJson(jsonData);
      } else {
        throw Exception('Failed to load hospital: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi tải thông tin bệnh viện: $e');
    }
  }
}
