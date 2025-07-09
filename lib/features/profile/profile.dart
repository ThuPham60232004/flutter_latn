import 'package:flutter/material.dart';
import 'services/profile_service.dart';
import 'models/profile_model.dart';
import '../../core/utils/text_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_latn/features/auth/presentation/screens/login_screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  ProfileModel? _profile;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final profileData = await ProfileService.getUserProfile();
      final profile = ProfileModel.fromJson(profileData);

      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color accent = const Color(0xFF19C3AE);
    final Color bgColor = const Color(0xFFF6F8FA);

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
                      backgroundImage: const NetworkImage(
                        'https://randomuser.me/api/portraits/women/44.jpg',
                      ),
                    ),
                    Container(
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
            Text(
              'Lỗi tải dữ liệu',
              style: const TextStyle(
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
        const _SectionHeader(title: 'Thư viện ảnh'),
        _PhotoGallerySection(),
        const SizedBox(height: 24),
        const _SectionHeader(title: 'Chức năng'),
        _MenuItem(
          icon: Icons.favorite_border,
          label: 'Đã lưu',
          onTap: () => _showComingSoon(context),
        ),
        _MenuItem(
          icon: Icons.calendar_today,
          label: 'Lịch hẹn',
          onTap: () => _showComingSoon(context),
        ),
        _MenuItem(
          icon: Icons.credit_card,
          label: 'Phương thức thanh toán',
          onTap: () => _showComingSoon(context),
        ),
        _MenuItem(
          icon: Icons.help_outline,
          label: 'Câu hỏi thường gặp',
          onTap: () => _showComingSoon(context),
        ),
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
      'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=facearea&w=80&h=80',
      'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=facearea&w=80&h=80',
      'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?auto=format&fit=facearea&w=80&h=80',
      'https://images.unsplash.com/photo-1465101046530-73398c7f28ca?auto=format&fit=facearea&w=80&h=80',
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
