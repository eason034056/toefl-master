import 'package:flutter/material.dart';
import '../../../models/reading_passage.dart';
import 'reading_passage_screen.dart';
import 'reading_result_screen.dart';
import 'reading_overview_screen.dart';

class ReadingQuestionScreen extends StatefulWidget {
  final ReadingPassage passage;

  const ReadingQuestionScreen({
    super.key,
    required this.passage,
  });

  @override
  State<ReadingQuestionScreen> createState() => _ReadingQuestionScreenState();
}

class _ReadingQuestionScreenState extends State<ReadingQuestionScreen> {
  int _currentQuestionIndex = 0;
  final List<dynamic> _answers = List.filled(10, null); // 可以存放 int 或 List<int>

  @override
  Widget build(BuildContext context) {
    final question = widget.passage.questions[_currentQuestionIndex];

    // 如果是第10題（多選題），初始化為空列表
    if (question.isMultipleChoice && _answers[_currentQuestionIndex] == null) {
      _answers[_currentQuestionIndex] = <int>[];
    }

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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReadingPassageScreen(
                                passage: widget.passage,
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          'View Passage',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      const SizedBox(width: 16),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReadingOverviewScreen(
                                passage: widget.passage,
                                answers: _answers,
                                currentQuestionIndex: _currentQuestionIndex,
                                onQuestionSelected: (index) {
                                  setState(() {
                                    _currentQuestionIndex = index;
                                  });
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
                ],
              ),
              const SizedBox(height: 24),

              // 題目
              Text(
                'Question ${_currentQuestionIndex + 1}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                question.question,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),

              // 在題目下方添加提示文字（只在第10題顯示）
              if (question.isMultipleChoice)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    '* 此題為多選題，請選擇所有正確的答案',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ),

              // 選項
              ...List.generate(
                question.options.length,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        if (question.isMultipleChoice) {
                          // 如果是多選題
                          final answers = _answers[_currentQuestionIndex] as List<int>;
                          if (answers.contains(index)) {
                            // 如果已經選了這個選項，就移除它
                            answers.remove(index);
                          } else {
                            // 如果還沒選這個選項，就添加它
                            answers.add(index);
                          }
                        } else {
                          // 如果是單選題，直接設定答案
                          _answers[_currentQuestionIndex] = index;
                        }
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _getOptionBorderColor(question, index),
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: _getOptionBackgroundColor(question, index),
                      ),
                      child: Text(
                        "${index + 1}. ${question.options[index]}",
                        style: TextStyle(
                          color: _getOptionTextColor(question, index),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // 底部導航按鈕
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentQuestionIndex > 0)
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _currentQuestionIndex--;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        side: const BorderSide(color: Colors.black),
                      ),
                      child: const Text('Previous'),
                    ),
                  const Spacer(),
                  if (_currentQuestionIndex < widget.passage.questions.length - 1)
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _currentQuestionIndex++;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        side: const BorderSide(color: Colors.black),
                      ),
                      child: const Text('Next'),
                    )
                  else
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReadingResultScreen(
                              passage: widget.passage,
                              answers: _answers,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Submit'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 根據題目類型和選項狀態決定邊框顏色
  Color _getOptionBorderColor(ReadingQuestion question, int index) {
    if (question.isMultipleChoice) {
      final answers = _answers[_currentQuestionIndex] as List<int>;
      return answers.contains(index) ? Colors.black : Colors.black12;
    } else {
      return _answers[_currentQuestionIndex] == index ? Colors.black : Colors.black12;
    }
  }

  // 根據選項狀態決定背景顏色
  Color _getOptionBackgroundColor(ReadingQuestion question, int index) {
    if (question.isMultipleChoice) {
      final answers = _answers[_currentQuestionIndex] as List<int>;
      return answers.contains(index) ? Colors.black : Colors.white;
    } else {
      return _answers[_currentQuestionIndex] == index ? Colors.black : Colors.white;
    }
  }

  // 根據選項狀態決定文字顏色
  Color _getOptionTextColor(ReadingQuestion question, int index) {
    if (question.isMultipleChoice) {
      final answers = _answers[_currentQuestionIndex] as List<int>;
      return answers.contains(index) ? Colors.white : Colors.black;
    } else {
      return _answers[_currentQuestionIndex] == index ? Colors.white : Colors.black;
    }
  }
}
