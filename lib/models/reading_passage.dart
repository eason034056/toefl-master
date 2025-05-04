class ReadingPassage {
  final String id;
  final String title;
  final String content;
  final int wordCount;
  final List<ReadingQuestion> questions;
  final bool isCompleted;

  ReadingPassage({
    required this.id,
    required this.title,
    required this.content,
    required this.wordCount,
    required this.questions,
    this.isCompleted = false,
  });
}

class ReadingQuestion {
  final String id;
  final String question;
  final List<String> options;
  final dynamic correctAnswer;
  final String explanation;
  final bool isMultipleChoice;

  ReadingQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    this.isMultipleChoice = false,
  });

  bool isCorrect(dynamic userAnswer) {
    if (isMultipleChoice) {
      final userAnswers = userAnswer as List<int>;
      final correctAnswers = correctAnswer as List<int>;
      return userAnswers.length == correctAnswers.length && userAnswers.every((answer) => correctAnswers.contains(answer));
    } else {
      return userAnswer == correctAnswer;
    }
  }
}
