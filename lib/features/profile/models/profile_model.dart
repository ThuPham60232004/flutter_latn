import 'package:intl/intl.dart';

class ProfileModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? password;
  final DateTime? dateOfBirth;
  final String? avatarUrl;

  ProfileModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.password,
    this.dateOfBirth,
    this.avatarUrl,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      password: json['password'],
      dateOfBirth:
          json['dateOfBirth'] != null
              ? DateTime.parse(json['dateOfBirth'])
              : null,
      avatarUrl: json['urlImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'urlImage': avatarUrl,
    };
  }

  String get displayName => name;
  String get displayEmail => email;
  String get displayPhone => phone ?? 'Chưa cập nhật';
  String get displayAge {
    if (dateOfBirth == null) return 'Chưa cập nhật';
    final now = DateTime.now();
    final age = now.year - dateOfBirth!.year;
    final monthDiff = now.month - dateOfBirth!.month;
    if (monthDiff < 0 || (monthDiff == 0 && now.day < dateOfBirth!.day)) {
      return '${age - 1} tuổi';
    }
    return '$age tuổi';
  }

  String get displayDateOfBirth {
    if (dateOfBirth == null) return 'Chưa cập nhật';
    return DateFormat('dd/MM/yyyy').format(dateOfBirth!);
  }

  String get displayAvatarUrl =>
      avatarUrl ??
      'https://cdn-media.sforum.vn/storage/app/media/1image/anh-hoat-hinh-cute-thumb.jpg';
}
