import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_application_latn/features/pineline_main/result/result_screen.dart';

class GetResult extends StatefulWidget {
  @override
  _GetResultState createState() => _GetResultState();
}

class _GetResultState extends State<GetResult> {
  Future<String>? futureResult;
  String? diseaseName;

  @override
  void initState() {
    super.initState();
    futureResult = getResultFromAPI();
  }

  String formatKetQua(String raw) {
    return raw.replaceAll(RegExp(r'[,\s\-]+'), '');
  }

  Future<String> getResultFromAPI() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('_id');

    if (userId == null) {
      return "Không tìm thấy ID người dùng.";
    }

    final url =
        'https://fastapi-service-748034725478.europe-west4.run.app/api/diagnosis/result?key=$userId';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // final rawKetQua = data['ketqua'] ?? '';
        final rawKetQua = "i, m, p, e, t, i, g, o ";
        final cleaned = formatKetQua(rawKetQua);
        diseaseName = cleaned;
        return "Tên bệnh: $cleaned";
      } else {
        return "Lỗi server: ${response.statusCode}";
      }
    } catch (e) {
      return "Lỗi kết nối: $e";
    }
  }

  void navigateToResultScreen() {
    if (diseaseName != null && diseaseName!.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(diseaseName: diseaseName!),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Dữ liệu chưa sẵn sàng hoặc không hợp lệ")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
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
                height: 250,
                width: double.infinity,
                child: FutureBuilder<String>(
                  future: futureResult,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text("Lỗi: ${snapshot.error}");
                    } else {
                      return DottedBorder(
                        color: Colors.black,
                        strokeWidth: 1.2,
                        dashPattern: [2, 1],
                        borderType: BorderType.RRect,
                        radius: const Radius.circular(12),
                        padding: const EdgeInsets.all(16),
                        child: SingleChildScrollView(
                          child: Text(
                            snapshot.data ?? "Không có dữ liệu",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
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
                  onPressed: navigateToResultScreen,
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
