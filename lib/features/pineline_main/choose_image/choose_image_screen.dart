import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_latn/features/pineline_main/get_description/screen/user_description.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
class ChooseImageScreen extends StatefulWidget {
  const ChooseImageScreen({super.key});

  @override
  State<ChooseImageScreen> createState() => _ChooseImageScreenState();
}

class _ChooseImageScreenState extends State<ChooseImageScreen> {
  File? _selectedImage;
  bool _isLoading = false;
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
      compressQuality: 85,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Chỉnh sửa ảnh',
          toolbarColor: Colors.teal,
          toolbarWidgetColor: Colors.white,
          hideBottomControls: false,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Chỉnh sửa ảnh',
          aspectRatioLockEnabled: false,
        ),
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
    _showErrorDialog('Không tìm thấy thông tin người dùng. Vui lòng đăng nhập lại.');
    return;
  }

  final uri = Uri.parse('https://fastapi-service-748034725478.europe-west4.run.app/api/start-diagnosis');

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
        MaterialPageRoute(builder: (context) =>  User_Description()),
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
      builder: (_) => AlertDialog(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chẩn đoán da liễu"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Chọn ảnh chẩn đoán",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const Text(
              "Hãy chọn ảnh để chẩn đoán da liễu",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            _selectedImage == null
                ? Container(
                    width: double.infinity,
                    height: 520,
                    child: DottedBorder(
                      color: const Color.fromARGB(255, 0, 0, 0),
                      strokeWidth: 1.2,
                      dashPattern: [2, 1],
                      borderType: BorderType.RRect,
                      radius: const Radius.circular(12),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 5),
                          Row(
                            children: const [
                              Icon(Icons.image_not_supported, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                "Các loại ảnh:",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                  fontSize: 22,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Hệ thống hỗ trợ các định dạng ảnh: .JPG, ",
                            style: TextStyle(fontSize: 14),
                          ),
                          const Text(
                            ".JPEG, .PNG. Dung lượng tối đa: 5MB/ảnh",
                            style: TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: const [
                              Icon(Icons.warning, color: Colors.red),
                              SizedBox(width: 20),
                              Text(
                                "Lưu ý:",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                  fontSize: 22,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const _BulletText("1. Ảnh cần rõ nét, không mờ, không rung."),
                          const _BulletText("2. Tránh ảnh bị lóa sáng, ngược sáng hoặc có nhiều bóng tối."),
                          const _BulletText("3. Ưu tiên ảnh gốc, không chỉnh sửa màu sắc."),
                          const _BulletText("4. Đảm bảo vùng tổn thương nằm rõ trong ảnh."),
                          const _BulletText("5. Tránh ảnh bị cắt xén mất vùng quan trọng."),
                          const SizedBox(height: 8),
                          Center(
                            child: Image.asset(
                              'assets/images/example.webp',
                              height: 130,
                              width: 250,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _selectedImage!,
                          height: 380,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.edit),
                        label: const Text("Chỉnh sửa ảnh"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                    ],
                  ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: _selectedImage == null ? _showImageSourceActionSheet : _uploadImage,
                      child: Text(
                        _selectedImage == null ? "Chọn ảnh" : "Tiếp tục",
                        style: const TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
            ),
          ],
        ),
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
