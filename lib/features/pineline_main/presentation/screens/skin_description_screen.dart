import 'package:flutter/material.dart';

class SkinDescriptionForm extends StatelessWidget {
  final ScrollController scrollController;

  SkinDescriptionForm({required this.scrollController});

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
        controller: scrollController,
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
          _BulletText("Bạn có thể mô tả rõ hơn các vị trí trên cơ thể nơi tổn thương da bắt đầu xuất hiện hoặc đang hiện diện?"),
          customMultilineInput(hint: "Ví dụ, tổn thương có thể khu trú ở những vùng cụ thể như trán, hai bên má, da đầu, sau gáy, vùng cổ, ngực, lưng, bụng, khuỷu tay, đầu gối, cổ tay, mu bàn tay, lòng bàn chân, hoặc những vùng da có nếp gấp như nách, bẹn, hay quanh cơ quan sinh dục. Vui lòng mô tả càng chi tiết càng tốt (ví dụ: mặt ngoài khuỷu tay trái, vùng da sau tai phải, hay kẽ ngón chân cái...')'"),
          _BulletText("Bạn bắt đầu nhận thấy các dấu hiệu tổn thương da hoặc triệu chứng bất thường từ khi nào?  Tình trạng này đã kéo dài bao lâu – tính từ thời điểm xuất hiện đầu tiên đến hiện tại?"),
          customMultilineInput(
           hint: '''Ví dụ: khoảng 3 ngày, gần 2 tuần, hơn 1 tháng, hoặc nhiều năm nếu đã tái phát nhiều lần. Nếu không nhớ chính xác, bạn có thể ước lượng khoảng thời gian gần đúng.'''
          ),
          _BulletText("Bạn có thể mô tả đặc điểm bên ngoài của tổn thương da mà bạn đang gặp phải không?"),
          customMultilineInput(hint:"Hình dạng và biểu hiện của tổn thương có thể bao gồm các hiện tượng như da đỏ, sưng nề, nổi mẩn, bong vảy, mụn nước, đóng vảy tiết, loét, dày da, thay đổi sắc tố (sạm hoặc trắng), ngứa hoặc đau... Nếu có nhiều biểu hiện, bạn có thể liệt kê tất cả những gì mình quan sát được."),
          _BulletText("Khi bị tổn thương da, bạn cảm nhận được những cảm giác như thế nào tại vùng da đó? Tình trạng này có gây ngứa, đau rát, châm chích, nóng, căng tức, nhạy cảm khi chạm vào, hay hoàn toàn không gây khó chịu?"),
          customMultilineInput(hint:"Nếu cảm giác thay đổi theo thời gian (ví dụ: lúc đầu ngứa, sau đó rát), bạn cũng có thể mô tả chi tiết hơn."),
          _BulletText("Tình trạng tổn thương da hiện tại có lan rộng ra so với vị trí ban đầu không? Bạn có nhận thấy tổn thương lan rộng theo thời gian không?"),
          customMultilineInput(hint:"Ví dụ, tổn thương có thể bắt đầu ở một vùng nhỏ rồi lan ra các vùng lân cận, đối xứng hai bên cơ thể, hoặc thậm chí lan khắp người. Ngược lại, cũng có thể tổn thương chỉ khu trú ở một vùng cố định và không thay đổi nhiều về diện tích. "),
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
              onPressed: () {},
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
}
Widget customMultilineInput({required String hint}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    child: TextField(
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
      padding: const EdgeInsets.symmetric(horizontal: 11,vertical: 8.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 17, color: Colors.black87,fontWeight: FontWeight.bold),
      ),
    );
  }
}
