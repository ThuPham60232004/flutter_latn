import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_latn/features/pineline_main/get_description/screen/user_description.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';

class ChooseImageScreen extends StatefulWidget {
  const ChooseImageScreen({super.key});

  @override
  State<ChooseImageScreen> createState() => _ChooseImageScreenState();
}

class _ChooseImageScreenState extends State<ChooseImageScreen>
    with TickerProviderStateMixin {
  File? _selectedImage;
  bool _isLoading = false;
  bool _showTutorial = true;
  int _currentTutorialStep = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late AnimationController _tutorialController;
  late Animation<double> _tutorialFadeAnimation;
  late Animation<Offset> _tutorialSlideAnimation;
  late AnimationController _scanAnimationController;

  final List<TutorialStep> _tutorialSteps = [
    TutorialStep(
      title: "Chọn ảnh rõ nét",
      description:
          "Đảm bảo ảnh được chụp trong điều kiện ánh sáng tốt và không bị mờ",
      icon: Icons.photo_camera,
    ),
    TutorialStep(
      title: "Căn chỉnh vùng da",
      description: "Đặt vùng da cần chẩn đoán vào giữa khung hình",
      icon: Icons.center_focus_strong,
    ),
    TutorialStep(
      title: "Tránh ánh sáng mạnh",
      description: "Không chụp dưới ánh sáng trực tiếp hoặc trong bóng tối",
      icon: Icons.light_mode,
    ),
    TutorialStep(
      title: "Giữ khoảng cách phù hợp",
      description: "Giữ điện thoại cách vùng da khoảng 15-20cm",
      icon: Icons.straighten,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _tutorialController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _tutorialFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _tutorialController, curve: Curves.easeOut),
    );
    _tutorialSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _tutorialController, curve: Curves.easeOut),
    );

    _scanAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _animationController.forward();
    _tutorialController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _tutorialController.dispose();
    _scanAnimationController.dispose();
    super.dispose();
  }

  Future<String?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('_id');
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 85);
    if (pickedFile == null) return;

    final croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 90,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Chỉnh sửa ảnh',
          toolbarColor: Colors.teal,
          toolbarWidgetColor: Colors.white,
          hideBottomControls: false,
          lockAspectRatio: false,
        ),
        IOSUiSettings(title: 'Chỉnh sửa ảnh', aspectRatioLockEnabled: false),
      ],
    );

    if (croppedFile != null) {
      setState(() {
        _selectedImage = File(croppedFile.path);
      });

      String extension = path.extension(croppedFile.path).toLowerCase();
      print('Đuôi ảnh sau crop: $extension');
    }
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Chọn từ thư viện'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Chụp ảnh'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;
    setState(() {
      _isLoading = true;
    });

    final userId = await _getUserId();
    print(userId);
    if (userId == null) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog(
        'Không tìm thấy thông tin người dùng. Vui lòng đăng nhập lại.',
      );
      return;
    }

    final uri = Uri.parse(
      'https://fastapi-service-748034725478.europe-west4.run.app/api/start-diagnosis',
    );

    try {
      final request = http.MultipartRequest('POST', uri);

      request.fields['user_id'] = userId;
      final imageStream = http.ByteStream(_selectedImage!.openRead());
      final imageLength = await _selectedImage!.length();

      final multipartFile = http.MultipartFile(
        'image',
        imageStream,
        imageLength,
        filename: path.basename(_selectedImage!.path),
      );

      request.files.add(multipartFile);
      final response = await request.send();
      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        print('Phản hồi server: $respStr');

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => User_Description()),
        );
      } else {
        print('Upload thất bại. Mã lỗi: ${response.statusCode}');
        _showErrorDialog('Gửi ảnh thất bại. Mã lỗi: ${response.statusCode}');
      }
    } catch (e) {
      print('Lỗi upload: $e');
      _showErrorDialog('Có lỗi xảy ra khi gửi ảnh.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Lỗi'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Đóng'),
              ),
            ],
          ),
    );
  }

  void _nextTutorialStep() {
    if (_currentTutorialStep < _tutorialSteps.length - 1) {
      setState(() {
        _currentTutorialStep++;
      });
      _tutorialController.forward(from: 0.0);
    } else {
      setState(() {
        _showTutorial = false;
      });
    }
  }

  void _previousTutorialStep() {
    if (_currentTutorialStep > 0) {
      setState(() {
        _currentTutorialStep--;
      });
      _tutorialController.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF199A8E).withOpacity(0.1),
                  Colors.white,
                  const Color(0xFF199A8E).withOpacity(0.05),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildAppBar(),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                _buildHeader(theme),
                                const SizedBox(height: 24),
                                _buildImageSelectionCard(theme),
                                const SizedBox(height: 18),
                                if (_selectedImage == null)
                                  _buildGuidelinesCard(theme),
                                const SizedBox(height: 24),
                                _buildActionButton(theme),
                                const SizedBox(height: 18),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_showTutorial) _buildTutorialOverlay(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF199A8E).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF199A8E),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            "Chẩn đoán da liễu",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF199A8E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        ShaderMask(
          shaderCallback:
              (bounds) => LinearGradient(
                colors: [
                  const Color(0xFF199A8E),
                  const Color(0xFF199A8E).withOpacity(0.8),
                ],
              ).createShader(bounds),
          child: Text(
            "Chọn ảnh chẩn đoán",
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Hãy chọn hoặc chụp ảnh vùng da cần chẩn đoán.\nẢnh rõ nét giúp kết quả chính xác hơn!",
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.black87,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildImageSelectionCard(ThemeData theme) {
    return Hero(
      tag: 'image_selection',
      child: Card(
        elevation: 8,
        shadowColor: const Color(0xFF199A8E).withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, const Color(0xFF199A8E).withOpacity(0.05)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child:
                _selectedImage == null
                    ? _buildImagePicker(theme)
                    : _buildImagePreview(),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker(ThemeData theme) {
    return Column(
      children: [
        GestureDetector(
          onTap: _showImageSourceActionSheet,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF199A8E).withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF199A8E).withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Decorative elements
                Positioned(
                  top: 20,
                  left: 20,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF199A8E).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.photo_library_rounded,
                      color: Color(0xFF199A8E),
                      size: 24,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF199A8E).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Color(0xFF199A8E),
                      size: 24,
                    ),
                  ),
                ),
                // Center illustration
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFF199A8E).withOpacity(0.05),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF199A8E).withOpacity(0.2),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.add_photo_alternate_rounded,
                          color: Color(0xFF199A8E),
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Thêm ảnh",
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: const Color(0xFF199A8E),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Camera button
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF199A8E),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF199A8E).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          "Chạm để chọn hoặc chụp ảnh",
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: const Color(0xFF199A8E),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.info_outline, color: Colors.orange[700], size: 18),
              const SizedBox(width: 8),
              Text(
                "Hỗ trợ JPG, JPEG, PNG. Tối đa 5MB",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.orange[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    return Stack(
      alignment: Alignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.file(
            _selectedImage!,
            height: 300,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        if (_isLoading)
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
                child: Container(color: Colors.black.withOpacity(0.2)),
              ),
            ),
          ),
        if (_isLoading)
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: AnimatedBuilder(
                animation: _scanAnimationController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: ScanEffectPainter(_scanAnimationController.value),
                  );
                },
              ),
            ),
          ),
        if (_isLoading)
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Đang phân tích...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Vui lòng đợi trong giây lát.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    shadows: const [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        if (!_isLoading)
          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.edit_rounded, color: Color(0xFF199A8E)),
                onPressed: () => _pickImage(ImageSource.gallery),
                tooltip: "Chỉnh sửa ảnh",
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildGuidelinesCard(ThemeData theme) {
    return Card(
      elevation: 4,
      shadowColor: Colors.orange.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.orange.withOpacity(0.1),
              Colors.orange.withOpacity(0.05),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange[700],
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Lưu ý khi chọn ảnh",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...List.generate(
                5,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: Colors.orange[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          [
                            "Ảnh rõ nét, không mờ, không rung.",
                            "Tránh lóa sáng, ngược sáng hoặc nhiều bóng tối.",
                            "Ưu tiên ảnh gốc, không chỉnh sửa màu sắc.",
                            "Đảm bảo vùng tổn thương nằm rõ trong ảnh.",
                            "Tránh ảnh bị cắt xén mất vùng quan trọng.",
                          ][index],
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.black87,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(ThemeData theme) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF199A8E).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF199A8E)),
                ),
              )
              : ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF199A8E),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed:
                    _selectedImage == null
                        ? _showImageSourceActionSheet
                        : _uploadImage,
                icon: Icon(
                  _selectedImage == null
                      ? Icons.add_photo_alternate_rounded
                      : Icons.check_circle_rounded,
                  size: 24,
                ),
                label: Text(
                  _selectedImage == null ? "Chọn ảnh" : "Tiếp tục",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
    );
  }

  Widget _buildTutorialOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Stack(
        children: [
          // Tutorial content
          Center(
            child: FadeTransition(
              opacity: _tutorialFadeAnimation,
              child: SlideTransition(
                position: _tutorialSlideAnimation,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF199A8E).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _tutorialSteps[_currentTutorialStep].icon,
                          size: 40,
                          color: const Color(0xFF199A8E),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _tutorialSteps[_currentTutorialStep].title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF199A8E),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _tutorialSteps[_currentTutorialStep].description,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (_currentTutorialStep > 0)
                            TextButton.icon(
                              onPressed: _previousTutorialStep,
                              icon: const Icon(Icons.arrow_back),
                              label: const Text("Quay lại"),
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF199A8E),
                              ),
                            )
                          else
                            const SizedBox(width: 100),
                          ElevatedButton.icon(
                            onPressed: _nextTutorialStep,
                            icon: Icon(
                              _currentTutorialStep < _tutorialSteps.length - 1
                                  ? Icons.arrow_forward
                                  : Icons.check,
                            ),
                            label: Text(
                              _currentTutorialStep < _tutorialSteps.length - 1
                                  ? "Tiếp tục"
                                  : "Bắt đầu",
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF199A8E),
                              foregroundColor: Colors.white,
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
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Progress indicator
          Positioned(
            top: 48,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _tutorialSteps.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        index == _currentTutorialStep
                            ? const Color(0xFF199A8E)
                            : Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BulletText extends StatelessWidget {
  final String text;
  const _BulletText(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, color: Colors.black87),
      ),
    );
  }
}

class TutorialStep {
  final String title;
  final String description;
  final IconData icon;

  TutorialStep({
    required this.title,
    required this.description,
    required this.icon,
  });
}

class ScanEffectPainter extends CustomPainter {
  final double position;

  ScanEffectPainter(this.position);

  @override
  void paint(Canvas canvas, Size size) {
    final scanLineX = position * size.width;

    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.7)
          ..strokeWidth = 2.5
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF199A8E).withOpacity(0),
              const Color(0xFF199A8E).withOpacity(0.8),
              const Color(0xFF199A8E),
              const Color(0xFF199A8E).withOpacity(0.8),
              const Color(0xFF199A8E).withOpacity(0),
            ],
            stops: const [0.0, 0.4, 0.5, 0.6, 1.0],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final glowPaint =
        Paint()
          ..color = const Color(0xFF199A8E).withOpacity(0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    canvas.drawLine(
      Offset(scanLineX, 0),
      Offset(scanLineX, size.height),
      paint..strokeWidth = 1.0,
    );
    canvas.drawRect(
      Rect.fromLTWH(scanLineX - 15, 0, 30, size.height),
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant ScanEffectPainter oldDelegate) {
    return position != oldDelegate.position;
  }
}
