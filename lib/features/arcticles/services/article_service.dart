import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article_model.dart';

class Tag {
  final String id;
  final String name;
  Tag({required this.id, required this.name});
  factory Tag.fromJson(Map<String, dynamic> json) =>
      Tag(id: json['_id'] ?? '', name: json['name'] ?? '');
}

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
        final List<Article> articles = [];
        for (final json in jsonData) {
          final tagIds = json['tags'] ?? [];
          final tagNames = await getTagNames(
            tagIds is List ? tagIds : [tagIds],
          );
          final article = Article.fromJson({...json, 'tags': tagNames});
          articles.add(article);
        }
        return articles;
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
        final tagIds = jsonData['tags'] ?? [];
        final tagNames = await getTagNames(tagIds is List ? tagIds : [tagIds]);
        return Article.fromJson({...jsonData, 'tags': tagNames});
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
        final List<Article> articles = [];
        for (final json in jsonData) {
          final tagIds = json['tags'] ?? [];
          final tagNames = await getTagNames(
            tagIds is List ? tagIds : [tagIds],
          );
          final article = Article.fromJson({...json, 'tags': tagNames});
          articles.add(article);
        }
        return articles;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  static Future<List<Tag>> getAllTags() async {
    final response = await http.get(
      Uri.parse('$baseUrl/tags'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((json) => Tag.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load tags: \\${response.statusCode}');
    }
  }

  // Fetch tag name by ID
  static final Map<String, String> _tagNameCache = {};

  static Future<String> getTagNameById(String tagId) async {
    if (_tagNameCache.containsKey(tagId)) {
      return _tagNameCache[tagId]!;
    }
    final response = await http.get(
      Uri.parse('$baseUrl/tag/$tagId'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final name = jsonData['name'] ?? tagId;
      _tagNameCache[tagId] = name;
      return name;
    } else {
      return tagId; // fallback to ID if not found
    }
  }

  // Helper to map a list of tag IDs to names
  static Future<List<String>> getTagNames(List<dynamic> tagIds) async {
    final List<String> names = [];
    for (final tagId in tagIds) {
      names.add(await getTagNameById(tagId.toString()));
    }
    return names;
  }
}
