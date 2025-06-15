import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_latn/features/pineline_main/result/result.dart';
class Differentiation_Question_Modal extends StatefulWidget {
  final ScrollController scrollController;

  Differentiation_Question_Modal({required this.scrollController});

  @override
  State<Differentiation_Question_Modal> createState() =>
      _Differentiation_Question_ModalState();
}

class _Differentiation_Question_ModalState extends State<Differentiation_Question_Modal> {
  List<String> questions = [];
  bool isLoading = true;
  Map<int, TextEditingController> controllers = {};

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  Future<void> fetchQuestions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('_id') ?? '';

      final url = Uri.parse(
          'https://fastapi-service-748034725478.europe-west4.run.app/api/differentiation_questions?key=$userId');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is List && data.isNotEmpty && data[0]['questions'] is List) {
          setState(() {
            questions = List<String>.from(data[0]['questions'])
                .where((q) => q.trim() != ".")
                .toList();

            for (int i = 0; i < questions.length; i++) {
              controllers[i] = TextEditingController();
            }

            isLoading = false;
          });
        } else {
          throw Exception("Dữ liệu không đúng định dạng.");
        }
      } else {
        throw Exception("Lỗi kết nối API: ${response.statusCode}");
      }
    } catch (e) {
      print("Lỗi: $e");
      setState(() {
        isLoading = false;
        questions = [];
      });
    }
  }

  Future<void> submitAnswers() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('_id') ?? '';

    List<String> userDescriptions = controllers.entries.map((entry) {
      return entry.value.text.trim();
    }).where((desc) => desc.isNotEmpty).toList();

    final payload = {
      'user_description': userDescriptions,
    };

    final url = Uri.parse(
        'https://fastapi-service-748034725478.europe-west4.run.app/api/submit-differentiation-questions?key=$userId');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );
      print(response);
      if (response.statusCode == 200) {
        print("Gửi thành công!");
        Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => Result()),
      );
      } else {
        print("Lỗi khi gửi dữ liệu: ${response.body}");
      }
    } catch (e) {
      print("Lỗi kết nối: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              controller: widget.scrollController,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  "Câu hỏi phân biệt chẩn đoán",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                ...questions.map((q) => buildQuestionWidget(q)).toList(),
                SizedBox(height: 16),
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
                    onPressed: () {
                      submitAnswers();
                    },
                    child: const Text(
                      "Tiếp theo",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget buildQuestionWidget(String fullQuestion) {
    final index = questions.indexOf(fullQuestion);
    controllers.putIfAbsent(index, () => TextEditingController());

    final RegExp explainRegex = RegExp(r'\((.*?)\)');
    final explanationMatch = explainRegex.firstMatch(fullQuestion);
    final explanation = explanationMatch?.group(1);

    final RegExp titleRegex = RegExp(r'\*\*(.*?)\*\*');
    final titleMatch = titleRegex.firstMatch(fullQuestion);
    final title = titleMatch?.group(1)?.trim();

    String content = fullQuestion
        .replaceAll(RegExp(r'\*\*(.*?)\*\*'), '')
        .replaceAll(RegExp(r'\(.*?\)'), '')
        .trim();

    return Column(
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
        SizedBox(height: 12),
      ],
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
