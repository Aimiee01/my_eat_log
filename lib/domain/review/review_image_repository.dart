import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:my_eat_log/domain/review/entities/review_image.dart';

class ReviewImageRepository {
  const ReviewImageRepository._();

  static const instance = ReviewImageRepository._();

  FirebaseStorage get _storage => FirebaseStorage.instance;

  /// [files] (写真)をストレージの指定の[path]に保存する。
  /// 写真を保存したら、URLを取得して返す。
  Future<String?> putImages(
    List<File> files, {
    required String path,
  }) async {
    for (final file in files) {
      final ref = _storage.ref(path);
      await ref.putFile(file);
      return ref.getDownloadURL();
    }
  }

  /// ReviewImage[data]を、Reviewのサブコレクションドキュメントとして保存する。
  Future<void> add(
    ReviewImage data, {
    required String reviewId,
  }) async {
    await reviewImagesRef(reviewId).add(data);
  }
}
