import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Result extends StatefulWidget {
  @override
  _ResultState createState() => _ResultState();
}

class _ResultState extends State<Result> {
  Future<List<Map<String, String>>>? futureDiagnoses;

  @override
  void initState() {
    super.initState();
    futureDiagnoses = fetchDiagnosisList();
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
        print('Mã lỗi HTTP: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Lỗi kết nối: $e');
      return [];
    }
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

    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Color(0xFFB2DFDB).withOpacity(0.3),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 16,
            color: Color(0xFF199A8E).withOpacity(0.08),
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ketqua.toUpperCase(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF222B45),
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Độ phù hợp: ',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
              if (showWarning) ...[
                SizedBox(width: 30),
                Tooltip(
                  message:
                      'Kết quả chẩn đoán chỉ mang tính chất tham khảo.\nVui lòng tham khảo ý kiến bác sĩ để được tư vấn chính xác.',
                  textStyle: TextStyle(color: Colors.white),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.red,
                        size: 15,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Cảnh báo',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.grey.shade100,
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Hủy bỏ',
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) {
                        return Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: FutureBuilder<String>(
                            future: fetchDiseaseDescription(ketqua),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: SizedBox(
                                    height: 100,
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                );
                              } else {
                                final textLines =
                                    snapshot.data?.split('\n') ??
                                    ['Không có dữ liệu'];

                                return Container(
                                  padding: EdgeInsets.all(20),
                                  constraints: BoxConstraints(maxHeight: 600),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.medical_information_rounded,
                                            color: Color(0xFF199A8E),
                                            size: 24,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Thông tin bệnh học',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF222B45),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 16),
                                      Expanded(
                                        child: SingleChildScrollView(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children:
                                                textLines.map((line) {
                                                  if (line.trim().isEmpty)
                                                    return SizedBox.shrink();
                                                  if (line.startsWith(
                                                    "Thuốc điều trị:",
                                                  )) {
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            vertical: 8.0,
                                                          ),
                                                      child: Text(
                                                        "💊 ${line.trim()}",
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 15,
                                                          color: Color(
                                                            0xFF222B45,
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                  if (line.startsWith("-")) {
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            left: 12.0,
                                                            bottom: 4,
                                                          ),
                                                      child: Text(
                                                        line,
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: Color(
                                                            0xFF6B7280,
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                  if (line.contains(':')) {
                                                    final parts = line.split(
                                                      ':',
                                                    );
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            vertical: 6.0,
                                                          ),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          RichText(
                                                            text: TextSpan(
                                                              text:
                                                                  "${parts[0]}: ",
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 15,
                                                                color: Color(
                                                                  0xFF222B45,
                                                                ),
                                                              ),
                                                              children: [
                                                                TextSpan(
                                                                  text:
                                                                      parts
                                                                          .sublist(
                                                                            1,
                                                                          )
                                                                          .join(
                                                                            ':',
                                                                          )
                                                                          .trim(),
                                                                  style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .normal,
                                                                    fontSize:
                                                                        14,
                                                                    color: Color(
                                                                      0xFF6B7280,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Divider(
                                                            height: 16,
                                                            color: Color(
                                                              0xFFB2DFDB,
                                                            ).withOpacity(0.3),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  }
                                                  return Text(line);
                                                }).toList(),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                      ElevatedButton.icon(
                                        onPressed:
                                            () => Navigator.of(context).pop(),
                                        icon: Icon(
                                          Icons.close,
                                          color: Colors.white,
                                        ),
                                        label: Text(
                                          'Đóng',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xFF199A8E),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                          ),
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF179B8E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Xem thông tin',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE0F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: BackButton(color: Colors.black),
        title: Text(
          "Kết quả chẩn đoán",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: FutureBuilder<List<Map<String, String>>>(
            future: futureDiagnoses,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Text(
                    "Không có dữ liệu chẩn đoán.",
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                  ),
                );
              }

              final diagnoses = snapshot.data!;
              return ListView.builder(
                itemCount: diagnoses.length,
                itemBuilder: (context, index) {
                  final item = diagnoses[index];
                  return buildDiagnosisCard(
                    item['ketqua']!,
                    item['do_phu_hop']!,
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
