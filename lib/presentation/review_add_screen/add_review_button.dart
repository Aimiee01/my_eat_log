import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_eat_log/domain/review/entities/review.dart';
import 'package:my_eat_log/domain/review/entities/review_image.dart';
import 'package:my_eat_log/domain/review/review_image_repository.dart';
import 'package:my_eat_log/domain/review/review_repository.dart';
import 'package:uuid/uuid.dart';

class AddReviewButton extends StatelessWidget {
  const AddReviewButton(
    this._imageFileList, {
    Key? key,
    required this.shopNameController,
    required this.menuNameController,
    required this.commentController,
    required this.globalKey,
  }) : super(key: key);
  final TextEditingController shopNameController;
  final TextEditingController menuNameController;
  final TextEditingController commentController;

  /// カメラロールで選択された写真のリスト
  final List<File> _imageFileList;

  // <FormState>を必ず入れる
  final GlobalKey<FormState> globalKey;
  @override
  Widget build(BuildContext context) {
    /// レビュー登録するボタンが押された時の処理
    Future<void> _onSaveButtonPressed() async {
      // validateフォームの入力状態を検証
      if (!globalKey.currentState!.validate()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('必要な情報を入力してください')),
        );
        return;
      }

      /// reviewImagesクラスのリストを作成・型はReviewImageを指定
      /// reviewのサブコレクションimages
      final reviewImages = <ReviewImage>[];
      if (_imageFileList.isNotEmpty) {
        String? storagePath;
        // timestampは写真がある時にしか使わないのでこの場所に書く
        final timestamp = DateTime.now().millisecondsSinceEpoch;

        // 写真の枚数だけ写真をupload→Urlを取得
        for (var i = 0; i < _imageFileList.length; i++) {
          // 秒まで入れたfile名を生成
          storagePath = 'user-id/menu-images/upload-pic-$timestamp-$i.png';
          final storageUrl = await ReviewImageRepository.instance.putImage(
            _imageFileList[i],
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
      }

      // UuidでReviewID(DocumentIDとしても使う)を生成する（packageのimportが必要）バージョンはv4を指定
      final reviewId = const Uuid().v4();
      final newReview = Review(
        shopName: shopNameController.text,
        menuName: menuNameController.text,
        comment: commentController.text,
        latestImageUrl:
            reviewImages.isEmpty ? null : reviewImages.last.storageUrl,
      );
      await ReviewRepository.instance.add(
        newReview,
        reviewId: reviewId,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('登録されました'),
        ),
      );

      // 画像を reviews/:id/images コレクションに追加する
      if (reviewImages.isNotEmpty) {
        for (final reviewImage in reviewImages) {
          await ReviewImageRepository.instance.add(
            reviewImage,
            reviewId: reviewId,
          );
        }
      }
    }

    return ElevatedButton(
      onPressed: () async {
        await _onSaveButtonPressed();
        Navigator.pop(context);
      },
      style: ElevatedButton.styleFrom(
          primary: Colors.blue, onPrimary: Colors.white),
      child: const Text(
        '登録',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
    );
  }
}
