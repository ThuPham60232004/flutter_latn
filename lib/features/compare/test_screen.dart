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

class _ProcessListScreenState extends State<ProcessListScreen>
    with TickerProviderStateMixin {
  List<CompareProcess> processes = [];
  CompareResult? result;
  String? _userId;
  double _sliderValue = 0.5;
  bool _isLoading = false;
  bool _isCreatingProcess = false;
  bool _isUpdatingProcess = false;
  String? _errorMessage;

  AnimationController? _fadeController;
  AnimationController? _slideController;
  Animation<double>? _fadeAnimation;
  Animation<Offset>? _slideAnimation;

  @override
  void initState() {
    super.initState();
    _loadUserId();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController!, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController!, curve: Curves.easeOutCubic),
    );

    _fadeController?.forward();
    _slideController?.forward();
  }

  @override
  void dispose() {
    _fadeController?.dispose();
    _slideController?.dispose();
    super.dispose();
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
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                const Text('Tạo tiến trình thành công!'),
              ],
            ),
            backgroundColor: const Color(0xFF19C3AE),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      } else {
        setState(() {
          _isCreatingProcess = false;
        });
      }
    } catch (e) {
      setState(() {
        _isCreatingProcess = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text('Lỗi tạo tiến trình: $e')),
            ],
          ),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
        final compareResult = await CompareService.compareImages(
          userId: _userId!,
          processId: processId,
          imageFile: file,
        );

        setState(() {
          result = compareResult;
          _isUpdatingProcess = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                const Text('Cập nhật tiến trình thành công!'),
              ],
            ),
            backgroundColor: const Color(0xFF19C3AE),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      } else {
        setState(() {
          _isUpdatingProcess = false;
        });
      }
    } catch (e) {
      setState(() {
        _isUpdatingProcess = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text('Lỗi cập nhật tiến trình: $e')),
            ],
          ),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Future<void> _deleteProcess(String processId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.warning, color: Colors.orange.shade600),
                const SizedBox(width: 12),
                const Text('Xác nhận xóa'),
              ],
            ),
            content: const Text(
              'Bạn có chắc chắn muốn xóa tiến trình này không? Hành động này không thể hoàn tác.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Hủy',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
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
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  const Text('Đã xóa tiến trình thành công'),
                ],
              ),
              backgroundColor: const Color(0xFF19C3AE),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Lỗi khi xóa: $e')),
              ],
            ),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Widget _buildCompareResult() {
    if (result == null) return const SizedBox();

    return FadeTransition(
      opacity: _fadeAnimation ?? const AlwaysStoppedAnimation(1.0),
      child: SlideTransition(
        position: _slideAnimation ?? const AlwaysStoppedAnimation(Offset.zero),
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, const Color(0xFFF8FFFE)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF19C3AE).withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF19C3AE).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.compare_arrows,
                      color: Color(0xFF19C3AE),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      "Kết quả so sánh",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Color(0xFF2D3748),
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
              const SizedBox(height: 24),
              Container(
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
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
                                    height: 300,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: width,
                                        height: 300,
                                        color: Colors.grey.shade200,
                                        child: const Icon(
                                          Icons.image_not_supported,
                                          size: 50,
                                        ),
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
                                    height: 300,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: width,
                                        height: 300,
                                        color: Colors.grey.shade200,
                                        child: const Icon(
                                          Icons.image_not_supported,
                                          size: 50,
                                        ),
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
                                color: const Color(0xFF19C3AE),
                                borderRadius: BorderRadius.circular(2),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF19C3AE,
                                    ).withOpacity(0.5),
                                    blurRadius: 8,
                                    offset: const Offset(0, 0),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            left: width * _sliderValue - 15,
                            top: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF19C3AE),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'So sánh',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
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
                  activeTrackColor: const Color(0xFF19C3AE),
                  inactiveTrackColor: Colors.grey.shade300,
                  thumbColor: const Color(0xFF19C3AE),
                  overlayColor: const Color(0xFF19C3AE).withOpacity(0.2),
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 8,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 16,
                  ),
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
                          color: Color(0xFF2D3748),
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
                          color: Color(0xFF2D3748),
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
        ),
      ),
    );
  }

  Widget _buildProcessCard(CompareProcess process, int index) {
    return FadeTransition(
      opacity: _fadeAnimation ?? const AlwaysStoppedAnimation(1.0),
      child: SlideTransition(
        position: _slideAnimation ?? const AlwaysStoppedAnimation(Offset.zero),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, const Color(0xFFF8FFFE)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF19C3AE).withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Process Image
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF19C3AE).withOpacity(0.2),
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child:
                            process.imageUrls.isNotEmpty
                                ? Image.network(
                                  process.imageUrls.first,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey.shade200,
                                      child: const Icon(
                                        Icons.image_not_supported,
                                        color: Colors.grey,
                                        size: 30,
                                      ),
                                    );
                                  },
                                )
                                : Container(
                                  color: Colors.grey.shade200,
                                  child: const Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey,
                                    size: 30,
                                  ),
                                ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Process Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(
                                    process.status ?? 'pending',
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _getStatusText(process.status ?? 'pending'),
                                  style: TextStyle(
                                    color: _getStatusColor(
                                      process.status ?? 'pending',
                                    ),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                'ID: ${process.id.substring(0, 8)}...',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tiến trình ${index + 1}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (process.createdAt != null)
                            Text(
                              'Tạo lúc: ${_formatDate(process.createdAt!)}',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          const SizedBox(height: 8),
                          Text(
                            '${process.imageUrls.length} ảnh đã tải',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Action Buttons
              Container(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF19C3AE).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.edit,
                          color: const Color(0xFF19C3AE),
                          size: 20,
                        ),
                        onPressed:
                            _isUpdatingProcess
                                ? null
                                : () => _updateProcess(process.id),
                        tooltip: 'Cập nhật',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: Colors.red.shade400,
                          size: 20,
                        ),
                        onPressed: () => _deleteProcess(process.id),
                        tooltip: 'Xóa',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return FadeTransition(
      opacity: _fadeAnimation ?? const AlwaysStoppedAnimation(1.0),
      child: SlideTransition(
        position: _slideAnimation ?? const AlwaysStoppedAnimation(Offset.zero),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF19C3AE).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.photo_library_outlined,
                  size: 64,
                  color: const Color(0xFF19C3AE),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Chưa có tiến trình nào",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Tạo tiến trình mới để bắt đầu so sánh ảnh",
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return FadeTransition(
      opacity: _fadeAnimation ?? const AlwaysStoppedAnimation(1.0),
      child: SlideTransition(
        position: _slideAnimation ?? const AlwaysStoppedAnimation(Offset.zero),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red.shade400,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Đã xảy ra lỗi",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _errorMessage ?? "Không thể tải dữ liệu",
                style: TextStyle(fontSize: 16, color: Colors.red.shade500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _fetchProcesses,
                icon: const Icon(Icons.refresh),
                label: const Text("Thử lại"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red.shade700,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
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
        return "Chờ xử lý";
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: AppBar(
        title: const Text(
          "Danh sách tiến trình",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF19C3AE),
        elevation: 0,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchProcesses,
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          if (_errorMessage != null && processes.isEmpty)
            Expanded(child: _buildErrorState())
          else if (_isLoading)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF19C3AE),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Đang tải...",
                      style: TextStyle(fontSize: 16, color: Color(0xFF2D3748)),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child:
                  processes.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: processes.length,
                        itemBuilder:
                            (context, index) =>
                                _buildProcessCard(processes[index], index),
                      ),
            ),
          if (result != null) _buildCompareResult(),
        ],
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: result != null ? 380.0 : 16.0),
        child: FloatingActionButton.extended(
          onPressed: _isCreatingProcess ? null : _createProcess,
          backgroundColor: const Color(0xFF19C3AE),
          foregroundColor: Colors.white,
          icon:
              _isCreatingProcess
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
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
