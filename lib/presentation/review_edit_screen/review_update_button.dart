import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_eat_log/domain/review/entities/review.dart';
import 'package:my_eat_log/domain/review/entities/review_image.dart';
import 'package:my_eat_log/domain/review/review_image_repository.dart';
import 'package:my_eat_log/domain/review/review_repository.dart';

class ItemUpdateButton extends StatelessWidget {
  const ItemUpdateButton({
    Key? key,
    required this.snapshot,
    required this.shopNameController,
    required this.menuNameController,
    required this.commentController,
    required this.ratingStar,
    required this.globalKey,
    required this.reviewDoc,
    required this.imageFileList,
    required this.imageUrlList,
  }) : super(key: key);

  final QuerySnapshot<ReviewImage> snapshot;
  final TextEditingController shopNameController;
  final TextEditingController menuNameController;
  final TextEditingController commentController;
  final double ratingStar;
  final GlobalKey<FormState> globalKey;
  final QueryDocumentSnapshot<Review> reviewDoc;
  // Storageにある写真の中で、削除する写真
  final List<File> imageFileList;
  final List<String> imageUrlList;

  @override
  Widget build(BuildContext context) {
    Future<void> updateItem() async {
      // validateフォームの入力状態を検証
      if (!globalKey.currentState!.validate()) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('必要な情報を入力してください')));
        return;
      }

      final reviewImages = <ReviewImage>[];
      final imageInfoList = snapshot.docs.map((e) {
        return DeleteImageParameter(
          documentId: e.id,
          storagePath: e.data().storagePath,
        );
      });
      final imageIds = imageInfoList.map((e) => e.documentId);

      // 写真が選択されていればfirebase Storageに保存する
      if (imageFileList.isNotEmpty) {
        String? storagePath;
        // timestampは写真がある時にしか使わないのでこの場所に書く
        final timestamp = DateTime.now().millisecondsSinceEpoch;

        // 写真の枚数だけ写真をupload→Urlを取得
        for (var i = 0; i < imageFileList.length; i++) {
          // 秒まで入れたfile名を生成
          storagePath = 'user-id/menu-images/upload-pic-$timestamp-$i.png';
          final storageUrl = await ReviewImageRepository.instance.putImage(
            imageFileList[i],
            path: storagePath,
          );

          reviewImages.add(
            ReviewImage(
              storagePath: storagePath,
              storageUrl: storageUrl,
              updatedAt: Timestamp.now(),
            ),
          );
        }
        //latestImageUrlを最後に追加した写真のURLに更新する
        await ReviewRepository.instance.updateLatestImageUrl(
            reviewImages.last.storageUrl,
            reviewId: reviewDoc.id);
      }
      // reviewの内容を更新する
      await ReviewRepository.instance.update(
        shopNameController.text,
        menuNameController.text,
        commentController.text,
        ratingStar,
        reviewId: reviewDoc.id,
      );

      if (imageIds.isNotEmpty) {
        for (final imageId in imageIds) {
          // 全写真のリスト
          final docs = snapshot.docs;
          debugPrint('docs.last.id == doc.id: ${docs.last.id == imageId}');

          await ReviewImageRepository.instance.deletes(
            imageInfoList: imageInfoList.toList(),
            reviewId: reviewDoc.id,
          );

          // 登録済みの最後の写真と削除された写真のIDを比較
          if (docs.last.id != imageId) {
            // 削除した画像は最後の画像ではなかったので latestImageUrl を書き換える必要はない。
            // 早期リターンする
            return;
          }

          // 写真リストから削除された写真を取り除く
          docs.removeLast();

          // 最後の画像を削除していた場合
          if (docs.isEmpty) {
            // latestImageUrl: null にする
            await ReviewRepository.instance.updateLatestImageUrl(
              null,
              reviewId: reviewDoc.id,
            );
            return;
          }
          // 最後の画像を削除したが、まだ他に画像が残っている場合
          // 残っている画像のうち、最後の画像を latestImageUrl に設定する
          final lastDoc = docs.last;
          await ReviewRepository.instance.updateLatestImageUrl(
            lastDoc.data().storageUrl,
            reviewId: reviewDoc.id,
          );
        }
      }

      /// アップロード済みの写真を削除する
      /// 削除された写真より前に登録した写真があればlatestImageUrlを更新する

      // 削除する写真のドキュメント

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('登録されました'),
        ),
      );
      // imagePathにはファイル名を指定する
      if (reviewImages.isNotEmpty) {
        for (final reviewImage in reviewImages) {
          await ReviewImageRepository.instance.add(
            reviewImage,
            reviewId: reviewDoc.id,
          );
        }
      }
    }

    /// レビュー更新ボタン
    return ElevatedButton(
      onPressed: () async {
        await updateItem();
        Navigator.pop(context);
      },
      child: const Text(
        '更新',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
    );
  }
}
