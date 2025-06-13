import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import '../widgets/home_search.dart';
import 'package:shared_preferences/shared_preferences.dart';
class HomeHeader extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const HomeHeader({super.key, required this.scaffoldKey});

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  late VideoPlayerController _controller;
  String userName = '';
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/images/background.mp4')
      ..initialize().then((_) {
        _controller.setLooping(true);
        _controller.play();
        setState(() {});
      });
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final storedName = prefs.getString('name') ?? 'Người dùng';
    setState(() {
      userName = storedName;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(80),
                bottomRight: Radius.zero,
              ),
              child: _controller.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    )
                  : Container(color: Colors.teal),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.teal.withOpacity(0.7),
                    Colors.teal.shade300.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(80),
                  bottomRight: Radius.zero,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
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
                Text(
                  'Xin chào 🎉',
                  style: GoogleFonts.lato(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                Text(
                  userName,
                  style: GoogleFonts.lato(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                const HomeSearch(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
