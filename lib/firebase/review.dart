import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  Review({
    required this.shopName,
    required this.menuName,
    required this.comment,
    this.latestImageUrl,
    // 以下は必須ではない
  });
  Review.fromJson(Map<String, Object?> json)
      : this(
          shopName: json['shopName']! as String,
          menuName: json['menuName']! as String,
          comment: json['comment']! as String,
          latestImageUrl: json['latestImageUrl'] as String?,
        );

  final String shopName;
  final String menuName;
  final String comment;
  final String? latestImageUrl;

  Map<String, Object?> toJson() {
    return {
      'shopName': shopName,
      'menuName': menuName,
      'comment': comment,
      'latestImageUrl': latestImageUrl,
    };
  }
}

final reviewsRef =
    FirebaseFirestore.instance.collection('reviews').withConverter<Review>(
          fromFirestore: (snapshot, _) => Review.fromJson(snapshot.data()!),
          toFirestore: (reviews, _) => reviews.toJson(),
        );
