import 'package:intl/intl.dart';

class ProfileModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? password;
  final DateTime? dateOfBirth;
  final String? avatarUrl;

  const ProfileModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.password,
    this.dateOfBirth,
    this.avatarUrl,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    try {
      return ProfileModel(
        id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        phone: json['phone']?.toString(),
        password: json['password']?.toString(),
        dateOfBirth:
            json['dateOfBirth'] != null
                ? DateTime.tryParse(json['dateOfBirth'].toString()) ?? null
                : null,
        avatarUrl: json['urlImage']?.toString(),
      );
    } catch (e) {
      throw Exception('Lỗi parse dữ liệu hồ sơ: $e');
    }
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

  String get displayName => name.isNotEmpty ? name : 'Chưa cập nhật';

  String get displayEmail => email.isNotEmpty ? email : 'Chưa cập nhật';

  String get displayPhone =>
      (phone != null && phone!.isNotEmpty) ? phone! : 'Chưa cập nhật';

  String get displayAge {
    if (dateOfBirth == null) return 'Chưa cập nhật';
    try {
      final now = DateTime.now();
      final age = now.year - dateOfBirth!.year;
      final monthDiff = now.month - dateOfBirth!.month;
      if (monthDiff < 0 || (monthDiff == 0 && now.day < dateOfBirth!.day)) {
        return '${age - 1} tuổi';
      }
      return '$age tuổi';
    } catch (e) {
      return 'Chưa cập nhật';
    }
  }

  String get displayDateOfBirth {
    if (dateOfBirth == null) return 'Chưa cập nhật';
    try {
      return DateFormat('dd/MM/yyyy').format(dateOfBirth!);
    } catch (e) {
      return 'Chưa cập nhật';
    }
  }

  String get displayAvatarUrl {
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return avatarUrl!;
    }
    return 'https://cdn-media.sforum.vn/storage/app/media/1image/anh-hoat-hinh-cute-thumb.jpg';
  }

  // Validation methods
  bool get isValidName => name.trim().isNotEmpty;

  bool get isValidEmail {
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+');
    return emailRegex.hasMatch(email);
  }

  bool get isValidPhone {
    if (phone == null || phone!.isEmpty) return true; // Optional field
    return phone!.length >= 8;
  }

  bool get isValidDateOfBirth {
    if (dateOfBirth == null) return false;
    final now = DateTime.now();
    return dateOfBirth!.isBefore(now) && dateOfBirth!.isAfter(DateTime(1900));
  }

  bool get isValidAvatarUrl {
    if (avatarUrl == null || avatarUrl!.isEmpty) return false;
    try {
      final uri = Uri.parse(avatarUrl!);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  bool get isValid {
    return isValidName &&
        isValidEmail &&
        isValidPhone &&
        isValidDateOfBirth &&
        isValidAvatarUrl;
  }

  // Copy with method for updates
  ProfileModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? password,
    DateTime? dateOfBirth,
    String? avatarUrl,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProfileModel &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.phone == phone &&
        other.dateOfBirth == dateOfBirth &&
        other.avatarUrl == avatarUrl;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        email.hashCode ^
        phone.hashCode ^
        dateOfBirth.hashCode ^
        avatarUrl.hashCode;
  }

  @override
  String toString() {
    return 'ProfileModel(id: $id, name: $name, email: $email, phone: $phone, dateOfBirth: $dateOfBirth, avatarUrl: $avatarUrl)';
  }
}
