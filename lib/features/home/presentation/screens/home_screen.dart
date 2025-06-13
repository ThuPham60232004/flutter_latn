import 'package:flutter/material.dart';
import '../widgets/home_header.dart';
import 'package:flutter_application_latn/features/pineline_main/choose_image/choose_image_screen.dart';
import 'package:flutter_application_latn/features/pineline_main/get_description/screen/user_description.dart';
import 'package:flutter_application_latn/features/pineline_main/result/result_screen.dart';
import 'package:flutter_application_latn/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter_application_latn/features/auth/presentation/screens/register_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: const Text('Anh Thu Pham'),
              accountEmail: const Text('user@example.com'), 
              currentAccountPicture: const CircleAvatar(
                backgroundImage: NetworkImage(
                    'https://randomuser.me/api/portraits/women/44.jpg'),
              ),
              decoration: const BoxDecoration(color: Colors.teal),
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Chọn ảnh'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChooseImageScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Quy trình một'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => User_Description()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Đăng nhập'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.app_registration),
              title: const Text('Đăng ký'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => RegisterScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _logout(context);
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          HomeHeader(scaffoldKey: _scaffoldKey),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildServiceMenu(),
                const SizedBox(height: 24),
                _buildBannerCard(),
                const SizedBox(height: 24),
                _buildSectionTitle('Bác sĩ hàng đầu'),
                const SizedBox(height: 12),
                _buildTopDoctors(),
                const SizedBox(height: 24),
                _buildSectionTitle('Bài viết về sức khỏe'),
                const SizedBox(height: 12),
                _buildHealthArticle(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) {
    // TODO: Thực hiện xoá token / trạng thái đăng nhập tại đây
    // Ví dụ:
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // await prefs.remove('token');

    // Quay về LoginScreen và xoá các màn hình trước
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
      (route) => false,
    );
  }

  Widget _buildServiceMenu() {
    final items = [
      {'icon': Icons.local_hospital, 'label': 'Bác sĩ'},
      {'icon': Icons.local_pharmacy, 'label': 'Nhà thuốc'},
      {'icon': Icons.local_hospital_outlined, 'label': 'Bệnh viện'},
      {'icon': Icons.local_shipping, 'label': 'Xe cứu thương'},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: items
          .map((item) => Column(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.teal.withOpacity(0.1),
                    child: Icon(item['icon'] as IconData, color: Colors.teal),
                  ),
                  const SizedBox(height: 8),
                  Text(item['label'] as String, style: const TextStyle(fontSize: 12)),
                ],
              ))
          .toList(),
    );
  }

  Widget _buildBannerCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Bảo vệ sớm cho sức khỏe gia đình bạn",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                ElevatedButton(
                  onPressed: null,
                  child: Text(
                    "Tìm hiểu thêm",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(Colors.teal),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              "https://img.freepik.com/free-photo/portrait-female-doctor-wearing-white-coat_23-2148963797.jpg",
              width: 80,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text('Xem tất cả', style: TextStyle(color: Colors.teal)),
      ],
    );
  }

  Widget _buildTopDoctors() {
    final doctors = [
      {
        'name': 'Tiến sĩ Marcus Horitz',
        'specialty': 'Bác sĩ tim mạch',
        'image': 'https://randomuser.me/api/portraits/men/32.jpg',
        'rating': '4.9',
        'reviews': '120+'
      },
      {
        'name': 'Tiến sĩ Maria Elena',
        'specialty': 'Nhà tâm lý học',
        'image': 'https://randomuser.me/api/portraits/women/44.jpg',
        'rating': '4.8',
        'reviews': '100+'
      },
      {
        'name': 'Tiến sĩ Stevi Jessi',
        'specialty': 'Bác sĩ chỉnh hình',
        'image': 'https://randomuser.me/api/portraits/women/65.jpg',
        'rating': '4.7',
        'reviews': '90+'
      },
    ];

    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: doctors.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (_, index) {
          final doc = doctors[index];
          return Container(
            width: 140,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.grey.shade100,
            ),
            child: Column(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(doc['image']!),
                  radius: 30,
                ),
                const SizedBox(height: 8),
                Text(doc['name']!, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                Text(doc['specialty']!, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text("${doc['rating']} (${doc['reviews']})", style: const TextStyle(fontSize: 12)),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHealthArticle() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: const DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(
                    "https://nutricare.com.vn/wp-content/uploads/2021/12/benh-tieu-duong-kieng-an-trai-cay-gi.jpg"),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "28 loại trái cây lành mạnh nhất bạn có thể ăn",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text("10 tháng 6 năm 2021 • Đọc trong 5 phút",
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
