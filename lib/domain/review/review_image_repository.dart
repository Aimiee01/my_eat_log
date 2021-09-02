import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:my_eat_log/domain/review/entities/review_image.dart';

class ReviewImageRepository {
  const ReviewImageRepository._();

  static const instance = ReviewImageRepository._();

  FirebaseStorage get _storage => FirebaseStorage.instance;

  /// [imageFileList] (写真)をストレージの指定の[path]に保存する。
  /// 写真を保存したら、URLを取得して返す。
  /// [pathExtension]はファイルの拡張子である！
  Future<List<String>> putImages(
    List<File> imageFileList, {
    required String path,
    String pathExtension = 'png',
  }) async {
    final urls = <String>[];
    // forでリストの数分回す
    for (var i = 0; i < imageFileList.length; i++) {
      final file = imageFileList[i];
      final storagePath = '$path-$i.$pathExtension';
      // 参照の作成
      final ref = _storage.ref(storagePath);

      await ref.putFile(file);
      urls.add(await ref.getDownloadURL());
    }
    return urls;
  }

  /// ReviewImage[data]を、Reviewのサブコレクションドキュメントとして保存する。
  Future<void> add(
    ReviewImage data, {
    required String reviewId,
  }) async {
    await reviewImagesRef(reviewId).add(data);
  }
}
