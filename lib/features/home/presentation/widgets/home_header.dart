import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeHeader extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const HomeHeader({super.key, required this.scaffoldKey});

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  String userName = '';
  String avatarUrl =
      'https://randomuser.me/api/portraits/men/32.jpg'; // fallback avatar

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadAvatar();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final storedName = prefs.getString('name') ?? 'Người dùng';
    setState(() {
      userName = storedName;
    });
  }

  Future<void> _loadAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    final storedAvatar = prefs.getString('avatar');
    if (storedAvatar != null && storedAvatar.isNotEmpty) {
      setState(() {
        avatarUrl = storedAvatar;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final headerHeight = screenHeight * 0.28;
    final minHeight = 180.0;
    final maxHeight = 260.0;
    final finalHeight = headerHeight.clamp(minHeight, maxHeight);

    final horizontalPadding = screenWidth * 0.06;
    final topPadding = screenHeight * 0.03;

    return Container(
      height: finalHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF19C3AE), Color.fromARGB(255, 14, 124, 111)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(screenWidth * 0.18),
          bottomRight: Radius.circular(screenWidth * 0.04),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF19C3AE).withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: topPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: () {
                      widget.scaffoldKey.currentState?.openEndDrawer();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: screenWidth * 0.07,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: screenWidth * 0.065,
                      backgroundImage: NetworkImage(avatarUrl),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Xin chào',
                              style: GoogleFonts.lato(
                                fontSize: screenWidth * 0.038,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '👋',
                              style: TextStyle(fontSize: screenWidth * 0.038),
                            ),
                          ],
                        ),
                        Text(
                          userName,
                          style: GoogleFonts.lato(
                            fontSize: screenWidth * 0.052,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Chúc bạn một ngày tuyệt vời và nhiều sức khỏe!',
                          style: GoogleFonts.lato(
                            color: Colors.white.withOpacity(0.92),
                            fontSize: screenWidth * 0.032,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}
