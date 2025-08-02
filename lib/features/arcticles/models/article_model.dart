class Article {
  final String id;
  final String title;
  final String mainImage;
  final String content;
  final DateTime date;
  final String author;
  final String authorImage;
  final String authorDescription;
  final List<String> tags; // Now tag names, not IDs

  Article({
    required this.id,
    required this.title,
    required this.mainImage,
    required this.content,
    required this.date,
    required this.author,
    required this.authorImage,
    required this.authorDescription,
    required this.tags,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] ?? json['_id'] ?? '',
      title: json['title'] ?? '',
      mainImage: json['mainImage'] ?? '',
      content: json['content'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      author: json['author'] ?? '',
      authorImage: json['authorImage'] ?? '',
      authorDescription: json['authorDescription'] ?? '',
      tags:
          json['tags'] != null
              ? (json['tags'] is List
                  ? List<String>.from(json['tags'])
                  : [json['tags'].toString()])
              : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'mainImage': mainImage,
      'content': content,
      'date': date.toIso8601String(),
      'author': author,
      'authorImage': authorImage,
      'authorDescription': authorDescription,
      'tags': tags,
    };
  }

  Map<String, dynamic> toUIMap() {
    return {
      'id': id,
      'title': title,
      'image': mainImage,
      'category': tags.isNotEmpty ? tags.first : 'Nghiên cứu y khoa',
      'date': _formatDate(date),
      'read_time': _calculateReadTime(content),
      'author': author,
      'author_avatar': authorImage,
      'author_title': 'Chuyên gia',
      'author_bio': authorDescription,
      'summary': _generateSummary(content),
      'content': content,
      'tags': tags,
    };
  }

  Map<String, String> toListMap() {
    return {
      'image': mainImage,
      'tag': tags.isNotEmpty ? tags.first : 'Nghiên cứu y khoa',
      'title': title,
      'date': _formatDate(date),
      'readTime': '${_calculateReadTime(content)} phút đọc',
    };
  }

  String _formatDate(DateTime date) {
    final months = [
      'Tháng 1',
      'Tháng 2',
      'Tháng 3',
      'Tháng 4',
      'Tháng 5',
      'Tháng 6',
      'Tháng 7',
      'Tháng 8',
      'Tháng 9',
      'Tháng 10',
      'Tháng 11',
      'Tháng 12',
    ];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }

  int _calculateReadTime(String content) {
    final wordCount = content.split(' ').length;
    final readTime = (wordCount / 200).ceil();
    return readTime < 1 ? 1 : readTime;
  }

  String _generateSummary(String content) {
    final sentences = content.split('.');
    if (sentences.length >= 2) {
      return '${sentences[0]}. ${sentences[1]}.';
    }
    return content.length > 150 ? '${content.substring(0, 150)}...' : content;
  }
}
