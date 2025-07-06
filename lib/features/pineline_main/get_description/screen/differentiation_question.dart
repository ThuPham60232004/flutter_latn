import 'package:flutter_application_latn/features/pineline_main/get_description/modal/differentiation_question_modal.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

class Differentiation_Question extends StatefulWidget {
  @override
  _Differentiation_QuestionState createState() => _Differentiation_QuestionState();
}

class _Differentiation_QuestionState extends State<Differentiation_Question> with SingleTickerProviderStateMixin {
  bool isRightSelected = true;
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  late Animation<double> _scaleButton;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _scaleButton = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
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
          Center(
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
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
                          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
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
                                child: Icon(Icons.question_answer_rounded, size: 80, color: Color(0xFF199A8E)),
                              ),
                            ),
                            const SizedBox(height: 28),
                            Text(
                              "Thông tin bổ sung về bệnh lý",
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
                              "Vui lòng trả lời các câu hỏi sau để giúp hệ thống đánh giá chính xác hơn. Nếu không muốn trả lời, bạn có thể bỏ qua bước này.",
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
                                  child: GestureDetector(
                                    onTapDown: (_) => _controller.reverse(),
                                    onTapUp: (_) => _controller.forward(),
                                    onTapCancel: () => _controller.forward(),
                                    onTap: () {
                                      setState(() {
                                        isRightSelected = false;
                                      });
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        builder: (context) => Container(
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                                          ),
                                          child: DraggableScrollableSheet(
                                            expand: false,
                                            initialChildSize: 0.9,
                                            minChildSize: 0.5,
                                            maxChildSize: 0.95,
                                            builder: (context, scrollController) {
                                              return Differentiation_Question_Modal(scrollController: scrollController);
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                    child: ScaleTransition(
                                      scale: _scaleButton,
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: Color(0xFF199A8E),
                                          elevation: 2,
                                          side: BorderSide(color: Color(0xFF199A8E), width: 1.2),
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                        ),
                                        icon: Icon(Icons.edit_note_rounded),
                                        label: Text("Trả lời câu hỏi"),
                                        onPressed: null, 
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: GestureDetector(
                                    onTapDown: (_) => _controller.reverse(),
                                    onTapUp: (_) => _controller.forward(),
                                    onTapCancel: () => _controller.forward(),
                                    onTap: () {
                                      setState(() {
                                        isRightSelected = true;
                                      });
                                    },
                                    child: ScaleTransition(
                                      scale: _scaleButton,
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: Color(0xFF199A8E),
                                          elevation: 2,
                                          side: BorderSide(color: Color(0xFF199A8E), width: 1.2),
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                        ),
                                        icon: Icon(Icons.skip_next_rounded),
                                        label: Text("Bỏ qua"),
                                        onPressed: null, 
                                      ),
                                    ),
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