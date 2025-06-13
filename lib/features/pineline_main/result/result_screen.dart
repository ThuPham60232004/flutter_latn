import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ResultScreen extends StatefulWidget {
  final String diseaseName; 

 const ResultScreen({Key? key, required this.diseaseName}) : super(key: key);

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  Future<String>? futureDescription;

  @override
  void initState() {
    super.initState();
    futureDescription = fetchDiseaseDescription(widget.diseaseName);
  }
 Future<String> fetchDiseaseDescription(String diseaseName) async {
  final url =
      'https://fastapi-service-748034725478.europe-west4.run.app/api/knowledge?disease_name=$diseaseName';

  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final info = data['disease_info'][0];

      String description = '''
  Tên bệnh: ${info['Tên bệnh'] ?? 'Không tìm thấy'}
  Tên khoa học: ${info['Tên khoa học'] ?? 'Không tìm thấy'}
  Triệu chứng: ${info['Triệu chứng'] ?? 'Không tìm thấy'}
  Vị trí xuất hiện: ${info['Vị trí xuất hiện'] ?? 'Không tìm thấy'}
  Nguyên nhân: ${info['Nguyên nhân'] ?? 'Không tìm thấy'}
  Tiêu chí chẩn đoán: ${info['Tiêu chí chẩn đoán'] ?? 'Không tìm thấy'}
  Chẩn đoán phân biệt: ${info['Chẩn đoán phân biệt'] ?? 'Không tìm thấy'}
  Điều trị: ${info['Điều trị'] ?? 'Không tìm thấy'}
  Phòng bệnh: ${info['Phòng bệnh'] ?? 'Không tìm thấy'}

  Thuốc điều trị:
  ${(info['Các loại thuốc'] as List).map((thuoc) {
    return "- ${thuoc['Tên thuốc'] ?? 'Không rõ'}: ${thuoc['Liều lượng'] ?? 'Không rõ'}, thời gian: ${thuoc['Thời gian sử dụng'] ?? 'Không rõ'}";
  }).join('\n')}
  ''';

        return description;
      } else {
        return "Lỗi server: ${response.statusCode}";
      }
    } catch (e) {
      return "Lỗi kết nối: $e";
    }
  }

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
              const Text(
                "Kết quả",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                "Kết quả sẽ không hoàn toàn chính xác",
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 560,
                child: FutureBuilder<String>(
                  future: futureDescription,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text("Lỗi: ${snapshot.error}");
                    } else {
                      return DottedBorder(
                        color: const Color.fromARGB(255, 0, 0, 0),
                        strokeWidth: 1.2,
                        dashPattern: [2, 1],
                        borderType: BorderType.RRect,
                        radius: const Radius.circular(12),
                        padding: const EdgeInsets.all(16),
                        child: SingleChildScrollView(
                          child: Text(
                            snapshot.data ?? "Không có dữ liệu.",
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black87),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
              const Spacer(),
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
                    // TODO: Điều hướng tiếp nếu cần
                  },
                  child: const Text(
                    "Tiếp theo",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
