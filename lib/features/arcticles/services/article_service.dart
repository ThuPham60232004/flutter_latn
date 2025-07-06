import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article_model.dart';

class ArticleService {
  static const String baseUrl =
      'https://fastapi-service-748034725478.europe-west4.run.app/api';

  static Future<List<Article>> getArticles() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/papers'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Article.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load articles: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi tải bài viết: $e');
    }
  }

  static Future<Article?> getArticleById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/papers/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return Article.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to load article: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi tải bài viết: $e');
    }
  }

  static Future<List<Article>> searchArticles(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/papers/search?q=${Uri.encodeComponent(query)}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Article.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search articles: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi tìm kiếm bài viết: $e');
    }
  }

  static Future<List<Article>> getArticlesByCategory(String category) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/papers/category/${Uri.encodeComponent(category)}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Article.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  static Future<List<Article>> getArticlesByTag(String tag) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/papers-by-tag?tag=${Uri.encodeComponent(tag)}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Article.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}
