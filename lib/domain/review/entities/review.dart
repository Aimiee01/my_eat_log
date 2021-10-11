import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewField {
  static const shopName = 'shopName';
  static const menuName = 'menuName';
  static const comment = 'comment';
  static const latestImageUrl = 'latestImageUrl';
  static const ratingStar = 'ratingStar';
  static const favoriteEnable = 'favoriteEnable';
  static const visitedDate = 'visitedDate';
}

class Review {
  Review({
    required this.shopName,
    required this.menuName,
    required this.comment,
    this.latestImageUrl,
    required this.ratingStar,
    required this.favoriteEnable,
    required this.visitedDate,
  });
  Review.fromJson(Map<String, Object?> json)
      : this(
          shopName: json[ReviewField.shopName]! as String,
          menuName: json[ReviewField.menuName]! as String,
          comment: json[ReviewField.comment]! as String,
          latestImageUrl: json[ReviewField.latestImageUrl] as String?,
          ratingStar: json[ReviewField.ratingStar]! as double,
          favoriteEnable: json[ReviewField.favoriteEnable]! as bool,
          visitedDate: json[ReviewField.visitedDate]! as String,
        );

  final String shopName;
  final String menuName;
  final String comment;
  final String? latestImageUrl;
  final double ratingStar;
  final bool favoriteEnable;
  final String visitedDate;

  Map<String, Object?> toJson() {
    return {
      ReviewField.shopName: shopName,
      ReviewField.menuName: menuName,
      ReviewField.comment: comment,
      ReviewField.latestImageUrl: latestImageUrl,
      ReviewField.ratingStar: ratingStar,
      ReviewField.favoriteEnable: favoriteEnable,
      ReviewField.visitedDate: visitedDate,
    };
  }
}

final reviewsRef =
    FirebaseFirestore.instance.collection('reviews').withConverter<Review>(
          fromFirestore: (snapshot, _) => Review.fromJson(snapshot.data()!),
          toFirestore: (reviews, _) => reviews.toJson(),
        );
