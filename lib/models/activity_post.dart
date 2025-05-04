class ActivityPost {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String imageUrl;
  final String description;
  final DateTime createdAt;
  final Map<String, dynamic>? practiceData; // 練習相關數據

  ActivityPost({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.imageUrl,
    required this.description,
    required this.createdAt,
    this.practiceData,
  });

  // 從 JSON 創建模型實例
  factory ActivityPost.fromJson(Map<String, dynamic> json) {
    return ActivityPost(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userAvatar: json['userAvatar'] as String,
      imageUrl: json['imageUrl'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      practiceData: json['practiceData'] as Map<String, dynamic>?,
    );
  }

  // 轉換為 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'imageUrl': imageUrl,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'practiceData': practiceData,
    };
  }
}
