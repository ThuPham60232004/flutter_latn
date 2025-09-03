class CompareProcess {
  final String id;
  final String userId;
  final List<String> imageUrls;
  final DateTime? createdAt;
  final String? status;

  CompareProcess({
    required this.id,
    required this.userId,
    required this.imageUrls,
    this.createdAt,
    this.status,
  });

  factory CompareProcess.fromJson(Map<String, dynamic> json) {
    return CompareProcess(
      id: (json['id'] ?? json['_id'] ?? json['process_id'] ?? json['processId'] ?? '').toString(),
      userId: (json['userId'] ?? json['user_id'] ?? '').toString(),
      imageUrls: List<String>.from(
        (json['imageUrl'] ?? json['image_urls'] ?? json['images'] ?? [])
            .map((e) => e.toString()),
      ),
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt']) 
          : null,
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id, 
      'userId': userId, 
      'imageUrl': imageUrls,
      'createdAt': createdAt?.toIso8601String(),
      'status': status,
    };
  }
}

class CompareResult {
  final String firstImage;
  final String latestImage;
  final String? processId;
  final double? similarity;
  final DateTime? createdAt;

  CompareResult({
    required this.firstImage, 
    required this.latestImage,
    this.processId,
    this.similarity,
    this.createdAt,
  });

  factory CompareResult.fromJson(Map<String, dynamic> json) {
    return CompareResult(
      firstImage: json['first_image'] ?? '',
      latestImage: json['latest_image'] ?? '',
      processId: json['process_id'],
      similarity: json['similarity']?.toDouble(),
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_image': firstImage, 
      'latest_image': latestImage,
      'process_id': processId,
      'similarity': similarity,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
