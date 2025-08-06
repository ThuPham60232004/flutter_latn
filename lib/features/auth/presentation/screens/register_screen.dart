import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_latn/features/auth/presentation/widgets/register_widget.dart';
import 'package:flutter_application_latn/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter_application_latn/core/utils/exceptions.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool agree = false;
  bool obscurePassword = true;
  bool isLoading = false;
  final outlineBorderColor = Color(0xFFE5E7EB);
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  String dateOfBirth = "2004-01-10";

  // Validation error messages
  String? nameError;
  String? emailError;
  String? phoneError;
  String? passwordError;
  String? dateOfBirthError;

  // Email validation regex - more comprehensive
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  // Phone validation regex
  static final RegExp _phoneRegex = RegExp(r'^[0-9]{10,11}$');

  // Validate name
  String? _validateName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'Vui lòng nhập tên';
    }

    final trimmedName = name.trim();

    if (trimmedName.length < 2) {
      return 'Tên phải có ít nhất 2 ký tự';
    }

    if (trimmedName.length > 50) {
      return 'Tên quá dài (tối đa 50 ký tự)';
    }

    if (!RegExp(r'^[a-zA-ZÀ-ỹ\s]+$').hasMatch(trimmedName)) {
      return 'Tên chỉ được chứa chữ cái và khoảng trắng';
    }

    if (trimmedName.contains('  ')) {
      return 'Tên không được chứa khoảng trắng liên tiếp';
    }

    if (trimmedName.startsWith(' ') || trimmedName.endsWith(' ')) {
      return 'Tên không được bắt đầu hoặc kết thúc bằng khoảng trắng';
    }

    return null;
  }

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

  String? _validatePhone(String? phone) {
    if (phone == null || phone.trim().isEmpty) {
      return 'Vui lòng nhập số điện thoại';
    }

    final trimmedPhone = phone.trim();

    final digitsOnly = trimmedPhone.replaceAll(RegExp(r'[^0-9]'), '');

    if (digitsOnly.length < 10) {
      return 'Số điện thoại phải có ít nhất 10 chữ số';
    }

    if (digitsOnly.length > 11) {
      return 'Số điện thoại không được quá 11 chữ số';
    }

    if (!_phoneRegex.hasMatch(digitsOnly)) {
      return 'Số điện thoại không đúng định dạng';
    }

    if (!digitsOnly.startsWith('0')) {
      return 'Số điện thoại phải bắt đầu bằng số 0';
    }

    return null;
  }

  String? _validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
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

  String? _validateDateOfBirth(String? dateOfBirth) {
    if (dateOfBirth == null || dateOfBirth.isEmpty) {
      return 'Vui lòng chọn ngày sinh';
    }

    try {
      final date = DateTime.parse(dateOfBirth);
      final now = DateTime.now();
      final age =
          now.year -
          date.year -
          (now.month < date.month ||
                  (now.month == date.month && now.day < date.day)
              ? 1
              : 0);

      if (age < 1) {
        return 'Tuổi phải lớn hơn 1';
      }

      if (age > 120) {
        return 'Tuổi không hợp lệ';
      }

      if (date.isAfter(now)) {
        return 'Ngày sinh không thể là ngày trong tương lai';
      }
    } catch (e) {
      return 'Ngày sinh không hợp lệ';
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
      nameError = null;
      emailError = null;
      phoneError = null;
      passwordError = null;
      dateOfBirthError = null;
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

  Future<void> register() async {
    _clearValidationErrors();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text.trim();

    final nameValidation = _validateName(name);
    final emailValidation = _validateEmail(email);
    final phoneValidation = _validatePhone(phone);
    final passwordValidation = _validatePassword(password);
    final dateOfBirthValidation = _validateDateOfBirth(dateOfBirth);

    if (nameValidation != null) {
      setState(() => nameError = nameValidation);
      _showErrorMessage(nameValidation);
      return;
    }

    if (emailValidation != null) {
      setState(() => emailError = emailValidation);
      _showErrorMessage(emailValidation);
      return;
    }

    if (phoneValidation != null) {
      setState(() => phoneError = phoneValidation);
      _showErrorMessage(phoneValidation);
      return;
    }

    if (passwordValidation != null) {
      setState(() => passwordError = passwordValidation);
      _showErrorMessage(passwordValidation);
      return;
    }

    if (dateOfBirthValidation != null) {
      setState(() => dateOfBirthError = dateOfBirthValidation);
      _showErrorMessage(dateOfBirthValidation);
      return;
    }

    if (!agree) {
      _showErrorMessage(
        'Vui lòng đồng ý với điều khoản dịch vụ và chính sách bảo mật',
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final hasConnection = await _checkNetworkConnectivity();
      if (!hasConnection) {
        _showErrorMessage('Không có kết nối internet. Vui lòng kiểm tra lại.');
        return;
      }

      final url = Uri.parse(
        "https://fastapi-service-748034725478.europe-west4.run.app/api/register",
      );

      final request = http.MultipartRequest("POST", url);
      request.fields['name'] = name;
      request.fields['email'] = email;
      request.fields['phone'] = phone.replaceAll(RegExp(r'[^0-9]'), '');
      request.fields['password'] = password;
      request.fields['dateOfBirth'] = dateOfBirth;

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Yêu cầu đăng ký đã hết thời gian chờ');
        },
      );

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSuccessMessage('Đăng ký thành công!');

        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) => const SuccessDialog(),
          );
        }
      } else if (response.statusCode == 400) {
        try {
          final responseBody = jsonDecode(response.body);
          final error =
              responseBody['detail']?.toString() ?? 'Đăng ký thất bại';
          _showErrorMessage(error);
        } catch (e) {
          _showErrorMessage('Dữ liệu không hợp lệ');
        }
      } else if (response.statusCode == 409) {
        _showErrorMessage('Email hoặc số điện thoại đã tồn tại');
      } else if (response.statusCode == 429) {
        _showErrorMessage('Quá nhiều yêu cầu đăng ký. Vui lòng thử lại sau.');
      } else if (response.statusCode >= 500) {
        _showErrorMessage('Lỗi máy chủ. Vui lòng thử lại sau.');
      } else {
        try {
          final responseBody = jsonDecode(response.body);
          _showErrorMessage(
            responseBody['detail']?.toString() ?? 'Đăng ký thất bại',
          );
        } catch (e) {
          _showErrorMessage(
            'Đăng ký thất bại (Mã lỗi: ${response.statusCode})',
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
            : 'Yêu cầu đăng ký đã hết thời gian chờ',
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

  InputDecoration inputStyle(
    IconData icon,
    String hint, {
    bool isError = false,
    String? errorText,
  }) {
    return InputDecoration(
      prefixIcon: Icon(icon),
      hintText: hint,
      errorText: errorText,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isError ? Colors.red : outlineBorderColor,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isError ? Colors.red : outlineBorderColor,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
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
        dateOfBirthError = null;
      });
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
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
                    const SizedBox(height: 24),
                    const Text(
                      'Đăng ký',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: nameController,
                      textInputAction: TextInputAction.next,
                      validator: _validateName,
                      decoration: inputStyle(
                        Icons.person_outline,
                        'Nhập tên của bạn',
                        isError: nameError != null,
                        errorText: nameError,
                      ),
                      onChanged: (value) {
                        if (nameError != null) {
                          setState(() => nameError = null);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: _validateEmail,
                      decoration: inputStyle(
                        Icons.email_outlined,
                        'Nhập email của bạn',
                        isError: emailError != null,
                        errorText: emailError,
                      ),
                      onChanged: (value) {
                        if (emailError != null) {
                          setState(() => emailError = null);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      validator: _validatePhone,
                      decoration: inputStyle(
                        Icons.phone_outlined,
                        'Nhập số điện thoại',
                        isError: phoneError != null,
                        errorText: phoneError,
                      ),
                      onChanged: (value) {
                        if (phoneError != null) {
                          setState(() => phoneError = null);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      textInputAction: TextInputAction.done,
                      validator: _validatePassword,
                      decoration: inputStyle(
                        Icons.lock_outline,
                        'Nhập mật khẩu của bạn',
                        isError: passwordError != null,
                        errorText: passwordError,
                      ).copyWith(
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
                      ),
                      onChanged: (value) {
                        if (passwordError != null) {
                          setState(() => passwordError = null);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: AbsorbPointer(
                        child: TextFormField(
                          validator: _validateDateOfBirth,
                          decoration: inputStyle(
                            Icons.calendar_today_outlined,
                            'Chọn ngày sinh',
                            isError: dateOfBirthError != null,
                            errorText: dateOfBirthError,
                          ),
                          controller: TextEditingController(text: dateOfBirth),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
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
                            text: const TextSpan(
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
                        onPressed: (agree && !isLoading) ? register : null,
                        child:
                            isLoading
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                : const Text(
                                  "Đăng ký",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Wrap(
                        children: [
                          const Text("Đã có tài khoản? "),
                          GestureDetector(
                            onTap:
                                isLoading
                                    ? null
                                    : () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const LoginScreen(),
                                        ),
                                      );
                                    },
                            child: const Text(
                              "Đăng nhập",
                              style: TextStyle(color: Color(0xFF0F968A)),
                            ),
                          ),
                        ],
                      ),
                    ),
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
