import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_latn/features/auth/presentation/widgets/login_widget.dart';
import 'package:flutter_application_latn/features/auth/presentation/screens/forgot_screen.dart';
import 'package:flutter_application_latn/features/auth/presentation/screens/register_screen.dart';
import 'package:flutter_application_latn/core/utils/exceptions.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool obscurePassword = true;

  String? emailError;
  String? passwordError;

  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  String? _validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'Vui lòng nhập email';
    }

    final trimmedEmail = email.trim();

    if (trimmedEmail.contains(' ')) {
      return 'Email không được chứa khoảng trắng';
    }

    final vietnameseChars =
        'àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđÀÁẠẢÃÂẦẤẬẨẪĂẰẮẶẲẴÈÉẸẺẼÊỀẾỆỂỄÌÍỊỈĨÒÓỌỎÕÔỒỐỘỔỖƠỜỚỢỞỠÙÚỤỦŨƯỪỨỰỬỮỲÝỴỶỸĐ';
    for (int i = 0; i < trimmedEmail.length; i++) {
      if (vietnameseChars.contains(trimmedEmail[i])) {
        return 'Email không được chứa ký tự tiếng Việt có dấu';
      }
    }

    final invalidChars = [
      '<',
      '>',
      '(',
      ')',
      '[',
      ']',
      '\\',
      ',',
      ';',
      ':',
      '"',
      "'",
      '`',
      '~',
      '!',
      '@',
      '#',
      '\$',
      '%',
      '^',
      '&',
      '*',
      '+',
      '=',
      '|',
      '{',
      '}',
      '?',
    ];

    if (trimmedEmail.contains('..')) {
      return 'Email không được chứa dấu chấm liên tiếp';
    }

    final parts = trimmedEmail.split('@');
    if (parts.length != 2) {
      return 'Email phải chứa đúng một ký tự @';
    }

    final localPart = parts[0];
    final domain = parts[1];

    if (localPart.isEmpty) {
      return 'Phần trước @ không được để trống';
    }

    if (localPart.length > 64) {
      return 'Phần trước @ quá dài (tối đa 64 ký tự)';
    }

    if (localPart.startsWith('.') || localPart.endsWith('.')) {
      return 'Phần trước @ không được bắt đầu hoặc kết thúc bằng dấu chấm';
    }

    if (domain.isEmpty) {
      return 'Tên miền không được để trống';
    }

    if (domain.length < 3) {
      return 'Tên miền email không hợp lệ (quá ngắn)';
    }

    if (domain.length > 253) {
      return 'Tên miền email quá dài (tối đa 253 ký tự)';
    }

    if (domain.startsWith('.') || domain.endsWith('.')) {
      return 'Tên miền không được bắt đầu hoặc kết thúc bằng dấu chấm';
    }

    if (!RegExp(r'^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(domain)) {
      return 'Tên miền email không đúng định dạng';
    }

    if (domain.contains('..')) {
      return 'Tên miền không được chứa dấu chấm liên tiếp';
    }

    if (!_emailRegex.hasMatch(trimmedEmail)) {
      return 'Email không đúng định dạng';
    }

    if (trimmedEmail.length > 254) {
      return 'Email quá dài (tối đa 254 ký tự)';
    }

    return null;
  }

  String? _validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }

    if (password.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }

    if (password.length > 128) {
      return 'Mật khẩu quá dài (tối đa 128 ký tự)';
    }

    if (password.contains(' ')) {
      return 'Mật khẩu không được chứa khoảng trắng';
    }

    return null;
  }

  Future<bool> _checkNetworkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  void _clearValidationErrors() {
    setState(() {
      emailError = null;
      passwordError = null;
    });
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> login() async {
    _clearValidationErrors();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    final emailValidation = _validateEmail(email);
    final passwordValidation = _validatePassword(password);

    if (emailValidation != null) {
      setState(() => emailError = emailValidation);
      _showErrorMessage(emailValidation);
      return;
    }

    if (passwordValidation != null) {
      setState(() => passwordError = passwordValidation);
      _showErrorMessage(passwordValidation);
      return;
    }

    if (email.contains('<') ||
        email.contains('>') ||
        email.contains('"') ||
        email.contains("'")) {
      _showErrorMessage('Email chứa ký tự không hợp lệ');
      return;
    }

    setState(() => isLoading = true);

    try {
      final hasConnection = await _checkNetworkConnectivity();
      if (!hasConnection) {
        _showErrorMessage('Không có kết nối internet. Vui lòng kiểm tra lại.');
        return;
      }

      final response = await http
          .post(
            Uri.parse(
              "https://fastapi-service-748034725478.europe-west4.run.app/api/login",
            ),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"email": email, "password": password}),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw TimeoutException('Yêu cầu đăng nhập đã hết thời gian chờ');
            },
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data == null) {
          _showErrorMessage('Dữ liệu phản hồi không hợp lệ');
          return;
        }

        if (data['_id'] == null ||
            data['name'] == null ||
            data['email'] == null) {
          _showErrorMessage('Thông tin người dùng không đầy đủ');
          return;
        }

        if (data['_id'].toString().isEmpty ||
            data['name'].toString().isEmpty ||
            data['email'].toString().isEmpty) {
          _showErrorMessage('Thông tin người dùng không hợp lệ');
          return;
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', data['_id']);
        await prefs.setString('name', data['name']);
        await prefs.setString('email', data['email']);
        await prefs.setString('avatar', data['urlImage'] ?? '');
        await prefs.setString('urlImage', data['urlImage'] ?? '');

        _showSuccessMessage('Đăng nhập thành công!');

        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const SuccessDialog(),
          );
        }
      } else if (response.statusCode == 401) {
        _showErrorMessage('Email hoặc mật khẩu không đúng');
      } else if (response.statusCode == 404) {
        _showErrorMessage('Tài khoản không tồn tại');
      } else if (response.statusCode == 429) {
        _showErrorMessage('Quá nhiều yêu cầu đăng nhập. Vui lòng thử lại sau.');
      } else if (response.statusCode >= 500) {
        _showErrorMessage('Lỗi máy chủ. Vui lòng thử lại sau.');
      } else {
        try {
          final error = jsonDecode(response.body);
          _showErrorMessage(error["message"] ?? "Đăng nhập thất bại");
        } catch (e) {
          _showErrorMessage(
            'Đăng nhập thất bại (Mã lỗi: ${response.statusCode})',
          );
        }
      }
    } on SocketException catch (_) {
      _showErrorMessage(
        'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối internet.',
      );
    } on TimeoutException catch (e) {
      _showErrorMessage(
        e.message.isNotEmpty
            ? e.message
            : 'Yêu cầu đăng nhập đã hết thời gian chờ',
      );
    } on FormatException catch (_) {
      _showErrorMessage('Dữ liệu phản hồi không đúng định dạng');
    } on HttpException catch (e) {
      _showErrorMessage('Lỗi HTTP: ${e.message}');
    } catch (e) {
      _showErrorMessage('Lỗi không xác định: $e');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 32),
                    const Text(
                      'Đăng nhập',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: _validateEmail,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.email_outlined),
                        hintText: 'Nhập email của bạn',
                        errorText: emailError,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(
                            color: Color(0xFFE5E7EB),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        if (emailError != null) {
                          setState(() => emailError = null);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      textInputAction: TextInputAction.done,
                      validator: _validatePassword,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock_outline),
                        hintText: 'Nhập mật khẩu của bạn',
                        errorText: passwordError,
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(
                            color: Color(0xFFE5E7EB),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        if (passwordError != null) {
                          setState(() => passwordError = null);
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed:
                            isLoading
                                ? null
                                : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const ForgotScreen(),
                                    ),
                                  );
                                },
                        child: const Text(
                          'Quên mật khẩu?',
                          style: TextStyle(color: Color(0xFF0F968A)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF0F968A),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        onPressed: isLoading ? null : login,
                        child:
                            isLoading
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                : const Text(
                                  "Đăng nhập",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Wrap(
                        children: [
                          const Text("Không có tài khoản? "),
                          GestureDetector(
                            onTap:
                                isLoading
                                    ? null
                                    : () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => RegisterScreen(),
                                        ),
                                      );
                                    },
                            child: const Text(
                              "Đăng ký",
                              style: TextStyle(color: Color(0xFF0F968A)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
