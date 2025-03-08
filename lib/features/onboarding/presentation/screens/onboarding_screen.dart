import 'package:flutter/material.dart';
import '../widgets/welcome_text.dart';
import '../widgets/indicator.dart';
import '../widgets/start_button.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.teal.shade400, Colors.teal.shade300],
              ),
            ),
          ),
          // Onboarding content
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(34),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  WelcomeText(),  // ✅ Tiêu đề
                  SizedBox(height: 12),
                  Text(
                    'AI Health Diagnosis là ứng dụng sử dụng trí tuệ nhân tạo (AI) để hỗ trợ bạn trong việc phát hiện sớm các dấu hiệu bệnh lý dựa trên hình ảnh y khoa.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  SizedBox(height: 16),
                  Indicator(),  // ✅ Chỉ số trang
                  SizedBox(height: 16),
                  StartButton(), // ✅ Nút "Bắt đầu"
                  SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
