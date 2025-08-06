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
  Map<String, dynamic>? _result;
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
      // Call single API that handles both standardization and knowledge retrieval
      final url =
          'https://fastapi-service-748034725478.europe-west4.run.app/api/knowledge/translate?disease_name=${Uri.encodeComponent(diseaseName)}';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Check if we have standardized name in response
        if (data['standardized_name'] != null) {
          setState(() {
            _standardizedName = data['standardized_name'];
          });
        }
        
        if (data['disease_info'] == null || data['disease_info'].isEmpty) {
          setState(() {
            _error = 'Không tìm thấy thông tin bệnh.';
            _isLoading = false;
          });
          return;
        }
        final info = data['disease_info'][0];
        setState(() {
          _result = info;
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

  Widget _buildDiseaseInfo(Map<String, dynamic> info) {
    final List<Widget> widgets = [];
    
    // Helper function to add section if data exists
    void addSection(String title, String? data) {
      if (data != null && data.isNotEmpty && data != 'Không tìm thấy') {
        widgets.add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                data,
                style: const TextStyle(fontSize: 15, height: 1.4),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      }
    }
    
    // Add sections with data
    addSection('Tên bệnh', info['Tên bệnh']);
    addSection('Tên khoa học', info['Tên khoa học']);
    addSection('Triệu chứng', info['Triệu chứng']);
    addSection('Vị trí xuất hiện', info['Vị trí xuất hiện']);
    addSection('Nguyên nhân', info['Nguyên nhân']);
    addSection('Tiêu chí chẩn đoán', info['Tiêu chí chẩn đoán']);
    addSection('Chẩn đoán phân biệt', info['Chẩn đoán phân biệt']);
    addSection('Điều trị', info['Điều trị']);
    addSection('Phòng bệnh', info['Phòng bệnh']);
    
    // Handle medications
    if (info['Các loại thuốc'] is List && (info['Các loại thuốc'] as List).isNotEmpty) {
      widgets.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thuốc điều trị',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 8),
            ...(info['Các loại thuốc'] as List).map<Widget>((thuoc) {
              final tenThuoc = thuoc['Tên thuốc'] ?? 'Không rõ';
              final lieuLuong = thuoc['Liều lượng'] ?? 'Không rõ';
              final thoiGian = thuoc['Thời gian sử dụng'] ?? 'Không rõ';
              
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• $tenThuoc',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Liều lượng: $lieuLuong',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      'Thời gian sử dụng: $thoiGian',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
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
                      child: _buildDiseaseInfo(_result!),
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
