import 'package:flutter_application_latn/features/pineline_main/get_description/modal/differentiation_question_modal.dart';
import 'package:flutter/material.dart';
class Differentiation_Question extends StatefulWidget {
  @override
  _Differentiation_QuestionState createState() => _Differentiation_QuestionState();
}

class _Differentiation_QuestionState extends State<Differentiation_Question> {
  bool isRightSelected = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height:70),
            Image.asset(
              'assets/images/logo_text_black.png', 
              height: 420,
              width:500
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                "Vui lòng cung cấp đầy đủ các thông tin đến bệnh lý để quá trình đánh giá được chính xác hơn.",
                style: TextStyle(fontSize: 18, color: const Color.fromARGB(255, 91, 89, 89)),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height:60),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(80),
              ),
              margin: EdgeInsets.only(bottom: 32),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isRightSelected = false;
                        });

                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true, 
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          builder: (context) => DraggableScrollableSheet(
                            expand: false,
                            builder: (context, scrollController) {
                              return Differentiation_Question_Modal(scrollController: scrollController);
                            },
                          ),
                        );
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        height: 60, 
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(left: 2, right: 1),
                        decoration: BoxDecoration(
                          color: isRightSelected ? Colors.transparent : Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: isRightSelected
                              ? []
                              : [BoxShadow(color: Colors.black12, blurRadius: 2)],
                        ),
                        child: Text(
                          'Tiếp theo',
                          style: TextStyle(
                            fontSize: 14,
                            color: isRightSelected ? Colors.grey : Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isRightSelected = true;
                        });
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        height: 60,
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(left: 1, right: 2),
                        decoration: BoxDecoration(
                          color: isRightSelected ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: isRightSelected
                              ? [BoxShadow(color: Colors.black12, blurRadius: 2)]
                              : [],
                        ),
                        child: Text(
                          'Không mô tả',
                          style: TextStyle(
                            fontSize: 14,
                            color: isRightSelected ? Colors.black : Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
             )   
          ],
        ),
      ),
    );
  }
} 