import 'package:flutter/material.dart';
import '../../../models/reading_passage.dart';

class ReadingOverviewScreen extends StatelessWidget {
  final ReadingPassage passage;
  final List<dynamic> answers;
  final int currentQuestionIndex;
  final Function(int) onQuestionSelected;

  const ReadingOverviewScreen({
    super.key,
    required this.passage,
    required this.answers,
    required this.currentQuestionIndex,
    required this.onQuestionSelected,
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
              // 頂部導航
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Overview',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // 題目網格
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: passage.questions.length,
                  itemBuilder: (context, index) {
                    final isAnswered = answers[index] != null;
                    final isCurrentQuestion = index == currentQuestionIndex;

                    return InkWell(
                      onTap: () {
                        onQuestionSelected(index);
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isCurrentQuestion ? Colors.black : Colors.black12,
                            width: isCurrentQuestion ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          color: isAnswered ? Colors.black : Colors.white,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isAnswered ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
