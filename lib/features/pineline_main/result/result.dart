import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Result extends StatefulWidget {
  final String? finalDiagnosis;
  Result({this.finalDiagnosis});

  @override
  _ResultState createState() => _ResultState();
}

class _ResultState extends State<Result> {
  Future<List<Map<String, String>>>? futureDiagnoses;
  Future<String>? futureDiseaseInfo;

  @override
  void initState() {
    super.initState();
    futureDiagnoses = fetchDiagnosisList();
    if (widget.finalDiagnosis != null && widget.finalDiagnosis!.isNotEmpty) {
      futureDiseaseInfo = fetchDiseaseDescription(widget.finalDiagnosis!);
    }
  }

  Future<List<Map<String, String>>> fetchDiagnosisList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('_id');

    if (userId == null) return [];

    final url =
        'https://fastapi-service-748034725478.europe-west4.run.app/api/final-diagnose?key=$userId';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is Map<String, dynamic> && data['diagnosis'] is List) {
          final List<dynamic> diagnosisList = data['diagnosis'];

          return diagnosisList.map<Map<String, String>>((item) {
            return {
              'ketqua': item['ketqua'].toString(),
              'do_phu_hop': item['do_phu_hop'].toString(),
            };
          }).toList();
        } else {
          print('Dữ liệu không hợp lệ hoặc diagnosis = null');
          return [];
        }
      } else {
        print('Mã lỗi HTTP:  {response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Lỗi kết nối: $e');
      return [];
    }
  }

  Future<String> fetchDiseaseDescription(String diseaseName) async {
    final url =
        'https://fastapi-service-748034725478.europe-west4.run.app/api/knowledge?disease_name=${Uri.encodeComponent(diseaseName)}';

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
        return "Lỗi server:  {response.statusCode}";
      }
    } catch (e) {
      return "Lỗi kết nối: $e";
    }
  }

  Color getColorForLevel(String level) {
    switch (level.toLowerCase()) {
      case 'cao':
        return Colors.green;
      case 'trung bình':
        return Colors.orange;
      case 'thấp':
      default:
        return Colors.red;
    }
  }

  Widget buildDiagnosisCard(String ketqua, String doPhuHop) {
    bool showWarning = doPhuHop.toLowerCase() != 'cao';
    final levelColor = getColorForLevel(doPhuHop);

    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_hospital, color: Colors.teal, size: 28),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    ketqua.toUpperCase(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF222B45),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: levelColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    doPhuHop.toUpperCase(),
                    style: TextStyle(
                      color: levelColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (showWarning)
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.red,
                      size: 18,
                    ),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Kết quả chẩn đoán chỉ mang tính chất tham khảo. Vui lòng tham khảo ý kiến bác sĩ để được tư vấn chính xác.',
                        style: TextStyle(color: Colors.red, fontSize: 13),
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

  Widget buildDiseaseInfoSection(AsyncSnapshot<String> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (snapshot.hasError || !snapshot.hasData) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Text(
          'Không thể lấy thông tin bệnh học.',
          style: TextStyle(color: Colors.red),
        ),
      );
    }
    final lines = snapshot.data!.split('\n');
    return Card(
      elevation: 6,
      margin: EdgeInsets.only(bottom: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.medical_information_rounded,
                  color: Colors.teal,
                  size: 28,
                ),
                SizedBox(width: 10),
                Text(
                  'Thông tin bệnh học',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ...lines.map((line) {
              if (line.trim().isEmpty) return SizedBox.shrink();
              if (line.startsWith('Thuốc điều trị:')) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    "💊 ${line.trim()}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.teal[900],
                    ),
                  ),
                );
              }
              if (line.startsWith("-")) {
                return Padding(
                  padding: const EdgeInsets.only(left: 12.0, bottom: 4),
                  child: Text(
                    line,
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                );
              }
              if (line.contains(':')) {
                final parts = line.split(':');
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: RichText(
                    text: TextSpan(
                      text: "${parts[0]}: ",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.teal[700],
                      ),
                      children: [
                        TextSpan(
                          text: parts.sublist(1).join(':').trim(),
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return Text(line);
            }).toList(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6FCFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leading: BackButton(color: Colors.teal[800]),
        title: Text(
          "Kết quả chẩn đoán",
          style: TextStyle(
            color: Colors.teal[900],
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (futureDiseaseInfo != null)
                  FutureBuilder<String>(
                    future: futureDiseaseInfo,
                    builder:
                        (context, snapshot) =>
                            buildDiseaseInfoSection(snapshot),
                  ),
                SizedBox(height: 24),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    label: Text(
                      'Quay lại',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal[700],
                      padding: EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
