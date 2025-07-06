import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/config/api_config.dart';
import '../models/compare_model.dart';

class CompareService {
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
      throw Exception('Lỗi tải ảnh ban đầu: $e');
    }
  }

  /// Upload comparison image and get both images
  /// Returns: CompareResult object
  static Future<CompareResult> compareImages({
    required String userId,
    required String processId,
    required File imageFile,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
          ApiConfig.buildUrl('${ApiConfig.trackCheckProcess}/$processId'),
        ),
      );

      // Add user_id field
      request.fields['user_id'] = userId;

      // Add image file
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
      throw Exception('Error comparing images: $e');
    }
  }
}
