import 'package:flutter/material.dart';
import 'package:flutter_application_latn/core/routes.dart';

class StartButton extends StatelessWidget {
  const StartButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onPressed: () {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        },
        child: const Text(
          'Bắt đầu',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }
}
