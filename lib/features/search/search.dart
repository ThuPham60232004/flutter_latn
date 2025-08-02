import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DiseaseSearchScreen extends StatefulWidget {
  const DiseaseSearchScreen({Key? key}) : super(key: key);

  @override
  State<DiseaseSearchScreen> createState() => _DiseaseSearchScreenState();
}

class _DiseaseSearchScreenState extends State<DiseaseSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String? _result;
  String? _standardizedName;
  bool _isLoading = false;
  String? _error;

  Future<void> _searchDisease() async {
    final diseaseName = _controller.text.trim();
    if (diseaseName.isEmpty) {
      setState(() {
        _error = 'Vui lòng nhập tên bệnh.';
        _result = null;
        _standardizedName = null;
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
      _result = null;
      _standardizedName = null;
    });
    try {
      // Step 1: Standardize disease name
      final standardizeUrl =
          'https://fastapi-service-748034725478.europe-west4.run.app/api/generate-disease-name?disease_name=${Uri.encodeComponent(diseaseName)}';
      final standardizeResponse = await http.get(Uri.parse(standardizeUrl));
      if (standardizeResponse.statusCode != 200) {
        setState(() {
          _error = 'Lỗi chuẩn hóa tên bệnh: ${standardizeResponse.statusCode}';
          _isLoading = false;
        });
        return;
      }
      final standardizedName = json.decode(standardizeResponse.body) as String;
      if (standardizedName.isEmpty) {
        setState(() {
          _error = 'Không thể chuẩn hóa tên bệnh.';
          _isLoading = false;
        });
        return;
      }
      setState(() {
        _standardizedName = standardizedName;
      });
      // Step 2: Query knowledge API with standardized name
      final url =
          'https://fastapi-service-748034725478.europe-west4.run.app/api/knowledge?disease_name=${Uri.encodeComponent(standardizedName)}';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['disease_info'] == null || data['disease_info'].isEmpty) {
          setState(() {
            _error = 'Không tìm thấy thông tin bệnh.';
            _isLoading = false;
          });
          return;
        }
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

Thuốc điều trị:\n''';
        if (info['Các loại thuốc'] is List) {
          for (final thuoc in info['Các loại thuốc']) {
            description +=
                "- ${thuoc['Tên thuốc'] ?? 'Không rõ'}: ${thuoc['Liều lượng'] ?? 'Không rõ'}, thời gian: ${thuoc['Thời gian sử dụng'] ?? 'Không rõ'}\n";
          }
        }
        setState(() {
          _result = description;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Lỗi server: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Lỗi kết nối: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tra cứu bệnh'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.06),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Nhập tên bệnh',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _controller.clear(),
                ),
              ),
              onSubmitted: (_) => _searchDisease(),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _searchDisease,
              icon: const Icon(Icons.search),
              label: const Text('Tra cứu'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            if (_standardizedName != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Chip(
                    label: Text(
                      'Tên chuẩn hóa: $_standardizedName',
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.teal,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            if (_isLoading) const Center(child: CircularProgressIndicator()),
            if (_error != null)
              Text(
                _error!,
                style: const TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            if (_result != null)
              Expanded(
                child: SingleChildScrollView(
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Text(
                        _result!,
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
