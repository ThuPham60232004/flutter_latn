import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_latn/core/utils/exceptions.dart';

class ResetPromptScreen extends StatefulWidget {
  final String email;
  const ResetPromptScreen({super.key, required this.email});

  @override
  State<ResetPromptScreen> createState() => _ResetPromptScreenState();
}

class _ResetPromptScreenState extends State<ResetPromptScreen> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _obscure = true;

  String? _codeError;
  String? _passwordError;

  String? _validateCode(String? code) {
    if (code == null || code.trim().isEmpty) {
      return 'Vui lòng nhập mã xác thực';
    }

    final trimmedCode = code.trim();

    if (!RegExp(r'^[0-9]+$').hasMatch(trimmedCode)) {
      return 'Mã xác thực chỉ được chứa số';
    }

    if (trimmedCode.length != 6) {
      return 'Mã xác thực phải có đúng 6 số';
    }

    return null;
  }

  String? _validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Vui lòng nhập mật khẩu mới';
    }

    if (password.length < 8) {
      return 'Mật khẩu phải có ít nhất 8 ký tự';
    }

    if (password.length > 128) {
      return 'Mật khẩu quá dài (tối đa 128 ký tự)';
    }

    if (password.contains(' ')) {
      return 'Mật khẩu không được chứa khoảng trắng';
    }

    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Mật khẩu phải có ít nhất 1 chữ in hoa';
    }

    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Mật khẩu phải có ít nhất 1 chữ thường';
    }

    if (!RegExp(r'\d').hasMatch(password)) {
      return 'Mật khẩu phải có ít nhất 1 chữ số';
    }

    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password)) {
      return 'Mật khẩu phải có ít nhất 1 ký tự đặc biệt';
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
      _codeError = null;
      _passwordError = null;
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

  Future<void> _resetPassword() async {
    _clearValidationErrors();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final code = _codeController.text.trim();
    final password = _passwordController.text.trim();

    final codeValidation = _validateCode(code);
    final passwordValidation = _validatePassword(password);

    if (codeValidation != null) {
      setState(() => _codeError = codeValidation);
      _showErrorMessage(codeValidation);
      return;
    }

    if (passwordValidation != null) {
      setState(() => _passwordError = passwordValidation);
      _showErrorMessage(passwordValidation);
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final hasConnection = await _checkNetworkConnectivity();
      if (!hasConnection) {
        if (mounted) {
          _showErrorMessage(
            'Không có kết nối internet. Vui lòng kiểm tra lại.',
          );
        }
        return;
      }

      final response = await http
          .post(
            Uri.parse(
              'https://old-med-api-18037738556.asia-southeast1.run.app/api/reset-password?email=${Uri.encodeComponent(widget.email)}&verification_code=${Uri.encodeComponent(code)}&new_password=${Uri.encodeComponent(password)}',
            ),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw TimeoutException(
                'Yêu cầu đặt lại mật khẩu đã hết thời gian chờ',
              );
            },
          );

      if (response.statusCode == 200) {
        if (mounted) {
          _showSuccessMessage('Đặt lại mật khẩu thành công!');
          setState(() {
            _loading = false;
          });

          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          });
        }
      } else if (response.statusCode == 400) {
        try {
          final responseBody = jsonDecode(response.body);
          final error =
              responseBody['detail']?.toString() ?? 'Dữ liệu không hợp lệ';
          if (mounted) {
            _showErrorMessage(error);
          }
        } catch (e) {
          if (mounted) {
            _showErrorMessage('Dữ liệu không hợp lệ');
          }
        }
      } else if (response.statusCode == 404) {
        if (mounted) {
          _showErrorMessage('Email không tồn tại trong hệ thống');
        }
      } else if (response.statusCode == 409) {
        if (mounted) {
          _showErrorMessage('Mã xác thực không đúng hoặc đã hết hạn');
        }
      } else if (response.statusCode == 429) {
        if (mounted) {
          _showErrorMessage('Quá nhiều yêu cầu. Vui lòng thử lại sau.');
        }
      } else if (response.statusCode >= 500) {
        if (mounted) {
          _showErrorMessage('Lỗi máy chủ. Vui lòng thử lại sau.');
        }
      } else {
        try {
          final responseBody = jsonDecode(response.body);
          if (mounted) {
            _showErrorMessage(
              responseBody['detail']?.toString() ?? 'Đặt lại mật khẩu thất bại',
            );
          }
        } catch (e) {
          if (mounted) {
            _showErrorMessage(
              'Đặt lại mật khẩu thất bại (Mã lỗi: ${response.statusCode})',
            );
          }
        }
      }
    } on SocketException catch (_) {
      if (mounted) {
        _showErrorMessage(
          'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối internet.',
        );
      }
    } on TimeoutException catch (e) {
      if (mounted) {
        _showErrorMessage(
          e.message.isNotEmpty
              ? e.message
              : 'Yêu cầu đặt lại mật khẩu đã hết thời gian chờ',
        );
      }
    } on FormatException catch (_) {
      if (mounted) {
        _showErrorMessage('Dữ liệu phản hồi không đúng định dạng');
      }
    } on HttpException catch (e) {
      if (mounted) {
        _showErrorMessage('Lỗi HTTP: ${e.message}');
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('Lỗi không xác định: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đặt lại mật khẩu'),
        backgroundColor: const Color(0xFF0F968A),
        foregroundColor: Colors.white,
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
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _codeController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        validator: _validateCode,
                        decoration: InputDecoration(
                          labelText: 'Mã xác thực (6 số)',
                          errorText: _codeError,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Colors.red),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 2,
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          if (_codeError != null) {
                            setState(() => _codeError = null);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscure,
                        textInputAction: TextInputAction.done,
                        validator: _validatePassword,
                        decoration: InputDecoration(
                          labelText: 'Mật khẩu mới',
                          errorText: _passwordError,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Colors.red),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 2,
                            ),
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
                        onChanged: (value) {
                          if (_passwordError != null) {
                            setState(() => _passwordError = null);
                          }
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
