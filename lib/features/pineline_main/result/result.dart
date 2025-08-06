import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter_application_latn/core/utils/exceptions.dart';
import 'package:flutter_application_latn/features/home/presentation/screens/home_screen.dart';

class Result extends StatefulWidget {
  final String? finalDiagnosis;
  const Result({super.key, this.finalDiagnosis});

  @override
  State<Result> createState() => _ResultState();
}

class _ResultState extends State<Result> {
  Future<List<Map<String, String>>>? futureDiagnoses;
  Future<String>? futureDiseaseInfo;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    futureDiagnoses = fetchDiagnosisList();
    if (widget.finalDiagnosis != null && widget.finalDiagnosis!.isNotEmpty) {
      futureDiseaseInfo = fetchDiseaseDescription(widget.finalDiagnosis!);
    }
  }

  Future<bool> _checkNetworkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  void _showErrorMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<List<Map<String, String>>> fetchDiagnosisList() async {
    try {
      final hasConnection = await _checkNetworkConnectivity();
      if (!hasConnection) {
        if (mounted) {
          _showErrorMessage(
            'Không có kết nối internet. Vui lòng kiểm tra lại.',
          );
        }
        return [];
      }

      final prefs = await SharedPreferences.getInstance();
      final String? userId = prefs.getString('userId');

      if (userId == null || userId.isEmpty) {
        if (mounted) {
          _showErrorMessage(
            'Không tìm thấy thông tin người dùng. Vui lòng đăng nhập lại.',
          );
        }
        return [];
      }

      final url = Uri.parse(
        'https://fastapi-service-748034725478.europe-west4.run.app/api/final-diagnose?key=$userId',
      );

      final response = await http
          .get(url)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw TimeoutException(
                'Yêu cầu lấy kết quả chẩn đoán đã hết thời gian chờ',
              );
            },
          );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;

        if (data['diagnosis'] is List) {
          final List<dynamic> diagnosisList =
              data['diagnosis'] as List<dynamic>;

          return diagnosisList.map<Map<String, String>>((item) {
            return {
              'ketqua': (item['ketqua'] ?? '').toString(),
              'do_phu_hop': (item['do_phu_hop'] ?? '').toString(),
            };
          }).toList();
        } else {
          if (mounted) {
            _showErrorMessage('Dữ liệu không hợp lệ hoặc diagnosis = null');
          }
          return [];
        }
      } else if (response.statusCode == 401) {
        if (mounted) {
          _showErrorMessage(
            'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
          );
        }
        return [];
      } else if (response.statusCode == 404) {
        if (mounted) {
          _showErrorMessage('Không tìm thấy kết quả chẩn đoán.');
        }
        return [];
      } else if (response.statusCode >= 500) {
        if (mounted) {
          _showErrorMessage('Lỗi máy chủ. Vui lòng thử lại sau.');
        }
        return [];
      } else {
        if (mounted) {
          _showErrorMessage('Lỗi kết nối API: ${response.statusCode}');
        }
        return [];
      }
    } on SocketException catch (_) {
      if (mounted) {
        _showErrorMessage(
          'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối internet.',
        );
      }
      return [];
    } on TimeoutException catch (e) {
      if (mounted) {
        _showErrorMessage(
          e.message.isNotEmpty
              ? e.message
              : 'Yêu cầu lấy kết quả chẩn đoán đã hết thời gian chờ',
        );
      }
      return [];
    } on FormatException catch (_) {
      if (mounted) {
        _showErrorMessage('Dữ liệu phản hồi không đúng định dạng');
      }
      return [];
    } catch (e) {
      if (mounted) {
        _showErrorMessage('Lỗi không xác định: $e');
      }
      return [];
    }
  }

  Future<String> fetchDiseaseDescription(String diseaseName) async {
    try {
      final hasConnection = await _checkNetworkConnectivity();
      if (!hasConnection) {
        if (mounted) {
          _showErrorMessage(
            'Không có kết nối internet. Vui lòng kiểm tra lại.',
          );
        }
        return 'Không thể kết nối internet';
      }

      final url = Uri.parse(
        'https://fastapi-service-748034725478.europe-west4.run.app/api/knowledge?disease_name=${Uri.encodeComponent(diseaseName)}',
      );

      final response = await http
          .get(url)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw TimeoutException(
                'Yêu cầu lấy thông tin bệnh học đã hết thời gian chờ',
              );
            },
          );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;

        if (data['disease_info'] is List &&
            (data['disease_info'] as List).isNotEmpty) {
          final info =
              (data['disease_info'] as List)[0] as Map<String, dynamic>;

          final String description = '''
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
${(info['Các loại thuốc'] as List<dynamic>?)?.map((thuoc) {
                final thuocMap = thuoc as Map<String, dynamic>;
                return "- ${thuocMap['Tên thuốc'] ?? 'Không rõ'}: ${thuocMap['Liều lượng'] ?? 'Không rõ'}, thời gian: ${thuocMap['Thời gian sử dụng'] ?? 'Không rõ'}";
              }).join('\n') ?? 'Không có thông tin thuốc'}
''';

          return description;
        } else {
          return 'Không tìm thấy thông tin bệnh học cho bệnh này.';
        }
      } else if (response.statusCode == 404) {
        return 'Không tìm thấy thông tin bệnh học cho bệnh này.';
      } else if (response.statusCode >= 500) {
        return 'Lỗi máy chủ. Vui lòng thử lại sau.';
      } else {
        return 'Lỗi server: ${response.statusCode}';
      }
    } on SocketException catch (_) {
      if (mounted) {
        _showErrorMessage(
          'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối internet.',
        );
      }
      return 'Lỗi kết nối: Không thể kết nối đến máy chủ';
    } on TimeoutException catch (e) {
      if (mounted) {
        _showErrorMessage(
          e.message.isNotEmpty
              ? e.message
              : 'Yêu cầu lấy thông tin bệnh học đã hết thời gian chờ',
        );
      }
      return 'Lỗi kết nối: Yêu cầu đã hết thời gian chờ';
    } on FormatException catch (_) {
      if (mounted) {
        _showErrorMessage('Dữ liệu phản hồi không đúng định dạng');
      }
      return 'Lỗi kết nối: Dữ liệu không hợp lệ';
    } catch (e) {
      if (mounted) {
        _showErrorMessage('Lỗi không xác định: $e');
      }
      return 'Lỗi kết nối: $e';
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
    final bool showWarning = doPhuHop.toLowerCase() != 'cao';
    final Color levelColor = getColorForLevel(doPhuHop);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.local_hospital, color: Colors.teal, size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    ketqua.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF222B45),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
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
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.red,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Kết quả chẩn đoán chỉ mang tính chất tham khảo. Vui lòng tham khảo ý kiến bác sĩ để được tư vấn chính xác.',
                        style: const TextStyle(color: Colors.red, fontSize: 13),
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
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (snapshot.hasError || !snapshot.hasData) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24.0),
        child: Text(
          'Không thể lấy thông tin bệnh học.',
          style: TextStyle(color: Colors.red),
        ),
      );
    }
    final lines = snapshot.data!.split('\n');
    return Card(
      elevation: 6,
      margin: const EdgeInsets.only(bottom: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.medical_information_rounded,
                  color: Colors.teal,
                  size: 28,
                ),
                const SizedBox(width: 10),
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
            const SizedBox(height: 16),
            ...lines.map((line) {
              if (line.trim().isEmpty) return const SizedBox.shrink();
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
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
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
                          style: const TextStyle(
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
      backgroundColor: const Color(0xFFF6FCFB),
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
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
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
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const HomeScreen()),
                      );
                    },
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    label: const Text(
                      'Quay lại',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal[700],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 3,
                    ),
                  ),
                )

              ],
            ),
          ),
        ),
      ),
    );
  }
}
