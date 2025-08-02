import 'package:flutter_application_latn/features/pineline_main/get_description/modal/differentiation_question_modal.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

class Differentiation_Question extends StatefulWidget {
  @override
  _Differentiation_QuestionState createState() =>
      _Differentiation_QuestionState();
}

class _Differentiation_QuestionState extends State<Differentiation_Question>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  bool _isSkipLoading = false;

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

  Future<void> _onSkip() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 28,
                ),
                SizedBox(width: 8),
                Text('Xác nhận'),
              ],
            ),
            content: Text('Bạn có chắc chắn muốn dừng chẩn đoán?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Không'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Dừng'),
              ),
            ],
          ),
    );
    if (confirm == true) {
      setState(() {
        _isSkipLoading = true;
      });
      // Simulate server call (replace with real call if available)
      await Future.delayed(Duration(seconds: 1));
      setState(() {
        _isSkipLoading = false;
      });
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFFF6FAFB),
      body: Stack(
        children: [
          // Animated gradient background
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
          // Decorative blurred circle
          Positioned(
            top: -60,
            left: -60,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.tealAccent.withOpacity(0.18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.teal.withOpacity(0.08),
                    blurRadius: 60,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            right: -40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.teal.withOpacity(0.10),
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
                    horizontal: 16.0,
                    vertical: 16.0,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(36),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                      child: Container(
                        width: size.width < 400 ? double.infinity : 400,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.72),
                          borderRadius: BorderRadius.circular(36),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.10),
                              blurRadius: 36,
                              offset: const Offset(0, 16),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.white.withOpacity(0.25),
                            width: 1.5,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 40,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Medical illustration/icon
                            AnimatedScale(
                              scale: 1.0,
                              duration: const Duration(milliseconds: 900),
                              curve: Curves.elasticOut,
                              child: Container(
                                height: 110,
                                width: 110,
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF199A8E,
                                  ).withOpacity(0.13),
                                  borderRadius: BorderRadius.circular(28),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.teal.withOpacity(0.10),
                                      blurRadius: 18,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.medical_services_rounded,
                                  size: 70,
                                  color: Color(0xFF199A8E),
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                            Text(
                              "Thông tin bổ sung về bệnh lý",
                              style: TextStyle(
                                fontSize: 27,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF199A8E),
                                letterSpacing: 1.1,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 14),
                            Text(
                              "Vui lòng trả lời các câu hỏi sau để giúp hệ thống đánh giá chính xác hơn. Nếu không muốn trả lời, bạn có thể bỏ qua bước này.",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[800],
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 38),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 18,
                                      ),
                                      backgroundColor: const Color(0xFF199A8E),
                                      foregroundColor: Colors.white,
                                      elevation: 5,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      textStyle: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    label: Text("Trả lời câu hỏi"),
                                    onPressed: () {
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
                                                  return Differentiation_Question_Modal(
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
                                const SizedBox(width: 18),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 18,
                                      ),
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.red[700],
                                      side: const BorderSide(
                                        color: Color(0xFFE53935),
                                        width: 1.5,
                                      ),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      textStyle: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    icon:
                                        _isSkipLoading
                                            ? SizedBox(
                                              width: 22,
                                              height: 22,
                                              child: CircularProgressIndicator(
                                                color: Colors.red,
                                                strokeWidth: 2.5,
                                              ),
                                            )
                                            : Icon(Icons.close_rounded),
                                    label: Text(
                                      _isSkipLoading
                                          ? "Đang dừng..."
                                          : "Bỏ qua",
                                    ),
                                    onPressed: _isSkipLoading ? null : _onSkip,
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
