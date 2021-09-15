import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_eat_log/domain/review/entities/review.dart';
import 'package:my_eat_log/domain/review/entities/review_image.dart';

class ReviewRepository {
  const ReviewRepository._();

  static const instance = ReviewRepository._();

  /// レビューコレクションのデータすべてを取得する
  Stream<QuerySnapshot<Review>> fetchAll() {
    return reviewsRef.snapshots();
  }

  /// reviewを一件、ドキュメントID[reviewId]を指定して新規追加する。
  Future<void> add(
    Review data, {
    required String reviewId,
  }) async {
    await reviewsRef.doc(reviewId).set(data);
  }

  /// latestImageUrlの上書き
  @Deprecated('Freezedを使ってReviewImageをcopyできるようになってから使用する')
  Future<void> overwrite({
    required ReviewImage? reviewImage,
    required String reviewId,
  }) async {
    if (reviewImage != null) {
      await FirebaseFirestore.instance.collection('reviews').doc(reviewId)
          // latestImageUrlを更新する
          .update({
        'latestImageUrl': reviewImage.storageUrl,
      });
    } else {
      await reviewsRef.doc(reviewId).update({'latestImageUrl': ''});
    }
  }

  /// LatestImageUrlを更新する
  Future<void> updateLatestImageUrl(
    String? url, {
    required String reviewId,
  }) async {
    await reviewsRef.doc(reviewId).update({'latestImageUrl': url});
    // reviewsRef. doc(reviewId).update(
    //   {ReviewField.latestImageUrl: url},
    // );
  }

  ///
  Future<void> update(
    String shopName,
    String menuName,
    String comment,
    double ratingStar, {
    required String reviewId,
  }) async {
    await reviewsRef.doc(reviewId).update(
      {
        ReviewField.shopName: shopName,
        ReviewField.menuName: menuName,
        ReviewField.comment: comment,
        ReviewField.ratingStar: ratingStar,
        // 新しく追加される写真をlatestImageUrlに入れる
      },
    );
  }
}
