import 'package:flutter/material.dart';
import '../../../models/reading_passage.dart';

class ReadingExplanationScreen extends StatelessWidget {
  final ReadingQuestion question; // 要顯示的題目
  final dynamic userAnswer; // 使用者的答案

  const ReadingExplanationScreen({
    super.key,
    required this.question,
    required this.userAnswer,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCorrect = userAnswer == question.correctAnswer; // 判斷答案對錯

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. 返回按鈕
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(height: 24),

              // 2. 題目
              Text(
                question.question,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // 3. 選項列表
              ...List.generate(
                question.options.length,
                (index) => SizedBox(
                  width: double.infinity, // 讓選項寬度填滿螢幕
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _getOptionBorderColor(index), // 根據不同情況顯示不同顏色
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: _getOptionBackgroundColor(index),
                    ),
                    child: Text(
                      "${index + 1}. ${question.options[index]}",
                      style: TextStyle(
                        color: _getOptionTextColor(index),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // 4. 詳解
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isCorrect ? Icons.check_circle : Icons.info,
                          color: isCorrect ? Colors.green : Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isCorrect ? '答對了！' : '詳解',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      question.explanation,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 根據選項狀態決定邊框顏色
  Color _getOptionBorderColor(int index) {
    if (index == question.correctAnswer) return Colors.green;
    if (index == userAnswer) return Colors.red;
    return Colors.black12;
  }

  // 根據選項狀態決定背景顏色
  Color _getOptionBackgroundColor(int index) {
    if (index == question.correctAnswer) return Colors.green.withOpacity(0.1);
    if (index == userAnswer) return Colors.red.withOpacity(0.1);
    return Colors.white;
  }

  // 根據選項狀態決定文字顏色
  Color _getOptionTextColor(int index) {
    if (index == question.correctAnswer) return Colors.green;
    if (index == userAnswer) return Colors.red;
    return Colors.black;
  }
}
