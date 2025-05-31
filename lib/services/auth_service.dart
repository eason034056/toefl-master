import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/user.dart' as app_user;
import 'user_service.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final UserService _userService = UserService();

  // 獲取當前用戶
  firebase_auth.User? get currentUser => _auth.currentUser;

  // 註冊新用戶
  Future<app_user.User> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      print('開始註冊新用戶...');
      print('Email: $email');
      print('Name: $name');

      // 創建 Firebase Auth 用戶
      print('正在創建 Firebase Auth 用戶...');
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        print('❌ 註冊失敗：無法創建 Firebase Auth 用戶');
        throw Exception('註冊失敗：無法創建用戶');
      }
      print('✅ Firebase Auth 用戶創建成功');
      print('用戶 ID: ${firebaseUser.uid}');

      // 創建用戶資料
      print('正在創建用戶資料...');
      final user = await _userService.createUser(
        id: firebaseUser.uid,
        email: email,
        name: name,
      );
      print('✅ 用戶資料創建成功');
      print('用戶資料：${user.toJson()}');

      return user;
    } catch (e) {
      print('❌ 註冊過程發生錯誤：$e');
      rethrow;
    }
  }

  // 登入
  Future<app_user.User> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      print('開始登入...');
      print('Email: $email');

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        print('❌ 登入失敗：無法獲取 Firebase Auth 用戶資料');
        throw Exception('登入失敗：無法獲取用戶資料');
      }
      print('✅ Firebase Auth 登入成功');
      print('用戶 ID: ${firebaseUser.uid}');

      // 獲取用戶資料
      print('正在獲取用戶資料...');
      final user = await _userService.getUser(firebaseUser.uid);
      if (user == null) {
        print('❌ 登入失敗：找不到用戶資料');
        throw Exception('登入失敗：找不到用戶資料');
      }
      print('✅ 成功獲取用戶資料');
      print('用戶資料：${user.toJson()}');

      return user;
    } catch (e) {
      print('❌ 登入過程發生錯誤：$e');
      rethrow;
    }
  }

  // 登出
  Future<void> signOut() async {
    try {
      print('正在登出...');
      await _auth.signOut();
      print('✅ 登出成功');
    } catch (e) {
      print('❌ 登出失敗：$e');
      rethrow;
    }
  }

  // 重設密碼
  Future<void> resetPassword(String email) async {
    try {
      print('正在發送重設密碼郵件...');
      print('Email: $email');
      await _auth.sendPasswordResetEmail(email: email);
      print('✅ 重設密碼郵件已發送');
    } catch (e) {
      print('❌ 重設密碼失敗：$e');
      rethrow;
    }
  }
}
