import 'package:flutter/foundation.dart';
import 'word_collection.dart';
import 'word.dart';

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

  // 將用戶資料轉換為 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'savedCollections': savedCollections.map((c) => c.toJson()).toList(),
      'favoriteWordIds': favoriteWordIds,
      'wordProgress': wordProgress.map((key, value) => MapEntry(key, value.toJson())),
    };
  }

  // 從 JSON 創建用戶實例
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      avatarUrl: json['avatarUrl'],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      savedCollections: (json['savedCollections'] as List).map((c) => WordCollection.fromJson(c)).toList(),
      favoriteWordIds: List<String>.from(json['favoriteWordIds']),
      wordProgress: (json['wordProgress'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, UserWordProgress.fromJson(value)),
      ),
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
