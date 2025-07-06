import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_latn/features/pineline_main/get_description/screen/differentiation_question.dart';

class User_Description_Modal extends StatefulWidget {
  final ScrollController scrollController;

  User_Description_Modal({required this.scrollController});

  @override
  State<User_Description_Modal> createState() => _User_Description_ModalState();
}

class _User_Description_ModalState extends State<User_Description_Modal>
    with SingleTickerProviderStateMixin {
  final TextEditingController positionController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  final TextEditingController appearanceController = TextEditingController();
  final TextEditingController sensationController = TextEditingController();
  final TextEditingController spreadController = TextEditingController();

  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<double> _scaleButton;
  bool _isLoading = false;

  // For staggered animation
  final int _fieldCount = 5;
  late List<bool> _fieldVisible;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scaleButton = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward();

    _fieldVisible = List.generate(_fieldCount, (_) => false);
    _staggerFields();
  }

  Future<void> _staggerFields() async {
    for (int i = 0; i < _fieldCount; i++) {
      await Future.delayed(Duration(milliseconds: 100));
      if (mounted) setState(() => _fieldVisible[i] = true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> submitDescription() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('_id') ?? '';

    final userDescription = '''
Vị trí tổn thương: ${positionController.text.trim()}
Thời gian xuất hiện: ${durationController.text.trim()}
Đặc điểm tổn thương: ${appearanceController.text.trim()}
Cảm giác tại vùng tổn thương: ${sensationController.text.trim()}
Mức độ lan rộng: ${spreadController.text.trim()}
''';

    final url = Uri.parse(
      'https://fastapi-service-748034725478.europe-west4.run.app/api/submit-user-description?key=$userId',
    );

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_description': userDescription}),
      );

      if (response.statusCode == 200) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => Differentiation_Question()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gửi thất bại: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('⚠️ Lỗi khi gửi: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, const Color(0xFFECF4F3).withOpacity(0.7)],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.edit_note_rounded,
                    color: Color(0xFF199A8E),
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Mô tả chi tiết tổn thương da",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),
            Expanded(
              child: ListView(
                controller: widget.scrollController,
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                  top: 12,
                ),
                children: [
                  _buildAnimatedInputSection(
                    index: 0,
                    child: _buildInputSection(
                      title: "Vị trí tổn thương",
                      hint:
                          "Ví dụ: mặt ngoài khuỷu tay trái, vùng da sau tai phải...",
                      icon: Icons.location_on_outlined,
                      controller: positionController,
                    ),
                  ),
                  _buildAnimatedInputSection(
                    index: 1,
                    child: _buildInputSection(
                      title: "Thời gian xuất hiện",
                      hint: "Bạn bắt đầu nhận thấy các dấu hiệu từ khi nào?",
                      icon: Icons.access_time_rounded,
                      controller: durationController,
                    ),
                  ),
                  _buildAnimatedInputSection(
                    index: 2,
                    child: _buildInputSection(
                      title: "Đặc điểm bên ngoài",
                      hint: "Mô tả hình dạng và biểu hiện của tổn thương...",
                      icon: Icons.visibility_outlined,
                      controller: appearanceController,
                    ),
                  ),
                  _buildAnimatedInputSection(
                    index: 3,
                    child: _buildInputSection(
                      title: "Cảm giác tại vùng da",
                      hint: "Mô tả cảm giác như ngứa, đau, rát...",
                      icon: Icons.sentiment_satisfied_alt_outlined,
                      controller: sensationController,
                    ),
                  ),
                  _buildAnimatedInputSection(
                    index: 4,
                    child: _buildInputSection(
                      title: "Mức độ lan rộng",
                      hint:
                          "Tổn thương có lan rộng không? Mô tả chi tiết nếu có.",
                      icon: Icons.zoom_out_map_rounded,
                      controller: spreadController,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : submitDescription,
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.resolveWith<Color>(
                          (states) {
                            if (states.contains(WidgetState.pressed)) {
                              return const Color(
                                0xFF2E7D32,
                              ); 
                            }
                            if (states.contains(WidgetState.hovered)) {
                              return const Color(
                                0xFF1DAA9D,
                              );
                            }
                            return const Color(0xFF199A8E);
                          },
                        ),
                        foregroundColor: WidgetStateProperty.all(Colors.white),
                        padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(vertical: 18),
                        ),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        elevation: WidgetStateProperty.resolveWith<double>((
                          states,
                        ) {
                          if (states.contains(WidgetState.hovered)) return 6.0;
                          return 2.0;
                        }),
                        shadowColor: WidgetStateProperty.all(
                          const Color(0xFF199A8E).withOpacity(0.5),
                        ),
                        textStyle: WidgetStateProperty.all(
                          const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      icon:
                          _isLoading
                              ? Container()
                              : const Icon(Icons.send_rounded),
                      label:
                          _isLoading
                              ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                  strokeWidth: 2.5,
                                ),
                              )
                              : const Text("Gửi mô tả"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedInputSection({
    required int index,
    required Widget child,
  }) {
    return AnimatedOpacity(
      opacity: _fieldVisible[index] ? 1 : 0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      child: AnimatedSlide(
        offset: _fieldVisible[index] ? Offset.zero : const Offset(0, 0.2),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
        child: child,
      ),
    );
  }

  Widget _buildInputSection({
    required String title,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF199A8E), size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF199A8E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: TextField(
              controller: controller,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                contentPadding: const EdgeInsets.all(16),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
