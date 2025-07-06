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
import 'package:flutter_application_latn/features/pharmacies/pharmacies_screen.dart';

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
    {'icon': Icons.local_hospital, 'label': 'Bác sĩ'},
    {'icon': Icons.local_pharmacy, 'label': 'Nhà thuốc'},
    {'icon': Icons.local_hospital_outlined, 'label': 'Bệnh viện'},
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return ListView(
      padding: EdgeInsets.all(screenWidth * 0.04), // Responsive padding
      children: [
        _buildServiceMenu(),
        SizedBox(height: screenHeight * 0.03), // Responsive spacing
        const _AnimatedBannerCard(),
        SizedBox(height: screenHeight * 0.03), // Responsive spacing
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

    final crossAxisCount = 3;
    final childAspectRatio =
        screenWidth > 600 ? 1.0 : (screenWidth > 400 ? 1.2 : 1.5);
    final spacing = screenWidth * 0.02;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: spacing,
      crossAxisSpacing: spacing,
      childAspectRatio: childAspectRatio,
      children:
          _serviceItems
              .map(
                (item) => _AnimatedIconMenu(
                  icon: item['icon'] as IconData,
                  label: item['label'] as String,
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
                  fontSize: screenWidth * 0.045, // Responsive font size
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Container(
                margin: EdgeInsets.only(top: screenHeight * 0.002),
                height: 3,
                width: screenWidth * 0.1, // Responsive width
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
    final hospitalCardHeight = screenHeight * 0.25; // Responsive height

    if (isLoadingHospitals) {
      return SizedBox(
        height: hospitalCardHeight,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
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
                size: screenHeight * 0.08, // Responsive icon size
                color: Colors.grey[400],
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                'Không có bệnh viện nào',
                style: TextStyle(
                  fontSize: screenHeight * 0.022, // Responsive font size
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
        separatorBuilder:
            (_, __) =>
                SizedBox(width: MediaQuery.of(context).size.width * 0.04),
        itemBuilder: (_, index) {
          final hospital = topHospitals[index];
          final hospitalData = hospital.toUIMap();
          return _AnimatedHospitalCard(hospital: hospitalData);
        },
      ),
    );
  }

  Widget _buildHealthArticle() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    if (isLoadingArticles) {
      return Container(
        padding: EdgeInsets.all(screenWidth * 0.03), // Responsive padding
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(
            screenWidth * 0.03,
          ), // Responsive radius
        ),
        child: Row(
          children: [
            Container(
              width: screenWidth * 0.2, // Responsive width
              height: screenHeight * 0.08, // Responsive height
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(
                  screenWidth * 0.02,
                ), // Responsive radius
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                ),
              ),
            ),
            SizedBox(width: screenWidth * 0.03), // Responsive spacing
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Đang tải bài viết...",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.04, // Responsive font size
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.005), // Responsive spacing
                  Text(
                    "Vui lòng chờ",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: screenWidth * 0.03, // Responsive font size
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
        padding: EdgeInsets.all(screenWidth * 0.03), // Responsive padding
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(
            screenWidth * 0.03,
          ), // Responsive radius
        ),
        child: Row(
          children: [
            Container(
              width: screenWidth * 0.2, // Responsive width
              height: screenHeight * 0.08, // Responsive height
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(
                  screenWidth * 0.02,
                ), // Responsive radius
              ),
              child: Icon(
                Icons.article_outlined,
                color: Colors.grey[400],
                size: screenWidth * 0.08, // Responsive icon size
              ),
            ),
            SizedBox(width: screenWidth * 0.03), // Responsive spacing
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Không có bài viết nào",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.04, // Responsive font size
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.005), // Responsive spacing
                  Text(
                    "Hãy quay lại sau",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: screenWidth * 0.03, // Responsive font size
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
        padding: EdgeInsets.all(screenWidth * 0.03), // Responsive padding
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(
            screenWidth * 0.03,
          ), // Responsive radius
        ),
        child: Row(
          children: [
            Container(
              width: screenWidth * 0.2, // Responsive width
              height: screenHeight * 0.08, // Responsive height
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  screenWidth * 0.02,
                ), // Responsive radius
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(article.mainImage),
                ),
              ),
            ),
            SizedBox(width: screenWidth * 0.03), // Responsive spacing
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.04, // Responsive font size
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: screenHeight * 0.005), // Responsive spacing
                  Text(
                    "${article.date.day} tháng ${article.date.month} năm ${article.date.year} • Đọc trong ${_calculateReadTime(article.content)} phút",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: screenWidth * 0.03, // Responsive font size
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
          case 'Bệnh viện':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ListHospitalPage()),
            );
            break;
          case 'Nhà thuốc':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PharmaciesScreen()),
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
              radius: screenWidth * 0.06, // Responsive radius
              backgroundColor: Colors.teal.withOpacity(0.1),
              child: Icon(
                widget.icon,
                color: Colors.teal,
                size: screenWidth * 0.05, // Responsive icon size
              ),
            ),
            SizedBox(height: screenHeight * 0.005), // Responsive spacing
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

class _AnimatedHospitalCard extends StatefulWidget {
  final Map<String, String> hospital;
  const _AnimatedHospitalCard({required this.hospital});
  @override
  State<_AnimatedHospitalCard> createState() => _AnimatedHospitalCardState();
}

class _AnimatedHospitalCardState extends State<_AnimatedHospitalCard> {
  double _scale = 1.0;
  @override
  Widget build(BuildContext context) {
    final hospital = widget.hospital;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Calculate responsive card dimensions
    final cardWidth = screenWidth * 0.4; // 40% of screen width
    final cardHeight = screenHeight * 0.25; // 25% of screen height
    final minWidth = 140.0;
    final maxWidth = 200.0;
    final finalWidth = cardWidth.clamp(minWidth, maxWidth);

    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.96),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => HospitalScreen(hospital: hospital)),
        );
      },
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: finalWidth,
          height: cardHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              screenWidth * 0.05,
            ), // Responsive radius
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.teal.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(
                    screenWidth * 0.05,
                  ), // Responsive radius
                  topRight: Radius.circular(
                    screenWidth * 0.05,
                  ), // Responsive radius
                ),
                child: Container(
                  height: cardHeight * 0.5, // 50% of card height
                  width: double.infinity,
                  child:
                      (hospital['image']?.isNotEmpty == true)
                          ? Image.network(
                            hospital['image']!,
                            width: double.infinity,
                            height: cardHeight * 0.5, // 50% of card height
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                width: double.infinity,
                                height: cardHeight * 0.5, // 50% of card height
                                color: Colors.grey[200],
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value:
                                        loadingProgress.expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.teal,
                                    ),
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return _buildHomeCardFallbackImage();
                            },
                          )
                          : _buildHomeCardFallbackImage(),
                ),
              ),

              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(
                    screenWidth * 0.025,
                  ), // Responsive padding
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hospital['name'] ?? '',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    screenWidth * 0.032, // Responsive font size
                                height: 1.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(
                              height: screenHeight * 0.005,
                            ), // Responsive spacing
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal:
                                    screenWidth * 0.015, // Responsive padding
                                vertical:
                                    screenHeight * 0.002, // Responsive padding
                              ),
                              decoration: BoxDecoration(
                                color: Colors.teal.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(
                                  screenWidth * 0.02,
                                ), // Responsive radius
                              ),
                              child: Text(
                                hospital['specialty'] ?? '',
                                style: TextStyle(
                                  color: Colors.teal[700],
                                  fontSize:
                                      screenWidth *
                                      0.022, // Responsive font size
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal:
                                  screenWidth * 0.01, // Responsive padding
                              vertical:
                                  screenHeight * 0.001, // Responsive padding
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                screenWidth * 0.015,
                              ), // Responsive radius
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star,
                                  size:
                                      screenWidth *
                                      0.025, // Responsive icon size
                                  color: Colors.amber,
                                ),
                                SizedBox(
                                  width: screenWidth * 0.002,
                                ), // Responsive spacing
                                Text(
                                  hospital['rating'] ?? '4.5',
                                  style: TextStyle(
                                    fontSize:
                                        screenWidth *
                                        0.022, // Responsive font size
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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

  Widget _buildHomeCardFallbackImage() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: double.infinity,
      height: screenHeight * 0.125, // Responsive height
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.teal.withOpacity(0.1), Colors.teal.withOpacity(0.05)],
        ),
      ),
      child: Icon(
        Icons.local_hospital,
        color: Colors.teal,
        size: screenWidth * 0.1, // Responsive icon size
      ),
    );
  }
}

class _AnimatedBannerCard extends StatefulWidget {
  const _AnimatedBannerCard();
  @override
  State<_AnimatedBannerCard> createState() => _AnimatedBannerCardState();
}

class _AnimatedBannerCardState extends State<_AnimatedBannerCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _opacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _offset = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    Future.delayed(
      const Duration(milliseconds: 300),
      () => _controller.forward(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder:
          (context, child) => Opacity(
            opacity: _opacity.value,
            child: SlideTransition(position: _offset, child: child),
          ),
      child: const _BannerCard(),
    );
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return ClipRRect(
      borderRadius: BorderRadius.circular(
        screenWidth * 0.04,
      ), // Responsive radius
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.all(screenWidth * 0.04), // Responsive padding
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(
              screenWidth * 0.04,
            ), // Responsive radius
            border: Border.all(color: Colors.teal.shade100, width: 1.5),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Bảo vệ sớm cho sức khỏe gia đình bạn",
                      style: TextStyle(
                        fontSize: screenWidth * 0.04, // Responsive font size
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: screenHeight * 0.015,
                    ), // Responsive spacing
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            screenWidth * 0.02,
                          ), // Responsive radius
                        ),
                      ),
                      child: Text(
                        "Tìm hiểu thêm",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.035, // Responsive font size
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: screenWidth * 0.04), // Responsive spacing
              ClipRRect(
                borderRadius: BorderRadius.circular(
                  screenWidth * 0.03,
                ), // Responsive radius
                child: Image.network(
                  "https://media.thanhtravietnam.vn/public/uploads/2025/05/16/682679dbda99ce573b8d6b93.jpg",
                  width: screenWidth * 0.2, // Responsive width
                  height: screenHeight * 0.12, // Responsive height
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
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
          prefs.getString('avatar') ??
          'https://randomuser.me/api/portraits/men/32.jpg',
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
      'label': 'Chọn ảnh',
      'builder': (BuildContext context) => const ChooseImageScreen(),
    },
    {
      'icon': Icons.article,
      'label': 'Bài báo',
      'builder': (BuildContext context) => ArticlesScreen(),
    },
    {
      'icon': Icons.login,
      'label': 'Đăng nhập',
      'builder': (BuildContext context) => const LoginScreen(),
    },
    {
      'icon': Icons.app_registration,
      'label': 'Đăng ký',
      'builder': (BuildContext context) => RegisterScreen(),
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
                  vertical: screenHeight * 0.04, // Responsive padding
                  horizontal: screenWidth * 0.05, // Responsive padding
                ),
                child: FutureBuilder<UserInfo>(
                  future: UserInfo.fromPrefs(),
                  builder: (context, snapshot) {
                    final user =
                        snapshot.data ??
                        const UserInfo(
                          name: 'Người dùng',
                          email: 'user@example.com',
                          avatar: '',
                        );
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.account_circle_rounded,
                              color: Colors.white,
                              size: screenWidth * 0.1, // Responsive icon size
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
                                size:
                                    screenWidth * 0.055, // Responsive icon size
                              ),
                              SizedBox(
                                width: screenWidth * 0.02,
                              ), // Responsive spacing
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
              horizontal: screenWidth * 0.04, // Responsive padding
              vertical: screenHeight * 0.015, // Responsive padding
            ),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                foregroundColor: Colors.red,
                minimumSize: Size(
                  double.infinity,
                  screenHeight * 0.06,
                ), // Responsive height
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    screenWidth * 0.04,
                  ), // Responsive radius
                ),
                elevation: 0,
              ),
              icon: Icon(
                Icons.logout,
                size: screenWidth * 0.05, // Responsive icon size
              ),
              label: Text(
                'Đăng xuất',
                style: TextStyle(
                  fontSize: screenWidth * 0.04, // Responsive font size
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
        horizontal: screenWidth * 0.03, // Responsive padding
        vertical: screenHeight * 0.005, // Responsive padding
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.teal,
          size: screenWidth * 0.055, // Responsive icon size
        ),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: screenWidth * 0.04, // Responsive font size
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: screenWidth * 0.04, // Responsive icon size
          color: Colors.grey[400],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            screenWidth * 0.035,
          ), // Responsive radius
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.03, // Responsive padding
          vertical: 0,
        ),
        dense: true,
        visualDensity: VisualDensity.compact,
        onTap: onTap,
      ),
    );
  }
}
