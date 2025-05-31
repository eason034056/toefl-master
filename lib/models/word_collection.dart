import 'word.dart';

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
    return WordCollection(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      words: (json['words'] as List).map((w) => Word.fromJson(w)).toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'words': words.map((w) => w.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
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
