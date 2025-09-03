import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_latn/features/auth/presentation/screens/reset_prompt_screen.dart';
import 'dart:convert';

class ForgotScreen extends StatefulWidget {
  const ForgotScreen({Key? key}) : super(key: key);

  @override
  State<ForgotScreen> createState() => _ForgotScreenState();
}

class _ForgotScreenState extends State<ForgotScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _success = false;
  String? _error;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    setState(() {
      _loading = true;
      _error = null;
      _success = false;
    });
    try {
      final response = await http.post(
        Uri.parse(
          'https://old-med-api-18037738556.asia-southeast1.run.app/api/forgot-password?email=${_emailController.text.trim()}',
        ),
      );
      if (response.statusCode == 200) {
        setState(() {
          _success = true;
          _loading = false;
        });
        // Navigate to reset prompt screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => ResetPromptScreen(email: _emailController.text.trim()),
          ),
        );
      } else {
        String message = 'Không thể gửi mã xác thực. Vui lòng thử lại.';
        try {
          final data = jsonDecode(response.body);
          if (data['message'] != null) {
            message = data['message'];
          }
        } catch (_) {}
        setState(() {
          _error = message;
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Lỗi kết nối. Vui lòng thử lại.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 32.0,
                vertical: 24,
              ),
              child: Card(
                elevation: 12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lock_reset_rounded,
                          size: 64,
                          color: Color(0xFF0F968A),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Quên mật khẩu',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F968A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Nhập địa chỉ email của bạn và chúng tôi sẽ gửi liên kết đặt lại mật khẩu.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Color(0xFF0F968A),
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: const Icon(Icons.email_rounded),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập email.';
                            }
                            if (!value.contains('@')) {
                              return 'Vui lòng nhập email hợp lệ.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          child:
                              _loading
                                  ? const CircularProgressIndicator()
                                  : ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: const Size.fromHeight(48),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      backgroundColor: Color(0xFF0F968A),
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: () {
                                      if (_formKey.currentState?.validate() ??
                                          false) {
                                        _sendResetLink();
                                      }
                                    },
                                    child: const Text(
                                      'Gửi liên kết đặt lại mật khẩu',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                        ),
                        if (_error != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: AnimatedOpacity(
                              opacity: _error != null ? 1 : 0,
                              duration: const Duration(milliseconds: 400),
                              child: Text(
                                _error!,
                                style: const TextStyle(color: Colors.redAccent),
                              ),
                            ),
                          ),
                        if (_success)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: AnimatedOpacity(
                              opacity: _success ? 1 : 0,
                              duration: const Duration(milliseconds: 400),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.check_circle, color: Colors.green),
                                  SizedBox(width: 8),
                                  Text(
                                    'Vui lòng kiểm tra email của bạn.',
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 0, 0, 0),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
