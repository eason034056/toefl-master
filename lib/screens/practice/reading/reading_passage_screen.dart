import 'package:flutter/material.dart';
import '../../../models/reading_passage.dart';
import 'reading_question_screen.dart';
import 'reading_overview_screen.dart';

class ReadingPassageScreen extends StatelessWidget {
  final ReadingPassage passage;

  const ReadingPassageScreen({
    super.key,
    required this.passage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 頂部導航列
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReadingOverviewScreen(
                            passage: passage,
                            answers: List.filled(passage.questions.length, null), // 初始狀態所有題目都未作答
                            currentQuestionIndex: 0, // 從第一題開始
                            onQuestionSelected: (index) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ReadingQuestionScreen(
                                    passage: passage,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'Overview',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 文章標題
              Text(
                passage.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // 文章內容
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    passage.content,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),
                ),
              ),

              // 底部按鈕
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReadingQuestionScreen(passage: passage),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.black),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Go to Questions'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
