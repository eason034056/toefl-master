import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('幫助與支援'),
      ),
      body: ListView(
        children: [
          // 常見問題
          ExpansionTile(
            title: const Text('常見問題'),
            leading: const Icon(Icons.help_outline),
            children: [
              ListTile(
                title: const Text('如何開始學習？'),
                subtitle: const Text('點擊查看詳細說明'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('如何開始學習？'),
                      content: const SingleChildScrollView(
                        child: Text(
                          '1. 註冊並登入您的帳號\n'
                          '2. 在首頁選擇您想要學習的單字集\n'
                          '3. 開始學習單字，系統會根據您的學習進度調整複習時間\n'
                          '4. 定期查看學習統計，了解您的學習狀況\n'
                          '5. 設定每日學習目標，保持學習動力',
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('關閉'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              ListTile(
                title: const Text('如何追蹤學習進度？'),
                subtitle: const Text('點擊查看詳細說明'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('如何追蹤學習進度？'),
                      content: const SingleChildScrollView(
                        child: Text(
                          '1. 在首頁查看您的學習統計\n'
                          '2. 查看已學習的單字數量\n'
                          '3. 查看學習時間統計\n'
                          '4. 查看學習曲線圖表\n'
                          '5. 查看學習日曆，了解每日學習狀況',
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('關閉'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              ListTile(
                title: const Text('如何設定每日目標？'),
                subtitle: const Text('點擊查看詳細說明'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('如何設定每日目標？'),
                      content: const SingleChildScrollView(
                        child: Text(
                          '1. 點擊首頁的設定按鈕\n'
                          '2. 選擇「每日目標」選項\n'
                          '3. 設定您想要每天學習的單字數量\n'
                          '4. 設定您想要每天學習的時間\n'
                          '5. 系統會根據您的設定提醒您完成目標',
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('關閉'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          // 使用教學
          ExpansionTile(
            title: const Text('使用教學'),
            leading: const Icon(Icons.school_outlined),
            children: [
              ListTile(
                title: const Text('基本操作指南'),
                subtitle: const Text('點擊查看詳細說明'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('基本操作指南'),
                      content: const SingleChildScrollView(
                        child: Text(
                          '1. 註冊與登入\n'
                          '   - 點擊「註冊」按鈕創建新帳號\n'
                          '   - 使用電子郵件和密碼登入\n'
                          '\n'
                          '2. 瀏覽單字集\n'
                          '   - 在首頁查看所有可用的單字集\n'
                          '   - 點擊單字集查看詳細內容\n'
                          '\n'
                          '3. 學習單字\n'
                          '   - 點擊單字查看詳細解釋\n'
                          '   - 使用「認識」和「不認識」按鈕標記單字\n'
                          '   - 查看例句和相關單字\n'
                          '\n'
                          '4. 複習單字\n'
                          '   - 系統會根據您的學習狀況安排複習\n'
                          '   - 在「複習」頁面查看需要複習的單字\n'
                          '   - 完成複習後更新學習進度',
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('關閉'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              ListTile(
                title: const Text('進階功能說明'),
                subtitle: const Text('點擊查看詳細說明'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('進階功能說明'),
                      content: const SingleChildScrollView(
                        child: Text(
                          '1. 自訂學習計劃\n'
                          '   - 創建個人化的學習計劃\n'
                          '   - 設定學習目標和時間表\n'
                          '   - 追蹤學習進度\n'
                          '\n'
                          '2. 學習統計\n'
                          '   - 查看學習時間統計\n'
                          '   - 查看學習曲線圖表\n'
                          '   - 分析學習效果\n'
                          '\n'
                          '3. 單字收藏\n'
                          '   - 收藏重要的單字\n'
                          '   - 創建自訂單字集\n'
                          '   - 分享單字集給其他用戶\n'
                          '\n'
                          '4. 學習提醒\n'
                          '   - 設定學習提醒\n'
                          '   - 接收學習通知\n'
                          '   - 追蹤學習目標',
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('關閉'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          // 聯絡我們
          ListTile(
            title: const Text('聯絡我們'),
            subtitle: const Text('有任何問題都可以聯絡我們'),
            leading: const Icon(Icons.contact_support_outlined),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('聯絡方式'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.email_outlined),
                        title: const Text('電子郵件'),
                        subtitle: const Text('support@toefl90days.com'),
                        onTap: () => _launchUrl('mailto:support@toefl90days.com'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.phone_outlined),
                        title: const Text('電話'),
                        subtitle: const Text('+886 2 1234 5678'),
                        onTap: () => _launchUrl('tel:+886212345678'),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('關閉'),
                    ),
                  ],
                ),
              );
            },
          ),
          // 關於我們
          ListTile(
            title: const Text('關於我們'),
            subtitle: const Text('了解更多關於 TOEFL 90 Days'),
            leading: const Icon(Icons.info_outline),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'TOEFL 90 Days',
                applicationVersion: '1.0.0',
                applicationIcon: const FlutterLogo(size: 64),
                children: [
                  const Text(
                    'TOEFL 90 Days 是一個幫助你準備 TOEFL 考試的應用程式。'
                    '我們提供完整的學習計劃、單字學習、練習題等功能，'
                    '幫助你在 90 天內達到理想的 TOEFL 分數。',
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
