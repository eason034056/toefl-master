import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
      ),
      body: ListView(
        children: [
          // 通知設定
          SwitchListTile(
            title: const Text('通知'),
            subtitle: const Text('接收應用程式通知'),
            secondary: const Icon(Icons.notifications_outlined),
            value: settingsProvider.notificationsEnabled,
            onChanged: (value) {
              settingsProvider.setNotificationsEnabled(value);
            },
          ),
          // 主題設定
          ListTile(
            title: const Text('主題'),
            subtitle: const Text('選擇應用程式主題'),
            leading: const Icon(Icons.palette_outlined),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('選擇主題'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RadioListTile<ThemeMode>(
                        title: const Text('跟隨系統'),
                        value: ThemeMode.system,
                        groupValue: settingsProvider.themeMode,
                        onChanged: (value) {
                          if (value != null) {
                            settingsProvider.setThemeMode(value);
                            Navigator.pop(context);
                          }
                        },
                      ),
                      RadioListTile<ThemeMode>(
                        title: const Text('淺色'),
                        value: ThemeMode.light,
                        groupValue: settingsProvider.themeMode,
                        onChanged: (value) {
                          if (value != null) {
                            settingsProvider.setThemeMode(value);
                            Navigator.pop(context);
                          }
                        },
                      ),
                      RadioListTile<ThemeMode>(
                        title: const Text('深色'),
                        value: ThemeMode.dark,
                        groupValue: settingsProvider.themeMode,
                        onChanged: (value) {
                          if (value != null) {
                            settingsProvider.setThemeMode(value);
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          // 語言設定
          ListTile(
            title: const Text('語言'),
            subtitle: const Text('選擇應用程式語言'),
            leading: const Icon(Icons.language_outlined),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('選擇語言'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RadioListTile<String>(
                        title: const Text('繁體中文'),
                        value: 'zh_TW',
                        groupValue: settingsProvider.language,
                        onChanged: (value) {
                          if (value != null) {
                            settingsProvider.setLanguage(value);
                            Navigator.pop(context);
                          }
                        },
                      ),
                      RadioListTile<String>(
                        title: const Text('English'),
                        value: 'en',
                        groupValue: settingsProvider.language,
                        onChanged: (value) {
                          if (value != null) {
                            settingsProvider.setLanguage(value);
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          // 清除快取
          ListTile(
            title: const Text('清除快取'),
            subtitle: const Text('清除應用程式快取資料'),
            leading: const Icon(Icons.cleaning_services_outlined),
            onTap: () async {
              final result = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('清除快取'),
                  content: const Text('確定要清除快取嗎？'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('取消'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('確定'),
                    ),
                  ],
                ),
              );

              if (result == true) {
                await settingsProvider.clearCache();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('快取已清除')),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
