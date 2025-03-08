import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isTyping = false;

  void _showAttachmentMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt, color: Colors.blueAccent),
              title: Text("Chụp hình"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.upload_file, color: Colors.greenAccent),
              title: Text("Đăng tải ảnh từ thư viện"),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 4,
      ),
      body: Column(
        children: [
          Expanded(child: Center(child: Text("Chưa có tin nhắn"))),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black54, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                children: [
                  TextField(
                          controller: _controller,
                          onChanged: (text) => setState(() => _isTyping = text.isNotEmpty),
                          decoration: InputDecoration(
                            hintText: "Nhập mô tả triệu chứng bệnh của bạn VD: Da có mẩn đỏ ngứa ngáy",
                            hintStyle: TextStyle(color: Colors.black45),
                            border: InputBorder.none,
                          ),
                        ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                        IconButton(
                        icon: Icon(Icons.add_circle, size: 30, color: Colors.black54),
                        onPressed: () => _showAttachmentMenu(context),
                      ),
                      Icon(
                        Icons.mic,
                        color: Colors.black54,
                      ),
                        ],
                      ),
                      AnimatedSwitcher(
                        duration: Duration(milliseconds: 300),
                        child: IconButton(
                          key: ValueKey<bool>(_isTyping),
                          icon: Icon(
                            Icons.send,
                            color: _isTyping ? Colors.blueAccent : Colors.grey,
                          ),
                          onPressed: _isTyping ? () {} : null,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}