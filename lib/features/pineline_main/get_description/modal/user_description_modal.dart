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

class _User_Description_ModalState extends State<User_Description_Modal> {
  final TextEditingController positionController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  final TextEditingController appearanceController = TextEditingController();
  final TextEditingController sensationController = TextEditingController();
  final TextEditingController spreadController = TextEditingController();

Future<void> submitDescription() async {
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

      print("Dữ liệu gửi: $userDescription");

    if (response.statusCode == 200) {
      print('Gửi mô tả thành công!');

      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => Differentiation_Question()),
      );
    } else {
      print('Gửi thất bại: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    print('⚠️ Lỗi khi gửi: $e');
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
      child: ListView(
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
            "Mô tả chi tiết tổn thương da",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          _BulletText("Bạn có thể mô tả rõ hơn vị trí tổn thương?"),
          customMultilineInput(hint: "Ví dụ, tổn thương có thể khu trú ở những vùng cụ thể như trán, hai bên má, da đầu, sau gáy, vùng cổ, ngực, lưng, bụng, khuỷu tay, đầu gối, cổ tay, mu bàn tay, lòng bàn chân, hoặc những vùng da có nếp gấp như nách, bẹn, hay quanh cơ quan sinh dục. Vui lòng mô tả càng chi tiết càng tốt (ví dụ: mặt ngoài khuỷu tay trái, vùng da sau tai phải, hay kẽ ngón chân cái...')'", controller: positionController),
          _BulletText("Tình trạng này kéo dài bao lâu?"),
          customMultilineInput(hint: "Bạn bắt đầu nhận thấy các dấu hiệu tổn thương da hoặc triệu chứng bất thường từ khi nào?  Tình trạng này đã kéo dài bao lâu – tính từ thời điểm xuất hiện đầu tiên đến hiện tại?", controller: durationController),
          _BulletText("Đặc điểm bên ngoài tổn thương?"),
          customMultilineInput(hint: "Hình dạng và biểu hiện của tổn thương có thể bao gồm các hiện tượng như da đỏ, sưng nề, nổi mẩn, bong vảy, mụn nước, đóng vảy tiết, loét, dày da, thay đổi sắc tố (sạm hoặc trắng), ngứa hoặc đau... Nếu có nhiều biểu hiện, bạn có thể liệt kê tất cả những gì mình quan sát được.", controller: appearanceController),
          _BulletText("Cảm giác tại vùng da tổn thương?"),
          customMultilineInput(hint: "Nếu cảm giác thay đổi theo thời gian (ví dụ: lúc đầu ngứa, sau đó rát), bạn cũng có thể mô tả chi tiết hơn.", controller: sensationController),
          _BulletText("Tổn thương có lan rộng không?"),
          customMultilineInput(hint: "Ví dụ, tổn thương có thể bắt đầu ở một vùng nhỏ rồi lan ra các vùng lân cận, đối xứng hai bên cơ thể, hoặc thậm chí lan khắp người. Ngược lại, cũng có thể tổn thương chỉ khu trú ở một vùng cố định và không thay đổi nhiều về diện tích. ", controller: spreadController),
          SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            onPressed: submitDescription,
            child: const Text("Tiếp theo", style: TextStyle(fontSize: 16, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

Widget customMultilineInput({required String hint, required TextEditingController controller}) {
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

class _BulletText extends StatelessWidget {
  final String text;
  const _BulletText(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 17, color: Colors.black87, fontWeight: FontWeight.bold),
      ),
    );
  }
}
