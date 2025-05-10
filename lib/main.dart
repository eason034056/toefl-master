import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import '/config/theme.dart';
import '/screens/home/home_screen.dart';
import '/providers/check_in_provider.dart';
import '/services/storage_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    // 測試 Firebase Storage 連接
    final storageService = StorageService();
    await storageService.testFirebaseConnection();
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization error: $e');
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CheckInProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TOEFL Prep App',
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}
