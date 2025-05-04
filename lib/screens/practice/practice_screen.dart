import 'package:flutter/material.dart';
import '../../screens/practice/reading/reading_list_screen.dart';

class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. 標題區塊
                const Text(
                  'Practice',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '選擇一個類別開始今日任務',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),

                // 2. 練習類別網格
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    _buildPracticeCard(
                      icon: Icons.book_outlined,
                      title: 'Reading',
                      onTap: () {
                        // 當使用者點擊時，導航到閱讀練習列表頁面
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ReadingListScreen(),
                          ),
                        );
                      },
                    ),
                    _buildPracticeCard(
                      icon: Icons.headphones_outlined,
                      title: 'Listening',
                      onTap: () {
                        // TODO: 導航到聽力練習頁面
                      },
                    ),
                    _buildPracticeCard(
                      icon: Icons.mic_outlined,
                      title: 'Speaking',
                      onTap: () {
                        // TODO: 導航到口說練習頁面
                      },
                    ),
                    _buildPracticeCard(
                      icon: Icons.edit_outlined,
                      title: 'Writing',
                      onTap: () {
                        // TODO: 導航到寫作練習頁面
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPracticeCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 36,
                color: Colors.black,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
