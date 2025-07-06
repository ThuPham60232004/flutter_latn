import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_application_latn/features/pineline_main/get_description/modal/user_description_modal.dart';

class User_Description extends StatefulWidget {
  @override
  _User_DescriptionState createState() => _User_DescriptionState();
}

class _User_DescriptionState extends State<User_Description>
    with SingleTickerProviderStateMixin {
  bool isRightSelected = true;
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FAFB),
      body: Stack(
        children: [
          // Soft animated gradient background
          AnimatedContainer(
            duration: const Duration(seconds: 2),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFB2FEFA), Color(0xFF199A8E)],
              ),
            ),
          ),
          Center(
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.55),
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 36,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Modern illustration (replace with your asset or Lottie)
                            AnimatedScale(
                              scale: 1.0,
                              duration: const Duration(milliseconds: 900),
                              curve: Curves.elasticOut,
                              child: Container(
                                height: 120,
                                width: 120,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 16,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.health_and_safety_rounded,
                                  size: 80,
                                  color: Color(0xFF199A8E),
                                ),
                                // To use a Lottie animation, replace above with:
                                // Lottie.asset('assets/your_animation.json', height: 120)
                              ),
                            ),
                            const SizedBox(height: 28),
                            Text(
                              "Chào mừng bạn!",
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF199A8E),
                                letterSpacing: 1.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Hãy mô tả tình trạng da của bạn để chúng tôi hỗ trợ tốt nhất. Nếu không muốn mô tả, bạn có thể bỏ qua bước này.",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[800],
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          !isRightSelected
                                              ? Color(0xFF199A8E)
                                              : Colors.white,
                                      foregroundColor:
                                          !isRightSelected
                                              ? Colors.white
                                              : Color(0xFF199A8E),
                                      elevation: !isRightSelected ? 4 : 0,
                                      side: BorderSide(
                                        color: Color(0xFF199A8E),
                                        width: 1.2,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    icon: Icon(Icons.edit_note_rounded),
                                    label: Text("Mô tả chi tiết"),
                                    onPressed: () {
                                      setState(() {
                                        isRightSelected = false;
                                      });
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        builder:
                                            (context) => Container(
                                              decoration: const BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.vertical(
                                                      top: Radius.circular(30),
                                                    ),
                                              ),
                                              child: DraggableScrollableSheet(
                                                expand: false,
                                                initialChildSize: 0.9,
                                                minChildSize: 0.5,
                                                maxChildSize: 0.95,
                                                builder: (
                                                  context,
                                                  scrollController,
                                                ) {
                                                  return User_Description_Modal(
                                                    scrollController:
                                                        scrollController,
                                                  );
                                                },
                                              ),
                                            ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          isRightSelected
                                              ? Color(0xFF199A8E)
                                              : Colors.white,
                                      foregroundColor:
                                          isRightSelected
                                              ? Colors.white
                                              : Color(0xFF199A8E),
                                      elevation: isRightSelected ? 4 : 0,
                                      side: BorderSide(
                                        color: Color(0xFF199A8E),
                                        width: 1.2,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    icon: Icon(Icons.skip_next_rounded),
                                    label: Text("Bỏ qua"),
                                    onPressed: () {
                                      setState(() {
                                        isRightSelected = true;
                                      });
                                    },
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
