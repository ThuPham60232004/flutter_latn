import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_latn/features/pineline_main/result/result.dart';
import 'dart:ui';

class Differentiation_Question_Modal extends StatefulWidget {
  final ScrollController scrollController;

  Differentiation_Question_Modal({required this.scrollController});

  @override
  State<Differentiation_Question_Modal> createState() =>
      _Differentiation_Question_ModalState();
}

class _Differentiation_Question_ModalState
    extends State<Differentiation_Question_Modal>
    with SingleTickerProviderStateMixin {
  List<String> questions = [];
  bool isLoading = true;
  Map<int, TextEditingController> controllers = {};
  bool _isSubmitting = false;

  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<double> _scaleButton;
  late Animation<double> _iconScale;
  late List<bool> _fieldVisible;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scaleButton = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _iconScale = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _controller.forward();
    fetchQuestions();
  }

  Future<void> fetchQuestions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId') ?? '';

      final url = Uri.parse(
        'https://fastapi-service-748034725478.europe-west4.run.app/api/diagnosis/$userId/questions',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("API Response: $data"); // Debug log

        // Handle different response formats
        List<String> questionList = [];
        
        if (data is List && data.isNotEmpty) {
          // Format: [{"questions": [...]}]
          final item = data[0];
          final qList = item['questions'] ?? item['question'];
          if (qList is List) {
            questionList = List<String>.from(qList).where((q) => q.trim() != ".").toList();
          }
        } else if (data is Map) {
          // Format: {"questions": [...]} or {"question": [...]}
          final qList = data['questions'] ?? data['question'];
          if (qList is List) {
            questionList = List<String>.from(qList).where((q) => q.trim() != ".").toList();
          }
        } else if (data is List) {
          // Format: ["question1", "question2", ...]
          questionList = List<String>.from(data).where((q) => q.trim() != ".").toList();
        }

        if (questionList.isNotEmpty) {
          setState(() {
            questions = questionList;
            for (int i = 0; i < questions.length; i++) {
              controllers[i] = TextEditingController();
            }
            _fieldVisible = List.generate(questions.length, (_) => false);
            _staggerFields();
            isLoading = false;
          });
        } else {
          throw Exception("Không tìm thấy câu hỏi trong dữ liệu API.");
        }
      } else {
        throw Exception("Lỗi kết nối API: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Lỗi: $e");
      setState(() {
        isLoading = false;
        questions = [];
      });
      // Show error dialog to user
      if (mounted) {
        _showErrorDialog('Không thể tải câu hỏi: $e');
      }
    }
  }

  Future<void> _staggerFields() async {
    for (int i = 0; i < questions.length; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) setState(() => _fieldVisible[i] = true);
    }
  }

  Future<void> submitAnswers() async {
    if (_isSubmitting) return;
    setState(() {
      _isSubmitting = true;
    });
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId') ?? '';

    if (userId.isEmpty) {
      setState(() {
        _isSubmitting = false;
      });
      _showErrorDialog('Không tìm thấy người dùng. Vui lòng đăng nhập lại.');
      return;
    }

    // Gộp Q&A thành 1 string (JSON string đơn giản)
    String qaString = '';
    for (int i = 0; i < questions.length; i++) {
      final q = questions[i];
      final a = controllers[i]?.text.trim() ?? '';
      if (a.isNotEmpty) {
        qaString += 'Câu hỏi ${i + 1}: $q\nTrả lời: $a\n\n';
      }
    }
    print(qaString);

    if (qaString.trim().isEmpty) {
      setState(() {
        _isSubmitting = false;
      });
      _showErrorDialog('Bạn chưa nhập câu trả lời nào.');
      return;
    }

    final encodedAnswer = Uri.encodeComponent(qaString);
    final url = Uri.parse(
      'https://fastapi-service-748034725478.europe-west4.run.app/api/diagnosis/$userId/submit?user_answers=$encodedAnswer',
    );

    try {
      final response = await http.post(url);

      if (response.statusCode == 200) {
        print("Gửi thành công!");
        // Parse response body for final_diagnosis
        String? finalDiagnosis;
        try {
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          finalDiagnosis = responseData['final_diagnosis']?.toString();
        } catch (e) {
          finalDiagnosis = null;
        }
        setState(() {
          _isSubmitting = false;
        });
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => Result(finalDiagnosis: finalDiagnosis),
          ),
        );
      } else {
        setState(() {
          _isSubmitting = false;
        });
        print(
          "Lỗi khi gửi dữ liệu: \\${response.statusCode} - \\${response.body}",
        );
        _showErrorDialog('Gửi thất bại: \\${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      print("Lỗi kết nối: $e");
      _showErrorDialog('Lỗi kết nối đến server.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Lỗi'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Đóng'),
              ),
            ],
          ),
    );
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
        child:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                  children: [
                    // Handle bar
                    Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    // Header
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          ScaleTransition(
                            scale: _iconScale,
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF199A8E,
                                ).withOpacity(0.08),
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(6),
                              child: const Icon(
                                Icons.question_answer_rounded,
                                color: Color(0xFF199A8E),
                                size: 28,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Câu hỏi phân biệt chẩn đoán",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFFE5E7EB),
                    ),
                    // Content
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
                          if (questions.isEmpty && !isLoading)
                            Container(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Không thể tải câu hỏi',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Vui lòng thử lại sau hoặc liên hệ hỗ trợ',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        isLoading = true;
                                        questions = [];
                                      });
                                      fetchQuestions();
                                    },
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Thử lại'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF199A8E),
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            ...List.generate(
                              questions.length,
                              (i) => _buildAnimatedInputSection(
                                index: i,
                                child: buildQuestionWidget(questions[i], i),
                              ),
                            ),
                          if (questions.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            MouseRegion(
                              cursor:
                                  _isSubmitting
                                      ? SystemMouseCursors.forbidden
                                      : SystemMouseCursors.click,
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 150),
                                curve: Curves.easeInOut,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          _isSubmitting
                                              ? Colors.grey.withOpacity(0.1)
                                              : Colors.teal.withOpacity(0.18),
                                      blurRadius: 12,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        _isSubmitting
                                            ? Colors.grey[400]
                                            : const Color(0xFF199A8E),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 18,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    elevation: 6,
                                    shadowColor: const Color(
                                      0xFF199A8E,
                                    ).withOpacity(0.25),
                                    textStyle: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  icon:
                                      _isSubmitting
                                          ? SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2.5,
                                            ),
                                          )
                                          : const Icon(Icons.send_rounded),
                                  label: Text(
                                    _isSubmitting ? "Đang gửi..." : "Tiếp theo",
                                  ),
                                  onPressed: _isSubmitting ? null : submitAnswers,
                                ),
                              ),
                            ),
                          ],
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
    if (_fieldVisible.isEmpty) return child;
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

  Widget buildQuestionWidget(String fullQuestion, int index) {
    controllers.putIfAbsent(index, () => TextEditingController());

    final RegExp explainRegex = RegExp(r'\((.*?)\)');
    final explanationMatch = explainRegex.firstMatch(fullQuestion);
    final explanation = explanationMatch?.group(1);

    final RegExp titleRegex = RegExp(r'\*\*(.*?)\*\*');
    final titleMatch = titleRegex.firstMatch(fullQuestion);
    final title = titleMatch?.group(1)?.trim();

    String content =
        fullQuestion
            .replaceAll(RegExp(r'\*\*(.*?)\*\*'), '')
            .replaceAll(RegExp(r'\(.*?\)'), '')
            .trim();

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
            child: _TextWithArrow(text: content),
          ),
          customMultilineInput(
            hint: explanation ?? "Nhập câu trả lời của bạn...",
            controller: controllers[index]!,
          ),
        ],
      ),
    );
  }
}

Widget customMultilineInput({
  required String hint,
  required TextEditingController controller,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    child: TextField(
      controller: controller,
      maxLines: null,
      keyboardType: TextInputType.multiline,
      style: TextStyle(fontSize: 16, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[700]),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Color(0xFFE5E7EB), width: 1.2),
        ),
      ),
    ),
  );
}

class _TextWithArrow extends StatelessWidget {
  final String text;

  const _TextWithArrow({required this.text});

  @override
  Widget build(BuildContext context) {
    if (!text.contains('->')) {
      return Text(
        text,
        style: const TextStyle(fontSize: 16, color: Colors.black87),
      );
    }

    final parts = text.split('->');
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 16, color: Colors.black87),
        children: [
          TextSpan(text: parts[0].trim() + ' '),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Icon(Icons.arrow_forward, size: 18, color: Colors.teal),
          ),
          TextSpan(text: ' ' + parts[1].trim()),
        ],
      ),
    );
  }
}
