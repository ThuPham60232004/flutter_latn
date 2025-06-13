import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_latn/features/auth/presentation/widgets/register_widget.dart';
class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool agree = false;
  bool obscurePassword = true;
  final outlineBorderColor = Color(0xFFE5E7EB);

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  String dateOfBirth = "2004-01-10";

  String? errorMessage;

  Future<void> register() async {
    final password = passwordController.text.trim();
    final phone = phoneController.text.trim();
    final email = emailController.text.trim();

    try {
      if (password.isEmpty) throw "Mật khẩu không được để trống";
      if (password.length < 6) throw "Mật khẩu phải có ít nhất 6 ký tự";
      if (!RegExp(r'[A-Z]').hasMatch(password)) throw "Mật khẩu phải chứa ít nhất một chữ hoa";
      if (!RegExp(r'\d').hasMatch(password)) throw "Mật khẩu phải chứa ít nhất một chữ số";
      if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password)) throw "Mật khẩu phải chứa ít nhất một ký tự đặc biệt";
      if (!RegExp(r"^\d{10,11}$").hasMatch(phone)) throw "Số điện thoại phải có 10 hoặc 11 chữ số";
      if (!RegExp(r"^[^@]+@[^@]+\.[^@]+").hasMatch(email)) throw "Email không hợp lệ";

      setState(() {
        errorMessage = null;
      });

      final url = Uri.parse("https://fastapi-service-748034725478.europe-west4.run.app//api/register");
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "name": nameController.text.trim(),
          "email": email,
          "phone": phone,
          "password": password,
          "dateOfBirth": dateOfBirth,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return const SuccessDialog();
            },
          );
        }
      else {
        final responseBody = jsonDecode(response.body);
        setState(() {
          errorMessage = responseBody['message'] ?? 'Đăng ký thất bại';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    }
  }

  InputDecoration inputStyle(IconData icon, String hint, {bool isError = false}) {
    return InputDecoration(
      prefixIcon: Icon(icon),
      hintText: hint,
      errorText: isError ? errorMessage : null,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isError ? Colors.red : outlineBorderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isError ? Colors.red : outlineBorderColor),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final initialDate = DateTime.tryParse(dateOfBirth) ?? DateTime(2004, 1, 10);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        dateOfBirth = picked.toIso8601String().split('T')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isError = errorMessage != null;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 24),
                Text(
                  'Đăng ký',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 32),
                TextField(
                  controller: nameController,
                  decoration: inputStyle(Icons.person_outline, 'Nhập tên của bạn'),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: inputStyle(Icons.email_outlined, 'Nhập email của bạn'),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: inputStyle(Icons.phone_outlined, 'Nhập số điện thoại'),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  decoration: inputStyle(Icons.lock_outline, 'Nhập mật khẩu của bạn', isError: isError)
                      .copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(obscurePassword ? Icons.visibility_off : Icons.visibility),
                          onPressed: () {
                            setState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                        ),
                      ),
                ),
                if (isError)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                    child: Text(
                      '*$errorMessage',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                SizedBox(height: 16),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer(
                    child: TextField(
                      decoration: inputStyle(Icons.calendar_today_outlined, 'Chọn ngày sinh'),
                      controller: TextEditingController(text: dateOfBirth),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: agree,
                      onChanged: (value) {
                        setState(() {
                          agree = value ?? false;
                        });
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(color: Colors.black),
                          children: [
                            TextSpan(text: 'Tôi đồng ý với '),
                            TextSpan(
                              text: 'Điều khoản dịch vụ',
                              style: TextStyle(color: Colors.teal),
                            ),
                            TextSpan(text: ' và '),
                            TextSpan(
                              text: 'Chính sách bảo mật',
                              style: TextStyle(color: Colors.teal),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
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
                    onPressed: agree ? register : null,
                    child: const Text(
                      "Đăng ký",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Center(
                  child: Wrap(
                    children: [
                      Text('Bạn đã có tài khoản? '),
                      GestureDetector(
                        onTap: () {
                          // Điều hướng sang màn hình đăng nhập
                        },
                        child: Text(
                          'Đăng nhập',
                          style: TextStyle(color: Colors.teal),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
