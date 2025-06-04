import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
class ResultScreen extends StatelessWidget {
  final String resultText = '''
Tên bệnh: Nấm da chân (Tinea Pedis)
Mô tả: Nấm da chân là một bệnh nhiễm nấm thường gặp, gây ra các triệu chứng như ngứa, rát, da nứt nẻ và có vảy, đặc biệt giữa các ngón chân – thường là ngón thứ tư và thứ năm.
Nguyên nhân: Bệnh do nấm gây ra và thường lây lan qua bề mặt ẩm ướt như sàn phòng tắm, hồ bơi hoặc phòng thay đồ.
Chẩn đoán: Thường được xác định qua khám lâm sàng.
Trong một số trường hợp cần thực hiện xét nghiệm cấy da để xác nhận.
Điều trị: Phần lớn các trường hợp có thể điều trị bằng kem chống nấm không kê đơn (OTC), trong khi những trường hợp nặng hơn có thể cần thuốc chống nấm kê đơn theo chỉ định của bác sĩ.
Phòng ngừa: 
– Để phòng bệnh, bạn nên giữ chân sạch sẽ, khô thoáng, thay tất sạch mỗi ngày; không đi chân trần ở nơi công cộng; giữ độ ẩm trong phòng tắm và giặt mùng chiếu chăn định kỳ.
Thuốc điều trị phổ biến gồm:
– Kem chống nấm không kê đơn (OTC): Sử dụng theo hướng dẫn trên nhãn đơn giản khi nhiễm trùng.
– Thuốc chống nấm kê đơn: Dùng theo liều lượng và thời gian do bác sĩ chỉ định.
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: Colors.black),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Kết quả",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Kết quả sẽ không hoàn toàn chính xác",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 20),
                Container(
                        width: double.infinity,
                        height: 560,
                        child: DottedBorder(
                          color: const Color.fromARGB(255, 0, 0, 0),
                          strokeWidth: 1.2,
                          dashPattern: [2, 1],
                          borderType: BorderType.RRect,
                          radius: const Radius.circular(12),
                          padding: const EdgeInsets.all(16),
                          child: SingleChildScrollView(
                              child: Text(
                                resultText,
                                style: TextStyle(fontSize: 14, color: Colors.black87),
                              ),
                          ),
                        ),
                      ),

              Spacer(),
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
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
