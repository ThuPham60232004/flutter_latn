import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ResetPromptScreen extends StatefulWidget {
  final String email;
  const ResetPromptScreen({Key? key, required this.email}) : super(key: key);

  @override
  State<ResetPromptScreen> createState() => _ResetPromptScreenState();
}

class _ResetPromptScreenState extends State<ResetPromptScreen> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _loading = false;
  String? _error;
  bool _success = false;
  bool _obscure = true;

  Future<void> _resetPassword() async {
    setState(() {
      _loading = true;
      _error = null;
      _success = false;
    });
    try {
      final response = await http.post(
        Uri.parse(
          'https://fastapi-service-748034725478.europe-west4.run.app/api/reset-password?email=${widget.email}&verification_code=${_codeController.text.trim()}&new_password=${_passwordController.text.trim()}',
        ),
      );
      if (response.statusCode == 200) {
        setState(() {
          _success = true;
          _loading = false;
        });
      } else {
        setState(() {
          _error =
              'Không thể đặt lại mật khẩu. Vui lòng kiểm tra mã xác thực và thử lại.';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đặt lại mật khẩu'),
        backgroundColor: const Color(0xFF0F968A),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
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
                      Text(
                        'Nhập mã xác thực và mật khẩu mới',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F968A),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: widget.email,
                        enabled: false,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _codeController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Mã xác thực (6 số)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập mã xác thực.';
                          }
                          if (value.length != 6) {
                            return 'Mã xác thực phải có 6 số.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          labelText: 'Mật khẩu mới',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed:
                                () => setState(() => _obscure = !_obscure),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập mật khẩu mới.';
                          }
                          if (value.length < 6) {
                            return 'Mật khẩu phải có ít nhất 6 ký tự.';
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
                                    backgroundColor: const Color(0xFF0F968A),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  onPressed: () {
                                    if (_formKey.currentState?.validate() ??
                                        false) {
                                      _resetPassword();
                                    }
                                  },
                                  child: const Text(
                                    'Đặt lại mật khẩu',
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
                                  'Đặt lại mật khẩu thành công!',
                                  style: TextStyle(color: Colors.green),
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
    );
  }
}
