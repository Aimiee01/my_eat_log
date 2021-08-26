import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_eat_log/domain/review/entities/review.dart';

class ReviewRepository {
  const ReviewRepository._();

  static const instance = ReviewRepository._();

  /// レビューコレクションのデータすべてを取得する
  Stream<QuerySnapshot<Review>> fetchAll() {
    return reviewsRef.snapshots();
  }

  /// レビュー[review]を一件、ドキュメントID[reviewId]を指定して新規追加する。
  Future<void> add(
    Review data, {
    required String reviewId,
  }) async {
    await reviewsRef.doc(reviewId).set(data);
  }
}
