import 'package:flutter/foundation.dart';
import 'word_collection.dart';
import 'word.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class User extends ChangeNotifier {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<WordCollection> savedCollections; // 用戶收藏的單字集
  final List<String> favoriteWordIds; // 用戶收藏的單字 ID 列表
  final Map<String, UserWordProgress> wordProgress; // 用戶的單字學習進度

  User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.createdAt,
    required this.updatedAt,
    List<WordCollection>? savedCollections,
    List<String>? favoriteWordIds,
    Map<String, UserWordProgress>? wordProgress,
  })  : savedCollections = savedCollections ?? [],
        favoriteWordIds = favoriteWordIds ?? [],
        wordProgress = wordProgress ?? {};

  // 複製並更新用戶資訊
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<WordCollection>? savedCollections,
    List<String>? favoriteWordIds,
    Map<String, UserWordProgress>? wordProgress,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      savedCollections: savedCollections ?? this.savedCollections,
      favoriteWordIds: favoriteWordIds ?? this.favoriteWordIds,
      wordProgress: wordProgress ?? this.wordProgress,
    );
  }

  // 將用戶資料轉換為 JSON（用於本地存儲）
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'savedCollections': savedCollections.map((c) => c.toLocalJson()).toList(),
      'favoriteWordIds': favoriteWordIds,
      'wordProgress': wordProgress.map((key, value) => MapEntry(key, value.toJson())),
    };
  }

  // 將用戶資料轉換為 Firestore 格式
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'savedCollections': savedCollections.map((c) => c.toJson()).toList(),
      'favoriteWordIds': favoriteWordIds,
      'wordProgress': wordProgress.map((key, value) {
        final json = value.toJson();
        // 將日期時間轉換為 Timestamp
        json['createdAt'] = Timestamp.fromDate(DateTime.parse(json['createdAt']));
        json['updatedAt'] = Timestamp.fromDate(DateTime.parse(json['updatedAt']));
        if (json['nextReviewDate'] != null) {
          json['nextReviewDate'] = Timestamp.fromDate(DateTime.parse(json['nextReviewDate']));
        }
        if (json['lastReviewDate'] != null) {
          json['lastReviewDate'] = Timestamp.fromDate(DateTime.parse(json['lastReviewDate']));
        }
        return MapEntry(key, json);
      }),
    };
  }

  // 從 JSON 創建用戶實例
  factory User.fromJson(Map<String, dynamic> json) {
    // 處理 createdAt 和 updatedAt
    DateTime parseDateTime(dynamic value) {
      if (value is String) {
        return DateTime.parse(value);
      } else if (value is Timestamp) {
        return value.toDate();
      }
      return DateTime.now(); // 預設值
    }

    // 處理 wordProgress 中的日期時間
    Map<String, UserWordProgress> parseWordProgress(Map<String, dynamic>? progressJson) {
      if (progressJson == null) return {};

      return progressJson.map((key, value) {
        if (value is Map<String, dynamic>) {
          // 處理 UserWordProgress 中的日期時間
          DateTime parseProgressDateTime(dynamic dateValue) {
            if (dateValue is String) {
              return DateTime.parse(dateValue);
            } else if (dateValue is Timestamp) {
              return dateValue.toDate();
            }
            return DateTime.now();
          }

          final progress = Map<String, dynamic>.from(value);
          // 轉換所有日期時間欄位
          progress['createdAt'] = parseProgressDateTime(progress['createdAt']);
          progress['updatedAt'] = parseProgressDateTime(progress['updatedAt']);
          if (progress['nextReviewDate'] != null) {
            progress['nextReviewDate'] = parseProgressDateTime(progress['nextReviewDate']);
          }
          if (progress['lastReviewDate'] != null) {
            progress['lastReviewDate'] = parseProgressDateTime(progress['lastReviewDate']);
          }

          return MapEntry(key, UserWordProgress.fromJson(progress));
        }
        return MapEntry(key, UserWordProgress.fromJson(value));
      });
    }

    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      createdAt: parseDateTime(json['createdAt']),
      updatedAt: parseDateTime(json['updatedAt']),
      savedCollections: (json['savedCollections'] as List?)?.map((c) => WordCollection.fromJson(c)).toList() ?? [],
      favoriteWordIds: List<String>.from(json['favoriteWordIds'] ?? []),
      wordProgress: parseWordProgress(json['wordProgress'] as Map<String, dynamic>?),
    );
  }

  // 添加收藏的單字集
  void addSavedCollection(WordCollection collection) {
    if (!savedCollections.any((c) => c.id == collection.id)) {
      savedCollections.add(collection);
      notifyListeners();
    }
  }

  // 移除收藏的單字集
  void removeSavedCollection(String collectionId) {
    savedCollections.removeWhere((c) => c.id == collectionId);
    notifyListeners();
  }

  // 添加收藏的單字
  void addFavoriteWord(String wordId) {
    if (!favoriteWordIds.contains(wordId)) {
      favoriteWordIds.add(wordId);
      notifyListeners();
    }
  }

  // 移除收藏的單字
  void removeFavoriteWord(String wordId) {
    favoriteWordIds.remove(wordId);
    notifyListeners();
  }

  // 檢查單字是否被收藏
  bool isWordFavorite(String wordId) {
    return favoriteWordIds.contains(wordId);
  }

  // 添加單字到學習列表
  void addWordToLearn(Word word) {
    if (!wordProgress.containsKey(word.id)) {
      final now = DateTime.now();
      wordProgress[word.id] = UserWordProgress(
        userId: id,
        wordId: word.id,
        createdAt: now,
        updatedAt: now,
      );
      notifyListeners();
    }
  }

  // 從學習列表中移除單字
  void removeWordFromLearn(String wordId) {
    wordProgress.remove(wordId);
    notifyListeners();
  }

  // 更新單字學習進度
  void updateWordProgress(String wordId, UserWordProgress progress) {
    wordProgress[wordId] = progress;
    notifyListeners();
  }

  // 獲取單字學習進度
  UserWordProgress? getWordProgress(String wordId) {
    return wordProgress[wordId];
  }

  // 檢查單字是否在學習列表中
  bool isWordInLearning(String wordId) {
    return wordProgress.containsKey(wordId);
  }

  // 檢查單字集是否被收藏
  bool isCollectionSaved(String collectionId) {
    return savedCollections.any((c) => c.id == collectionId);
  }
}
