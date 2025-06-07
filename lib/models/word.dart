import 'package:cloud_firestore/cloud_firestore.dart';

class Word {
  final String id; // 單字的唯一識別碼
  final String word; // 單字本身
  final String phonetic; // 音標
  final String audioUrl; // 發音音檔網址
  final String? imageUrl; // 圖片網址（可選）
  final List<WordMeaning> meanings; // 改為直接存放 WordMeaning 列表

  Word({
    required this.id,
    required this.word,
    required this.phonetic,
    required this.audioUrl,
    this.imageUrl,
    required this.meanings,
  });

  // 從 JSON 創建 Word 物件
  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      id: json['id'] as String,
      word: json['word'] as String,
      phonetic: json['phonetic'] as String,
      audioUrl: json['audioUrl'] as String,
      imageUrl: json['imageUrl'] as String?,
      meanings: (json['meanings'] as List).map((m) => WordMeaning.fromJson(m)).toList(),
    );
  }

  // 轉換為 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'word': word,
      'phonetic': phonetic,
      'audioUrl': audioUrl,
      'imageUrl': imageUrl,
      'meanings': meanings.map((m) => m.toJson()).toList(),
    };
  }

  // 複製並修改 Word 物件
  Word copyWith({
    String? id,
    String? word,
    String? phonetic,
    String? audioUrl,
    String? imageUrl,
    List<WordMeaning>? meanings,
  }) {
    return Word(
      id: id ?? this.id,
      word: word ?? this.word,
      phonetic: phonetic ?? this.phonetic,
      audioUrl: audioUrl ?? this.audioUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      meanings: meanings ?? this.meanings,
    );
  }
}

// 用戶的單字學習進度
class UserWordProgress {
  final String userId; // 用戶ID
  final String wordId; // 單字ID
  final DateTime createdAt; // 開始學習時間
  final DateTime updatedAt; // 最後更新時間
  final int reviewCount; // 複習次數
  final double masteryLevel; // 熟練度 (0-1)
  final DateTime? nextReviewDate; // 下次複習日期
  final bool isFavorite; // 是否收藏
  final int learningStage; // 學習階段 (0-5，0表示新詞，5表示已經完全掌握)
  final DateTime? lastReviewDate; // 上次複習時間

  UserWordProgress({
    required this.userId,
    required this.wordId,
    required this.createdAt,
    required this.updatedAt,
    this.reviewCount = 0,
    this.masteryLevel = 0.0,
    this.nextReviewDate,
    this.isFavorite = false,
    this.learningStage = 0,
    this.lastReviewDate,
  });

  // 從 JSON 創建 UserWordProgress 物件
  factory UserWordProgress.fromJson(Map<String, dynamic> json) {
    // 處理日期時間
    DateTime parseDateTime(dynamic value, String fieldName) {
      print('正在解析 $fieldName: $value (型別: ${value.runtimeType})');

      if (value == null) {
        print('$fieldName 為 null，返回 null');
        return DateTime.now();
      }

      if (value is DateTime) {
        print('$fieldName 已經是 DateTime 型別: $value');
        return value;
      } else if (value is String) {
        try {
          final date = DateTime.parse(value);
          print('成功將 $fieldName 從字串轉換為日期時間: $date');
          return date;
        } catch (e) {
          print('無法將 $fieldName 從字串轉換為日期時間: $e');
          return DateTime.now();
        }
      } else if (value is Timestamp) {
        final date = value.toDate();
        print('成功將 $fieldName 從 Timestamp 轉換為日期時間: $date');
        return date;
      }

      print('$fieldName 的型別不支援: ${value.runtimeType}');
      return DateTime.now();
    }

    print('開始解析 UserWordProgress JSON: $json');

    final progress = UserWordProgress(
      userId: json['userId'] as String,
      wordId: json['wordId'] as String,
      createdAt: parseDateTime(json['createdAt'], 'createdAt'),
      updatedAt: parseDateTime(json['updatedAt'], 'updatedAt'),
      reviewCount: json['reviewCount'] as int? ?? 0,
      masteryLevel: (json['masteryLevel'] as num?)?.toDouble() ?? 0.0,
      nextReviewDate: json['nextReviewDate'] != null ? parseDateTime(json['nextReviewDate'], 'nextReviewDate') : null,
      isFavorite: json['isFavorite'] as bool? ?? false,
      learningStage: json['learningStage'] as int? ?? 0,
      lastReviewDate: json['lastReviewDate'] != null ? parseDateTime(json['lastReviewDate'], 'lastReviewDate') : null,
    );

    print('解析完成，nextReviewDate: ${progress.nextReviewDate}');
    return progress;
  }

  // 轉換為 JSON（用於本地存儲）
  Map<String, dynamic> toJson() {
    final json = {
      'userId': userId,
      'wordId': wordId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'reviewCount': reviewCount,
      'masteryLevel': masteryLevel,
      'nextReviewDate': nextReviewDate?.toIso8601String(),
      'isFavorite': isFavorite,
      'learningStage': learningStage,
      'lastReviewDate': lastReviewDate?.toIso8601String(),
    };
    print('轉換為 JSON: $json');
    return json;
  }

  // 轉換為 Firestore 格式
  Map<String, dynamic> toFirestore() {
    final json = {
      'userId': userId,
      'wordId': wordId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'reviewCount': reviewCount,
      'masteryLevel': masteryLevel,
      'nextReviewDate': nextReviewDate != null ? Timestamp.fromDate(nextReviewDate!) : null,
      'isFavorite': isFavorite,
      'learningStage': learningStage,
      'lastReviewDate': lastReviewDate != null ? Timestamp.fromDate(lastReviewDate!) : null,
    };
    print('轉換為 Firestore 格式: $json');
    return json;
  }

  // 複製並修改 UserWordProgress 物件
  UserWordProgress copyWith({
    String? userId,
    String? wordId,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? reviewCount,
    double? masteryLevel,
    DateTime? nextReviewDate,
    bool? isFavorite,
    int? learningStage,
    DateTime? lastReviewDate,
  }) {
    return UserWordProgress(
      userId: userId ?? this.userId,
      wordId: wordId ?? this.wordId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      reviewCount: reviewCount ?? this.reviewCount,
      masteryLevel: masteryLevel ?? this.masteryLevel,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      isFavorite: isFavorite ?? this.isFavorite,
      learningStage: learningStage ?? this.learningStage,
      lastReviewDate: lastReviewDate ?? this.lastReviewDate,
    );
  }
}

class WordMeaning {
  final String partOfSpeech; // 詞性
  final String definition; // 解釋
  final String? example; // 例句（可選）
  final String? exampleTranslation; // 例句翻譯（可選）

  WordMeaning({
    required this.partOfSpeech,
    required this.definition,
    this.example,
    this.exampleTranslation,
  });

  // 從 JSON 創建 WordMeaning 物件
  factory WordMeaning.fromJson(Map<String, dynamic> json) {
    return WordMeaning(
      partOfSpeech: json['partOfSpeech'] as String,
      definition: json['definition'] as String,
      example: json['example'] as String?,
      exampleTranslation: json['exampleTranslation'] as String?,
    );
  }

  // 轉換為 JSON
  Map<String, dynamic> toJson() {
    return {
      'partOfSpeech': partOfSpeech,
      'definition': definition,
      'example': example,
      'exampleTranslation': exampleTranslation,
    };
  }
}
