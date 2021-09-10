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
    required this.shopNameController,
    required this.menuNameController,
    required this.commentController,
    required this.globalKey,
    required this.reviewDoc,
    required this.imageFileList,
  }) : super(key: key);

  final TextEditingController shopNameController;
  final TextEditingController menuNameController;
  final TextEditingController commentController;
  // <FormState>を必ず入れる(ジェネリクス)
  final GlobalKey<FormState> globalKey;
  final QueryDocumentSnapshot<Review> reviewDoc;

  final List<File> imageFileList;

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
        reviewId: reviewDoc.id,
      );

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
      style: ElevatedButton.styleFrom(
          primary: Colors.blue, onPrimary: Colors.white),
      child: const Text(
        '更新',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
    );
  }
}
