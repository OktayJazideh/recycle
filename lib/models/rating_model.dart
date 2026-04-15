import 'package:uuid/uuid.dart';

class RatingModel {
  final String id;
  final String orderId;
  final String fromUserId;
  final String fromUserName;
  final String toUserId;
  final String toUserName;
  final double score;
  final double accuracyScore;
  final double punctualityScore;
  final double behaviorScore;
  final String hiddenComment;
  final DateTime createdAt;

  RatingModel({
    String? id,
    required this.orderId,
    required this.fromUserId,
    required this.fromUserName,
    required this.toUserId,
    required this.toUserName,
    required this.score,
    this.accuracyScore = 0,
    this.punctualityScore = 0,
    this.behaviorScore = 0,
    this.hiddenComment = '',
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'id': id, 'orderId': orderId, 'fromUserId': fromUserId,
    'fromUserName': fromUserName, 'toUserId': toUserId,
    'toUserName': toUserName, 'score': score,
    'accuracyScore': accuracyScore, 'punctualityScore': punctualityScore,
    'behaviorScore': behaviorScore, 'hiddenComment': hiddenComment,
    'createdAt': createdAt.toIso8601String(),
  };
}

class ArticleModel {
  final String id;
  final String title;
  final String content;
  final String category;
  final String imageUrl;
  final String author;
  final int views;
  final int likes;
  final bool isPublished;
  final DateTime createdAt;

  ArticleModel({
    String? id,
    required this.title,
    required this.content,
    required this.category,
    this.imageUrl = '',
    this.author = 'Recycle Market',
    this.views = 0,
    this.likes = 0,
    this.isPublished = true,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'id': id, 'title': title, 'content': content,
    'category': category, 'imageUrl': imageUrl,
    'author': author, 'views': views, 'likes': likes,
    'isPublished': isPublished,
    'createdAt': createdAt.toIso8601String(),
  };
}
