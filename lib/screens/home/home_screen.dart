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

  @override
  Widget build(BuildContext context) {
    // 監聽打卡狀態
    return Consumer<CheckInProvider>(
      builder: (context, checkInProvider, child) {
        final hasCheckedIn = checkInProvider.isTodayCheckedIn;
        final streakCount = checkInProvider.status.streakCount;

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 點擊整個標題區域可以切換顯示
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showChallengeProgress = !_showChallengeProgress;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Check In',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (streakCount > 0)
                      Text(
                        '🔥 $streakCount days',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                hasCheckedIn ? 'Great job! You\'ve completed today\'s practice!' : 'Complete today\'s practice to continue the streak!',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: hasCheckedIn ? null : () => _showImageSourceDialog(context, checkInProvider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(hasCheckedIn ? 'CHECKED IN' : 'CHECK IN'),
              ),
              // 根據狀態顯示或隱藏 Challenge Progress
              if (_showChallengeProgress) ...[
                const SizedBox(height: 16),
                const ChallengeCalendar(),
              ],
            ],
          ),
        );
      },
    );
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
