class Hospital {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String img;
  final int yearEstablished;
  final List<String> specialties;
  final String region;
  final String? hospitalDescription;
  final double rate;

  Hospital({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.img,
    required this.yearEstablished,
    required this.specialties,
    required this.region,
    this.hospitalDescription,
    required this.rate,
  });

  factory Hospital.fromJson(Map<String, dynamic> json) {
    List<String> specialties = [];

    if (json['specialties'] != null) {
      if (json['specialties'] is List) {
        specialties = [];
        for (var item in json['specialties']) {
          if (item is String && item.contains(',')) {
            specialties.addAll(
              item.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty),
            );
          } else {
            specialties.add(item.toString().trim());
          }
        }
      } else if (json['specialties'] is String) {
        specialties =
            (json['specialties'] as String)
                .split(',')
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toList();
      }
    }

    return Hospital(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      img: json['img'] ?? '',
      yearEstablished: json['yearEstablished'] ?? 0,
      specialties: specialties,
      region: json['region'] ?? '',
      hospitalDescription: json['hospitalDescription'],
      rate: (json['rate'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'img': img,
      'yearEstablished': yearEstablished,
      'specialties': specialties,
      'region': region,
      'hospitalDescription': hospitalDescription,
      'rate': rate,
    };
  }

  Map<String, String> toUIMap() {
    return {
      'name': name,
      'specialty': specialties.isNotEmpty ? specialties.join(', ') : 'Đa khoa',
      'image': img,
      'rating': rate.toStringAsFixed(1),
      'location': address,
      'phone': phone,
      'yearEstablished': yearEstablished.toString(),
      'region': region,
      'description': hospitalDescription ?? 'Không có mô tả',
    };
  }
}
