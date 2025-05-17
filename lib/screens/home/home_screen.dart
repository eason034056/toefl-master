import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/check_in_provider.dart';
import '../../screens/practice/practice_screen.dart';
import '../../screens/dictionary/dictionary_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _currentIndex == 0 ? const HomeTab() : _buildOtherTabs(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            label: 'Practice',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books_outlined),
            label: 'Dictionary',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article_outlined),
            label: 'News',
          ),
        ],
      ),
    );
  }

  Widget _buildOtherTabs() {
    switch (_currentIndex) {
      case 1:
        return const PracticeScreen();
      case 2:
        return const DictionaryScreen();
      case 3:
        return const Center(child: Text('News Page'));
      default:
        return const HomeTab();
    }
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const UserHeader(),
          const CheckInSection(),
          const ActivityWall(),
        ],
      ),
    );
  }
}

class UserHeader extends StatelessWidget {
  const UserHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // User Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 1),
            ),
            child: const CircleAvatar(
              backgroundImage: NetworkImage('https://i.pinimg.com/474x/a1/27/73/a1277303ec49ee936b2ba11bb3a98a18.jpg'),
              radius: 25,
            ),
          ),
          const SizedBox(width: 12),
          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Alex Smith',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'alex.smith@example.com',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Icons
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CheckInSection extends StatefulWidget {
  const CheckInSection({super.key});

  @override
  State<CheckInSection> createState() => _CheckInSectionState();
}

class _CheckInSectionState extends State<CheckInSection> {
  bool _showChallengeProgress = false;

  // 取得本週的打卡狀態（週一到週日）
  List<bool> _getWeeklyCheckInStatus(List<DateTime> checkedInDates) {
    final now = DateTime.now();
    final int todayWeekday = now.weekday;
    // 取得本週一的日期
    final monday = now.subtract(Duration(days: todayWeekday - 1));
    // 產生本週一到週日的日期（7天）
    List<DateTime> weekDays = List.generate(7, (i) => monday.add(Duration(days: i)));
    // 檢查每一天有沒有在 checkedInDates 裡
    return weekDays.map((d) => checkedInDates.any((c) => c.year == d.year && c.month == d.month && c.day == d.day)).toList();
  }

  void _showImageSourceDialog(BuildContext context, CheckInProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('選擇照片來源'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('拍照'),
              onTap: () {
                Navigator.pop(context);
                provider.takeCheckInPhoto();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('從相簿選擇'),
              onTap: () {
                Navigator.pop(context);
                provider.pickPhotoFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CheckInProvider>(
      builder: (context, checkInProvider, child) {
        final hasCheckedIn = checkInProvider.isTodayCheckedIn;
        final streakCount = checkInProvider.status.streakCount;
        final checkedInDates = checkInProvider.status.checkedInDates;
        final int totalGoal = 90; // 目標天數
        final int currentProgress = streakCount; // 目前進度
        final weeklyStatus = _getWeeklyCheckInStatus(checkedInDates);

        return GestureDetector(
          onTap: () {
            setState(() {
              _showChallengeProgress = !_showChallengeProgress;
            });
          },
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // 左側火焰和 Streak 數字
                    Column(
                      children: [
                        // 火焰動畫
                        Image.asset(
                          'assets/images/fire.gif',
                          width: 60,
                          height: 60,
                        ),
                        const SizedBox(height: 4),
                        // Streak 數字
                        Text(
                          '$streakCount',
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                        const Text('Streak', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(width: 24),
                    // 右側進度條和本週狀態
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 進度數字
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline, // 讓文字對齊底部
                            textBaseline: TextBaseline.alphabetic, // 指定以字母基線作為對齊參考點
                            children: [
                              Text(
                                '$currentProgress ',
                                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                              ),
                              Text('/ $totalGoal', style: const TextStyle(fontSize: 16, color: Colors.grey)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // 進度條
                          ClipRRect(
                            // 用 ClipRRect 包住進度條來製造圓角效果
                            borderRadius: BorderRadius.circular(5), // 設定 5 像素的圓角
                            child: LinearProgressIndicator(
                              value: currentProgress / totalGoal,
                              minHeight: 10,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // 星期一到週日的打卡狀態
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(7, (i) {
                              // 每個星期的文字和打卡勾勾組合在一起
                              return Column(
                                children: [
                                  // 星期文字
                                  Text(['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][i], style: const TextStyle(fontSize: 14)),
                                  const SizedBox(height: 4),
                                  // 打卡勾勾
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      // 圓形外框
                                      shape: BoxShape.circle,
                                      // 如果已打卡就是黑色背景，否則是白色背景
                                      color: Colors.white,
                                      // 灰色邊框
                                      border: Border.all(
                                        color: weeklyStatus[i] ? Colors.black : Colors.grey[300]!,
                                        width: 2,
                                      ),
                                    ),
                                    child: weeklyStatus[i]
                                        // 已打卡顯示白色勾勾
                                        ? const Icon(Icons.check, color: Colors.black, size: 20)
                                        // 未打卡就空白
                                        : null,
                                  ),
                                ],
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // 展開 Challenge Progress
                if (_showChallengeProgress) ...[
                  const SizedBox(height: 16),
                  const ChallengeCalendar(),
                ],

                if (!_showChallengeProgress) ...[
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: hasCheckedIn
                        ? null // 已打卡就不能按
                        : () => _showImageSourceDialog(context, checkInProvider), // 沒打卡就打開選擇照片
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 45), // 按鈕寬度撐滿
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(hasCheckedIn ? '已打卡' : '打卡'),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class ChallengeCalendar extends StatefulWidget {
  const ChallengeCalendar({super.key});

  @override
  State<ChallengeCalendar> createState() => _ChallengeCalendarState();
}

class _ChallengeCalendarState extends State<ChallengeCalendar> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  void _previousMonth() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CheckInProvider>(
      builder: (context, provider, child) {
        final now = DateTime.now();
        final firstDayOfMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
        final lastDayOfMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
        final daysInMonth = lastDayOfMonth.day;
        final firstWeekday = firstDayOfMonth.weekday;

        // 計算需要顯示的總天數（包含上個月的天數）
        final totalDays = daysInMonth + (firstWeekday - 1);
        final totalCells = (totalDays / 7).ceil() * 7;

        return Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Progress',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: _previousMonth,
                      ),
                      Text(
                        '${_selectedDate.year}/${_selectedDate.month}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: _nextMonth,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // 星期列
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text('一'),
                  Text('二'),
                  Text('三'),
                  Text('四'),
                  Text('五'),
                  Text('六'),
                  Text('日'),
                ],
              ),
              const SizedBox(height: 8),
              // 日曆格子
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 1,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: totalCells,
                itemBuilder: (context, index) {
                  final displayIndex = index - (firstWeekday - 1);
                  if (displayIndex < 0 || displayIndex >= daysInMonth) {
                    return const SizedBox();
                  }

                  final currentDate = DateTime(_selectedDate.year, _selectedDate.month, displayIndex + 1);

                  final isToday = currentDate.year == now.year && currentDate.month == now.month && currentDate.day == now.day;

                  final isCheckedIn = provider.status.isDateCheckedIn(currentDate);

                  return Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCheckedIn ? Colors.black : null,
                      border: Border.all(
                        color: isToday ? Colors.black : Colors.black12,
                        width: isToday ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${displayIndex + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isCheckedIn ? Colors.white : Colors.black,
                          fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  int _getMonthlyCheckIns(List<DateTime> checkedInDates, DateTime now) {
    return checkedInDates.where((date) => date.year == now.year && date.month == now.month).length;
  }
}

class ActivityWall extends StatelessWidget {
  const ActivityWall({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CheckInProvider>(
      builder: (context, provider, child) {
        // 獲取所有活動並按時間倒序排列
        final activities = provider.status.activities.toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));

        return Container(
          margin: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Activity',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // 使用 ListView 來顯示所有活動
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: activities.length,
                itemBuilder: (context, index) {
                  final activity = activities[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 用戶資訊列
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(activity.userAvatar),
                              radius: 25,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  activity.userName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  _formatTimestamp(activity.timestamp),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // 打卡照片
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            activity.photoUrl,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // 格式化時間戳記
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} 分鐘前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} 小時前';
    } else {
      return '${timestamp.month}月${timestamp.day}日';
    }
  }
}
