import 'package:flutter_application_latn/features/pineline_main/get_description/modal/differentiation_question_modal.dart';
import 'package:flutter_application_latn/core/utils/exceptions.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DifferentiationQuestion extends StatefulWidget {
  const DifferentiationQuestion({super.key});

  @override
  State<DifferentiationQuestion> createState() =>
      _DifferentiationQuestionState();
}

class _DifferentiationQuestionState extends State<DifferentiationQuestion>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  bool _isSkipLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<bool> _checkNetworkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  void _showErrorMessage(String message) {
    if (!mounted) return;
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
    if (!mounted) return;
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

  Future<void> _onSkip() async {
    if (_isSkipLoading) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 28,
                ),
                const SizedBox(width: 8),
                const Text('Xác nhận'),
              ],
            ),
            content: const Text('Bạn có chắc chắn muốn dừng chẩn đoán?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Không'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Dừng'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      setState(() {
        _isSkipLoading = true;
        _errorMessage = null;
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

        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getString('userId');

        if (userId == null || userId.isEmpty) {
          if (mounted) {
            _showErrorMessage(
              'Không tìm thấy thông tin người dùng. Vui lòng đăng nhập lại.',
            );
          }
          return;
        }

        final uri = Uri.parse(
          'https://fastapi-service-748034725478.europe-west4.run.app/api/diagnosis/$userId/skip',
        );

        final response = await http
            .post(uri)
            .timeout(
              const Duration(seconds: 30),
              onTimeout: () {
                throw TimeoutException(
                  'Yêu cầu dừng chẩn đoán đã hết thời gian chờ',
                );
              },
            );

        if (response.statusCode == 200) {
          if (mounted) {
            _showSuccessMessage('Đã dừng chẩn đoán thành công!');
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        } else if (response.statusCode == 400) {
          try {
            final responseBody =
                jsonDecode(response.body) as Map<String, dynamic>;
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
        } else if (response.statusCode == 401) {
          if (mounted) {
            _showErrorMessage(
              'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
            );
          }
        } else if (response.statusCode == 404) {
          if (mounted) {
            _showErrorMessage('Không tìm thấy phiên chẩn đoán.');
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
          if (mounted) {
            _showErrorMessage(
              'Dừng chẩn đoán thất bại (Mã lỗi: ${response.statusCode})',
            );
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
                : 'Yêu cầu dừng chẩn đoán đã hết thời gian chờ',
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
            _isSkipLoading = false;
          });
        }
      }
    }
  }

  Future<void> _onAnswerQuestions() async {
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

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null || userId.isEmpty) {
        if (mounted) {
          _showErrorMessage(
            'Không tìm thấy thông tin người dùng. Vui lòng đăng nhập lại.',
          );
        }
        return;
      }

      if (mounted) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder:
              (context) => Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: DraggableScrollableSheet(
                  expand: false,
                  initialChildSize: 0.9,
                  minChildSize: 0.5,
                  maxChildSize: 0.95,
                  builder: (context, scrollController) {
                    return Differentiation_Question_Modal(
                      scrollController: scrollController,
                    );
                  },
                ),
              ),
        );
      }
    } on SocketException catch (_) {
      if (mounted) {
        _showErrorMessage(
          'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối internet.',
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('Lỗi không xác định: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFFF6FAFB),
      body: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(seconds: 2),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFB2FEFA), Color(0xFF199A8E)],
              ),
            ),
          ),
          Positioned(
            top: -60,
            left: -60,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.tealAccent.withValues(alpha: 0.18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.teal.withValues(alpha: 0.08),
                    blurRadius: 60,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            right: -40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.teal.withValues(alpha: 0.10),
              ),
            ),
          ),
          Center(
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 16.0,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(36),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                      child: Container(
                        width: size.width < 400 ? double.infinity : 400,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.72),
                          borderRadius: BorderRadius.circular(36),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.10),
                              blurRadius: 36,
                              offset: const Offset(0, 16),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                            width: 1.5,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 40,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedScale(
                              scale: 1.0,
                              duration: const Duration(milliseconds: 900),
                              curve: Curves.elasticOut,
                              child: Container(
                                height: 110,
                                width: 110,
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF199A8E,
                                  ).withValues(alpha: 0.13),
                                  borderRadius: BorderRadius.circular(28),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.teal.withValues(
                                        alpha: 0.10,
                                      ),
                                      blurRadius: 18,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.medical_services_rounded,
                                  size: 70,
                                  color: Color(0xFF199A8E),
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                            const Text(
                              "Thông tin bổ sung về bệnh lý",
                              style: TextStyle(
                                fontSize: 27,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF199A8E),
                                letterSpacing: 1.1,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 14),
                            Text(
                              "Vui lòng trả lời các câu hỏi sau để giúp hệ thống đánh giá chính xác hơn. Nếu không muốn trả lời, bạn có thể bỏ qua bước này.",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[800],
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (_errorMessage != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.red.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        color: Colors.red[700],
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _errorMessage!,
                                          style: TextStyle(
                                            color: Colors.red[700],
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            const SizedBox(height: 38),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 18,
                                      ),
                                      backgroundColor: const Color(0xFF199A8E),
                                      foregroundColor: Colors.white,
                                      elevation: 5,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      textStyle: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    label: const Text("Trả lời câu hỏi"),
                                    onPressed: _onAnswerQuestions,
                                  ),
                                ),
                                const SizedBox(width: 18),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 18,
                                      ),
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.red[700],
                                      side: const BorderSide(
                                        color: Color(0xFFE53935),
                                        width: 1.5,
                                      ),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      textStyle: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    icon:
                                        _isSkipLoading
                                            ? const SizedBox(
                                              width: 22,
                                              height: 22,
                                              child: CircularProgressIndicator(
                                                color: Colors.red,
                                                strokeWidth: 2.5,
                                              ),
                                            )
                                            : const Icon(Icons.close_rounded),
                                    label: Text(
                                      _isSkipLoading
                                          ? "Đang dừng..."
                                          : "Bỏ qua",
                                    ),
                                    onPressed: _isSkipLoading ? null : _onSkip,
                                  ),
                                ),
                              ],
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
        ],
      ),
    );
  }
}
