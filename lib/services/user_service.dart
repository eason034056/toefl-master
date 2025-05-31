import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import '../models/word_collection.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 創建新用戶
  Future<User> createUser({
    required String id,
    required String email,
    required String name,
    String? avatarUrl,
  }) async {
    try {
      print('開始創建用戶資料...');
      print('用戶 ID: $id');
      print('Email: $email');
      print('Name: $name');

      // 創建預設的"個人收藏"單字集
      print('正在創建預設的"個人收藏"單字集...');
      final personalCollection = WordCollection(
        id: 'user_favorites_$id', // 使用用戶ID來確保唯一性
        name: '個人收藏',
        description: '我收藏的單字',
        words: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      print('✅ 預設單字集創建成功');
      print('單字集 ID: ${personalCollection.id}');

      // 創建用戶資料
      print('正在創建用戶資料物件...');
      final user = User(
        id: id,
        email: email,
        name: name,
        avatarUrl: avatarUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        favoriteWordIds: [], // 空的收藏單字列表
        savedCollections: [personalCollection], // 包含預設的個人收藏單字集
        wordProgress: {}, // 空的學習進度記錄
      );
      print('✅ 用戶資料物件創建成功');

      // 將用戶資料寫入 Firestore
      print('正在將用戶資料寫入 Firestore...');
      await _firestore.collection('users').doc(id).set(user.toJson());
      print('✅ 用戶資料成功寫入 Firestore');
      print('用戶資料：${user.toJson()}');

      return user;
    } catch (e) {
      print('❌ 創建用戶資料失敗：$e');
      rethrow;
    }
  }

  // 獲取用戶資料
  Future<User?> getUser(String userId) async {
    try {
      print('正在從 Firestore 獲取用戶資料...');
      print('用戶 ID: $userId');

      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        print('✅ 成功獲取用戶資料');
        print('用戶資料：${doc.data()}');
        return User.fromJson(doc.data()!);
      }
      print('❌ 找不到用戶資料');
      return null;
    } catch (e) {
      print('❌ 獲取用戶資料失敗：$e');
      rethrow;
    }
  }

  // 更新用戶資料
  Future<void> updateUser(User user) async {
    try {
      print('正在更新用戶資料...');
      print('用戶 ID: ${user.id}');
      print('更新資料：${user.toJson()}');

      await _firestore.collection('users').doc(user.id).update(user.toJson());
      print('✅ 用戶資料更新成功');
    } catch (e) {
      print('❌ 更新用戶資料失敗：$e');
      rethrow;
    }
  }

  // 更新用戶收藏的單字集
  Future<void> updateSavedCollections(String userId, List<WordCollection> collections) async {
    try {
      print('正在更新用戶收藏的單字集...');
      print('用戶 ID: $userId');
      print('單字集數量: ${collections.length}');

      await _firestore.collection('users').doc(userId).update({
        'savedCollections': collections.map((c) => c.toJson()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ 單字集更新成功');
    } catch (e) {
      print('❌ 更新收藏單字集失敗：$e');
      rethrow;
    }
  }

  // 更新用戶收藏的單字
  Future<void> updateFavoriteWords(String userId, List<String> wordIds) async {
    try {
      print('正在更新用戶收藏的單字...');
      print('用戶 ID: $userId');
      print('收藏單字數量: ${wordIds.length}');

      await _firestore.collection('users').doc(userId).update({
        'favoriteWordIds': wordIds,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ 收藏單字更新成功');
    } catch (e) {
      print('❌ 更新收藏單字失敗：$e');
      rethrow;
    }
  }

  // 更新用戶的單字學習進度
  Future<void> updateWordProgress(String userId, Map<String, dynamic> progress) async {
    try {
      print('正在更新用戶的單字學習進度...');
      print('用戶 ID: $userId');
      print('進度資料：$progress');

      await _firestore.collection('users').doc(userId).update({
        'wordProgress': progress,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ 學習進度更新成功');
    } catch (e) {
      print('❌ 更新單字學習進度失敗：$e');
      rethrow;
    }
  }

  // 添加收藏的單字
  Future<void> addFavoriteWord(String userId, String wordId) async {
    try {
      print('正在添加收藏的單字...');
      print('用戶 ID: $userId');
      print('單字 ID: $wordId');

      await _firestore.collection('users').doc(userId).update({
        'favoriteWordIds': FieldValue.arrayUnion([wordId]),
      });
      print('✅ 單字收藏成功');
    } catch (e) {
      print('❌ 添加收藏單字失敗：$e');
      rethrow;
    }
  }

  // 移除收藏的單字
  Future<void> removeFavoriteWord(String userId, String wordId) async {
    try {
      print('正在移除收藏的單字...');
      print('用戶 ID: $userId');
      print('單字 ID: $wordId');

      await _firestore.collection('users').doc(userId).update({
        'favoriteWordIds': FieldValue.arrayRemove([wordId]),
      });
      print('✅ 單字移除成功');
    } catch (e) {
      print('❌ 移除收藏單字失敗：$e');
      rethrow;
    }
  }

  // 添加收藏的單字集
  Future<void> addSavedCollection(String userId, WordCollection collection) async {
    try {
      print('正在添加收藏的單字集...');
      print('用戶 ID: $userId');
      print('單字集 ID: ${collection.id}');

      await _firestore.collection('users').doc(userId).update({
        'savedCollections': FieldValue.arrayUnion([collection.toJson()]),
      });
      print('✅ 單字集收藏成功');
    } catch (e) {
      print('❌ 添加收藏單字集失敗：$e');
      rethrow;
    }
  }

  // 移除收藏的單字集
  Future<void> removeSavedCollection(String userId, String collectionId) async {
    try {
      print('正在移除收藏的單字集...');
      print('用戶 ID: $userId');
      print('單字集 ID: $collectionId');

      final user = await getUser(userId);
      if (user != null) {
        final updatedCollections = user.savedCollections.where((c) => c.id != collectionId).map((c) => c.toJson()).toList();
        await _firestore.collection('users').doc(userId).update({
          'savedCollections': updatedCollections,
        });
        print('✅ 單字集移除成功');
      } else {
        print('❌ 找不到用戶資料');
      }
    } catch (e) {
      print('❌ 移除收藏單字集失敗：$e');
      rethrow;
    }
  }
}
