import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  Review({
    required this.shopName,
    required this.menuName,
    required this.comment,
    // imagePathは必須ではない
    this.imagePath,
    this.imageUrl,
    this.updatedAt,
  });
  Review.fromJson(Map<String, Object?> json)
      : this(
          shopName: json['shopName']! as String,
          menuName: json['menuName']! as String,
          comment: json['comment']! as String,
          // nullになる可能性があるので「?」をつける
          imagePath: json['imagePath'] as String?,
          imageUrl: json['imageUrl'] as String?,
          updatedAt: json['updatedAt'] as Timestamp?,
        );

  final String shopName;
  final String menuName;
  final String comment;
  final String? imagePath;
  final String? imageUrl;
  final Timestamp? updatedAt;

  Map<String, Object?> toJson() {
    return {
      'shopName': shopName,
      'menuName': menuName,
      'comment': comment,
      'imagePath': imagePath,
      'imageUrl': imageUrl,
      'updatedAt': updatedAt,
    };
  }
}

final reviewsRef =
    FirebaseFirestore.instance.collection('reviews').withConverter<Review>(
          fromFirestore: (snapshot, _) => Review.fromJson(snapshot.data()!),
          toFirestore: (reviews, _) => reviews.toJson(),
        );
