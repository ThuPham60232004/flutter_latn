import 'package:flutter/material.dart';
import 'services/profile_service.dart';
import 'models/profile_model.dart';
import '../../core/utils/text_utils.dart';
import '../../core/utils/exceptions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_latn/features/auth/presentation/screens/login_screen.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  ProfileModel? _profile;
  bool _isLoading = true;
  String? _error;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadAvatarUrl();
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

  void _showSuccessMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _loadProfile() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final hasConnection = await _checkNetworkConnectivity();
      if (!hasConnection) {
        if (mounted) {
          _showErrorMessage(
            'Không có kết nối internet. Vui lòng kiểm tra lại.',
          );
        }
        setState(() {
          _error = 'Không có kết nối internet';
          _isLoading = false;
        });
        return;
      }

      final profileData = await ProfileService.getUserProfile();
      final profile = ProfileModel.fromJson(profileData);

      if (mounted) {
        setState(() {
          _profile = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
        _showErrorMessage('Lỗi tải thông tin hồ sơ: $e');
      }
    }
  }

  Future<void> _loadAvatarUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          _avatarUrl = prefs.getString('avatarUrl');
        });
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('Lỗi tải ảnh đại diện: $e');
      }
    }
  }

  Future<void> _updateProfile(ProfileModel updatedProfile) async {
    // Validate fields
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+');
    if (updatedProfile.name.trim().isEmpty) {
      _showErrorMessage('Tên không được để trống');
      return;
    }
    if (!emailRegex.hasMatch(updatedProfile.email)) {
      _showErrorMessage('Email không hợp lệ');
      return;
    }
    if (updatedProfile.phone != null &&
        updatedProfile.phone!.isNotEmpty &&
        updatedProfile.phone!.length < 8) {
      _showErrorMessage('Số điện thoại không hợp lệ');
      return;
    }
    if (updatedProfile.dateOfBirth == null) {
      _showErrorMessage('Ngày sinh không hợp lệ');
      return;
    }
    if (updatedProfile.avatarUrl == null || updatedProfile.avatarUrl!.isEmpty) {
      _showErrorMessage('Ảnh đại diện không hợp lệ');
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      final hasConnection = await _checkNetworkConnectivity();
      if (!hasConnection) {
        if (mounted) {
          _showErrorMessage(
            'Không có kết nối internet. Vui lòng kiểm tra lại.',
          );
        }
        return;
      }

      await ProfileService.updateUserProfile(updatedProfile.toJson());

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('avatarUrl', updatedProfile.avatarUrl!);
      await prefs.setString('userId', updatedProfile.id);
      await prefs.setString('userName', updatedProfile.name);
      await prefs.setString('userEmail', updatedProfile.email);
      if (updatedProfile.phone != null) {
        await prefs.setString('userPhone', updatedProfile.phone!);
      }
      if (updatedProfile.dateOfBirth != null) {
        await prefs.setString(
          'userDob',
          updatedProfile.dateOfBirth!.toIso8601String(),
        );
      }

      if (mounted) {
        setState(() {
          _profile = updatedProfile;
          _avatarUrl = updatedProfile.avatarUrl;
          _isLoading = false;
        });
        Navigator.of(context).pop();
        _showSuccessMessage('Cập nhật thành công!');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorMessage('Cập nhật thất bại: $e');
      }
    }
  }

  // Replace the old dialog with a beautiful modal bottom sheet
  void _showEditProfileSheet() {
    final nameController = TextEditingController(text: _profile?.name ?? '');
    final emailController = TextEditingController(text: _profile?.email ?? '');
    final phoneController = TextEditingController(text: _profile?.phone ?? '');
    final dobController = TextEditingController(
      text:
          _profile?.dateOfBirth != null
              ? _profile!.dateOfBirth!.toIso8601String().substring(0, 10)
              : '',
    );
    final avatarController = TextEditingController(
      text: _avatarUrl ?? _profile?.avatarUrl ?? '',
    );
    DateTime? selectedDob = _profile?.dateOfBirth;
    String? errorText;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: NetworkImage(
                            avatarController.text.isNotEmpty
                                ? avatarController.text
                                : 'https://cdn-media.sforum.vn/storage/app/media/1image/anh-hoat-hinh-cute-thumb.jpg',
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Color(0xFF19C3AE),
                          ),
                          onPressed: () {
                            setModalState(() {});
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Họ và tên',
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Số điện thoại',
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: dobController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Ngày sinh',
                        prefixIcon: const Icon(Icons.cake),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDob ?? DateTime(2000, 1, 1),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setModalState(() {
                                selectedDob = picked;
                                dobController.text = picked
                                    .toIso8601String()
                                    .substring(0, 10);
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: avatarController,
                      decoration: const InputDecoration(
                        labelText: 'Avatar URL',
                        prefixIcon: Icon(Icons.image),
                      ),
                      onChanged: (_) => setModalState(() {}),
                    ),
                    if (errorText != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          errorText!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF19C3AE),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child:
                            _isLoading
                                ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Text(
                                  'Lưu thay đổi',
                                  style: TextStyle(fontSize: 16),
                                ),
                        onPressed:
                            _isLoading
                                ? null
                                : () async {
                                  final emailRegex = RegExp(
                                    r'^[^@\s]+@[^@\s]+\.[^@\s]+',
                                  );
                                  if (nameController.text.trim().isEmpty) {
                                    setModalState(
                                      () =>
                                          errorText = 'Tên không được để trống',
                                    );
                                    return;
                                  }
                                  if (!emailRegex.hasMatch(
                                    emailController.text,
                                  )) {
                                    setModalState(
                                      () => errorText = 'Email không hợp lệ',
                                    );
                                    return;
                                  }
                                  if (phoneController.text.isNotEmpty &&
                                      phoneController.text.length < 8) {
                                    setModalState(
                                      () =>
                                          errorText =
                                              'Số điện thoại không hợp lệ',
                                    );
                                    return;
                                  }
                                  if (selectedDob == null) {
                                    setModalState(
                                      () =>
                                          errorText = 'Ngày sinh không hợp lệ',
                                    );
                                    return;
                                  }
                                  if (avatarController.text.isEmpty) {
                                    setModalState(
                                      () =>
                                          errorText =
                                              'Ảnh đại diện không hợp lệ',
                                    );
                                    return;
                                  }
                                  setModalState(() => errorText = null);
                                  await _updateProfile(
                                    ProfileModel(
                                      id: _profile?.id ?? '',
                                      name: nameController.text,
                                      email: emailController.text,
                                      phone: phoneController.text,
                                      password: _profile?.password,
                                      dateOfBirth: selectedDob,
                                      avatarUrl: avatarController.text,
                                    ),
                                  );
                                  if (context.mounted) {
                                    Navigator.of(context).pop();
                                  }
                                },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tính năng đang phát triển'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _logout(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      if (mounted) {
        _showErrorMessage('Lỗi đăng xuất: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color accent = Color(0xFF19C3AE);
    const Color bgColor = Color(0xFFF6F8FA);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CustomPaint(
              size: Size(MediaQuery.of(context).size.width, 180),
              painter: _AbstractLinePainter(),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 24),
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundImage: NetworkImage(
                        _avatarUrl ??
                            _profile?.displayAvatarUrl ??
                            'https://cdn-media.sforum.vn/storage/app/media/1image/anh-hoat-hinh-cute-thumb.jpg',
                      ),
                    ),
                    GestureDetector(
                      onTap: _showEditProfileSheet,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 4),
                          ],
                        ),
                        padding: const EdgeInsets.all(6),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 22,
                          color: Color(0xFF19C3AE),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  TextUtils.formatName(_profile?.displayName ?? 'Đang tải...'),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.teal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  _profile != null ? _profile!.displayAge : 'Đang tải...',
                  style: const TextStyle(fontSize: 15, color: Colors.black54),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(32),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x11000000),
                          blurRadius: 12,
                          offset: Offset(0, -4),
                        ),
                      ],
                    ),
                    child: _buildContent(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF19C3AE)),
            ),
            SizedBox(height: 16),
            Text(
              'Đang tải thông tin hồ sơ...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Lỗi tải dữ liệu',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF19C3AE),
                foregroundColor: Colors.white,
              ),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_profile == null) {
      return const Center(
        child: Text(
          'Không tìm thấy thông tin hồ sơ',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      children: [
        const _SectionHeader(title: 'Thông tin cá nhân'),
        _ProfileSectionCard(
          title: 'Họ và tên',
          content: _profile!.displayName,
          icon: Icons.person,
        ),
        _ProfileSectionCard(
          title: 'Email',
          content: _profile!.displayEmail,
          icon: Icons.email,
        ),
        _ProfileSectionCard(
          title: 'Số điện thoại',
          content: _profile!.displayPhone,
          icon: Icons.phone,
        ),
        _ProfileSectionCard(
          title: 'Ngày sinh',
          content: _profile!.displayDateOfBirth,
          icon: Icons.cake,
        ),
        const SizedBox(height: 18),
        _MenuItem(
          icon: Icons.logout,
          label: 'Đăng xuất',
          color: Colors.red,
          isLogout: true,
          onTap: () => _logout(context),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 2, top: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: Colors.teal,
        ),
      ),
    );
  }
}

class _ProfileSectionCard extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;
  const _ProfileSectionCard({
    required this.title,
    required this.content,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 7),
      elevation: 0,
      color: const Color(0xFFF6F8FA),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF19C3AE), size: 30),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(content),
      ),
    );
  }
}

class _PhotoGallerySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<String> defaultPhotos = [
      'https://hoseiki.vn/wp-content/uploads/2025/03/anime-chibi-cute-girl-23.jpg',
      'https://idep.edu.vn/upload/2025/02/hinh-anh-chibi-cute-004.webp',
      'https://jbagy.me/wp-content/uploads/2025/03/Hinh-anh-anime-chibi-nam-ngau-2.jpg',
      'https://hoanghamobile.com/tin-tuc/wp-content/uploads/2023/08/hinh-chibi-cute-de-ve-17.jpg',
    ];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 7),
      elevation: 0,
      color: const Color(0xFFF6F8FA),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.photo_library, color: Color(0xFF19C3AE)),
                SizedBox(width: 8),
                Text(
                  'Ảnh cá nhân',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 70,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children:
                    defaultPhotos
                        .map((url) => _PhotoThumbnail(url: url))
                        .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoThumbnail extends StatelessWidget {
  final String url;
  const _PhotoThumbnail({required this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final bool isLogout;
  final VoidCallback? onTap;
  const _MenuItem({
    required this.icon,
    required this.label,
    this.color,
    this.isLogout = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color ?? const Color(0xFF19C3AE)),
      title: Text(
        label,
        style: TextStyle(
          color: isLogout ? Colors.red : Colors.black,
          fontWeight: isLogout ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Color(0xFFB0BEC5),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
    );
  }
}

class _AbstractLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.08)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;
    final path =
        Path()
          ..moveTo(0, size.height * 0.7)
          ..quadraticBezierTo(
            size.width * 0.3,
            size.height,
            size.width,
            size.height * 0.5,
          )
          ..moveTo(size.width * 0.2, 0)
          ..quadraticBezierTo(
            size.width * 0.7,
            size.height * 0.5,
            size.width,
            0,
          );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
