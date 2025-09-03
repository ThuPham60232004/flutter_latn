import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/config/api_config.dart';
import '../models/compare_model.dart';

class CompareService {
  // Tạo tiến trình mới
  static Future<CompareProcess> uploadInitialImage({
    required String userId,
    required File imageFile,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.buildUrl(ApiConfig.createCheckProcess)),
      );

      request.fields['user_id'] = userId;
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonData = json.decode(responseData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return CompareProcess.fromJson(jsonData);
      } else {
        throw Exception(
          'Failed to upload image: ${response.statusCode} - $responseData',
        );
      }
    } catch (e) {
      throw Exception('Lỗi tạo tiến trình: $e');
    }
  }

  // Lấy danh sách tiến trình của user
  static Future<List<CompareProcess>> getUserProcesses(String userId) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.buildUrl('/user-check-process/$userId')),
        headers: ApiConfig.defaultHeaders,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => CompareProcess.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to get user processes: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Lỗi lấy danh sách tiến trình: $e');
    }
  }

  // Cập nhật tiến trình và nhận kết quả so sánh
  static Future<CompareResult> compareImages({
    required String userId,
    required String processId,
    required File imageFile,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
          ApiConfig.buildUrl('/track-check-process/$processId'),
        ),
      );

      request.fields['user_id'] = userId;
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonData = json.decode(responseData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return CompareResult.fromJson(jsonData);
      } else {
        throw Exception(
          'Failed to compare images: ${response.statusCode} - $responseData',
        );
      }
    } catch (e) {
      throw Exception('Lỗi so sánh ảnh: $e');
    }
  }

  // Xóa tiến trình
  static Future<bool> deleteProcess(String processId) async {
    try {
      final response = await http.delete(
        Uri.parse(ApiConfig.buildUrl('/delete-check-process/$processId')),
        headers: ApiConfig.defaultHeaders,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        throw Exception(
          'Failed to delete process: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Lỗi xóa tiến trình: $e');
    }
  }
}
