import 'word.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WordCollection {
  final String id;
  final String name;
  final String description;
  final List<Word> words;
  final DateTime createdAt;
  final DateTime updatedAt;

  WordCollection({
    required this.id,
    required this.name,
    required this.description,
    required this.words,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WordCollection.fromJson(Map<String, dynamic> json) {
    // 處理日期時間
    DateTime parseDateTime(dynamic value) {
      if (value is String) {
        return DateTime.parse(value);
      } else if (value is Timestamp) {
        return value.toDate();
      }
      return DateTime.now(); // 預設值
    }

    return WordCollection(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      words: (json['words'] as List?)?.map((w) => Word.fromJson(w)).toList() ?? [],
      createdAt: parseDateTime(json['createdAt']),
      updatedAt: parseDateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'words': words.map((w) => w.toJson()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // 用於本地存儲的 JSON 格式
  Map<String, dynamic> toLocalJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'words': words.map((w) => w.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // 將單字集轉換為 Firestore 格式
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'words': words.map((w) => w.toJson()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  WordCollection copyWith({
    String? id,
    String? name,
    String? description,
    List<Word>? words,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WordCollection(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      words: words ?? this.words,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
