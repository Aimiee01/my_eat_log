import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:my_eat_log/domain/review/entities/review_image.dart';

class ReviewImageRepository {
  const ReviewImageRepository._();

  static const instance = ReviewImageRepository._();

  FirebaseStorage get _storage => FirebaseStorage.instance;

  /// [imageFile] (写真)をストレージの指定の[path]に保存する。
  /// 写真を保存し、URLを取得して返す。
  Future<String> putImage(
    File imageFile, {
    required String path,
  }) async {
    // 参照の作成
    final ref = _storage.ref(path);
    // 写真を保存
    await ref.putFile(imageFile);
    final downloadUrl = _storage.ref(path).getDownloadURL();

    return downloadUrl;
  }

  /// ReviewImage[data]を、Reviewのサブコレクションドキュメントとして保存する。
  Future<void> add(
    ReviewImage data, {
    required String reviewId,
  }) async {
    await reviewImagesRef(reviewId).add(data);
  }

  /// 該当するレビューのimagesのドキュメントを削除する
  /// その後、storagePathを指定して該当するimageをFireStorageから削除する
  Future<void> delete({
    required String reviewId,
    required DeleteImageParameter deleteImage,
  }) async {
    await FirebaseFirestore.instance
        .collection('reviews')
        .doc(reviewId)
        .collection('images')
        .doc(deleteImage.documentId)
        .delete();
    // storageUrlじゃなくてstoragePathを指定する
    final ref = _storage.ref(deleteImage.storagePath);
    await ref.delete();
  }

  /// 更新ボタンを押すと呼ばれる
  Future<void> deletes({
    required String reviewId,
    required List<DeleteImageParameter> deleteImageList,
  }) async {
    for (final deleteImage in deleteImageList) {
      await delete(
        reviewId: reviewId,
        deleteImage: deleteImage,
      );
    }
  }
}

//
class DeleteImageParameter {
  const DeleteImageParameter({
    required this.documentId,
    required this.storagePath,
  });

  final String documentId;
  final String storagePath;
}
