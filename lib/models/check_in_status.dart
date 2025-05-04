class CheckInStatus {
  final bool hasCheckedIn; // 今日是否已打卡
  final DateTime? lastCheckIn; // 最後打卡時間
  final int streakCount; // 連續打卡天數
  final List<DateTime> checkedInDates; // 所有打卡日期
  final String? lastPhotoUrl; // 最後一次打卡的照片URL
  final List<CheckInActivity> activities;

  CheckInStatus({
    this.hasCheckedIn = false,
    this.lastCheckIn,
    this.streakCount = 0,
    List<DateTime>? checkedInDates,
    this.lastPhotoUrl,
    List<CheckInActivity>? activities,
  })  : checkedInDates = checkedInDates ?? [],
        activities = activities ?? [];

  // 創建新的狀態對象（不可變性設計）
  CheckInStatus copyWith({
    bool? hasCheckedIn,
    DateTime? lastCheckIn,
    int? streakCount,
    List<DateTime>? checkedInDates,
    String? lastPhotoUrl,
    List<CheckInActivity>? activities,
  }) {
    return CheckInStatus(
      hasCheckedIn: hasCheckedIn ?? this.hasCheckedIn,
      lastCheckIn: lastCheckIn ?? this.lastCheckIn,
      streakCount: streakCount ?? this.streakCount,
      checkedInDates: checkedInDates ?? this.checkedInDates,
      lastPhotoUrl: lastPhotoUrl ?? this.lastPhotoUrl,
      activities: activities ?? this.activities,
    );
  }

  bool isDateCheckedIn(DateTime date) {
    return checkedInDates.any((checkedDate) => checkedDate.year == date.year && checkedDate.month == date.month && checkedDate.day == date.day);
  }

  // 獲取特定月份的打卡天數
  int getMonthlyCheckIns(int year, int month) {
    return checkedInDates.where((date) => date.year == year && date.month == month).length;
  }
}

// 新增一個類別來表示單次打卡活動
class CheckInActivity {
  final DateTime timestamp; // 打卡時間
  final String photoUrl; // 照片網址
  final String userName; // 用戶名稱
  final String userAvatar; // 用戶頭像

  CheckInActivity({
    required this.timestamp,
    required this.photoUrl,
    required this.userName,
    required this.userAvatar,
  });
}
