import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';

class ChooseImageScreen extends StatelessWidget {
  const ChooseImageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
  padding: const EdgeInsets.all(16.0),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        "Chọn ảnh chẩn đoán",
        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
      ),
      const Text(
        "Hãy chọn ảnh để chẩn đoán da liễu",
        style: TextStyle(fontSize: 16),
      ),
      const SizedBox(height: 20),
      Container(
        width: double.infinity,
        height: 560,
        child: DottedBorder(
          color: const Color.fromARGB(255, 0, 0, 0),
          strokeWidth: 1.2,
          dashPattern: [2, 1],
          borderType: BorderType.RRect,
          radius: const Radius.circular(12),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 25),
              Row(
                children: const [
                  Icon(Icons.image_not_supported, color: Colors.red),
                  SizedBox(width: 8),
                  Text(
                    "Cách loại ảnh:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                      fontSize: 22
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                "Hệ thống hỗ trợ các định dạng ảnh: .JPG, .JPEG,",
                style: TextStyle(fontSize: 14),
              ),
              const Text(
                ".PNG. Dung lượng tối đa: 5MB/ảnh",
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 20),
              Row(
                children: const [
                  Icon(Icons.warning, color: Colors.red),
                  SizedBox(width: 20),
                  Text(
                    "Lưu ý:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                      fontSize: 22
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              const _BulletText("1. Ảnh cần rõ nét, không mờ, không rung."),
              const _BulletText("2. Tránh ảnh bị lóa sáng, ngược sáng hoặc có nhiều bóng tối che khuất."),
              const _BulletText("3. Ưu tiên ảnh gốc, không chỉnh sửa màu sắc hoặc làm mờ vùng tổn thương."),
              const _BulletText("4. Đảm bảo vùng nghi ngờ tổn thương hoặc cần chẩn đoán nằm rõ trong ảnh."),
              const _BulletText("5. Tránh ảnh bị cắt xén mất phần quan trọng."),
              Center(
              child: Image.asset(
                'assets/images/example.webp',
                height: 160,
                width: 250,
              ),
            )
            ],   
          ),
        ),
      ),

      const Spacer(),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          onPressed: () {},
          child: const Text(
            "Chọn ảnh",
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ),
    ],
  ),
)

    );
  }
}

class _BulletText extends StatelessWidget {
  final String text;
  const _BulletText(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, color: Colors.black87),
      ),
    );
  }
}
