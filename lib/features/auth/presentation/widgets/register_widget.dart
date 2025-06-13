import 'package:flutter/material.dart';
import 'package:flutter_application_latn/features/auth/presentation/screens/login_screen.dart';

class SuccessDialog extends StatelessWidget {
  const SuccessDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, 
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(24),
              child: const Icon(
                Icons.check,
                color: Color(0xFF0F968A),
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Thành công",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Tài khoản của bạn đã được đăng ký thành công",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => LoginScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F968A),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
                child: const Text(
                  "Đăng nhập",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
