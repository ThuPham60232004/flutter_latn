import 'package:flutter/material.dart';
import '../widgets/home_header.dart';
import 'package:flutter_application_latn/features/pineline_main/choose_image/choose_image_screen.dart';
import 'package:flutter_application_latn/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter_application_latn/features/auth/presentation/screens/register_screen.dart';
import 'package:flutter_application_latn/features/arcticles/arcticles_screen.dart';
import 'package:flutter_application_latn/features/arcticles/arcticles_detail.dart';
import 'package:flutter_application_latn/features/arcticles/models/article_model.dart';
import 'package:flutter_application_latn/features/arcticles/services/article_service.dart';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_latn/features/hospital/hospital_detail.dart';
import 'package:flutter_application_latn/features/hospital/list_hospital.dart';
import 'package:flutter_application_latn/features/hospital/models/hospital_model.dart';
import 'package:flutter_application_latn/features/hospital/services/hospital_service.dart';
import 'package:flutter_application_latn/core/utils/text_utils.dart';
import 'package:flutter_application_latn/features/search/search.dart';
import 'package:flutter_application_latn/features/search/search_hospital.dart';
import 'package:flutter_application_latn/features/arcticles/arcticles_list.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      backgroundColor: Colors.white,
      key: scaffoldKey,
      endDrawer: BeautifulDrawer(onLogout: () => _logout(context)),
      body: Column(
        children: [
          HomeHeader(scaffoldKey: scaffoldKey),
          const Expanded(child: _HomeScreenBody()),
        ],
      ),
    );
  }
}

class _HomeScreenBody extends StatefulWidget {
  const _HomeScreenBody();

  @override
  State<_HomeScreenBody> createState() => _HomeScreenBodyState();
}

class _HomeScreenBodyState extends State<_HomeScreenBody> {
  List<Hospital> topHospitals = [];
  List<Article> topArticles = [];
  bool isLoadingHospitals = true;
  bool isLoadingArticles = true;

  @override
  void initState() {
    super.initState();
    _loadTopHospitals();
    _loadTopArticles();
  }

  Future<void> _loadTopHospitals() async {
    try {
      final hospitals = await HospitalService.getHospitals();
      setState(() {
        topHospitals = hospitals.take(3).toList();
        isLoadingHospitals = false;
      });
    } catch (e) {
      setState(() {
        isLoadingHospitals = false;
        topHospitals = [];
      });
    }
  }

  Future<void> _loadTopArticles() async {
    try {
      final articles = await ArticleService.getArticles();
      setState(() {
        topArticles = articles.take(1).toList();
        isLoadingArticles = false;
      });
    } catch (e) {
      setState(() {
        isLoadingArticles = false;
        topArticles = [];
      });
    }
  }

  static const _serviceItems = [
    {'icon': Icons.local_hospital, 'label': 'Chẩn đoán'},
    {'icon': Icons.local_pharmacy, 'label': 'Bài báo'},
    {'icon': Icons.local_hospital_outlined, 'label': 'Bệnh viện'},
    {'icon': Icons.search, 'label': 'Tra cứu bệnh'},
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return ListView(
      padding: EdgeInsets.all(screenWidth * 0.04), // Responsive padding
      children: [
        SizedBox(height: screenHeight * 0.03),
        _buildServiceMenu(),
        SizedBox(height: screenHeight * 0.03),
        _buildSectionTitle(
          'Bệnh viện hàng đầu',
          context,
          onViewAll: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ListHospitalPage()),
            );
          },
        ),
        SizedBox(height: screenHeight * 0.015), // Responsive spacing
        _buildTopHospitals(),
        SizedBox(height: screenHeight * 0.03), // Responsive spacing
        _buildSectionTitle(
          'Bài viết về sức khỏe',
          context,
          onViewAll: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ArticlesScreen()),
            );
          },
        ),
        SizedBox(height: screenHeight * 0.015), // Responsive spacing
        _buildHealthArticle(),
      ],
    );
  }

  Widget _buildServiceMenu() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children:
          _serviceItems
              .map(
                (item) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.01,
                    ),
                    child: _AnimatedIconMenu(
                      icon: item['icon'] as IconData,
                      label: item['label'] as String,
                    ),
                  ),
                ),
              )
              .toList(),
    );
  }

  Widget _buildSectionTitle(
    String title,
    BuildContext context, {
    VoidCallback? onViewAll,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Container(
                margin: EdgeInsets.only(top: screenHeight * 0.002),
                height: 3,
                width: screenWidth * 0.1,
                decoration: BoxDecoration(
                  color: Colors.teal,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onViewAll,
          child: Text(
            'Xem tất cả',
            style: TextStyle(color: Colors.teal, fontSize: screenWidth * 0.035),
          ),
        ),
      ],
    );
  }

  Widget _buildTopHospitals() {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final hospitalCardHeight = screenHeight * 0.23;

    if (isLoadingHospitals) {
      return SizedBox(
        height: hospitalCardHeight,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF19C3AE)),
          ),
        ),
      );
    }

    if (topHospitals.isEmpty) {
      return SizedBox(
        height: hospitalCardHeight,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.local_hospital_outlined,
                size: screenHeight * 0.08,
                color: Colors.grey[400],
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                'Không có bệnh viện nào',
                style: TextStyle(
                  fontSize: screenHeight * 0.022,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: hospitalCardHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: topHospitals.length,
        separatorBuilder: (_, __) => SizedBox(width: screenWidth * 0.04),
        itemBuilder: (_, index) {
          final hospital = topHospitals[index];
          final hospitalData = hospital.toUIMap();
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HospitalScreen(hospital: hospitalData),
                ),
              );
            },
            child: Container(
              width: screenWidth * 0.46,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFFF8FAFA),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Color(0xFFE0E3E7), width: 1.2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child:
                          hospitalData['image'] != null &&
                                  hospitalData['image']!.isNotEmpty
                              ? Image.network(
                                hospitalData['image']!,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              )
                              : Container(
                                width: double.infinity,
                                color: Color(0xFF19C3AE).withOpacity(0.08),
                                child: Icon(
                                  Icons.local_hospital,
                                  color: Color(0xFF19C3AE),
                                  size: 36,
                                ),
                              ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    hospitalData['name'] ?? '',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.medical_services,
                        color: Color(0xFF19C3AE),
                        size: 15,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          hospitalData['specialty'] ?? '',
                          style: TextStyle(
                            color: Colors.teal[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.amber[800],
                              size: 15,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              hospitalData['rating'] ?? '4.5',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          backgroundColor: Color(0xFF19C3AE),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          minimumSize: Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => HospitalScreen(hospital: hospitalData),
                            ),
                          );
                        },
                        child: Text(
                          'Chi tiết',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHealthArticle() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    if (isLoadingArticles) {
      return Container(
        padding: EdgeInsets.all(screenWidth * 0.03),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(screenWidth * 0.03),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF19C3AE).withOpacity(0.08),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: screenWidth * 0.2,
              height: screenHeight * 0.08,
              decoration: BoxDecoration(
                color: Color(0xFF19C3AE).withOpacity(0.08),
                borderRadius: BorderRadius.circular(screenWidth * 0.02),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF19C3AE)),
                ),
              ),
            ),
            SizedBox(width: screenWidth * 0.03),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Đang tải bài viết...",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.04,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.005),
                  Text(
                    "Vui lòng chờ",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: screenWidth * 0.03,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (topArticles.isEmpty) {
      return Container(
        padding: EdgeInsets.all(screenWidth * 0.03),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(screenWidth * 0.03),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF19C3AE).withOpacity(0.08),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: screenWidth * 0.2,
              height: screenHeight * 0.08,
              decoration: BoxDecoration(
                color: Color(0xFF19C3AE).withOpacity(0.08),
                borderRadius: BorderRadius.circular(screenWidth * 0.02),
              ),
              child: Icon(
                Icons.article_outlined,
                color: Colors.grey[400],
                size: screenWidth * 0.08,
              ),
            ),
            SizedBox(width: screenWidth * 0.03),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Không có bài viết nào",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.04,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.005),
                  Text(
                    "Hãy quay lại sau",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: screenWidth * 0.03,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final article = topArticles.first;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ArticleDetailScreen(article: article.toUIMap()),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(screenWidth * 0.03),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(screenWidth * 0.03),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF19C3AE).withOpacity(0.08),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: screenWidth * 0.2,
              height: screenHeight * 0.08,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(screenWidth * 0.02),
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(article.mainImage),
                ),
              ),
            ),
            SizedBox(width: screenWidth * 0.03),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.04,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: screenHeight * 0.005),
                  Text(
                    "${article.date.day} tháng ${article.date.month} năm ${article.date.year} • Đọc trong ${_calculateReadTime(article.content)} phút",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: screenWidth * 0.03,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _calculateReadTime(String content) {
    final wordCount = content.split(' ').length;
    final readTime = (wordCount / 200).ceil();
    return readTime < 1 ? 1 : readTime;
  }
}

class _AnimatedIconMenu extends StatefulWidget {
  final IconData icon;
  final String label;
  const _AnimatedIconMenu({required this.icon, required this.label});
  @override
  State<_AnimatedIconMenu> createState() => _AnimatedIconMenuState();
}

class _AnimatedIconMenuState extends State<_AnimatedIconMenu> {
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.9),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: () {
        switch (widget.label) {
          case 'Bài báo':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ArticlesListPage()),
            );
            break;
          case 'Tra cứu bệnh viện':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchHospital()),
            );
            break;
          case 'Tra cứu bệnh':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DiseaseSearchScreen()),
            );
            break;
          case 'Chẩn đoán':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChooseImageScreen()),
            );
            break;
          default:
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${widget.label} - Tính năng đang phát triển'),
                duration: const Duration(seconds: 2),
              ),
            );
        }
      },
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: screenWidth * 0.06,
              backgroundColor: Colors.teal.withOpacity(0.1),
              child: Icon(
                widget.icon,
                color: Colors.teal,
                size: screenWidth * 0.05,
              ),
            ),
            SizedBox(height: screenHeight * 0.005),
            Text(
              widget.label,
              style: TextStyle(
                fontSize: screenWidth * 0.025, // Responsive font size
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class UserInfo {
  final String name;
  final String email;
  final String avatar;
  const UserInfo({
    required this.name,
    required this.email,
    required this.avatar,
  });

  static Future<UserInfo> fromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return UserInfo(
      name: prefs.getString('name') ?? 'Người dùng',
      email: prefs.getString('email') ?? 'user@example.com',
      avatar:
          prefs.getString('urlImage') ??
          'https://cdn-media.sforum.vn/storage/app/media/1image/anh-hoat-hinh-cute-thumb.jpg',
    );
  }

  static Future<void> saveToPrefs({
    required String name,
    String? email,
    String? avatar,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', name);
    if (email != null) await prefs.setString('email', email);
    if (avatar != null) await prefs.setString('avatar', avatar);
  }
}

class BeautifulDrawer extends StatelessWidget {
  final VoidCallback onLogout;
  const BeautifulDrawer({Key? key, required this.onLogout}) : super(key: key);

  static final _drawerItems = [
    {
      'icon': Icons.image,
      'label': 'Chẩn đoán',
      'builder': (BuildContext context) => const ChooseImageScreen(),
    },
    {
      'icon': Icons.article,
      'label': 'Bài báo',
      'builder': (BuildContext context) => ArticlesScreen(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF199A8E),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(
                  screenWidth * 0.08,
                ), // Responsive radius
                bottomRight: Radius.circular(
                  screenWidth * 0.08,
                ), // Responsive radius
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33199A8E),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.04,
                  horizontal: screenWidth * 0.05,
                ),
                child: FutureBuilder<UserInfo>(
                  future: UserInfo.fromPrefs(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    final user =
                        snapshot.data ??
                        const UserInfo(
                          name: 'Người dùng',
                          email: 'user@example.com',
                          avatar:
                              'https://cdn-media.sforum.vn/storage/app/media/1image/anh-hoat-hinh-cute-thumb.jpg',
                        );
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            user.avatar.isNotEmpty
                                ? CircleAvatar(
                                  radius: screenWidth * 0.05,
                                  backgroundImage: NetworkImage(user.avatar),
                                  backgroundColor: Colors.white,
                                )
                                : Icon(
                                  Icons.account_circle_rounded,
                                  color: Colors.white,
                                  size: screenWidth * 0.1,
                                ),
                            SizedBox(
                              width: screenWidth * 0.03,
                            ), // Responsive spacing
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.name,
                                    style: TextStyle(
                                      fontSize:
                                          screenWidth *
                                          0.05, // Responsive font size
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(
                                    height: screenHeight * 0.005,
                                  ), // Responsive spacing
                                  Text(
                                    user.email,
                                    style: TextStyle(
                                      fontSize:
                                          screenWidth *
                                          0.035, // Responsive font size
                                      color: Colors.white70,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: screenHeight * 0.02,
                        ), // Responsive spacing
                        Container(
                          width: double.infinity,
                          height: screenHeight * 0.06, // Responsive height
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(
                              screenWidth * 0.04,
                            ), // Responsive radius
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.favorite,
                                color: Colors.white,
                                size: screenWidth * 0.055,
                              ),
                              SizedBox(width: screenWidth * 0.02),
                              Text(
                                "Chào mừng bạn trở lại!",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize:
                                      screenWidth *
                                      0.038, // Responsive font size
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.02), // Responsive spacing
          ..._drawerItems.map(
            (item) => _DrawerItem(
              icon: item['icon'] as IconData,
              label: item['label'] as String,
              onTap: () {
                Navigator.pop(context);
                final builder = item['builder'];
                if (builder is Widget Function(BuildContext)) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => builder(context)),
                  );
                }
              },
            ),
          ),
          const Spacer(),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04, 
              vertical: screenHeight * 0.015,
            ),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                foregroundColor: Colors.red,
                minimumSize: Size(
                  double.infinity,
                  screenHeight * 0.06,
                ), 
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    screenWidth * 0.04,
                  ), 
                ),
                elevation: 0,
              ),
              icon: Icon(
                Icons.logout,
                size: screenWidth * 0.05, 
              ),
              label: Text(
                'Đăng xuất',
                style: TextStyle(
                  fontSize: screenWidth * 0.04, 
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                onLogout();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.03,
        vertical: screenHeight * 0.005,
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.teal, size: screenWidth * 0.055),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: screenWidth * 0.04,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: screenWidth * 0.04,
          color: Colors.grey[400],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(screenWidth * 0.035),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.03,
          vertical: 0,
        ),
        dense: true,
        visualDensity: VisualDensity.compact,
        onTap: onTap,
      ),
    );
  }
}
