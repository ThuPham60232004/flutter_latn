import 'package:flutter/material.dart';

class HospitalSpecialtyDetailScreen extends StatelessWidget {
  final String specialtyName;
  final IconData specialtyIcon;
  const HospitalSpecialtyDetailScreen({
    Key? key,
    required this.specialtyName,
    required this.specialtyIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE6F6F2), Color(0xFFF6F8FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.white.withOpacity(0.95),
          title: Row(
            children: [
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  specialtyName,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          centerTitle: true,
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutExpo,
                  margin: const EdgeInsets.only(bottom: 24),
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF43E2B8), Color(0xFF199A8E)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF199A8E).withOpacity(0.18),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(specialtyIcon, color: Colors.white, size: 54),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  margin: const EdgeInsets.symmetric(horizontal: 0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.teal.withOpacity(0.07),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    border: Border.all(
                      color: const Color(0xFF43E2B8).withOpacity(0.08),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 22,
                            decoration: BoxDecoration(
                              color: const Color(0xFF199A8E),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            specialtyName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Chuyên khoa này tập trung vào việc cung cấp dịch vụ chăm sóc và điều trị chuyên sâu cho bệnh nhân. Đội ngũ bác sĩ hàng đầu của chúng tôi có nhiều kinh nghiệm và tận tâm mang lại kết quả tốt nhất cho từng bệnh nhân.\n\nMô tả chuyên khoa sẽ được cập nhật chi tiết hơn trong thời gian tới.',
                        style: TextStyle(color: Colors.grey, fontSize: 15),
                      ),
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 22,
                            decoration: BoxDecoration(
                              color: const Color(0xFF43E2B8),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Bác sĩ tiêu biểu',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 110,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: 4,
                          separatorBuilder:
                              (context, index) => const SizedBox(width: 14),
                          itemBuilder: (context, index) {
                            final doctors = [
                              {
                                'name': 'TS.BS. Nguyễn Văn An',
                                'image':
                                    'https://cdn.medinet.gov.vn/Media/1_News/Images/2021/11/bs-nguyen-van-an.jpg',
                              },
                              {
                                'name': 'TS.BS. Trần Thị Mai',
                                'image':
                                    'https://cdn.medinet.gov.vn/Media/1_News/Images/2021/11/bs-tran-thi-mai.jpg',
                              },
                              {
                                'name': 'TS.BS. Lê Quang Huy',
                                'image':
                                    'https://cdn.medinet.gov.vn/Media/1_News/Images/2021/11/bs-le-quang-huy.jpg',
                              },
                              {
                                'name': 'TS.BS. Phạm Thị Hạnh',
                                'image':
                                    'https://cdn.medinet.gov.vn/Media/1_News/Images/2021/11/bs-pham-thi-hanh.jpg',
                              },
                            ];
                            return _DoctorCard(
                              name: doctors[index]['name']!,
                              imageUrl: doctors[index]['image']!,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DoctorCard extends StatefulWidget {
  final String name;
  final String imageUrl;
  const _DoctorCard({required this.name, required this.imageUrl});

  @override
  State<_DoctorCard> createState() => _DoctorCardState();
}

class _DoctorCardState extends State<_DoctorCard> {
  double _scale = 1.0;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.93),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: 90,
          height: 160,
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.teal.withOpacity(0.07),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(widget.imageUrl),
                radius: 22,
              ),
              const SizedBox(height: 6),
              Text(
                widget.name,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
