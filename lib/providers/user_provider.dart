import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/user.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  final _firestore = FirebaseFirestore.instance;
  final _auth = firebase_auth.FirebaseAuth.instance;
  final _storage = FirebaseStorage.instance;

  User? get user => _user;

  Future<void> setUser(User user) async {
    _user = user;
    notifyListeners();
  }

  Future<void> updateUser(User updatedUser) async {
    try {
      await _firestore.collection('users').doc(updatedUser.id).update({
        'name': updatedUser.name,
        'email': updatedUser.email,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _user = updatedUser;
      notifyListeners();
    } catch (e) {
      throw Exception('更新用戶資料失敗：$e');
    }
  }

  Future<void> updateAvatar(String imagePath) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('用戶未登入');

      // 上傳圖片到 Firebase Storage
      final ref = _storage.ref().child('avatars/${user.uid}');
      await ref.putFile(File(imagePath));
      final url = await ref.getDownloadURL();

      // 更新用戶資料
      await _firestore.collection('users').doc(user.uid).update({
        'avatarUrl': url,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 更新本地用戶資料
      if (_user != null) {
        _user = _user!.copyWith(avatarUrl: url);
        notifyListeners();
      }
    } catch (e) {
      throw Exception('更新頭像失敗：$e');
    }
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('用戶未登入');

      // 重新認證用戶
      final credential = firebase_auth.EmailAuthProvider.credential(
        email: user.email!,
        password: oldPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // 更新密碼
      await user.updatePassword(newPassword);
    } catch (e) {
      throw Exception('修改密碼失敗：$e');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _user = null;
    notifyListeners();
  }
}
