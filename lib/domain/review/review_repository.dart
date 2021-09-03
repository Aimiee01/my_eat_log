import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_eat_log/domain/review/entities/review.dart';

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

  ///
  Future<void> update(
    String shopName,
    String menuName,
    String comment,
    String? storageUrl, {
    required String reviewId,
  }) async {
    await reviewsRef.doc(reviewId).update(
      {
        ReviewField.shopName: shopName,
        ReviewField.menuName: menuName,
        ReviewField.comment: comment,
        // 新しく追加される写真をlatestImageUrlに入れる
        if (storageUrl != null) ReviewField.latestImageUrl: storageUrl
      },
    );
  }
}
