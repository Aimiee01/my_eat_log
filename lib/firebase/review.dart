import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewField {
  static const shopName = 'shopName';
  static const menuName = 'menuName';
  static const comment = 'comment';
  static const latestImageUrl = 'latestImageUrl';
}

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
          shopName: json[ReviewField.shopName]! as String,
          menuName: json[ReviewField.menuName]! as String,
          comment: json[ReviewField.comment]! as String,
          latestImageUrl: json[ReviewField.latestImageUrl] as String?,
        );

  final String shopName;
  final String menuName;
  final String comment;
  final String? latestImageUrl;

  Map<String, Object?> toJson() {
    return {
      ReviewField.shopName: shopName,
      ReviewField.menuName: menuName,
      ReviewField.comment: comment,
      ReviewField.latestImageUrl: latestImageUrl,
    };
  }
}

final reviewsRef =
    FirebaseFirestore.instance.collection('reviews').withConverter<Review>(
          fromFirestore: (snapshot, _) => Review.fromJson(snapshot.data()!),
          toFirestore: (reviews, _) => reviews.toJson(),
        );
