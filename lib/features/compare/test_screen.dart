import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/compare_service.dart';
import 'models/compare_model.dart';

class ProcessListScreen extends StatefulWidget {
  const ProcessListScreen({super.key});

  @override
  State<ProcessListScreen> createState() => _ProcessListScreenState();
}

class _ProcessListScreenState extends State<ProcessListScreen> {
  List<CompareProcess> processes = [];
  CompareResult? result;
  String? _userId;
  double _sliderValue = 0.5;
  bool _isLoading = false;
  bool _isCreatingProcess = false;
  bool _isUpdatingProcess = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  // Lấy user_id từ SharedPreferences
  Future<void> _loadUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId') ?? prefs.getString('_id');
      if (userId == null || userId.isEmpty) {
        throw Exception('Không tìm thấy userId trong SharedPreferences');
      }
      
      setState(() {
        _userId = userId;
        _errorMessage = null;
      });
      
      // Sau khi có user_id, fetch danh sách tiến trình
      await _fetchProcesses();
    } catch (e) {
      setState(() {
        _errorMessage = "Không thể tải thông tin người dùng: $e";
      });
    }
  }

  Future<void> _fetchProcesses() async {
    if (_userId == null) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Sử dụng API thực
      final processesList = await CompareService.getUserProcesses(_userId!);
      setState(() {
        processes = processesList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Không thể tải danh sách tiến trình: $e";
        _isLoading = false;
      });
    }
  }

  Future<void> _createProcess() async {
    if (_userId == null) return;
    
    setState(() {
      _isCreatingProcess = true;
      _errorMessage = null;
    });

    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      
      if (picked != null) {
        final file = File(picked.path);
        // Sử dụng API thực
        final process = await CompareService.uploadInitialImage(
          userId: _userId!,
          imageFile: file,
        );
        setState(() {
          processes.add(process);
          _isCreatingProcess = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tạo tiến trình mới thành công!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() {
          _isCreatingProcess = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Không thể tạo tiến trình: $e";
        _isCreatingProcess = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updateProcess(String processId) async {
    if (_userId == null) return;
    
    setState(() {
      _isUpdatingProcess = true;
      _errorMessage = null;
    });

    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      
      if (picked != null) {
        final file = File(picked.path);
        // Sử dụng API thực
        final compare = await CompareService.compareImages(
          userId: _userId!,
          processId: processId,
          imageFile: file,
        );
        setState(() {
          result = compare;
          _isUpdatingProcess = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('So sánh ảnh thành công!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() {
          _isUpdatingProcess = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Không thể so sánh ảnh: $e";
        _isUpdatingProcess = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteProcess(String processId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa tiến trình này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Sử dụng API thực
        final success = await CompareService.deleteProcess(processId);
        if (success) {
          setState(() {
            processes.removeWhere((p) => p.id == processId);
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã xóa tiến trình thành công'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi xóa: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildCompareResult() {
    if (result == null) return const SizedBox();
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.compare_arrows, color: Colors.teal.shade600),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  "Kết quả so sánh",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: Colors.black87,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    result = null;
                  });
                },
                icon: Icon(Icons.close, color: Colors.grey.shade600),
                tooltip: 'Đóng kết quả so sánh',
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 280,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  return Stack(
                    children: [
                      Row(
                        children: [
                          ClipRect(
                            child: Align(
                              alignment: Alignment.centerRight,
                              widthFactor: 1 - _sliderValue,
                              child: Image.network(
                                result!.firstImage,
                                fit: BoxFit.cover,
                                width: width,
                                height: 280,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: width,
                                    height: 280,
                                    color: Colors.grey.shade200,
                                    child: const Icon(Icons.image_not_supported, size: 50),
                                  );
                                },
                              ),
                            ),
                          ),
                          ClipRect(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              widthFactor: _sliderValue,
                              child: Image.network(
                                result!.latestImage,
                                fit: BoxFit.cover,
                                width: width,
                                height: 280,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: width,
                                    height: 280,
                                    color: Colors.grey.shade200,
                                    child: const Icon(Icons.image_not_supported, size: 50),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        left: width * _sliderValue - 2,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: 4,
                          decoration: BoxDecoration(
                            color: Colors.teal,
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.teal.withOpacity(0.5),
                                blurRadius: 4,
                                offset: const Offset(0, 0),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.teal.shade600,
              inactiveTrackColor: Colors.grey.shade300,
              thumbColor: Colors.teal.shade600,
              overlayColor: Colors.teal.shade200,
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            ),
            child: Slider(
              value: _sliderValue,
              onChanged: (v) => setState(() => _sliderValue = v),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.image, color: Colors.blue.shade600, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    "Trước",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Text(
                    "Sau",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.image, color: Colors.green.shade600, size: 20),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProcessCard(CompareProcess process, int index) {
    final String? status = process.status;
    final bool isKnownStatus = status == 'processing' || status == 'completed' || status == 'failed';
    final String knownStatus = status ?? 'processing';
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(20),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.teal.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: process.imageUrls.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    process.imageUrls.first,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.photo_library,
                        color: Colors.teal.shade600,
                        size: 30,
                      );
                    },
                  ),
                )
              : Icon(
                  Icons.photo_library,
                  color: Colors.teal.shade600,
                  size: 30,
                ),
        ),
        title: Text(
          "Tiến trình ${index + 1}",
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              "Số lượng ảnh: ${process.imageUrls.length}",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            if (isKnownStatus)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(knownStatus).shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getStatusText(knownStatus),
                  style: TextStyle(
                    color: _getStatusColor(knownStatus).shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: Icon(Icons.edit, color: Colors.blue.shade600),
                onPressed: _isUpdatingProcess ? null : () => _updateProcess(process.id),
                tooltip: 'Cập nhật',
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: Icon(Icons.delete, color: Colors.red.shade600),
                onPressed: () => _deleteProcess(process.id),
                tooltip: 'Xóa',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            "Chưa có tiến trình nào",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Tạo tiến trình mới để bắt đầu so sánh ảnh",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            "Đã xảy ra lỗi",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.red.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? "Không thể tải dữ liệu",
            style: TextStyle(
              fontSize: 14,
              color: Colors.red.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _fetchProcesses,
            icon: const Icon(Icons.refresh),
            label: const Text("Thử lại"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red.shade700,
            ),
          ),
        ],
      ),
    );
  }

  MaterialColor _getStatusColor(String status) {
    switch (status) {
      case "processing":
        return Colors.blue;
      case "completed":
        return Colors.green;
      case "failed":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case "processing":
        return "Đang xử lý";
      case "completed":
        return "Hoàn tất";
      case "failed":
        return "Thất bại";
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "Danh sách tiến trình",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          if (_errorMessage != null && processes.isEmpty)
            _buildErrorState()
          else if (_isLoading)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.teal),
                    SizedBox(height: 16),
                    Text("Đang tải..."),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: processes.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: processes.length,
                      itemBuilder: (context, index) => _buildProcessCard(processes[index], index),
                    ),
            ),
          if (result != null) _buildCompareResult(),
        ],
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(
          bottom: result != null ? 320.0 : 16.0, // Adjust padding when comparison result is shown
        ),
        child: FloatingActionButton.extended(
          onPressed: _isCreatingProcess ? null : _createProcess,
          backgroundColor: Colors.teal.shade600,
          foregroundColor: Colors.white,
          icon: _isCreatingProcess
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.add_a_photo),
          label: Text(_isCreatingProcess ? "Đang tạo..." : "Tạo tiến trình"),
          elevation: 4,
        ),
      ),
    );
  }
}
