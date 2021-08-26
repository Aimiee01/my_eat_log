import 'package:cloud_firestore/cloud_firestore.dart';

import 'review.dart';

class ReviewImageField {
  static const storagePath = 'storagePath';
  static const storageUrl = 'storageUrl';
  static const updatedAt = 'updatedAt';
}

class ReviewImage {
  ReviewImage({
    required this.storagePath,
    required this.storageUrl,
    required this.updatedAt,
  });
  ReviewImage.fromJson(Map<String, Object?> json)
      : this(
          // 必ずあるので「!」をつける
          storagePath: json['storagePath']! as String,
          storageUrl: json['storageUrl']! as String,
          updatedAt: json['updatedAt']! as Timestamp,
        );

  final String storagePath;
  final String storageUrl;
  final Timestamp updatedAt;

  Map<String, Object?> toJson() {
    return {
      'storagePath': storagePath,
      'storageUrl': storageUrl,
      'updatedAt': updatedAt,
    };
  }
}

// reviewIdを受け取る必要があるので関数にする
// 関数なので型を指定する
CollectionReference<ReviewImage> reviewImagesRef(String reviewId) {
  return reviewsRef
      .doc(reviewId)
      .collection('images')
      .withConverter<ReviewImage>(
        fromFirestore: (snapshot, _) => ReviewImage.fromJson(snapshot.data()!),
        toFirestore: (images, _) => images.toJson(),
      );
}
