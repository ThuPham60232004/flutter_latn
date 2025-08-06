import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/utils/exceptions.dart';

class ProfileService {
  static const String baseUrl =
      'https://fastapi-service-748034725478.europe-west4.run.app/api';

  static Future<bool> _checkNetworkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  static Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final hasConnection = await _checkNetworkConnectivity();
      if (!hasConnection) {
        throw NetworkException('Không có kết nối internet. Vui lòng kiểm tra lại.');
      }

      // Get user ID from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null || userId.isEmpty) {
        throw Exception('Không tìm thấy thông tin người dùng. Vui lòng đăng nhập lại.');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Yêu cầu lấy thông tin hồ sơ đã hết thời gian chờ');
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return data;
      } else if (response.statusCode == 401) {
        throw Exception('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');
      } else if (response.statusCode == 404) {
        throw Exception('Không tìm thấy thông tin hồ sơ người dùng.');
      } else if (response.statusCode >= 500) {
        throw Exception('Lỗi máy chủ. Vui lòng thử lại sau.');
      } else {
        throw ApiException('Lỗi kết nối API: ${response.statusCode}', response.statusCode);
      }
    } on SocketException catch (_) {
      throw NetworkException('Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối internet.');
    } on TimeoutException catch (e) {
      throw e;
    } on FormatException catch (_) {
      throw Exception('Dữ liệu phản hồi không đúng định dạng');
    } catch (e) {
      if (e is NetworkException || e is TimeoutException || e is ApiException) {
        rethrow;
      }
      throw Exception('Lỗi tải thông tin hồ sơ: $e');
    }
  }

  static Future<void> updateUserProfile(
    Map<String, dynamic> profileData,
  ) async {
    try {
      final hasConnection = await _checkNetworkConnectivity();
      if (!hasConnection) {
        throw NetworkException('Không có kết nối internet. Vui lòng kiểm tra lại.');
      }

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null || userId.isEmpty) {
        throw Exception('Không tìm thấy thông tin người dùng. Vui lòng đăng nhập lại.');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/users/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(profileData),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Yêu cầu cập nhật hồ sơ đã hết thời gian chờ');
        },
      );

      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 400) {
        try {
          final responseBody = json.decode(response.body) as Map<String, dynamic>;
          print(responseBody);
          final error = responseBody['detail']?.toString() ?? 'Dữ liệu không hợp lệ';
          throw Exception(error);
        } catch (e) {
          throw Exception('Dữ liệu không hợp lệ');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');
      } else if (response.statusCode == 404) {
        throw Exception('Không tìm thấy thông tin hồ sơ người dùng.');
      } else if (response.statusCode >= 500) {
        throw Exception('Lỗi máy chủ. Vui lòng thử lại sau.');
      } else {
        throw ApiException('Lỗi cập nhật hồ sơ: ${response.statusCode}', response.statusCode);
      }
    } on SocketException catch (_) {
      throw NetworkException('Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối internet.');
    } on TimeoutException catch (e) {
      throw e;
    } on FormatException catch (_) {
      throw Exception('Dữ liệu phản hồi không đúng định dạng');
    } catch (e) {
      if (e is NetworkException || e is TimeoutException || e is ApiException) {
        rethrow;
      }
      throw Exception('Lỗi cập nhật hồ sơ: $e');
    }
  }
}
