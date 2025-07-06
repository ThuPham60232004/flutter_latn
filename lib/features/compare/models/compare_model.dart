class CompareProcess {
  final String id;
  final String userId;
  final List<String> imageUrls;

  CompareProcess({
    required this.id,
    required this.userId,
    required this.imageUrls,
  });

  factory CompareProcess.fromJson(Map<String, dynamic> json) {
    return CompareProcess(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      imageUrls: List<String>.from(json['imageUrl'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'userId': userId, 'imageUrl': imageUrls};
  }
}

class CompareResult {
  final String firstImage;
  final String latestImage;

  CompareResult({required this.firstImage, required this.latestImage});

  factory CompareResult.fromJson(Map<String, dynamic> json) {
    return CompareResult(
      firstImage: json['first_image'] ?? '',
      latestImage: json['latest_image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'first_image': firstImage, 'latest_image': latestImage};
  }
}
