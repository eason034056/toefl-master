import 'package:flutter/material.dart';
import '../../../models/reading_passage.dart';
import 'reading_explanation_screen.dart'; // 記得引入詳解頁面

class ReadingResultScreen extends StatelessWidget {
  final ReadingPassage passage;
  final List<dynamic> answers;

  const ReadingResultScreen({
    super.key,
    required this.passage,
    required this.answers,
  });

  int get _correctAnswers {
    int count = 0;
    for (int i = 0; i < answers.length; i++) {
      if (answers[i] == passage.questions[i].correctAnswer) {
        count++;
      }
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "You've completed\nthe passage!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Score: $_correctAnswers / ${passage.questions.length}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),

              // 答題結果列表
              Expanded(
                child: ListView.builder(
                  itemCount: passage.questions.length,
                  itemBuilder: (context, index) {
                    final isCorrect = answers[index] == passage.questions[index].correctAnswer;
                    // 修改這裡，把 Container 包在 InkWell 裡面
                    return InkWell(
                      onTap: () {
                        // 點擊時跳轉到詳解頁面
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReadingExplanationScreen(
                              question: passage.questions[index],
                              userAnswer: answers[index],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Q${index + 1}  ${passage.questions[index].question}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            Icon(
                              isCorrect ? Icons.check : Icons.close,
                              color: isCorrect ? Colors.green : Colors.red,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // 底部按鈕
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil(
                      (route) => route.isFirst,
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
                  child: const Text('Return to Passages'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
