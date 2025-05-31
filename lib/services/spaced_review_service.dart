import '../models/word.dart'; // UserWordProgress 也在這個檔案裡，不需要另外 import

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
  static DateTime calculateNextReviewDate(int learningStage, DateTime lastReviewDate) {
    final interval = _intervalDays[learningStage.clamp(0, _intervalDays.length - 1)];
    return lastReviewDate.add(Duration(days: interval));
  }

  // 根據答題結果更新單字狀態
  static UserWordProgress updateWordAfterReview({
    required UserWordProgress word,
    required bool isCorrect,
  }) {
    final now = DateTime.now();

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
      lastReviewDate: now,
      nextReviewDate: calculateNextReviewDate(newLearningStage, now),
      reviewCount: word.reviewCount + 1,
    );
  }

  // 取得今天需要複習的單字
  static bool shouldReviewToday(UserWordProgress word) {
    if (word.nextReviewDate == null) return true;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final reviewDate = DateTime(
      word.nextReviewDate!.year,
      word.nextReviewDate!.month,
      word.nextReviewDate!.day,
    );

    // 如果下次複習日期已經過了，就應該要複習
    return reviewDate.compareTo(today) <= 0;
  }

  // 計算單字應該要複習的優先順序
  static double calculateReviewPriority(UserWordProgress word) {
    if (word.nextReviewDate == null) return 1.0;

    final now = DateTime.now();
    final daysOverdue = now.difference(word.nextReviewDate!).inDays;

    // 如果已經超過複習日期，優先順序會隨著天數增加而提高
    if (daysOverdue > 0) {
      return 1.0 + (daysOverdue * 0.1); // 每過一天增加 0.1 的優先順序
    }

    // 如果還沒到複習日期，根據距離複習日期的遠近計算優先順序
    final daysUntilReview = word.nextReviewDate!.difference(now).inDays;
    return 1.0 / (1.0 + daysUntilReview); // 越接近複習日期，優先順序越高
  }

  // 為新加入的單字分配複習時間
  static UserWordProgress assignInitialReviewDate(UserWordProgress word, int index, int totalWords, int dailyNewWords) {
    final now = DateTime.now();

    // 計算這個單字應該被分配到哪一天
    // 例如：如果每天要學 5 個新單字，那麼第 6 個單字應該在第 2 天學習
    final dayOffset = (index ~/ dailyNewWords) + 1;

    // 設定初始複習時間，使用當天的開始時間（00:00:00）
    final initialReviewDate = DateTime(
      now.year,
      now.month,
      now.day + dayOffset,
    );

    return word.copyWith(
      createdAt: now,
      updatedAt: now,
      lastReviewDate: now,
      nextReviewDate: initialReviewDate,
    );
  }

  // 計算需要多少天來完成所有新單字的學習
  static int calculateTotalDays(int totalWords, int dailyNewWords) {
    return (totalWords / dailyNewWords).ceil();
  }

  // 計算今天應該學習的新單字數量
  static int calculateTodayNewWordsCount(int totalWords, int dailyNewWords, int alreadyLearnedWords) {
    final remainingWords = totalWords - alreadyLearnedWords;
    return remainingWords > dailyNewWords ? dailyNewWords : remainingWords;
  }
}
