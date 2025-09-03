import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_latn/core/utils/exceptions.dart';

class ResetScreen extends StatefulWidget {
  const ResetScreen({super.key});

  @override
  State<ResetScreen> createState() => _ResetScreenState();
}

class _ResetScreenState extends State<ResetScreen> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _success = false;
  String? _emailError;

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
    for (int i = 0; i < trimmedEmail.length; i++) {
      if (invalidChars.contains(trimmedEmail[i])) {
        return 'Email chứa ký tự không hợp lệ';
      }
    }

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
      _emailError = null;
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

    final email = _emailController.text.trim();

    final emailValidation = _validateEmail(email);

    if (emailValidation != null) {
      setState(() => _emailError = emailValidation);
      _showErrorMessage(emailValidation);
      return;
    }

    setState(() {
      _loading = true;
      _success = false;
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
              'https://old-med-api-18037738556.asia-southeast1.run.app/api/forgot-password?email=${Uri.encodeComponent(email)}',
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
          _showSuccessMessage('Email đặt lại mật khẩu đã được gửi!');
          setState(() {
            _success = true;
            _loading = false;
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
    _emailController.dispose();
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
                        'Nhập email để đặt lại mật khẩu',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F968A),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        validator: _validateEmail,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          errorText: _emailError,
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
                          if (_emailError != null) {
                            setState(() => _emailError = null);
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
                                    'Gửi email đặt lại mật khẩu',
                                    style: TextStyle(color: Colors.white),
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
                                  'Email đã được gửi thành công!',
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
