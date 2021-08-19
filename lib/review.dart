import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  Review({
    required this.shopName,
    required this.menuName,
    required this.comment,
    // imageUrlは必須ではない
    this.imageUrl,
  });
  Review.fromJson(Map<String, Object?> json)
      : this(
          shopName: json['shopName']! as String,
          menuName: json['menuName']! as String,
          comment: json['comment']! as String,
          // nullになる可能性があるので「?」をつける
          imageUrl: json['imageUrl'] as String?,
        );

  final String shopName;
  final String menuName;
  final String comment;
  final String? imageUrl;

  Map<String, Object?> toJson() {
    return {
      'shopName': shopName,
      'menuName': menuName,
      'comment': comment,
      'imageUrl': imageUrl,
    };
  }
}

final reviewsRef =
    FirebaseFirestore.instance.collection('reviews').withConverter<Review>(
          fromFirestore: (snapshot, _) => Review.fromJson(snapshot.data()!),
          toFirestore: (reviews, _) => reviews.toJson(),
        );
