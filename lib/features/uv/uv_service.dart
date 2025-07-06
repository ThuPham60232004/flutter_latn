import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class UVService {
  static const String baseUrl =
      'https://fastapi-service-748034725478.europe-west4.run.app/api';

  // Request location permission
  static Future<bool> requestLocationPermission() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    // Check location permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  // Get current location
  static Future<Position?> getCurrentLocation() async {
    try {
      bool hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        return null;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return position;
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  // Get UV index from API
  static Future<Map<String, dynamic>?> getUVIndex(
    double lat,
    double lon,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/uv-index?lat=$lat&lon=$lon'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print('UV index data: $data');
        return data;
      } else {
        print('Error fetching UV index: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception fetching UV index: $e');
      return null;
    }
  }

  // Get UV level description based on UV index
  static String getUVLevel(double uvIndex) {
    if (uvIndex <= 2) return 'Thấp';
    if (uvIndex <= 5) return 'Trung bình';
    if (uvIndex <= 7) return 'Cao';
    if (uvIndex <= 10) return 'Rất cao';
    return 'Cực cao';
  }

  // Get UV color based on UV index
  static Color getUVColor(double uvIndex) {
    if (uvIndex <= 2) return Colors.green;
    if (uvIndex <= 5) return Colors.yellow;
    if (uvIndex <= 7) return Colors.orange;
    if (uvIndex <= 10) return Colors.red;
    return Colors.purple;
  }

  // Get UV message based on UV index
  static String getUVMessage(double uvIndex) {
    if (uvIndex <= 2) {
      return '🟢 UV thấp, an toàn để ra ngoài.';
    } else if (uvIndex <= 5) {
      return '🟡 UV trung bình, cần bảo vệ da khi ra ngoài.';
    } else if (uvIndex <= 7) {
      return '🟠 UV cao! Giảm thời gian ngoài trời giữa trưa.';
    } else if (uvIndex <= 10) {
      return '🔴 UV rất cao! Tránh ra ngoài, bảo vệ tối đa.';
    } else {
      return '🟣 UV cực cao! Nguy hiểm, tránh ra ngoài hoàn toàn.';
    }
  }
}
