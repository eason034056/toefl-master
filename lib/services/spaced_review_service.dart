import '../models/word.dart';

class SpacedReviewService {
  // 每個學習階段的間隔天數
  static const List<int> _intervalDays = [
    1, // 階段 0：1天後複習
    3, // 階段 1：3天後複習
    7, // 階段 2：7天後複習
    14, // 階段 3：14天後複習
    30, // 階段 4：30天後複習
    60, // 階段 5：60天後複習
  ];

  // 計算下次複習時間
  static DateTime calculateNextReviewDate(int learningStage) {
    final now = DateTime.now();
    final interval = _intervalDays[learningStage.clamp(0, _intervalDays.length - 1)];
    return now.add(Duration(days: interval));
  }

  // 根據答題結果更新單字狀態
  static Word updateWordAfterReview({
    required Word word,
    required bool isCorrect,
  }) {
    // 計算新的學習階段
    int newLearningStage = word.learningStage;
    if (isCorrect) {
      // 答對時，階段+1（最高到5）
      newLearningStage = (word.learningStage + 1).clamp(0, 5);
    } else {
      // 答錯時，階段-1（最低到0）
      newLearningStage = (word.learningStage - 1).clamp(0, 5);
    }

    // 計算新的熟練度（0.0 - 1.0）
    double newMasteryLevel = (newLearningStage / 5).clamp(0.0, 1.0);

    // 更新單字資訊
    return word.copyWith(
      learningStage: newLearningStage,
      masteryLevel: newMasteryLevel,
      lastReviewDate: DateTime.now(),
      nextReviewDate: calculateNextReviewDate(newLearningStage),
      reviewCount: word.reviewCount + 1,
    );
  }

  // 取得今天需要複習的單字
  static bool shouldReviewToday(Word word) {
    if (word.nextReviewDate == null) return true;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final reviewDate = DateTime(
      word.nextReviewDate!.year,
      word.nextReviewDate!.month,
      word.nextReviewDate!.day,
    );

    return reviewDate.compareTo(today) <= 0;
  }
}
