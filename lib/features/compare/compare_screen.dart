import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/compare_service.dart';
import 'models/compare_model.dart';

class CompareScreen extends StatefulWidget {
  const CompareScreen({super.key});

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  final ImagePicker _picker = ImagePicker();

  // State variables
  String? _processId;
  String? _uploadedImageUrl;
  String? _firstImageUrl;
  String? _latestImageUrl;
  String? _userId;
  double _sliderValue = 0.5;
  bool _isUploading = false;
  bool _isComparing = false;

  // UI state
  bool _hasInitialImage = false;
  bool _hasComparisonImages = false;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('_id') ?? '123'; // Default user ID
    });
  }

  // Feature 1: Initial Image Upload
  Future<void> _pickAndUploadInitialImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image == null) return;

      setState(() {
        _isUploading = true;
      });

      // Use the service to upload image
      final CompareProcess result = await CompareService.uploadInitialImage(
        userId: _userId!,
        imageFile: File(image.path),
      );

      if (!mounted) return;

      setState(() {
        _processId = result.id;
        _uploadedImageUrl =
            result.imageUrls.isNotEmpty ? result.imageUrls[0] : null;
        _hasInitialImage = true;
        _isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tải ảnh lên thành công!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi tải ảnh lên: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Feature 2: Upload New Image & Compare
  Future<void> _pickAndCompareImage() async {
    if (_processId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng tải ảnh ban đầu trước'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image == null) return;

      setState(() {
        _isComparing = true;
      });

      // Use the service to compare images
      final CompareResult result = await CompareService.compareImages(
        userId: _userId!,
        processId: _processId!,
        imageFile: File(image.path),
      );

      if (!mounted) return;

      setState(() {
        _firstImageUrl = result.firstImage;
        _latestImageUrl = result.latestImage;
        _hasComparisonImages = true;
        _isComparing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tải ảnh so sánh thành công!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isComparing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi so sánh ảnh: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildInitialUploadSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bước 1: Tải ảnh ban đầu',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'Nhấn vào khung bên dưới để chọn và tải ảnh đầu tiên để so sánh.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _isUploading ? null : _pickAndUploadInitialImage,
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(
                  color: _hasInitialImage ? Colors.green : Colors.grey.shade300,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade50,
              ),
              child:
                  _isUploading
                      ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Đang tải lên...'),
                          ],
                        ),
                      )
                      : _hasInitialImage && _uploadedImageUrl != null
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          _uploadedImageUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                              ),
                            );
                          },
                        ),
                      )
                      : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Nhấn để chọn ảnh',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
            ),
          ),
          if (_hasInitialImage) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tải ảnh ban đầu thành công! ID: ${_processId?.substring(0, 8)}...',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildComparisonSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bước 2: So sánh ảnh',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'Chọn ảnh mới để so sánh với ảnh ban đầu bằng thanh trượt bên dưới.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          if (!_hasInitialImage)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange.shade600),
                  const SizedBox(width: 8),
                  const Text(
                    'Vui lòng tải ảnh ban đầu trước',
                    style: TextStyle(color: Colors.orange),
                  ),
                ],
              ),
            )
          else ...[
            ElevatedButton.icon(
              onPressed: _isComparing ? null : _pickAndCompareImage,
              icon:
                  _isComparing
                      ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.compare_arrows),
              label: Text(
                _isComparing ? 'Đang so sánh...' : 'Chọn ảnh để so sánh',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_hasComparisonImages &&
                _firstImageUrl != null &&
                _latestImageUrl != null) ...[
              Container(
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
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
                                  _firstImageUrl!,
                                  fit: BoxFit.cover,
                                  width: width,
                                ),
                              ),
                            ),
                            ClipRect(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                widthFactor: _sliderValue,
                                child: Image.network(
                                  _latestImageUrl!,
                                  fit: BoxFit.cover,
                                  width: width,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                          left:
                              width * _sliderValue - 1.5, // Center the divider
                          top: 0,
                          bottom: 0,
                          child: Container(width: 3, color: Colors.teal),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text(
                    'Trước',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: Slider(
                      value: _sliderValue,
                      onChanged: (value) {
                        setState(() {
                          _sliderValue = value;
                        });
                      },
                      activeColor: Colors.teal,
                      inactiveColor: Colors.grey.shade300,
                    ),
                  ),
                  const Text(
                    'Sau',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const Text(
                          'Trước',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 80,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              _firstImageUrl!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      children: [
                        const Text(
                          'Sau',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 80,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              _latestImageUrl!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('So sánh ảnh'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildInitialUploadSection(),
            const Divider(height: 1),
            _buildComparisonSection(),
          ],
        ),
      ),
    );
  }
}
